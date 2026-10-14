-- test_equisdots.lua — unit test for lua/equisdots.lua with a stub Hyprland API.
package.path = (arg[0]:match("^(.*)/[^/]*$") or ".") .. "/?.lua;" .. package.path
local equisdots = require("equisdots")

local errors = 0
local function ok(cond, msg)
    if not cond then errors = errors + 1; io.stderr:write("FAIL: " .. msg .. "\n") end
end

-- stub hl
local binds = {}
local hl = {
    dsp = { exec_cmd = function(c) return { kind = "exec", cmd = c } end },
    bind = function(key, dispatcher, opts)
        binds[#binds + 1] = { key = key, dispatcher = dispatcher, opts = opts }
    end,
}

local report = { binds = {}, logs = {} }
local manifest = { id = "demo" }
local mod = equisdots.make(manifest, "/tmp/demo", report, hl)

ok(mod.id == "demo", "id")
ok(mod.dir == "/tmp/demo", "dir")
ok(mod.api == equisdots.API_VERSION, "api version")
ok(mod.script("x.sh") == "/tmp/demo/scripts/x.sh", "script path")
ok(type(mod.exec("true")) == "table", "exec dispatcher")

mod.bind("SUPER + X", mod.exec("true"), { label = "X: run", locked = true })
ok(#binds == 1, "one bind")
ok(binds[1].key == "SUPER + X", "bind key")
ok(binds[1].opts and binds[1].opts.locked == true, "bind passes flags")
ok(binds[1].opts.label == nil, "bind strips label before hl.bind")
ok(#report.binds == 1 and report.binds[1].label == "X: run", "report records label")

mod.bind("SUPER + Y", mod.exec("false"))
ok(binds[2].opts == nil, "bind with no opts")

mod.log("hello")
ok(#report.logs == 1 and report.logs[1] == "hello", "log recorded")

-- a fragment consumes the SDK exactly like the loader does
local frag = function(...)
    local m = ...
    m.bind("SUPER + Z", m.exec("true"), { label = "Z" })
end
frag(mod)
ok(#binds == 3, "fragment bind")

if errors == 0 then print("equisdots.lua: ok") else os.exit(1) end
