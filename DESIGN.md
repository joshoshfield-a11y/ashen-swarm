# ASHEN SWARM — Design Document (v1.0, 2026-10-31)

Original top-down roguelite survival shooter. Genre-inspired only.
NOT a clone of Survivor.io, Vampire Survivors, Archero, or any named title.
No copied names, art, characters, music, or assets from those games.

## Fantasy
You are the Ember Warden, last keeper of a dying ash-field. The swarm pours
out of the cinders. Hold the field for 10 minutes, slay the Ember Matriarch,
and the dawn breaks. Fail, and the ash takes you.

## Core loop (10-minute run, 600 s)
- Move with left virtual joystick (floating origin, follows first touch) or
  WASD / arrows on desktop. Weapons auto-fire at the nearest enemy.
- Enemies spawn at the arena edge, scale with time. Elites (gold tint, 3x HP)
  at 180 s and 360 s. Boss "Ember Matriarch" spawns at 540 s; killing her
  before 600 s = VICTORY. Surviving to 600 s without killing her = defeat
  by the swarm surge (boss enrages, arena closes in — honest fail state).
- Kills drop ember gems (XP). Level-up pauses the run and offers 1-of-3
  upgrades (reroll button, 1 free reroll per level-up).
- Weapons (each has 5 levels, stacking effects):
  1. Ember Bolt (starter) — fast single bolt, upgrades: +count, +damage, +pierce
  2. Frost Shard — slow fan of shards, slows enemies, upgrades: +count, +slow
  3. Storm Arc — chaining lightning to N nearest, upgrades: +jumps, +damage
  4. Cinder Orbit — orbiting blades, upgrades: +blades, +radius, +damage
  5. Ember Nova — periodic radial burst, upgrades: +damage, -cooldown
- Passives: Swift Boots (+move speed), Ember Heart (+max HP + heal),
  Magnet Charm (+pickup radius), Sharpened Core (+damage), Vital Spark (+regen)
- Meta-progression (local only, `user://profile.json` v1): shards earned
  from gems banked at run end (win or lose, partial on loss) buy permanent
  +HP / +Damage / +Speed / +Magnet levels in the Forge menu. Atomic write
  (temp file + rename), migration over defaults, in-memory fallback.

## Heroes (v1 ships 1, fully playable)
- Ember Warden: HP 100, speed 220, bolt starter. Others are NOT shipped
  half-done; a second hero is a post-v1 decision, not a stub in the menu.

## Enemies (tuning table in scripts/game.gd ENEMIES)
- Cinderling: chaser, fast, low HP. Brute: slow, high HP, big hit.
  Spitter: keeps range ~260, fires ember bolts. Elite: any kind, gold
  tint via modulate, 3x HP, drops 5 gems. Matriarch: 4000 HP, charge attack
  (telegraphed dash), radial bullet burst, summons cinderlings.

## Arena
Bounded 2400x2400 ash field, camera follows player, parallax ember dust
(3 layers, GPU-free drift via code offsets), vignette + ember grade via a
CanvasItem shader on a fullscreen ColorRect, AI arena tile (1024, tiled).
Seeded scatter: rocks/embers placed from a salted RNG per run so the field
reads hand-dressed but never identical. Rocks are visual only (no collision
maze — readability first on a phone).

## Juice (game-feel-juice skill, cosmetic only, never writes sim state)
- Trauma screenshake (0..1, decays, offset ~ trauma^2), hit-stop 40-90 ms
  on elite/boss kills, pooled damage numbers, pooled glow particles
  (additive) + smoke particles (alpha), hit flash (modulate white 80 ms),
  squash-and-stretch on player bob, pickup magnet easing, pitch-varied
  procedural one-shots (no ripped audio; synth via AudioStreamWAV built
  in code — see scripts/audio_synth.gd).

## Performance (S25 tier + desktop tier)
- Pools, fixed sizes: enemies 140, player projectiles 200, enemy bullets 120,
  gems 300, damage numbers 48, particles 2x256. Nothing instantiated or
  freed during a run (ring cursors, steal-oldest).
- Fixed timestep: physics 60 Hz, logic in _physics_process; rendering
  interpolates by engine default. Enemy separation is O(n) with a spatial
  hash grid (cell 64) — no O(n^2) over the full roster.
