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
ok(binds[1].opts.description == "X: run", "label surfaces as hyprctl description")
ok(#report.binds == 1 and report.binds[1].label == "X: run", "report records label")
ok(report.binds[1].id == "x-run", "default bind id is the label slug")

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

-- ── bind ids + user overrides (keybinds editor contract) ──────────────────
local binds2 = {}
local hl2 = {
    dsp = { exec_cmd = function(c) return { kind = "exec", cmd = c } end },
    bind = function(key, dispatcher, opts)
        binds2[#binds2 + 1] = { key = key, dispatcher = dispatcher, opts = opts }
    end,
}
local report2 = { binds = {}, logs = {} }
local mod2 = equisdots.make({ id = "ov" }, "/tmp/ov", report2, hl2, {
    ["x-run"] = false,                 -- user disabled this single bind
    ["y-run"] = "SUPER + ALT + Y",     -- user rebound this bind
})
mod2.bind("SUPER + X", mod2.exec("true"), { label = "X: run" })
ok(#binds2 == 0, "disabled override skips hl.bind")
ok(report2.binds[1].disabled == true, "disabled bind recorded")
ok(report2.binds[1].id == "x-run", "disabled bind keeps its id")

mod2.bind("SUPER + Y", mod2.exec("true"), { label = "Y: run", id = "y-run" })
ok(#binds2 == 1 and binds2[1].key == "SUPER + ALT + Y", "rebound key applied to hl.bind")
ok(report2.binds[2].overridden == true, "override recorded")
ok(report2.binds[2].defaultKey == "SUPER + Y", "default key kept for reset")

mod2.bind("SUPER + U", mod2.exec("true"), { label = "U: run", description = "custom desc" })
ok(binds2[2].opts and binds2[2].opts.description == "custom desc", "explicit description wins")

mod2.bind("SUPER + W", mod2.exec("true"), { label = "W: run", locked = true })
ok(binds2[3].opts.locked == true and binds2[3].opts.description == "W: run",
   "label surfaces as description next to flags")

mod2.bind("SUPER + V", mod2.exec("true"), { label = "W: run" })
ok(#report2.logs == 1, "duplicate bind id logs a warning")

if errors == 0 then print("equisdots.lua: ok") else os.exit(1) end
