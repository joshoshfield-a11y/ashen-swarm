# ASHEN SWARM — Build Log (append-only, dated)

## 2026-10-31 — Project start (coordinator, autonomous grant)
- Parent decision carried in: original top-down roguelite survival shooter,
  10-minute runs, joystick + auto-fire, waves/elites/boss, 1-of-3 level-ups,
  local meta-progression. NOT a clone of any named title.
- Workspace: `~/workspace/ashen-swarm/` (new; voxbox/starfall untouched).
  Git init, local commits only. No push/merge/publish/store submission.
- Skills read (SKILL.md only, never whole library): godot-export-pipeline,
  game-feel-juice, procedural-worlds, shader-craft, character-controller,
  npc-enemy-systems, save-persistence, automated-playtest, sprite_batch_qc.

## 2026-10-31 — Sprites (sprite rule: AI templates first, never primitives)
- Generated 6 AI images on pure black: hero Ember Warden, Cinderling,
  Ash Brute, Ember Spitter, Ember Matriarch (boss), ash-dusk arena tile.
  Raws kept in `assets/raw/` (never edited in place).
- Keyed with `tools/key_sprites.py`: border flood-fill through near-black
  (<48) pixels only, so dark interiors survive; 1.1 px Gaussian feather;
  trim + centre on 512 square (`-512` game copies). Arena copied full-bleed
  at 1024 (no keying). Glow radials + gem pickups drawn procedurally in
  the same script (radial gradients, not character art).
- QC: contact sheet `qa/sprite-sheet.png` viewed — PASS. All five
  characters read clean on dark backdrop, consistent ash+ember family.
  Note: Spitter legs are thin at game size; its glowing sac carries the
  read, accepted. No second regeneration pass needed.
- App icon: generated icon art, converted WebP→PNG to `assets/sprites/icon.png`.

## 2026-10-31 — Code (Godot 4.8 beta 1, gl_compatibility, 2D)
- Single-scene architecture by design: `scenes/Main.tscn` + `scripts/game.gd`
  builds the whole world procedurally (no hand-written scene wiring to rot).
  Manual distance sim (no physics bodies) for determinism + headless tests.
- Pools (fixed, ring cursors, steal-oldest n/a — inactive slot reuse):
  enemies 140, player bullets 200, enemy bullets 120, gems 300,
  damage numbers 48, additive particles 180 mobile / 256 desktop,
  smoke 90 / 128. Spatial hash grid (cell 64) for separation + bullet hits.
- Juice (cosmetic only): trauma shake (trauma^2), hit-stop on elite/boss
  kills, pooled damage numbers, additive glow + alpha smoke, white hit
  flash, squash-and-stretch bob, vignette shader (fullscreen ColorRect),
  procedural WAV one-shots (`scripts/audio_synth.gd`, no ripped audio).
- Save: `user://profile.json` v1, temp-file + rename with .bak fallback,
  migration over defaults, in-memory fallback on load failure.
  Verified: headless test run wrote shards to the user profile file.
- Quality tiers: MOBILE (Android/iOS or settings=mobile) particle x0.7 +
  smaller pools; DESKTOP full. Camera zoom 0.85 portrait / 1.0 landscape.

## 2026-10-31 — Errors fixed (all in game.gd)
1. `float % int` parse error: `Time.get_unix_time_from_system()` returns
   float in Godot 4 — wrapped in `int(...)`.
2. `:=` type-inference failures on Dictionary Variant arithmetic
   (`player_pos - e["pos"]` etc.) — replaced with explicit types
   (`var x: Vector2 = ...`, `var d: float = ...`) at 5 sites.
3. Test flag invisible: user args after `--` live in
   `OS.get_cmdline_user_args()`, not `get_cmdline_args()` — now checks both.
4. Level-up stall in headless test (no one taps a card) — test mode
   auto-takes the first offer, recursively draining queued level-ups.
5. XP starvation (distant kills dropped unreachable gems; test reached
   only Lv 2 by boss time) — gem vacuum: gems older than 8 s drift to the
   player at >=130 px/s. Retest: Lv 5, kills 118 (was Lv 2 / 90).

## 2026-10-31 — Headless verification (before export)
- Menu boot: `ASHEN_HEADLESS_OK menu_built pools=140/200`, exit 0, zero
  script errors.