- Quality tiers: MOBILE (S25): particles x0.7, glow sprites on, no fullscreen
  blur, vignette shader on; DESKTOP: particles x1.0, extra ember layer.
  Draw-call census target: < 60 nodes visible (pooled nodes are the census).
- No per-frame string formatting in hot paths except the 4 Hz HUD refresh.

## Controls / UX
- Title -> Forge (meta) -> Run. Pause button top-right + Esc/P. Level-up
  cards are big touch targets (>= 96 px). Settings: sound on/off, shake
  on/off, quality auto/mobile/desktop, joystick side left/right.
- Accessibility: damage numbers toggle, high-contrast enemy outline
  (gold elites + red telegraphs), no flashing faster than 3 Hz except
  hit-stop frames (kept < 100 ms).

## What is deliberately NOT in v1
- No online, no ads, no IAP, no accounts, no cloud save, no multiplayer.
- No second hero, no endless mode (win/lose at 10 min is the game).
- No store submission from this build (debug-signed APK only; release
  signing is a user-side step).

## Honest limits (carried to the final report)
- Headless export + badging + signature prove packaging, NOT phone runtime.
  S25 play, touch feel, and real fps are the user's verdicts.
- AI sprites are single-frame art animated by squash/bob/tilt in code —
  no skeletal animation. That is the documented trade for shipping a
  complete game in one autonomous pass.

---

# v1.1 (2026-11-01) — new sprite family, real walk cycles, faster hero, blending terrain

## Tuning table (v1.1, scripts/game.gd; v1.0 values in brackets)
- Hero base speed: **245** [220] = +11.4%. Justification: "slightly faster"
  means perceptible but not game-breaking. 11% keeps relative closing
  speeds intact once chasers are scaled by the same ratio, preserves the
  Swift Boots stacking curve (max 245+100=345 before Forge, vs 320 in v1.0),
  and stays inside the existing camera/joystick feel — no control rework.
- Cinderling 117 [105], Brute 61 [55], Spitter 84 [75] — each ~+11%,
  same ratio as the hero, so kiting margins are unchanged.
- Boss chase 78 [70], enraged 128 [115], charge dash 578 [520] — same ratio.
- Spitter bullet 234 [210] — same ratio, so dodge windows are unchanged.
- Spawn interval: `max(0.30, 0.95 - t*0.0010)` [max(0.32, 1.05 - t*0.0011)]
  — ~10% tighter, to offset the faster hero's larger ground coverage so
  kill rate does not trivialise. Batch formula unchanged.
- Weapon damage and boss HP UNCHANGED (boss 4000, 1800 in test mode).
  Playtest comparison (same harness, seed 1337): v1.0 short test
  108.7 s / level 5 / 118 kills; v1.1 short test 92.5 s / level 4 / 96 kills
  (kills/s 1.04 vs 1.09, within 5%; the faster boss kill is within
  single-run RNG variance of the weapon-offer shuffle — see QA-REPORT
  v1.1). No rebalance was needed; changing damage/HP to chase one
  deterministic run's number would be tuning to noise.
- Swift Boots (+20 flat/level) and Forge speed (+5%/level) unchanged.

## Animation spec (v1.1, frame-driven, pooled only)
- Hero: 4-frame walk (`hero-walk-0..3`), advances only while moving at
  `clamp(speed/28, 6, 12)` fps (~8.75 fps at speed 245); idle forces frame 0.
  Direction by `flip_h` from movement x-sign. Squash is now a secondary
  layer only (±0.02, was ±0.04).
- Enemies: 4-frame walk per kind at `clamp(speed/12, 5, 11)` fps; spitter
  holding range (200–300) idles at 2.0 fps. Wobble reduced to ±0.02.
  Frame swaps are texture assignments on pooled nodes (counter
  `_enemy_swaps`), never instantiation.
- Spitter attack telegraph: on shooting, `pose_hold = 0.3` s forces frame 3
  (lunge) on the pooled node, then the walk cycle resumes.
- Boss: 4-frame walk/advance at `clamp(speed/12, 5, 9)` fps, 16 fps during
  charge; telegraph phase forces the rearing attack-telegraph texture;
  death forces the collapsing death texture for a 0.6 s beat before the
  victory panel (player death during that beat still loses — `end_run`
  guards on state).
- Corpses: 16 pooled Sprite2D in the FX layer capture the killed enemy's
  current texture/position/scale/flip on death, fade over 0.45 s. Regular
  enemies have no separately drawn collapse pose — the fade + burst +
  smoke is the death treatment, and that is named here, not hidden.
