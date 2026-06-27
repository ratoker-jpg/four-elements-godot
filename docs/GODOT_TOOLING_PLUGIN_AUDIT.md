# GODOT_TOOLING_PLUGIN_AUDIT

Date: 2026-06-28
Status: docs-only audit — no plugins installed
Project: Four Elements Godot
Milestone: GODOT-M0D

---

## 1. Purpose

Evaluate Godot Asset Store / editor addons before starting runtime implementation (M1). Decide which tools are worth adopting for Four Elements.

**This is an audit only.** No plugins are installed in this milestone. The `addons/` directory must remain empty until a specific plugin is explicitly approved in a later milestone.

---

## 2. Decision rule

**Default stance: do not install plugins unless they clearly reduce work and have low lock-in.**

For M1, prefer simple native Godot implementation:
- custom RTS camera (native `Camera3D` script)
- simple plane/grid (`MeshInstance3D` + `StandardMaterial3D`)
- no terrain plugin
- no AI plugin
- no Git plugin dependency

Plugins are allowed later **only if ALL of the following are true**:
1. Compatible with Godot 4.7 (or latest stable 4.x at time of adoption)
2. Actively maintained (commit within last 12 months, or stable 1.0+ release)
3. MIT or compatible permissive license (or clearly acceptable license)
4. Easy to remove (no deep coupling with project.godot or core scenes)
5. Not required for core gameplay unless explicitly approved by Denis

**Categories marked "defer"**: revisit at the milestone where the need arises (e.g. state machine addon revisited at M6 Enemy AI).

---

## 3. Audit categories

| # | Category | When needed | Default stance |
|---|---|---|---|
| 1 | Git / source control workflow | All milestones | Use Git CLI / GitHub Desktop — no in-editor Git plugin |
| 2 | Project visibility / AI assistance | Optional, all milestones | Do not add AI/Codex plugins automatically |
| 3 | Terrain / map editing | M5A (if grid terrain insufficient) | Defer — use simple plane/grid first |
| 4 | Camera helpers | M1 | Defer — custom RTS orthographic camera is simpler |
| 5 | GDScript formatting / code quality | All milestones | Adopt GDScript Formatter (editor-only, low risk) |
| 6 | State machines / AI behavior | M6 (Enemy AI) | Defer until AI milestone |
| 7 | Editor readability / custom icons | All milestones | Defer — use plenticons icon pack (CC0, no runtime dependency) |
| 8 | Debugging / logging | All milestones | Use Godot 4.5+ built-in Logger; consider Log.gd for readable output |

---

## 4. Tool evaluation table