- Automated playtest (seed 1337, 120 s test run, boss at 75 s, 3x speed):
  `ASHEN_TEST_PASS time=108.7 level=5 kills=118 shards=94`, exit 0.
  Covers: spawn, weapons, gems, level-ups (auto-choice), elites n/a in
  short test (180/360 s thresholds — see QA-REPORT honest limits),
  boss spawn, boss radial burst, boss kill, victory + shard banking.
- Known workaround carried: sdkmanager is broken in this sandbox (Java
  ignores proxy); SDK already present (build-tools 36.1.0, android-36),
  editor settings already point at `~/android-sdk`, debug keystore
  auto-generated at `~/.local/share/godot/keystores/debug.keystore`.
  Export uses the non-Gradle template path (`use_gradle_build=false`).

## Rebuild from scratch (fatal-wipe recovery)
1. Godot 4.8 beta 1 at `~/tools/godot/godot`, templates
   `~/.local/share/godot/export_templates/4.8.beta1/`, SDK `~/android-sdk`.
2. Regenerate sprites (prompts in this log + raw filenames in
   `tools/key_sprites.py` MAPPING), run `python3 tools/key_sprites.py`.
3. `godot --headless --path .` must print ASHEN_HEADLESS_OK, exit 0.
4. `godot --headless --path . -- --ashen-test` must print ASHEN_TEST_PASS.
5. Export per EXPORT-REPORT.md, verify with apksigner + aapt2 badging.

---

# v1.1 build log (2026-10-31 → 2026-11-01)

## Art (4 image-generation calls, all in assets/raw-v11/, prompts in PROMPTS-v11.json)
1. Hero walk sheet 2x2 (`media-generation-v11-hero-walk-sheet-0-*.webp`).
2. Enemies walk grid 3x4, hero sheet as style reference
   (`media-generation-v11-enemies-walk-grid-0-*.webp`).
3. Boss walk grid 2x3, hero sheet as reference
   (`media-generation-v11-boss-walk-grid-0-*.webp`).
4. Terrain grid 2x2 full-bleed (`media-generation-v11-terrain-grid-0-*.webp`).
No regeneration pass needed for any class. v1.0 raws/sprites untouched.

## Keying / slicing (new scripts, v1.0 tools untouched)
- `tools/key_sprites_v11.py`: v1.0 keying rule + `make_tileable()`
  (48 px edge-average ramp), `edge_check()`, `gold_variant()` (PIL
  warm-gold transform). `tools/key_fast_v11.py`: same rule vectorised
  via scipy connected-components (ml-stack Python) for full grids.
- Output: `assets/sprites/v11/` — hero-walk-0..3, cinderling/brute/
  spitter-walk-0..3, boss-walk-0..3 + boss-telegraph + boss-death,
  gold variants per kind, 4 terrain variants, 3 procedural overlays
  (seeded rng 1337). Contact sheets `qa/v11-*.png`, all viewed on dark
  backdrops. Slice report `qa/v11-slice-report.json`.

## Errors + fixes (v1.1)
1. `rm -f assets/sprites/v11/terrain-*.png` glob deleted the first
   terrain `-512` set as well as the upscaled full-size files; the first
   terrain contact sheet came out blank. Regenerated identically from
   the untouched raw grid; rebuilt sheet verified. Decision: ship only
   the `-512` terrain copies (raw webp is the preserved full-res source)
   to keep the APK lean.
2. First headless Godot run hung idle (~5 min, 0.6% CPU): the log
   (`app_userdata/ASHEN SWARM/logs/godot.log`) showed a parse error, and
   with the main script unloaded the headless quit branch never ran, so
   the process slept forever. Root cause: `var fps_e := clamp(...)` —
   Godot's global `clamp()` returns Variant, and the project treats that
   inference as an error. Fix: explicit `var fps_e: float = ...`. Lesson:
   never use `:=` with `clamp()`/`min()`/`max()` (Variant returns); audit
   all `:=` lines after any edit. Killed the stuck process, fixed, boot
   went green immediately.
3. Terrain layout: seeded-hash candidates evaluated and rejected (full
   row of cracks; banding; runs of 3). Fixed verified 5x5 table chosen
   deliberately — see DESIGN.md v1.1. Rotation formula never yields 2
   (only 0/90/270 deg) — accepted, flip + jitter carry the rest.
4. `hero-walk-2` mirrored (both copies) so the rod stays on one side
   through the walk cycle; contact sheet rebuilt after the mirror.