- Gold elites are gold textures of the NEW set (`-gold-0..3` per kind),
  not a v1.0 recolor; the old gold `modulate` tint was removed.

## Terrain system (v1.1, replaces the single-tile 5x5 repeat)
- 4 seamless variants (all edge-continuous, `make_tileable` 48 px band,
  opposite-edge mean abs diff 0.0 for all 4): ash powder, ember cracks,
  scorch drifts, gravel flecks. No baked paths, roads, crosses or
  junctions — linear features stay overlays, never base tiles.
- Fixed verified 5x5 layout table (seeded-hash candidates were evaluated
  and rejected: one produced a full row of cracks, others banded or ran):
  `[[0,1,3,2,1],[2,3,1,0,2],[1,0,2,3,0],[3,2,0,1,3],[1,3,2,0,1]]`
  (0=powder, 1=cracks, 2=scorch, 3=gravel) — counts powder 6, cracks 7,
  scorch 6, gravel 6; zero adjacent-equal pairs; zero runs of 3.
- Per tile: rotation `((ix*ix*3 + iy*iy*5 + ix*iy*7) % 4) * 90 deg` (this
  formula never yields 2, so only 0/90/270 deg occur — accepted, the
  flip + jitter carry the rest of the variation), flip_h on a parity
  rule, brightness jitter 0.88–1.08, +0.03 warm shift when (ix+iy)%3==0.
- 42 overlay decals (14 per texture: ash drift, ember crack, scorch
  blotch — procedural PIL, seeded rng 1337) at random position/scale
  (0.4–1.1)/rotation/flip/alpha (0.5–0.85), plus the unchanged 190 scatter
  nodes. Ground census: 25 tiles + 190 scatter + 42 overlays = 257 nodes,
  all created at build time, none mid-run.

## Honest limits (v1.1, supersede the v1.0 list where they differ)
- Walk cycles are 4-frame texture cycles, still no skeletal rig; the
  brute cycle is deliberately subtle (heavy creature: leg shifts + arm
  swing) — documented, not a defect.
- Terrain is proven by data + viewed contact sheets, NOT in-game
  screenshots: headless Godot has no framebuffer. Variant distribution,
  edge continuity (MAD 0.0) and the viewed terrain sheet are the evidence.
- Still no dynamic Light2D; depth comes from top-light highlights,
  shading gradients, rim light in the art, plus additive glow halos.

---

# v1.2 (2026-11-01) — death/hurt/attack poses, blob shadows, 6-variant zoned terrain, dasher + lance

## Tuning table (v1.2, scripts/game.gd; v1.1 values in brackets)
- Hero speed UNCHANGED at 245. No damage/HP change to any existing
  weapon or enemy: the v1.2 playtests sit inside the v1.1 bands, so
  no rebalance was made to chase a single run's number.
  (Short: 90.2 s / level 4 / 92 kills; long: 397.4 s / level 26 /
  1444 kills / 344 shards — vs v1.1 long 392.9 s / 26 / 1446 / 344.)
- NEW ENEMY — Cinder Dasher ("dasher"): HP 30, walk speed 95, radius
  28, contact damage 16, XP 2, scale 0.62. Behaviour, distinct from the
  chaser (relentless contact), brute (slow tank) and spitter (ranged):
  stalks at 95 px/s, and when within 340 px with its dash cooldown
  ready it locks direction and plays a 0.6 s telegraphed windup
  (crouched pose, core flaring, no movement), then dashes 520 px/s
  for 0.35 s (~182 px lunge, attack pose) before a 3.0 s cooldown.
  First dash cooldown 1.0–2.0 s after spawn. Spawn: random pool from
  120 s (cinderling from 0 s, spitter from 60 s, brute from 150 s);
  elite waves (180 s / 360 s) now draw from 4 kinds including dasher.
  Gold elite variant: gold transform of the dasher frames, 3x HP.
