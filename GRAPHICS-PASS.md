# ASHEN SWARM — Graphics Pass

## Art direction
Dusk ash-field: near-black volcanic ground, molten-orange ember as the
single accent colour, cool ash-grey characters. Every character sprite
shares that palette (see `qa/sprite-sheet.png`), so threat reads instantly:
orange glow = enemy, grey + orange trim = player, gold tint = elite.

## Layers (bottom → top)
1. Arena tile (AI, 1024, tiled 5x5 = 2400x2400 field) with per-tile
   brightness jitter (0.92–1.04) for sunlit-mottle variation.
2. Scatter (190 nodes, visual only): 130 dark pebble blobs + 60 additive
   ember dots, seeded placement.
3. Gems (additive glow diamonds) + player glow halo (pulsing scale).
4. Enemies / player (AI sprites, squash-and-stretch bob, horizontal flip
   to face movement; NO full rotation — front-facing AI art reads best
   upright, and rotating it would look wrong).
5. Projectiles / particles (additive glow radials, tinted per element:
   ember orange, frost blue, storm purple) + alpha smoke.
6. Damage numbers (outlined labels, pooled).
7. Vignette shader (fullscreen ColorRect, CanvasItem shader: radial
   smoothstep darkening, 0.55 max) + red hurt flash (opacity pulse).
8. HUD / panels / joystick (CanvasLayer 10).

## What buys the quality (shader-craft + game-feel-juice applied)
- Additive glow everywhere light should bloom (halos, projectiles,
  particles, boss aura) instead of flat coloured discs — this is the
  single biggest perceived-quality difference vs primitive graphics.
- Trauma shake (squared falloff) + hit-stop + hit flash + damage numbers
  compose every hit; no silent damage anywhere.
- Squash-and-stretch bob on player and enemy wobble keeps single-frame
  AI art alive without skeletal animation (documented limit, see below).

## Tiers
- MOBILE (S25): particles 180 additive / 90 smoke, gem-burst x0.7,
  vignette on, no fullscreen blur. Pooled node census is fixed, so draw
  calls stay flat across tiers.
- DESKTOP: 256 / 128 particles, full bursts.
- Draw-call note: Godot 2D nodes are the census here (no three.js
  renderer.info equivalent); the pool sizes above ARE the census and
  nothing is instantiated mid-run.

## Honest limits
- Single-frame sprites animated by squash/bob/tilt/flip only — no walk
  cycles, no skeletal rig. This was the correct trade for a complete
  game in one autonomous pass; walk cycles are the clear v1.1 upgrade.
- No dynamic 2D lights (Light2D) — glow sprites + vignette achieve the
  look at a fraction of the mobile GPU cost; real lights are a desktop
  experiment, not a shipped feature.
- Arena tile is AI-generated and tiled, so a careful eye can spot the
  repeat at 5x5 — the scatter layer + vignette + ember dust break it up
  in practice. A hand-touched seamless tile is a v1.1 polish item.
- Phone runtime (real fps, touch feel, colour on an OLED panel) is NOT
  verifiable from this sandbox — see QA-REPORT.md.

---

# v1.1 (2026-11-01) — new 3D-look family, walk cycles, blending terrain

## New family (assets/raw-v11/ + assets/sprites/v11/, prompts in PROMPTS-v11.json)
Entirely new designs, not a v1.0 re-tint. Rendered/volumetric look:
strong top light, bright highlights on shoulders/hood, soft shading
gradients, subtle rim light, ash-grey + molten-orange palette.
- Hero: broad-shouldered ash-warden, tattered charcoal-grey greatcoat,
  molten-orange ember trim, hood, glowing ember chest core, ember-tipped
  rod. 4-frame walk sheet (2x2 grid), sliced with the v1.0 keying rule
  (border flood-fill through near-black <48, 1.1 px feather, trim +
  centre on transparent 512). One fix: `hero-walk-2` was mirrored so the
  rod stays on the same side through the cycle instead of teleporting
  sides at ~8 fps.
- Enemies: one 3x4 grid — Cinderling (small fast ember imp, cracked black
  cinder, glowing core), Ash Brute (large hulking, rocky charcoal, glowing
  orange cracks), Ember Spitter (lean, glowing orange throat sac, narrow
  snout). 4 walk frames each.
- Boss: 2x3 grid — Ember Matriarch, towering cracked black rock, blazing
  core, crown-like rocky horns: 4 walk poses + rearing attack-telegraph
  (arms raised, core flaring) + collapsing death pose (slumped, core
  dimming, rubble).
- Elites: deterministic PIL warm-gold transform of the NEW frames
  (`gold_variant()` in tools/key_sprites_v11.py) — same silhouettes,
  clearly gold/bronze, distinct from normal frames.