## Code (scripts/game.gd, +284/−46 vs v1.0)
- `HERO_FRAMES`/`ENEMY_FRAMES`/`ENEMY_GOLD_FRAMES`/`BOSS_FRAMES`/
  `BOSS_TELEGRAPH_TEX`/`BOSS_DEATH_TEX`/`TERRAIN_TEXS`/`OVERLAY_TEXS`,
  preloaded by `build_anim_textures()` (prints `ASHEN_V11_FRAMES ...`).
- Frame-driven animation (hero/enemies/boss), spitter pose-hold,
  boss telegraph/death textures + 0.6 s death beat, 16 pooled corpses.
- Speed retune: hero 245, chasers 117/61/84, boss 78/128/578, spitter
  bullet 234, spawn interval `max(0.30, 0.95 - t*0.0010)`. Damage/HP
  unchanged. Elite `modulate` gold tint removed (gold is now texture).
- Terrain: 25 tiles from the fixed layout table + 42 overlay decals +
  190 scatter = 257 ground nodes, all build-time.
- Test modes: `--ashen-test-long` (420 s sim, boss at 390 s, covers
  180/360 s elite waves), `--ashen-anim-check` (4 s circle drive,
  prints `ASHEN_ANIM_OK`), `ASHEN_TEST_ELITE` prints, `elites=` on the
  PASS line, `ASHEN_TEST_BOSS` loadout print (test-only).
- Title label now `v1.1 • Local save only • No ads, no accounts`.
- Save format unchanged (v1); v1.0 profile loads and accumulates.

## Headless verification (v1.1, before export)
- Menu boot: `ASHEN_V11_FRAMES hero=4 kinds=3 boss=4 terrain=4 overlays=3`
  + `ASHEN_HEADLESS_OK menu_built pools=140/200`, exit 0, zero script
  errors (after the clamp fix above).
- Anim check: `ASHEN_ANIM_OK hero_changes=27 enemy_swaps=29 hero_frame=2`,
  exit 0 — hero + enemy frame cycling proven in-engine.
- Short playtest (seed 1337, 120 s, boss 75 s, 3x): two runs —
  `time=92.5 level=4 kills=96 shards=88` and `time=82.3 level=4 kills=81
  shards=86` (see QA-REPORT v1.1 on harness variance; both PASS, exit 0).
- Long playtest (420 s sim, boss 390 s): `ASHEN_TEST_ELITE t=180.0 wave=1`,
  `ASHEN_TEST_ELITE t=360.0 wave=2`, `ASHEN_TEST_BOSS t=390.0 level=26`,
  `ASHEN_TEST_PASS time=392.9 level=26 kills=1446 shards=344 elites=2`.
  Elite waves v1.0 never executed headlessly are now covered.
- Save round-trip: pre-existing v1.0 profile (shards 173) loaded under
  v1.1 and banked to 261 (= 173 + 88) with meta/settings intact.
- Exit note: test runs print a benign `6 ObjectDB instances leaked at
  exit` warning — objects alive at `quit()` (pools are intentionally
  never freed during a run); exit code is 0 and PASS prints. Not a
  gameplay leak.

## Rebuild from scratch (v1.1 additions)
6. Regenerate v1.1 sprites per `assets/raw-v11/PROMPTS-v11.json`, run
   `tools/key_sprites_v11.py` (hero path) + `tools/key_fast_v11.py`
   (grids), regenerate overlays (seeded rng 1337 snippet in build
   history), mirror `hero-walk-2`.
7. `godot --headless --path . -- --ashen-anim-check` must print
   `ASHEN_ANIM_OK` with hero_changes > 0 and enemy_swaps > 0.
8. `godot --headless --path . -- --ashen-test-long` must print two
   `ASHEN_TEST_ELITE` lines and `ASHEN_TEST_PASS ... elites=2`.

---

# v1.2 build log (2026-11-01)

## Art (1 clean generation + 2 failed generations + derived frames)
1. Terrain grid 1x2 generated cleanly (`media-generation-v12-
   terrain-grid-0-*.webp`, 2240x1120): ember web + pale drift.
   Sliced into halves, made tileable, edge MAD 0.0/0.0 both.
2. Dasher grid (3x3) and poses grid (3x3) FAILED to generate
   (media pipeline integrity check) and were NOT retried — see
   GRAPHICS-PASS.md v1.2 provenance note. All v1.2 character
   frames are PIL-transform derivatives of v1.1 frames
   (`tools/key_sprites_v12.py`: squash_dim / lean / lunge /
   dasherize / gold_variant reuse). No v1.0 art involved anywhere.