- NEW WEAPON — Ember Lance ("lance"): 5 levels. A slow, piercing,
  long-range white-hot lance: damage 30 + 10/level (L1 40, L5 80),
  cooldown max(1.1, 2.0 − 0.15/level) s (L1 1.85, L5 1.25), speed
  720 px/s, radius 18, life 1.4 s, pierce 99 (everything in its path),
  range 1000. Count 1, +1 at L4 (twin lances at ±0.12 rad). Trade vs
  bolt (L1 20 dmg, ~0.52 s cd, single target): lance single-target
  DPS is lower (21.6 vs ~38) but crowd DPS is higher — the weapon is
  bought for lines of enemies, not for the boss. Level-up offer path:
  "Ember Lance" joins the weapon offer pool (new-weapon and upgrade
  entries); the v12 gate prints the sampled offers and pool membership
  (offers included lance on the gate run; pool_has_lance=true).
- Crit numbers (the v1.2 juice pick, cosmetic only): player-bullet
  hits roll 10% crit, x1.5 damage, rendered as a gold "N!" damage
  number at font size 30 (normal: size 22). Crits never feed back
  into sim state beyond the damage itself (the roll IS the hit's
  damage; the number is display). Boss bullet hits do not crit.

## Animation spec (v1.2, extends v1.1 frame-driven system)
- Priority per enemy per frame: hurt (0.15 s) > dasher telegraph /
  dash > attack (0.25 s) > spitter pose-hold (0.3 s, walk-3 lunge) >
  walk cycle. Pose branches re-assign on texture change only, so an
  interrupted pose (e.g. hurt during a windup) resumes cleanly.
  Counters `_attack_frames`, `_hurt_frames`, `_death_frames`,
  `_dash_telegraphs` feed the `--ashen-v12-check` gate.
- Death: kill now uses the kind's collapse pose texture (gold for
  elites) for the pooled corpse, then the existing fade (0.45 s) +
  burst + smoke. Hero death: on a losing run the hero sprite takes
  the collapse pose before the end panel.
- HONEST ART NOTE (read before crediting v1.2 poses as "drawn"): the
  two AI pose grids planned for v1.2 FAILED to generate (media
  pipeline integrity check, 2026-11-01) and were deliberately NOT
  retried. All v1.2 character frames are DERIVED from v1.1 frames via
  documented PIL transforms (death = rotate + squash-y 0.55 + dim
  0.55; hurt = lean −10°; attack = lunge-x 1.30; dasher = lean
  re-proportioning x0.82/y1.12 + warm core of the cinderling cycle).
  They read clearly on the viewed contact sheet (collapse poses
  especially), but they are transforms, not newly drawn art — a fresh
  generation task could replace them; this build does not pretend
  otherwise. The two new terrain variants ARE new AI art.
- Spitter attack frame: unchanged (walk-3 pose-hold). Boss telegraph /
  death: unchanged from v1.1.

