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

### Host factory (shell side)

The shell builds **one `PluginHost` per plugin** and injects it as an initial
property when it loads the host adapter (`ui/PluginHosts.qml`) and the settings
page (`BarEditor`) — the same instance for both:

```qml
Loader.setSource(url, { host: HostApi.forPlugin(entry) })
```

`HostApi.forPlugin` constructs a `PluginHost` bound to the shell's `Colors`,
`Caching`, `PluginsCatalog` and scale function (see the required properties on
`PluginHost.qml`). Plugins then write:

```qml
required property PluginHost host
// host.color("mauve", "#cba6f7") · host.s(12) · host.settings.set("x", 1) · host.exec("...")
```

The compositor half (`lua/equisdots.lua`) mirrors this by injecting the `mod`
table into each plugin's `hypr.lua`.

> Status: the types + Lua SDK are in place; the shell factory and the consumer
> migration are the next step (validated on a live session).

## Status

Work in progress on `branch/experimental` (mirrors the branch name used across
the equisdots repositories).

## License

MIT — see `LICENSE`.
