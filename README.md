# plugin-enc

Run the gocryptfs mechanics behind charly's encrypted volumes — mount, unmount,
initialize, and re-key gocryptfs-backed volumes (`verb:enc`).

The plugin owns the security-sensitive external-command surface carved out of
charly core. charly keeps the **deploy model** around gocryptfs
(`ResolvedBindMount` / `ResolveVolumeBacking`, the config loader, the path/probe
helpers, and the credential store) and host-prelifts it into a self-contained
`spec.EncExecInput` (the resolved per-volume plan plus the resolved passphrase)
that this plugin executes. The plugin owns only *how to drive gocryptfs* — nothing
about charly's path conventions, state detection, config loading, or credentials.

## What it provides

| Capability | Surface |
|---|---|
| `verb:enc` | execute the resolved encrypted-volume plan (`mount`, `unmount`, `ensure`, `passwd`) |

## The verb

`verb:enc` is invoked with the structured `spec.EncExecInput` over `OpExecute`
(not an authored `plugin_input`), so it declares no `#*Input`.

| Method | Meaning |
|---|---|
| `mount` | mount every not-yet-mounted volume in the plan |
| `unmount` | `fusermount3 -u` then stop the gocryptfs scope unit |
| `ensure` | auto-initialize then mount (the `charly start` ensure hook) |
| `passwd` | change the gocryptfs password for every initialized volume |

Mounts run under `systemd-run --scope --user --unit=<scope> gocryptfs
-allow_other`, with the passphrase supplied via a held `-extpass` script (never
on the command line). It is **compiled-in** so the passphrase never crosses a
socket: charly's in-core shim resolves `verb:enc` and invokes `OpExecute` in-proc.

## How to use it

`verb:enc` is an internal host contract driven by `charly config
mount|unmount|passwd` and `charly start` — not an authorable step. Compose the
plugin candy in a project that uses encrypted volumes:

```yaml
- '@github.com/opencharly/plugin-enc/candy/plugin-enc:<tag>'
```

## Layout

- `candy/plugin-enc/` — the plugin module: `enc.go` (provider +
  `NewProvider()`/`NewMeta()` + the gocryptfs mechanics), `schema/enc.cue` (the
  served declaration surface), `cmd/serve/main.go`.
- `charly.yml` — the root project manifest (`discover: candy`).
- `.github/workflows/tag-on-merge.yml` — CalVer tag + `CHANGELOG/` on merge.

## Related

- Owning skill: `/charly-automation:enc` — encrypted-volume (gocryptfs)
  semantics and the `charly config` surface. This candy carries no `skill:`
  entity of its own; the gap is tracked in
  [opencharly/opencharly#291](https://github.com/opencharly/opencharly/issues/291).
- `/charly-internals:plugin` — the plugin/provider model.
- [`opencharly/charly`](https://github.com/opencharly/charly) — the charly CLI.
