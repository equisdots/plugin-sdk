# equisdots · plugin-sdk

The **runtime SDK** for equisdots plugins. Reusable host-side code that plugins
and hosts build against — versioned in lockstep with `equisdots/plugin-api`.

Keeping it here (instead of inside the shell) removes the duplication between
`equisdots/shell` and `equisdots/niri-shell`, gives the SDK its own releases,
and lets any compositor shell consume the same kit.

## Scope

| Concern | Here |
|---|---|
| QML host API — the injected `PluginHost` handle | `qml/` |
| Editor widget kit (`qs.ui.sdk`) | `qml/` |
| Shared surface/overlay manager | `qml/` |
| Reactive settings API (`Settings` / `SettingsScope`) | `qml/` |
| Compositor-side Lua SDK (`mod.*`) | `lua/` |
| Types (`qmldir`, `.qmltypes`) and version | `qml/` |

The **contract** these implement lives in **`equisdots/plugin-api`**. The
standard's narrative lives in `equisdots/plugins → docs/plugins.md`.

## Consumption

- `equisdots/shell` and `equisdots/hyprland` vendor the SDK at deploy time
  (the same pattern used for `equisdots/palettes`).
- Plugins use the injected handle and the public kit:
  `required property PluginHost host` + `import qs.ui.sdk`.

## Status

Work in progress on `branch/experimental` (mirrors the branch name used across
the equisdots repositories).

## License

MIT — see `LICENSE`.