3. Procedural (PIL, not AI): blob-shadow texture (28 layered
   ellipses, max alpha 150), 6 weapon icons + 1 emblem (128 px
   flat shapes). Contact sheets `qa/v12-poses-sheet.png`,
   `qa/v12-terrain-sheet.png`, `qa/v12-icons-sheet.png` — all
   viewed on dark backdrops, PASS, no regeneration pass used.
   Alpha audit: every v12 character frame corners transparent,
   zero flagged (`qa/v12-slice-report.json`).
4. v1.0/v1.1 raws and sprites untouched.

## Code (scripts/game.gd, 2075 → 2505 lines)
- Dasher enemy (ENEMIES + walk/gold frames + telegraph/attack/
  death/hurt + gold): stalk → 0.6 s windup (locked dir) → 0.35 s
  dash at 520 px/s → 3.0 s cooldown; spawn from 120 s; elite
  waves draw from 4 kinds.
- Ember Lance weapon (5 levels, pierce 99, 720 px/s, white-hot
  glow, twin lances at L4) + offer-pool entry + `fire_lance()`.
- Animation priority: hurt > dasher telegraph/dash > attack >
  spitter pose-hold > walk; death corpses use collapse poses;
  hero collapse pose on losing runs; counters for the v12 gate.
- Blob shadows: 140 enemy-slot shadows + hero + boss, pooled,
  z 1, scale = char scale x 0.62, follow pooled nodes.
- Terrain: 6-variant layout table + pale-drift 0.72x grade +
  66 zone-blended overlays (16/zone + 18 global, edge-faded
  alpha) + boot prints for zones and census.
- Level-up cards: 3 preloaded TextureRect icons + `choice_icon()`
  (weapon icons; emblem tinted per passive/heal/shards).
- Title/menu: terrain backdrop + ghosted hero watermark sprites
  in the UI layer (hidden on run start via `hide_all_panels`).
- Juice pick: crit numbers (10% x1.5, gold "N!", font 30) on
  player-bullet enemy hits; boss hits do not crit.
- Leak fix: `stop_all_sfx()` before every test quit path —
  stops players and clears streams (see Errors below).

## Errors + fixes (v1.2)
1. `update_boss` vs `spawn_boss` anchor collision in the edit
   script (both contain the boss position pair): the edit script
   aborted before writing (all-or-nothing), the anchor was
   narrowed to the update_boss context (following glow-scale
   line), and the script re-ran clean. No partial edit ever hit
   the file — verified by the abort-before-write design.
2. V12 gate first run: `dash_telegraph=0` — the check dasher was
   one-shot by test bolts (dmg 60 vs hp 18) before its 1–2 s
   spawn dash cooldown expired. Fix (test-harness only): the
   gate primes the check dasher's `dash_cd = 0.0` at setup so
   it winds up on its first update. Re-run: `dash_telegraph=1`.
   Real-game dashers keep the 1–2 s spawn cooldown.
3. ObjectDB leak investigation (v1.1's "6 instances" warning):
   reproduced on v1.1 code as 2 instances (count varies with how
   many sfx players are mid-playback at quit) and identified
   with `--verbose`: `AudioStreamWAV` + `AudioStreamPlaybackWAV`,
   refcount 1 — the last-played sfx player's stream, still
   referenced at quit(). NOT a gameplay leak (no nodes, no
   per-frame growth; pools are intentionally never freed during
   a run and are freed with the tree). Fix: `stop_all_sfx()`
   before every test quit. Verified: v1.2 anim-check and v12-
   check runs print NO leak warning (previously 2). If a future
   run shows a leak again, re-run with `--verbose` and check
   whether it is again the sfx stream pair before concluding.

## Headless verification (v1.2, before export)
- Menu boot: `ASHEN_V11_FRAMES hero=4 kinds=4 boss=4 terrain=6
  overlays=3` + `ASHEN_V12_FRAMES dasher=8 poses=11 terrain=6
  icons=7 shadow=1` + `ASHEN_V12_ZONES ember=16 scorch=16 gravel=16
  global=18` + `ASHEN_V12_CENSUS tiles=25 scatter=190 overlays=66
  shadows=142 total=423` + `ASHEN_HEADLESS_OK menu_built
  pools=140/200`, exit 0, zero script errors, no leak warning.
- Anim check (regression): `ASHEN_ANIM_OK hero_changes=26
  enemy_swaps=27 hero_frame=1`, exit 0, no leak warning.
- V12 gate: `ASHEN_V12_OFFERS offers=["lance", "frost", "speed"]
  pool_has_lance=true`, then `ASHEN_V12_OK hero_changes=33
  enemy_swaps=117 attack=3 hurt=7 death=7 dash_telegraph=1
  lance=4 crits=0 crit_demo=1 dasher_spawns=1 dasher_kills=1
  hero_death=1`, exit 0, no leak warning. crits=0 is consistent
  with ~8 bullet hits at 10% (P ≈ 0.43); the render path is
  proven by crit_demo=1 and by natural crits in the short run.
- Short playtest (seed 1337, 120 s, boss 75 s, 3x):
  `ASHEN_TEST_BOSS t=75.0 level=3 weapons={ "bolt": 1,
  "lance": 1 }`, `ASHEN_TEST_PASS time=90.2 level=4 kills=92
  shards=87 elites=0`, `ASHEN_TEST_CRITS crits=5`, exit 0.
  Lance in a real run's boss-time loadout (offer path exercised
  end-to-end, not just the gate print).