## Terrain system (v1.2, 6 variants, zoned overlays)
- New variants: 4 = ember web (dense fine glowing crack network —
  distinct from v11 ember cracks' large plates), 5 = pale drift
  (pale ash drifts, few ember flecks). Both edge-continuous, MAD 0.0.
  Pale drift is graded 0.72x in code so its bright ash sits in the
  dusk palette instead of blowing out the field.
- Fixed verified 5x5 layout table:
  `[[0,1,4,2,3],[2,3,0,5,1],[1,4,2,3,0],[3,0,5,1,4],[4,5,1,0,2]]`
  (0=powder, 1=cracks, 2=scorch, 3=gravel, 4=ember-web, 5=pale-drift)
  — counts powder 5, cracks 5, scorch 4, gravel 4, ember-web 4,
  pale-drift 3; zero adjacent-equal pairs; zero runs of 3 (audited
  by script, QA-REPORT v1.2). 5x5 field size unchanged.
- Biome zones via overlays (no hard grid lines): 66 overlay decals —
  16 per zone inside a disc with alpha fading toward the zone edge,
  + 18 global. Zones: NW ember-crack field (centre 600,600, R 950,
  crack texture), centre scorch drifts (1200,1200, R 1050, scorch
  texture), SE gravel plain (1800,1800, R 950, grey-tinted drift
  texture). Zone tallies print at boot (`ASHEN_V12_ZONES`).
- Blob shadows: pooled soft dark ellipse sprite (procedural PIL, 512,
  max alpha 150, node alpha 0.7), one per enemy slot + hero + boss
  (142 total), z 1 (above ground, below characters), scale =
  character scale x 0.62, offset below centre (enemy: radius x 0.7;
  hero: +22 px; boss: +60 px). Shadows follow pooled nodes, never
  instantiated mid-run. NOT baked into keyed art (dark-on-black keys
  out under the flood-fill rule) — this is why they are in-engine.

## Ground / pool census (v1.2)
- 25 tiles + 190 scatter + 66 overlays + 142 shadows = 423 nodes
  (v1.1: 257). Everything else unchanged (enemies 140, bullets
  200/120, gems 300, dmgnums 48, particles 180/256, smoke 90/128,
  corpses 16). No mid-run instantiation (frame swaps, pose swaps,
  shadow follows, icon swaps are all pooled-node reuse).
- Level-up cards: 3 preloaded TextureRect icons (created once in
  build_ui, reused per offer) — weapon icons are distinct procedural
  shapes; passives/heal/shards use a generic emblem tinted per kind.
- Title/menu: fullscreen terrain backdrop (ember-web tile, cover
  scale, alpha 0.6) + ghosted hero watermark (hero-walk-0, scale
  1.15, alpha 0.32) behind the menu text; hidden on run start.

## Honest limits (v1.2, additions)
- Derived poses, not drawn poses (see art note above). The dasher
  reads as a lean cinderling variant at game size — its behaviour
  (windup + dash) is what distinguishes it in play, not a wholly
  original silhouette.
- Crits are a 10% roll: a 6 s gate run can legitimately show 0
  natural crits (~8 hits); the render path is proven by the gate's
  labelled crit demo, and natural-crit counts are reported per
  playtest in QA-REPORT (short run: 5).
- Terrain/zone proof is still data + contact sheets, not in-game
  screenshots (headless Godot has no framebuffer).
- Phone runtime still not verifiable from this sandbox.

---

# v1.3 (2026-11-01) — drawn dasher, boss enrage, live hero-death test, shadow toggle, boundary ring

## Tuning table (v1.3, scripts/game.gd; v1.2 values in brackets)
- Hero speed UNCHANGED at 245. No damage/HP change to any weapon or
  enemy: the v1.3 playtests sit inside the v1.2 bands, so no rebalance
  was made to chase a single run's number. (Short: 86.6 s / level 4 /
  93 kills / 87 shards, plus a second short observation 83.2 s /
  level 4 / 85 kills / 86 shards; long: 393.7 s / level 27 / 1504
  kills / 356 shards / 2 elites — vs v1.2 long 397.4 s / level 26 /
  1444 kills / 344 shards / 2 elites. The long run's slightly higher
  kill/shard count tracks its boss-time loadout shuffle (nova 5 /
  lance 4 vs v1.2's storm 5 / lance 2), not a balance change; kills/s
  ≈ 1.02–1.03 in both. No tuning change was made.)
- BOSS ENRAGE (new, the only behaviour tuning in v1.3): when the Ember
  Matriarch drops below 50% HP she enrages — `trigger_boss_enrage()`
  fires once (print `ASHEN_V13_ENRAGE hp=... max=...`), her glow aura
  grows (scale base 2.6 → 3.6, modulate hotter 1.6/0.7/0.3), chase
  speed rises 78 → 115 px/s, and attack cadence quickens: charge
  cycle 7.0 → 5.0 s, radial burst interval 4.0 → 2.8 s, summon
  interval 15.0 → 10.0 s. HARD READABILITY RULE (kept): telegraph
  0.8 s and charge 0.7 s at 578 px/s are UNCHANGED — cadence between
  attacks speeds up, never the windup itself. The last-30-seconds
  surge enrage (128 px/s) still exists separately and is strictly
  faster, so the two never stack into something faster than the
  surge. Enrage is checked both in `damage_boss()` (so a crossing
  on the killing frame still prints) and in `update_boss()` (so a
  gradual crossing prints even if damage stops). Boss HP unchanged
  (4000 real, 1800 test).
- Dasher behaviour UNCHANGED (stalk 95, windup 0.6 s, dash 520 px/s
  for 0.35 s, cooldown 3.0 s) — only its art changed (drawn hound
  replaces the re-proportioned cinderling). Same hitbox (radius 28),
  same scale (0.62), same contact damage (16).

## Animation spec (v1.3, extends v1.2 priority)
- Priority unchanged: hurt > dasher telegraph/dash > attack >
  spitter pose-hold > walk. The dasher's walk/telegraph/attack/
  death/hurt slots now point at DRAWN v13 frames (same keys, new
  paths); every other kind's pose slots still point at v1.2
  derived frames (see provenance table in GRAPHICS-PASS.md v1.3).
- Hero death: the collapse texture is still the v1.2 derived
  hero-death frame (the v1.3 hero pose grid failed, not retried).
  What changed is the PROOF: `--ashen-death-check` now kills the
  hero for real (see QA-REPORT v1.3) instead of assigning the
  texture in a labelled demo.
- Boss enrage aura is juice + signal: glow scale/modulate only,
  never sim state beyond the cadence numbers above.

## Settings (v1.3 addition)
- Shadows on/off toggle in Settings (new `ShdBtn`, next to Damage
  numbers). The 142 pooled blob shadows (140 enemy slots + hero +
  boss) are shown/hidden through `shadows_enabled()` every frame:
  player shadow in `update_run`, enemy shadows in `update_enemies`,
  boss shadow in `spawn_boss`/`update_boss`. The setting persists
  in `user://profile.json` settings (`"shadows": true/false`);
  a v1.2 profile (no `shadows` key) loads with shadows ON by
  default — format version stays 1, additive key only, no
  migration bump needed (proven by the round-trip test).

## Arena (v1.3 addition)
- Scorched boundary ring: ONE built-time Line2D tracing the arena
  rectangle (0,0)–(2400,2400), 26 px wide, additive ember colour
  (1, 0.45, 0.12, 0.85), z 0, created in `build_world()`, never
  instantiated mid-run. Ground census: 25 tiles + 190 scatter +
  66 overlays + 142 shadows + 1 ring = 424 nodes (v1.2: 423).

## Honest limits (v1.3, additions)
- Only the dasher is newly drawn in v1.3. Cinderling, brute,
  spitter and hero poses remain v1.2 PIL derivatives — the v1.3
  poses grid failed its integrity check and was not retried, per
  the task's no-retry rule. The provenance table in
  GRAPHICS-PASS.md v1.3 is the authority; nothing derived is
  described as drawn.
- The death pose's faint ground-scratch streak (raw artefact, part
  of the drawing) and walk-frame ember sparks ship as drawn.
