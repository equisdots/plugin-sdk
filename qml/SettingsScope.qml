import QtQuick
import Quickshell
import "."

// ═══════════════════════════════════════════════════════════════════════════
// SettingsScope — ergonomic, scoped accessor over the Settings singleton.
//
//   SettingsScope { id: cfg; scope: "dock" }
//   cfg.section.x        // reactive read (depends on Settings.data)
//   cfg.set("x", 1)      // scoped write
//   onChanged: ...       // fires AFTER the commit (post-state)
// ═══════════════════════════════════════════════════════════════════════════

Scope {
    id: scope

    required property string scope

    readonly property var section: Settings.section(scope)
    readonly property bool ready: Settings.ready
    readonly property int revision: Settings.revision

    signal keyChanged(string key)
    signal changed(var section)

    Connections {
        target: Settings
        function onChanged(s, k) { if (s === scope.scope) scope.keyChanged(k); }
        function onScopeChanged(s) { if (s === scope.scope) scope.changed(scope.section); }
    }

    function get(key, fallback) { return Settings.get(scope.scope + "." + key, fallback); }
    function has(key) { return Settings.has(scope.scope + "." + key); }
    function set(key, value) { Settings.set(scope.scope + "." + key, value); }
    function unset(key) { Settings.set(scope.scope + "." + key, null); }
    function setMany(patch, immediate) { let w = {}; w[scope.scope] = patch; Settings.setMany(w, immediate); }
}