- Save round-trip: v1.1-format profile (shards 261, meta 0,
  standard settings) loaded under v1.2 and banked to 348
  (= 261 + 87), meta/settings intact (loader adds the `dmgnums`
  default, as in v1.1). Format unchanged; no migration needed.
- Long playtest (420 s sim, boss 390 s): `ASHEN_TEST_ELITE t=180.0
  wave=1`, `t=360.2 wave=2`, boss-time loadout includes lance at
  level 2, `ASHEN_TEST_PASS time=397.4 level=26 kills=1444
  shards=344 elites=2`, `ASHEN_TEST_CRITS crits=115`, exit 0, no
  leak warning. vs v1.1 long (392.9 s / level 26 / 1446 kills /
  344 shards): essentially identical — lance + dasher + crits did
  not move 10-minute difficulty. Profile banked 348 → 692.

## Rebuild from scratch (v1.2 additions)
9. Terrain: regenerate per `assets/raw-v12/PROMPTS-v12.json`
   (terrain section), run `tools/key_sprites_v12.py` terrain
   stage (halves + make_tileable + edge_check must print 0.0).
10. Poses/dasher: if fresh art is ever generated, it must go
    through NEW generation calls (the failed v1.2 grids were not
    retried and their metadata-only .json files are the record);
    until then, `tools/key_sprites_v12.py` derives all character
    frames from v1.1 -512 sources — run the full script, check
    `qa/v12-slice-report.json` shows zero alpha-flagged frames.
11. `godot --headless --path . -- --ashen-v12-check` must print
    `ASHEN_V12_OK` with hero_changes > 0, enemy_swaps > 0,
    attack > 0, hurt > 0, death > 0, dash_telegraph > 0,
    lance > 0, dasher_spawns > 0, dasher_kills > 0, and no
    ObjectDB leak warning on stderr.

---

# v1.3 build log (2026-11-01)

## Art (1 clean generation + 1 failed generation, no retries)
1. Dasher hound grid 3x3 generated cleanly
   (`media-generation-v13-dasher-grid-0-a73917a0-25ad-4064-aa6b-
   919738398582.webp`, 1920x1280): lean ember hound-wraith
   quadruped, wholly new silhouette. Sliced by
   `tools/key_sprites_v13.py` (1% cell inset, v1.0/v1.1
   flood-fill keying, -512 only, gold_variant() elites):
   walk-0..3, telegraph, attack, death, hurt; (1,2) stalk idle
   is an unused spare. Alpha audit zero flagged
   (`qa/v13-slice-report.json`); contact sheets
   `qa/v13-dasher-sheet.png` + `qa/v13-dasher-gold-sheet.png`
   viewed on dark backdrops, PASS, no regeneration pass used.
2. Poses grid (4x3, cinderling/brute/spitter/hero
   death+hurt+attack) FAILED to generate (media pipeline
   integrity check, 2026-11-01) and was NOT retried — the task
   forbids looping retries and tweaked-argument re-attempts.
   Fallback per class: those kinds keep v1.2 derived frames.
   Prompt + failure record: `assets/raw-v13/PROMPTS-v13.json`.
3. v1.0/v1.1/v1.2 raws and sprites untouched; v12 dasher files
   still ship in the APK as unused fallback files (the game
   loads v13 dasher paths).