- Terrain: 2x2 full-bleed grid — ash powder, ember cracks, scorch drifts,
  gravel flecks. Made tileable with a 48 px edge-average ramp
  (`make_tileable()`); opposite-edge mean abs diff 0.0 for all 4 variants
  (pre-blend 10.7–29.0). No baked cross/junction features.
- Overlays: procedural PIL (seeded rng 1337, not AI art) — ash drift
  blotches, ember crack polylines, scorch blotches, 512 transparent PNGs.
- Contact sheets viewed (all on dark backdrops, qa/v11-*.png): hero PASS,
  enemies PASS, boss PASS, terrain PASS, gold PASS. Alpha-component audit
  of every character frame: no distant stray speck required regeneration.
  No regeneration pass was needed for any class (one simplified pass was
  available; none used).

## Depth / shadow decision
Baked drop shadows were NOT used: a dark shadow on a black background
keys out under the flood-fill rule. Depth comes from top-light highlights,
shading gradients and rim light in the art, plus the existing in-engine
additive glow halos. This is a deliberate trade, recorded here.

## Layers (v1.1 changes to the v1.0 list)
1. Ground is now 25 tiles from 4 variants (fixed layout table, rotation /
   flip / brightness jitter) + 42 overlay decals + 190 scatter nodes.
4. Characters are 4-frame walk cycles (see DESIGN.md v1.1 animation spec);
   squash/bob is a secondary layer only (±0.02).
- Pool census grows by exactly 16 corpse sprites; everything else is
  unchanged (enemies 140, bullets 200/120, gems 300, dmgnums 48,
  particles 180/256, smoke 90/128). No mid-run instantiation.

## Honest limits (v1.1)
- 4-frame texture cycles, no skeletal rig; brute cycle is subtle by design.
- No Light2D (unchanged from v1.0).
- Terrain proof is data + contact sheets, not in-game screenshots
  (headless Godot has no framebuffer) — see QA-REPORT.md v1.1.
- Phone runtime still not verifiable from this sandbox.

---

# v1.2 (2026-11-01) — derived poses, blob shadows, 6-variant terrain, icons

## What actually happened with the art (read first)
Two AI character grids were planned (dasher walk/pose grid, existing-
enemy pose grid). Both FAILED to generate (media pipeline integrity
check, 2026-11-01) and were NOT retried — retrying a failed generation
with changed arguments was ruled out, so v1.2 character art is derived,
not drawn. The terrain grid generated cleanly. Everything below is
labelled by provenance; nothing derived is described as drawn.

## Derived pose family (assets/sprites/v12/, from v1.1 -512 frames)
Transforms (tools/key_sprites_v12.py, all on transparent 512 canvases):
- Death: rotate ±8° + squash-y 0.55 + brightness 0.55 (slumped, dimmed).
- Hurt: lean −10° (recoil read, subtle by construction).
- Attack (cinderling, brute, dasher): lunge — stretch-x 1.30–1.35.
- Dasher walk 0..3: dasherize() — squeeze-x 0.82 + stretch-y 1.12 +
  warm-core boost of the cinderling walk cycle; telegraph = squashed
  + strongly warmed dasher frame; death/hurt derived from dasher
  frames the same way as the other kinds.
- Gold elites: gold_variant() of every derived pose (same transform
  as v1.1), so elite death/hurt/attack/telegraph stay gold.
- Alpha audit of every v12 character frame: opaque fractions
  0.08–0.32 (death poses lowest — crumpled = smaller area, expected),
  all four corners transparent, zero flagged. Full report:
  qa/v12-slice-report.json.
- Contact sheets viewed (dark backdrops): qa/v12-poses-sheet.png
  PASS (collapse poses read clearly; hurt/attack reads subtle but
  present; dasher reads as a lean charger variant; dasher-attack is
  small/thin at sheet scale — acceptable, it is a 0.35 s dash pose),
  qa/v12-terrain-sheet.png PASS (ember-web distinct from ember
  cracks; pale drift bright by design, graded 0.72x in code),
  qa/v12-icons-sheet.png PASS (6 weapon icons + emblem distinct at
  card size; shadow blob a soft dark ellipse, faint on dark
  backdrop by design). No regeneration pass was needed: no class
  was contaminated (stray text/specks), and the one simplified
  regeneration pass available was not used.

## New AI terrain (assets/raw-v12/, assets/sprites/v12/)
- Ember web: dense fine glowing crack network over black cinder
  plates. Pale drift: pale-grey wind-blown ash streaks, few ember
  flecks. Both sliced from the 2240x1120 grid halves and forced
  tileable (48 px band): opposite-edge mean abs diff 0.0 / 0.0.