- Enrage readability on a phone screen (aura + faster cadence) is
  still a human verdict — headless runs prove the marker, the
  numbers and the aura code path, not the feel.
- Phone runtime still not verifiable from this sandbox.


---

# v1.4 (2026-11-01) — portal spawning (no random spawns), feathered tile blending

## The spawn-location rule (the user's correction, stated exactly)
User feedback, two messages read together: "Enemies should spawn
randomly they should spawn from a portal somewhere on the map" then
"Shouldn't spawn randomly". Implementation: **enemies must NOT spawn
at random locations; they must spawn from a PORTAL on the map.**
Removed from the normal run: `spawn_random_enemy()` (ring around the
player, 640 px), elite waves at a ring around the player (560 px),
boss at a ring around the player (480 px). The function
`spawn_random_enemy()` is deleted; `ring_pos_around()` survives only
as a labelled TEST-ONLY helper (see below).

## Kind randomness vs location randomness (the distinction, explicit)
Only LOCATION randomness was removed. Spawn KIND selection stays
weighted/time-gated rng exactly as before: cinderling from 0 s,
spitter from 60 s, dasher from 120 s, brute from 150 s; elite waves
draw from all 4 kinds. A run's composition still varies; where
anything appears never does — it is always the current portal anchor.

## Portal system spec
- Visible Ember Portal on the arena: drawn swirling glow sprite
  (assets/sprites/v14/portal-ember-512.png, DRAWN — see
  GRAPHICS-PASS.md v1.4) + additive glow + ember ring (Line2D
  circle, radius 110) + relocation-warning glow. All 3 portal nodes
  are built-time only, never instantiated mid-run. The sprite slowly
  rotates (swirl); the glow pulses.
- Anchors (DETERMINISTIC, fixed cycle order NW → NE → SW → SE):
  `(600,600) → (1800,600) → (600,1800) → (1800,1800)`, inside the
  2400x2400 arena. The portal opens at anchor 0 at run start.
- Relocation schedule (anti-camp): every 120 s of run time the portal
  collapses and reopens at the NEXT anchor in sequence, with a 3 s
  warning telegraph at the new anchor first (pulsing warning glow,
  portal collapsed, spawns held). Anti-camp reasoning: the swarm's
  source moves on a fixed schedule, so camping one corner — or the
  portal itself — never stays safe; pressure always arrives from a
  new direction on a timetable the player can learn.