## Code (scripts/game.gd, 2505 → 2671 lines)
- Dasher texture paths (walk/gold/attack/hurt/death/telegraph)
  repointed v12 → v13; all other pose paths unchanged.
  `ASHEN_V13_FRAMES` + `ASHEN_V13_CENSUS` boot prints added.
- Boss enrage: `boss_enraged` flag + `trigger_boss_enrage()`
  (once, prints `ASHEN_V13_ENRAGE`), hooked from `damage_boss()`
  (hp > 0 and < 50% max) and `update_boss()` chase branch.
  Enraged: glow base 2.6 → 3.6 + hotter modulate, chase
  78 → 115, cycle 7.0 → 5.0 s, burst 4.0 → 2.8 s, summon
  15.0 → 10.0 s. Telegraph 0.8 s + charge 0.7 s at 578 px/s
  UNCHANGED. Surge (last 30 s, 128) kept separate and faster.
- Live death test: `--ashen-death-check` (100 HP, dmg_mult 1.0,
  no boss, 600 s limit); two-phase stream (fight 20 s, then
  2 cinderlings / 0.5 s at 250 px) overwhelms by contact
  damage; `end_run` test branch prints `ASHEN_DEATH_PASS`
  (lose screen, label, shards earned, totals, hero-death
  texture) with exit 0 for this mode only, plus a 300 s
  timeout FAIL guard.
- Shadow toggle: `shadows` settings key (default true, added
  on load for v1.2 profiles), `ShdBtn` in Settings,
  `shadows_enabled()` applied per frame to player (update_run),
  enemy (update_enemies) and boss (spawn/update_boss) shadows.
  `--ashen-shadow-check`: staged on → off → save+reload →
  on, prints `ASHEN_SHADOW_OK`.
- Boundary ring: 1 built-time Line2D (arena rectangle, 26 px,
  additive ember) in `build_world()`; census 424.
- V13 gate: `--ashen-v13-check` (shared v12 setup + boss spawn
  at 2 s + damage to 40% HP), prints `ASHEN_V13_OK`.
- Title label v1.2 → v1.3.

## Errors + fixes (v1.3)
1. Edit-script anchor collision: the player-shadow position
   block appears twice (start_run + update_run). The script
   aborted before writing (all-or-nothing design, v1.2
   lesson); the anchor was narrowed to the update_run
   instance via its following glow-scale line and re-ran
   clean. No partial edit ever hit the file.
2. First live-death run banked 0 shards (8 kills → 8/20 = 0):
   the stream overwhelmed in 5.3 s sim before 20 kills.
   Fix (harness only, not sim): two-phase stream — 20 s of
   normal fighting first, then the overwhelm stream. Re-run:
   `ASHEN_DEATH_PASS ... shards_earned=1 ... kills=23`
   (779 → 780). The death itself was always real combat
   damage; only the kill headroom changed.
3. Shadow gate prints a 3–5 ObjectDB leak warning (see
   QA-REPORT v1.3 leak note): `--verbose` identifies it as
   the known benign sfx stream/playback pair, count varying
   with mid-playback players at quit — same family as v1.2,
   exit 0, PASS line intact. Not a node leak; documented,
   not chased further (mixer-thread timing at exit, not
   fixable from GDScript).

## Headless verification (v1.3, before export)
- Menu boot: `ASHEN_V13_FRAMES dasher_drawn=8 dasher_gold=8`
  + `ASHEN_V13_CENSUS ... ring=1 total=424` +
  `ASHEN_HEADLESS_OK`, exit 0, zero script errors.
- Anim check: `ASHEN_ANIM_OK hero_changes=29 enemy_swaps=34
  hero_frame=2`, exit 0.
- V12 gate (regression, now on drawn dasher):
  `ASHEN_V12_OK ... attack=3 hurt=6 death=6 dash_telegraph=1
  ... dasher_spawns=1 dasher_kills=1 hero_death=1`, exit 0.
- V13 gate: `ASHEN_V13_ENRAGE hp=720.0 max=1800.0`,
  `ASHEN_V13_OK enrage=true dash_telegraph=1 enemy_swaps=163
  ring=true shadows=142`, exit 0.
- Death check: `ASHEN_DEATH_PASS lose_screen=true label=THE
  FIELD FALLS shards_earned=1 total_before=779 total_after=780
  hero_death_tex=true time=24.3 level=1 kills=23`, exit 0.
- Shadow check (x4): `ASHEN_SHADOW_OK on=true off_hidden=true
  persist_off=true on_again=true`, exit 0, leak note above.