| Addon/tool | Category | Potential value | Runtime dependency? | Maintenance risk | Godot 4.7 compatibility | Recommendation | Notes |
|---|---|---|---|---|---|---|---|
| Godot Git Plugin (official) | Git / source control | Low — Git CLI/GitHub Desktop already works | No (editor-only) | Medium — breaks on new Godot versions | Uncertain (official plugin lags behind engine releases) | **Do not adopt** | Use Git CLI / GitHub Desktop outside Godot. Avoid in-editor Git dependency. |
| GDScript Formatter (GDQuest) | GDScript formatting / code quality | Medium — consistent code style, auto-fix spacing/indentation | No (editor-only) | Low — pure GDScript addon | Yes — Godot 4.x compatible, actively maintained by GDQuest | **Adopt** (editor-only, no runtime impact) | Install in M1 or when first GDScript is written. Document format command in CONTRIBUTING. |
| Terrain3D | Terrain / map editing | Medium — high-performance editable terrain | Yes (GDExtension C++) | High — GDExtension binary must match Godot version; Reddit reports 4.6 compatibility issues requiring community patches | Uncertain for 4.7 — official says 4.4+, but 4.7 may need recompile | **Do not adopt for M1/M2** | Four Elements is a tile-based RTS, not open-world terrain. Use simple plane/grid. Revisit only if M5A map generation needs terrain heightmaps (unlikely). |
| TerraBrush | Terrain / map editing | Low-Medium — C# based terrain painting | Yes (C# / .NET) | High — requires .NET Godot build; limits to C# workflow | Uncertain for 4.7 | **Do not adopt** | Same reasoning as Terrain3D — tile-based RTS doesn't need heightmap terrain. TerraBrush adds C# dependency which conflicts with GDScript-first approach. |
| Phantom Camera | Camera helpers | Low for RTS — designed for cinematic/transitions, not fixed RTS ortho | No (editor + runtime nodes, but can be removed) | Low-Medium — pure GDScript | Yes — Godot 4.x compatible, actively maintained | **Do not adopt for M1** | RTS camera needs fixed orthographic angle + pan/zoom, no rotation, no cinematics. A 50-line custom `RTSCamera3D.gd` is simpler than learning Phantom Camera's API. Revisit only if complex camera transitions needed (unlikely for RTS). |
| LimboAI | State machines / AI behavior | Medium-High for M6 — behavior trees + state machines | Yes (C++ GDExtension or module) | Medium — C++ plugin, binary compatibility per Godot version | Yes — Godot 4.x compatible, actively maintained | **Defer to M6** | Do not adopt before Enemy AI milestone. For M2-M5 (harvester/builder/combat state machines), use simple GDScript enum-based FSM — lighter weight, no dependency. Re-evaluate at M6 when AI complexity justifies it. |
| plenticons (icon pack) | Editor readability / custom icons | Low-Medium — CC0 icon pack for custom nodes | No (static SVG/PNG resources) | Very low — CC0 license, no code | Yes — static assets, version-independent | **Adopt** (optional, low risk) | Useful when custom nodes (Tank3D, Harvester, etc.) need distinct editor icons. No runtime dependency. Drop into `addons/plenticons/` only when needed. |
| Log.gd | Debugging / logging | Medium — readable pretty-printing of GDScript data structures | No (autoload, editor+runtime but removable) | Low — pure GDScript single file | Yes — Godot 4.x compatible | **Adopt** (for dev debugging) | Better readability than `print()` for nested dicts/arrays. Use `Log.debug/info/warn/error`. Can be stripped for release builds. |
| LogDuck | Debugging / logging | Low-Medium — centralized logging with class detection | No (editor+runtime, toggleable) | Low — pure GDScript | Yes — Godot 4.x compatible | **Defer** | Log.gd covers the same need with simpler API. LogDuck's class-name detection is nice but not essential. Pick one — recommend Log.gd. |
| Godot 4.5+ built-in Logger | Debugging / logging | Low — basic level filtering via Project Settings | No (built-in) | None — part of engine | Yes — available since 4.5, in 4.7 | **Adopt** (baseline) | Already available. Use for basic level filtering. Combine with Log.gd for pretty-printing. |
| Fennara AI / Ziva / Godot AI / MCP helpers | Project visibility / AI assistance | Unknown — emerging category, privacy/security concerns | Yes (runtime + network access) | High — early-stage projects, unclear maintenance | Unknown — most are experimental | **Do not adopt** | Do not add AI/Codex/MCP plugins automatically. Privacy, security, and repo-access risks. If AI assistance is needed, use external tools (Codex CLI, Claude) outside Godot. |
| Godot Asset Library search (native) | Project visibility | Low — already built into editor | No | None | Yes | **Use** (already available) | Already part of Godot editor. No action needed. |

**Total tools evaluated: 11** (exceeds the 8-12 minimum).

---

## 5. Adoption summary

### Adopt now (M1 prep)

| Tool | Category | Reason |
|---|---|---|
| GDScript Formatter (GDQuest) | Code quality | Editor-only, no runtime dependency, MIT license, actively maintained. Keeps GDScript consistent. |
| Log.gd | Debugging | Pure GDScript, readable output, removable for release. Better than raw `print()`. |
| Godot 4.5+ built-in Logger | Debugging | Already available, zero cost. Baseline level filtering. |

### Adopt optionally (when needed)