- Telegraph + emerge: normal batches are telegraphed by a surge-ahead
  pulse — when the spawn timer is within 0.8 s of firing, the portal
  glow surges, so the burst is telegraphed ~0.8 s before it emerges
  (see the build-log note on why the burst itself is NOT delayed).
  Elite waves queue a 0.8 s portal burst telegraph before emerging
  as gold. Every spawned enemy gets a 0.4 s scale-up emerge
  treatment (20% → full scale), no instant pop-in.
- Boss and elites through the portal: elite waves (180 s / 360 s)
  emerge from the current portal as gold; the boss arrives via a
  large portal surge (surge 1.2) at the current portal anchor at
  boss time. Time gates and kind weighting unchanged; only location
  changed. If an elite wave or the boss trigger lands inside a
  relocation warning, it DEFERS to the new anchor (the warning is
  its telegraph) and counts only when it actually spawns — the
  deferred re-call does not double-count the wave (bug found and
  fixed in the first long run: elites=3 for two waves).
- Boss-summoned cinderlings (DOCUMENTED EXCEPTION, not a loophole):
  the Matriarch's summons appear around the BOSS (±90 px), because
  the boss is summoning them. They are boss-local, never a random
  ring around the player, and the code comment says so.
- TEST-ONLY spawns (labelled in code, not gameplay): v12/v13 gate
  setup spawns (one of each kind near the player), the death-check
  overwhelm stream (ring around the player), and the portal gate's
  own boss spawn (which itself goes through the portal). These are
  harness spawns; no normal run uses them.

## Tuning table (v1.4, scripts/game.gd; v1.3 values in brackets)
- Hero speed UNCHANGED at 245. No damage/HP change to any weapon or
  enemy. Spawn interval formula UNCHANGED
  (`max(0.30, 0.95 - t*0.0010)`) and batch formula unchanged
  (`mini(1 + t/90, 6)`).
- Why no retune despite lower long-run kills: the v1.4 long runs
  (392.6 s / level 25 / 1391 kills / 333 shards and 393.8 s / 25 /
  1396 / 334) sit ~7% below v1.3 (393.7 s / 27 / 1504 / 356), which
  tracks portal geometry (single-direction pressure, longer travel
  from a quadrant anchor, 3 s spawn holds per relocation) plus the
  boss-time loadout shuffle (nova 5 / bolt 4 vs v1.3's nova 5 /
  lance 4) — not a collapsed or trivial run: it still wins
  comfortably at ~393 s with a level-25 loadout. Per the standing
  rule, no damage/HP/interval change was made to chase one band.
  The one REAL balance bug found (see BUILD-LOG.md v1.4) was the
  serialised telegraph nearly halving the short-run spawn rate
  (54 kills); it was fixed by making the telegraph a surge-ahead
  pulse instead of a delay, restoring the short run to 92–93 s /
  level 4 / 93–97 kills / 87–88 shards — inside the v1.3 band.

## Terrain blending (v1.4, see GRAPHICS-PASS.md v1.4 for the metric)
- 40 feathered transition strips (one per adjacent differing tile
  pair; all 40 edges differ), procedural drift-texture bands with a
  centre-peaked feather profile (full at the shared edge, 0 at
  ±80 px). They are transparent gradient OVERLAYS, never baked
  cross/junction/line features in a base tile, never specific to
  one base tile (standing tile-overlay rule, kept).
- Zone-blend softness: zone overlay edge alpha factor 0.55 → 0.15
  (fade `1.0 - 0.85*(r/R)`), plus 12 bridging decals straddling
  zone boundaries (4 per zone-pair segment, alpha 0.30–0.50).
- Ground census: 25 tiles + 190 scatter + 66 zone overlays + 12
  bridges + 142 shadows + 1 ring + 40 transitions + 3 portal
  nodes = 479 nodes (v1.3: 424).

## Honest limits (v1.4, additions)
- Portal readability at phone scale (swirl + ring + warning glow
  against the ash field) is a human verdict — headless runs prove
  the markers, the anchor sequence and the spawn positions, not
  the feel. Same for tile-blend readability in play: the blend
  sheet + seam metric are the evidence, not in-game screenshots.
- Phone runtime still not verifiable from this sandbox.