- Short playtest: `time=86.6 level=4 kills=93 shards=87`
  (enrage at 864/1800) and round-trip run `time=83.2 level=4
  kills=85 shards=86`, exit 0.
- Long playtest: elites at 180.0/360.0, boss at 390.0
  (level 26, lance 4), `ASHEN_V13_ENRAGE hp=701.8 max=1800.0`,
  `ASHEN_TEST_PASS time=393.7 level=27 kills=1504 shards=356
  elites=2`, `ASHEN_TEST_CRITS crits=119`, exit 0, no leak.
- Save round-trip: synthetic v1.2 profile (500 shards, no
  `shadows` key) → 586 (= 500 + 86) with `shadows` added
  default true; real profile (1136) restored after.

## Rebuild from scratch (v1.3 additions)
12. Dasher: generate per `assets/raw-v13/PROMPTS-v13.json`
    (dasher section), run `tools/key_sprites_v13.py` (slice
    report must show zero flagged frames), view both
    `qa/v13-*-sheet.png` on dark backdrops.
13. Poses: if drawn poses are ever wanted, that is a NEW
    generation task — the failed v1.3 poses call must not be
    re-attempted with tweaked arguments; until then the v1.2
    derived frames are the shipped fallback (see
    GRAPHICS-PASS.md v1.3 provenance table).
14. `godot --headless --path . -- --ashen-v13-check` must print
    `ASHEN_V13_ENRAGE` and `ASHEN_V13_OK enrage=true`;
    `--ashen-death-check` must print `ASHEN_DEATH_PASS` with
    `shards_earned >= 1`; `--ashen-shadow-check` must print
    `ASHEN_SHADOW_OK` with all four fields true.
15. Export preset: version/code 4, version/name "1.3",
    export_path `build/ashen-swarm-v1.3.apk`, exclude_filter
    gains `assets/raw-v13/*`.


---

# v1.4 build log (2026-11-01)

## Art (1 clean generation, 0 regeneration passes)
1. Portal grid: single image generated cleanly
   (`media-generation-portal-ember-v14-0-589f3776-...webp`,
   1600x1600) — swirling ember portal, white-hot centre. Keyed by
   `tools/key_sprites_v14.py` (v1.0/v1.1 flood-fill rule): opaque
   0.5658, corners transparent, zero flagged. Contact sheet
   `qa/v14-portal-sheet.png` viewed, PASS; no regeneration pass
   used (no contamination).
2. Transition strips: PROCEDURAL PIL (not AI) — v11 drift overlay
   texture x centre-peaked feather profile. First sheet version
   used a flat warm colour and read as a grid frame; rebuilt as
   texture-based strips, which read as soft bridging. Sheet
   label clipping fixed in the same rebuild (label shortened).
3. Blend sheet `qa/v14-blend-sheet.png`: 5x5 tiles + 40 strips
   composited in PIL, viewed, PASS (see GRAPHICS-PASS.md v1.4
   for the honest subtlety note).
4. v1.0–v1.3 raws and sprites untouched.

## Code (scripts/game.gd, portal system + blending)
- Portal: `PORTAL_ANCHORS` [(600,600),(1800,600),(600,1800),
  (1800,1800)], fixed cycle; `portal_update()` (swirl, surge
  glow, 3 s relocation warning every 120 s, burst flush);
  `spawn_portal_batch()` / `spawn_portal_enemy()` (within 100 px
  of the anchor, recorded + violation-counted);
  `spawn_elite_wave()` and `_spawn_boss_at_portal()` through the
  portal with deferral during warnings; `spawn_random_enemy()`
  DELETED; `ring_pos_around()` kept as a labelled TEST-ONLY
  helper (death-check stream + gate setup only); boss-summon
  exception commented at the summon site.
- Emerge treatment: `spawn_in` 0.4 s scale-up ramp in
  `update_enemies()` (20% → full scale).
- Blending: 40 transition strips + 3 portal nodes in
  `build_world()`; zone fade 0.45 → 0.85 coefficient (edge
  factor 0.55 → 0.15); 12 bridge decals; `ASHEN_V14_CENSUS`
  (479) + `ASHEN_V14_FRAMES` boot prints.
- New gate `--ashen-portal-check`: asserts every portal spawn
  within 100 px of the anchor, deterministic anchor sequence,
  relocation warning + resumed spawns, elite-through-portal and
  boss-through-portal. Prints `ASHEN_V14_PORTAL_OK`.
- Title label v1.3 → v1.4. Save format UNCHANGED (v1).