## Depth / shadow decision (v1.2, resolves the v1.1 open item)
In-engine pooled blob shadows (procedural soft ellipse, NOT baked
into keyed art — the v1.1 reason still holds: dark-on-black keys
out). 142 shadow nodes, z 1, subtle alpha (texture max 150/255 x
node 0.7 ≈ 0.41 centre). They ground characters without muddying
the ash field; the field itself stays readable because shadows are
small (character scale x 0.62) and soft-edged.

## Layers (v1.2 changes to the v1.1 list)
1. Ground is now 25 tiles from 6 variants + 66 zone-blended overlay
   decals + 190 scatter nodes + 142 blob shadows (census 423).
4. Characters are walk cycles + hurt/attack/death/telegraph poses
   under the v1.2 priority rule (DESIGN.md v1.2 animation spec).
- Level-up cards carry small preloaded icons (not text-only).
- Title/menu: terrain backdrop + ghosted hero watermark.

## Honest limits (v1.2)
- Derived poses, not drawn poses — see the provenance note above.
  The dasher silhouette is a re-proportioned cinderling, not an
  original drawing; behaviour carries its identity.
- No Light2D (unchanged). Terrain/zone proof is data + contact
  sheets, not in-game screenshots. Phone runtime still unverified.

---

# v1.3 (2026-11-01) — drawn dasher hound; other poses stay derived (honest split)

## What actually happened with the art (read first)
v1.3 was a FRESH generation task, not a retry of the failed v1.2
grids: new dasher design, new prompts, new reference discipline.
Two generation calls were made. One succeeded, one failed — and
the failed one was NOT retried (the task forbids looping retries
and re-attempts with tweaked arguments). The result is a split
build, labelled per class below; the fallback rule (keep v1.2
derived frames for the failed class ONLY) was followed exactly.

## Drawn: dasher (assets/raw-v13/, assets/sprites/v13/)
- NEW creature: lean ember hound-wraith quadruped — elongated
  narrow snout, exposed ribbed charcoal flanks, jagged
  molten-orange spine ridge, long thin legs, trailing ember tail.
  A wholly new silhouette: it is NOT a cinderling variant, and it
  replaces the v1.2 dasher (lean re-proportioning x0.82/y1.12 of
  the cinderling cycle) in every slot: walk 0..3, telegraph
  (crouched, spine flaring bright), attack (lunging, jaws open),
  death (slumped, dim), hurt (rearing flinch).
- Slicing (tools/key_sprites_v13.py): 3x3 grid (1920x1280), 1%
  cell inset, v1.0/v1.1 flood-fill keying (border through
  near-black <48, 1.1 px feather, trim + centre on transparent
  512). Cell map: walk-0 (0,0), walk-1 (0,1), walk-2 (0,2),
  telegraph (1,0), attack (1,1), death (2,0), hurt (2,1),
  walk-3 (2,2); (1,2) stalk idle is an unused spare.
- Gold elites: gold_variant() of the new drawn frames (same
  transform discipline as v1.1/v1.2), so elite dasher walk/poses
  stay gold.
- Alpha audit (qa/v13-slice-report.json): opaque fractions
  0.116–0.274, all four corners transparent, zero flagged.
- Contact sheets viewed (dark backdrops): qa/v13-dasher-sheet.png
  PASS, qa/v13-dasher-gold-sheet.png PASS. Notes, not defects:
  the death pose carries one faint ground-scratch streak from
  the raw (part of the drawing); walk frames carry small detached
  ember sparks (drawn sparks, not contamination). No class was
  contaminated (no stray text/specks), so the one simplified
  regeneration pass available was NOT used.

## Per-class provenance table (v1.3 — the authority)
| Class / frame | v1.3 provenance | Source |
|---|---|---|
| Dasher walk 0..3 | DRAWN | v13 hound grid, sliced + keyed |
| Dasher telegraph / attack / death / hurt | DRAWN | v13 hound grid, sliced + keyed |
| Dasher gold variants (all 8) | DRAWN base + gold transform | gold_variant() of v13 frames |
| Cinderling death / hurt / attack | DERIVED (v1.2) | squash_dim / lean / lunge of v1.1 walk frames |
| Brute death / hurt / attack | DERIVED (v1.2) | squash_dim / lean / lunge of v1.1 walk frames |
| Spitter death / hurt | DERIVED (v1.2) | squash_dim / lean of v1.1 walk frames |
| Spitter attack | DRAWN v1.1 walk frame (pose-hold) | v11 spitter-walk-3, unchanged |
| Hero death | DERIVED (v1.2) | squash_dim of v1.1 hero-walk-0 |
| Hero hurt / attack | NOT SHIPPED | no v1.2 frame existed; v1.3 grid failed, not retried |
| Boss walk / telegraph / death | DRAWN v1.1 | unchanged |
| Terrain (6 variants), overlays, icons, shadow blob | Unchanged | v1.1 / v1.2, see earlier sections |