| Tool | Category | Trigger |
|---|---|---|
| plenticons | Editor icons | When custom nodes (Tank3D, Harvester) need distinct editor icons. CC0, no runtime dependency. |

### Defer to later milestone

| Tool | Category | Revisit at | Reason |
|---|---|---|---|
| LimboAI | State machines / AI | M6 (Enemy AI) | Only justified when AI complexity exceeds simple FSM. M2-M5 use enum-based GDScript FSM. |

### Do not adopt

| Tool | Category | Reason |
|---|---|---|
| Godot Git Plugin | Git | Git CLI/GitHub Desktop is more reliable; in-editor Git breaks on engine updates. |
| Terrain3D | Terrain | Tile-based RTS doesn't need heightmap terrain. GDExtension binary compatibility risk. |
| TerraBrush | Terrain | Same as Terrain3D + adds C# dependency conflicting with GDScript-first approach. |
| Phantom Camera | Camera | Custom 50-line RTS ortho camera is simpler than learning a cinematic camera framework. |
| LogDuck | Logging | Log.gd covers the same need; avoid having two logging systems. |
| Fennara AI / Ziva / Godot AI / MCP | AI assistance | Privacy/security/repo-access risks. Use external AI tools (Codex CLI, Claude) outside Godot. |

---

## 6. M1 native implementation plan

For M1, use **only native Godot** — no plugins:

```text
Camera:     Custom RTSCamera3D.gd (Camera3D + orthographic projection + pan/zoom script)
Ground:     MeshInstance3D plane + grid texture or ShaderMaterial
Tank:       Tank3D.tscn (MeshInstance3D hull + Marker3D TurretSocket + MeshInstance3D turret + Marker3D MuzzleSocket)
Selection:  MeshInstance3D ring (projected on ground, not screen-space circle)
HP bar:     Sprite3D billboard or Control node projected to unit position
Projectile: RigidBody3D or Area3D + script
```

No `addons/` directory needed for M1.

---

## 7. Re-audit rule

This audit is a snapshot as of 2026-06-28. Godot 4.7 addon ecosystem is still maturing. Re-audit:

- Before M5A (if terrain/map editing needs change)
- Before M6 (if AI complexity justifies LimboAI or similar)
- If any "do not adopt" decision blocks progress
- If Denis requests a specific tool

When re-auditing, check:
1. Last commit / release date on GitHub
2. Godot version compatibility (test on 4.7 specifically)
3. License (MIT preferred; avoid GPL for game code)
4. Runtime vs editor-only dependency
5. Removal cost (how much rework if plugin is dropped)

---

## 8. Sources

- Godot Asset Library: https://godotengine.org/asset-library/asset
- Godot 4.7 documentation: https://docs.godotengine.org/en/stable/
- Terrain3D: https://github.com/TokisanGames/Terrain3D (Godot 4.4+, GDExtension C++)
- TerraBrush: https://godotengine.org/asset-library/asset/2700 (C# based)
- Phantom Camera: https://github.com/ramokz/phantom-camera (Godot 4.x, GDScript)
- GDScript Formatter: https://github.com/GDQuest/GDScript-formatter (Godot 4.x, GDScript)
- LimboAI: https://github.com/limbonaut/limboai (Godot 4.x, C++ GDExtension)
- Log.gd: https://russmatney.github.io/log.gd (Godot 4.x, GDScript)
- LogDuck: https://godotengine.org/asset-library/asset/2911 (Godot 4.x, GDScript)
- plenticons: https://www.reddit.com/r/godot/comments/1ib6udc/ (CC0 icon pack)
- Godot Git Plugin: https://docs.godotengine.org/en/stable/tutorials/best_practices/version_control_systems.html (official, lags behind engine)

---

## 9. Maintenance rule

Update this document when:
- A tool is adopted (move from audit table to "Adopted" section with install date)
- A tool is rejected after testing (add test notes to "Do not adopt" section)
- Godot version changes (re-verify compatibility)
- Denis approves a previously-deferred tool

Keep this document as the single source of truth for Godot plugin/addon decisions until the project matures past M6.