## Errors + fixes (v1.4)
1. Serialised telegraph halved the spawn rate (REAL balance bug,
   caught by the short playtest, not waived): the first portal
   build delayed every batch 0.8 s behind the spawn timer, so
   the effective period became interval + 0.8 — short run fell
   to 54 kills / level 3 (v1.3 band: 85–93 / level 4). Fix: the
   telegraph is now a surge-ahead pulse (portal glow surges
   during the 0.8 s before the timer fires; the burst itself
   emerges on schedule), and elite waves keep the queued 0.8 s
   burst telegraph (infrequent, no rate effect). Re-run: short
   92.2 s / level 4 / 97 kills / 88 shards; death check restored
   to 33 kills / 1 shard (was 17 / 0 in the broken build).
2. Elite double-count on deferred waves: the first long run
   printed elites=3 for two waves — `spawn_elite_wave()` counted
   before the deferral check, then the deferred re-call counted
   again. Fix: count + print only when the wave actually spawns
   (deferred path counts nothing). Re-run long: elites=2, and
   the wave-2 log now correctly shows the 360 s trigger deferred
   through the warning and firing at 363.2 s from the new anchor
   (1800,1800).
3. Portal gate early-win race: the first gate run killed the boss
   before the 200 s verdict, so no `ASHEN_V14_PORTAL_OK` printed
   (exit 0 came from the generic TEST_PASS). Fix: `end_run()` in
   portal-check mode prints the portal verdict and exits on the
   gate's own criteria instead of waiting for 200 s. Post-fix
   gate: `ASHEN_V14_PORTAL_OK ok=true spawns=347 violations=0
   max_dist=96.9 relocs=1 warns=1 elite_portal=true
   boss_portal=true spawns_after_reloc=181` (early_win=true).
   Anchor sequence identical across all three gate runs
   (WARN next_idx=1 → RELOC idx=1, (1800,600)) — determinism
   proven by repetition, not asserted.

## Headless verification (v1.4, before export)
- Menu boot: `ASHEN_V14_FRAMES portal=true transitions=true`
  + `ASHEN_V14_CENSUS ... total=479` + `ASHEN_HEADLESS_OK`,
  exit 0, zero script errors.
- Portal gate (x3, post-fix x2 identical anchors): PASS, see above.
- Anim / v12 / v13 / shadow regressions: all PASS (anim 30/27,
  v12 OK incl. lance + dasher, v13 enrage 720/1800, shadow 4/4).
- Short playtest: `time=92.2 level=4 kills=97 shards=88`
  (boss-time loadout bolt 1 / storm 1, enrage 876/1800),
  `ASHEN_TEST_CRITS crits=5`, exit 0. Round-trip run:
  `time=86.0 level=4 kills=93 shards=87` (the save round-trip run).
- Long playtest (x2, post-fix): `time=392.6 level=25 kills=1391
  shards=333 elites=2` (loadout bolt 4 / nova 5, enrage 873.4)
  and `time=393.8 level=25 kills=1396 shards=334 elites=3`
  (pre-fix count; same run shape) — see DESIGN.md v1.4 for why
  no retune was made. Three relocations + both elite waves
  through the portal + boss through the portal in both runs.
- Death check (live): `ASHEN_DEATH_PASS ... shards_earned=1
  total 1414 → 1415 hero_death_tex=true time=25.4 level=2
  kills=33`, exit 0.
- Save round-trip: synthetic v1.3-format profile (500 shards)
  loaded under v1.4 and banked to 587 (= 500 + 87), settings
  intact, format still v1; real accumulated profile (1891
  shards) restored after every banking run.

## Rebuild from scratch (v1.4 additions)
16. Portal: generate per `assets/raw-v14/PROMPTS-v14.json`, run
    `tools/key_sprites_v14.py` (portal opaque ~0.57, corners
    transparent, zero flagged; blend sheet edges=40), view both
    `qa/v14-*-sheet.png` on dark backdrops.
17. `godot --headless --path . -- --ashen-portal-check` must print
    `ASHEN_V14_PORTAL_OK ok=true` with violations=0, relocs>=1,
    warns>=1, elite_portal=true, boss_portal=true,
    spawns_after_reloc>0; run it twice and confirm the same
    anchor sequence both times.
18. Export preset: version/code 5, version/name "1.4",
    export_path `build/ashen-swarm-v1.4.apk`, exclude_filter
    gains `assets/raw-v14/*`.