## Layers (v1.3 changes to the v1.2 list)
1. Ground is now 25 tiles + 66 zone overlays + 190 scatter +
   142 blob shadows + 1 scorched boundary ring (census 424).
4. Characters are walk cycles + hurt/attack/death/telegraph
   poses under the unchanged priority rule; only the dasher's
   slots changed art (derived → drawn).
- Settings gains a Shadows toggle (see DESIGN.md v1.3); shadow
  nodes are unchanged, only their visibility is now switchable.

## Honest limits (v1.3)
- The poses grid failure means v1.3 does NOT deliver drawn poses
  for the existing kinds or the hero. That work is still open as
  a future fresh generation task — it is not claimed here, and
  no v1.2 derived frame is re-labelled as drawn to fill the gap.
- v12 dasher files still ship inside the APK (they remain in the
  project tree as the fallback record); the game loads v13
  dasher paths, proven by `ASHEN_V13_FRAMES` and the v13 gate's
  dasher swaps. The APK is ~1.7 MB larger than v1.2 partly for
  this reason (plus the usual generation growth).
- No Light2D (unchanged). Terrain/zone/ring proof is data +
  contact sheets, not in-game screenshots. Phone runtime still
  unverified.


---

# v1.4 (2026-11-01) — drawn portal, feathered tile blending

## Portal art: DRAWN (one generation call, no regeneration needed)
- One fresh generation call (assets/raw-v14/, prompt + record in
  `assets/raw-v14/PROMPTS-v14.json`): swirling ember portal, top
  view, molten-orange ring spiralling to a white-hot centre, pure
  black background, no text. Keyed with the v1.0/v1.1 flood-fill
  rule (border through near-black <48, 1.1 px feather, trim +
  centre on transparent 512) by `tools/key_sprites_v14.py`:
  opaque fraction 0.5658, all four corners transparent, zero
  flagged. Contact sheet `qa/v14-portal-sheet.png` viewed on a
  dark backdrop: PASS — clean swirl, bright centre, no stray
  text/specks, no contamination, so the one simplified
  regeneration pass available was NOT used.
- Provenance: portal = DRAWN v14. Everything else unchanged
  (dasher drawn v13, other poses derived v1.2, terrain v1.1/v1.2).

## Tile blending method (fix seams, not variants)
- The 6 variants were already each internally tileable
  (opposite-edge MAD 0.0), but adjacent DIFFERENT variants in the
  5x5 field read as hard squares, and zone overlays faded only
  inside their discs. v1.4 adds, all built-time pooled overlays:
  (a) 40 transition strips — one per adjacent differing tile
  pair — using the existing v11 drift overlay texture with its
  alpha multiplied by a centre-peaked feather profile (full at
  the shared edge, fading to 0 at ±80 px), so the band dissolves
  into both neighbours instead of framing the tile or drawing a
  line; (b) zone fade widened (edge alpha factor 0.55 → 0.15);
  (c) 12 bridging decals across zone boundaries.
- Standing tile-overlay rule, kept: transition strips are
  transparent gradient overlays, never baked cross/junction/line
  features in a base tile, never specific to one base tile.

## Seam metric BEFORE → AFTER (script-audited from the layout table)
| Metric | Before (v1.3) | After (v1.4) |
|---|---|---|
| Adjacent differing tile edges (5x5 field) | 40 | 40 |
| Unblended hard edges | 40 | 0 |
| Transition-strip coverage | 0/40 (0%) | 40/40 (100%) |
| Zone overlay edge alpha factor | 0.55 | 0.15 |
| Zone-boundary bridging decals | 0 | 12 |
| Blend-strip profile | — | centre 1.0 → 0 at ±80 px, feathered |

## Sheets viewed (dark backdrops)
- `qa/v14-portal-sheet.png` PASS (portal + transition strip).
- `qa/v14-blend-sheet.png` PASS — 5x5 tiles with all 40 strips
  composited: edges read softened, no hard frame; honestly, at
  sheet scale the feather is subtle (that is the point — a
  feather is not a border), and the metric above, not the sheet
  alone, is the blending evidence. Headless proof is tile data +
  sheets + logs, NOT in-game screenshots (no framebuffer).

## Layers (v1.4 changes)
1. Ground is now 25 tiles + 40 transition strips + 66 zone
   overlays + 12 bridges + 190 scatter + 142 shadows + 1 ring
   + 3 portal nodes = 479 nodes (v1.3: 424).
- Portal nodes sit at z 1 (above ground, below characters) so
  emerging enemies read as coming OUT of the portal.

## Honest limits (v1.4)
- The blend sheet composites tiles + strips in PIL; it is not a
  screenshot of the running game (headless Godot has no
  framebuffer). In-game blend readability is a phone verdict.
- No Light2D (unchanged). Phone runtime still unverified.
