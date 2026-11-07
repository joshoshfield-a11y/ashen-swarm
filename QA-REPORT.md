# ASHEN SWARM — QA Report (v1.0, 2026-10-31)

## Gates
| Gate | Result | Evidence |
|---|---|---|
| Headless menu boot, zero script errors | PASS | `ASHEN_HEADLESS_OK menu_built pools=140/200`, exit 0 |
| Automated playtest (seed 1337, test run 120 s, boss 75 s, 3x speed) | PASS | `ASHEN_TEST_PASS time=108.7 level=5 kills=118 shards=94`, exit 0 |
| Sprite QC on contact sheet (dark backdrop) | PASS | `qa/sprite-sheet.png` viewed: clean transparency, distinct silhouettes, consistent family |
| Save persistence round-trip | PASS | `user://profile.json` shows shards 173 = 79 + 94 across two test runs, meta/settings intact |
| Pool discipline (no mid-run instantiation) | PASS by construction | All gameplay nodes pre-created in `build_pools()`; spawns reuse inactive slots only |
| APK export + badging + signature | PASS | 38,094,517 bytes, `com.ashenswarm.game` v1.0, apksigner Verifies (v2+v3, Godot debug cert) — see EXPORT-REPORT.md |

## What the playtest actually covers
Spawn loop, bolt auto-fire, gem magnet + 8 s vacuum, XP + level-up
(auto-choice in test mode), boss spawn at 75 s, boss radial burst +
summon + charge telegraph code paths, boss kill → victory, shard banking.
Two full test runs, both PASS, second after the gem-vacuum fix.

## What the playtest does NOT cover (honest gaps)
- Elite waves (180 s / 360 s thresholds) never fire in the 120 s test run.
  Code path is identical to normal spawns with `elite=true` + gold tint;
  risk is low but the wave itself is unexecuted headlessly. A 400 s test
  run would cover it — recommended before any store step, not blocking
  for a debug APK handoff (parent verification is the gate anyway).
- Real touch input: joystick code handles ScreenTouch/ScreenDrag +
  mouse-drag fallback, but no headless run exercises a real touch stream.
  Desktop keys + mouse-drag are the exercised paths.
- Real-device fps, OLED colour, portrait/landscape resize, audio on
  device speakers, and install/launch on the S25: NOT verifiable here.
  These are the user's verdicts by design (see task boundaries).
- No screenshot evidence from the game itself: headless Godot has no
  framebuffer to capture. Sprite sheet + test logs are the evidence pack.

## Bugs found and fixed during QA
1. Parse errors (float `%`, `:=` inference on Dictionary Variants) — fixed,
   menu boot clean after.
2. Test-flag routing (`get_cmdline_user_args`) — fixed.
3. Level-up stall in test mode — auto-choice added (test-only path).
4. XP starvation from distant kills — gem vacuum (8 s) added; level at
   boss kill rose 2 → 5, kills 90 → 118.

---

# QA Report v1.1 (2026-11-01)

## Gates
| Gate | Result | Evidence |
|---|---|---|
| Headless menu boot, zero script errors | PASS | `ASHEN_V11_FRAMES hero=4 kinds=3 boss=4 terrain=4 overlays=3` + `ASHEN_HEADLESS_OK menu_built pools=140/200`, exit 0 |
| Animation gate (frame-driven, in-engine) | PASS | `ASHEN_ANIM_OK hero_changes=27 enemy_swaps=29 hero_frame=2`, exit 0 |
| Short playtest (seed 1337, 120 s, boss 75 s, 3x) | PASS (x2) | `time=92.5 level=4 kills=96 shards=88` and `time=82.3 level=4 kills=81 shards=86`, exit 0 |
| Long playtest (420 s sim, boss 390 s) incl. elite waves | PASS | `ASHEN_TEST_ELITE t=180.0 wave=1`, `t=360.0 wave=2`, `ASHEN_TEST_PASS time=392.9 level=26 kills=1446 shards=344 elites=2` |
| Sprite contact sheets viewed (dark backdrops) | PASS | `qa/v11-hero-sheet.png`, `v11-enemies-sheet.png`, `v11-boss-sheet.png`, `v11-terrain-sheet.png`, `v11-gold-sheet.png` — all viewed, no class needed regeneration |
| Terrain variant distribution + edge continuity | PASS | Layout counts powder 6 / cracks 7 / scorch 6 / gravel 6, zero adjacent-equal pairs, zero runs of 3; opposite-edge mean abs diff 0.0 for all 4 variants |
| Save round-trip (v1.0 profile → v1.1) | PASS | v1.0 profile (shards 173, version 1) loaded under v1.1 and banked to 261 (= 173 + 88), meta/settings intact; format unchanged |
| Pool discipline (no mid-run instantiation) | PASS by construction | All nodes pre-created in `build_world()`/`build_pools()`; frame swaps + 16 pooled corpses only; ground census 257 (25 tiles + 190 scatter + 42 overlays) |
| APK export + badging + signature | PASS | See EXPORT-REPORT.md v1.1 |

## What the v1.1 playtests cover (beyond v1.0)
Elite waves at 180 s and 360 s (v1.0's honest gap, now executed: gold
textures of the new set, 3x HP path, wave prints), boss at 390 s in the
long run, boss death pose + 0.6 s death beat → victory, corpse fade
pool, spitter pose-hold path (exercised whenever a spitter fires in
range), hero/enemy frame cycling at speed-tied fps.

## Playtest variance — read before comparing single numbers (honest note)
The short test is NOT strictly deterministic across runs: two v1.1 runs
with the same seed gave 92.5 s / 96 kills and 82.3 s / 81 kills. Cause:
the sim integrates real frame deltas at 3x timescale, so frame pacing
on the host shifts spawn/weapon timer integration run to run (the sim
RNG itself is seeded 1337 in test mode; level-up offers are the
amplifier, since a different offer draw changes the loadout). v1.0's
108.7 s / 118 kills is one observation of the same noisy harness.
Comparison on the band, not the point: level 4–5, kills/s ~1.0–1.1,
boss kill well inside the 120 s limit in all three observations. The
v1.1 boss kill is somewhat faster (82–93 s vs 108.7 s) — consistent with
the intended retune (enemies reach the stationary test player ~11%
sooner, spawns ~10% tighter, so weapons engage sooner), not with the
game collapsing: kills/s is within 5% of v1.0 and the long run still
demands a level-26 loadout over 390 s. No damage/HP change was made to
chase a single run's number — that would be tuning to noise.

## What the playtest does NOT cover (honest gaps, v1.1)
- Real touch input: same as v1.0 — joystick handles ScreenTouch/ScreenDrag
  + mouse-drag fallback; no headless run exercises a real touch stream.
  The anim-check run drives `joy_vec` in a circle (movement branch), but
  the stationary playtest does not cover hero movement animation.
- Spitter attack pose and boss telegraph/death textures: code paths are
  wired and the textures are viewed on contact sheets, but no headless
  assertion screenshots them in-game (no framebuffer). The spitter
  pose-hold fires whenever a spitter shoots in range during any run;
  the boss telegraph/death textures fire in the boss fight of every
  playtest run (telegraph phase, death beat) — execution is covered,
  pixels are not.
- Brute walk cycle is deliberately subtle (heavy creature) — named, not
  a defect; leg shifts + arm swing read on the contact sheet.
- Hero moving-branch animation is covered only by the anim-check run,
  not by the stationary playtest.
- Real-device fps, OLED colour, portrait/landscape resize, audio on
  device speakers, install/launch on the S25: NOT verifiable here.
  These remain the user's verdicts by design.
- No screenshot evidence from the game itself: headless Godot has no
  framebuffer. Contact sheets + test logs + tile data are the evidence.

## Beta-test notes (self-run)
- No leaks on respawn by construction: `start_run()` hides and deactivates
  every pool slot; no node is freed or created after `build_pools()`.
- Pause/resume/restart/quit paths are UI-button wired; Esc/P wired on desktop.
- Level-up reroll: 1 free reroll per level-up, button disables at 0.
- Settings persist (sound/shake/quality/damage-numbers) via profile save.

---

# QA Report v1.2 (2026-11-01)

## Gates
| Gate | Result | Evidence |
|---|---|---|
| Headless menu boot, zero script errors | PASS | `ASHEN_V12_FRAMES dasher=8 poses=11 terrain=6 icons=7 shadow=1` + `ASHEN_V12_CENSUS tiles=25 scatter=190 overlays=66 shadows=142 total=423` + `ASHEN_HEADLESS_OK menu_built pools=140/200`, exit 0 |
| V12 animation/content gate (`--ashen-v12-check`, 6 s) | PASS | `ASHEN_V12_OFFERS offers=["lance", "frost", "speed"] pool_has_lance=true`, then `ASHEN_V12_OK hero_changes=33 enemy_swaps=117 attack=3 hurt=7 death=7 dash_telegraph=1 lance=4 crits=0 crit_demo=1 dasher_spawns=1 dasher_kills=1 hero_death=1`, exit 0 |
| Animation gate regression (`--ashen-anim-check`) | PASS | `ASHEN_ANIM_OK hero_changes=26 enemy_swaps=27 hero_frame=1`, exit 0 |
| Short playtest (seed 1337, 120 s, boss 75 s, 3x) | PASS | `ASHEN_TEST_PASS time=90.2 level=4 kills=92 shards=87 elites=0`, `ASHEN_TEST_CRITS crits=5`, exit 0; boss-time loadout included lance |
| Long playtest (420 s sim, boss 390 s) incl. elite waves | PASS | `ASHEN_TEST_ELITE t=180.0 wave=1`, `t=360.2 wave=2`, `ASHEN_TEST_BOSS t=390.0 level=26 weapons={ "bolt": 2, "frost": 1, "storm": 5, "orbit": 3, "lance": 2, "nova": 2 }`, `ASHEN_TEST_PASS time=397.4 level=26 kills=1444 shards=344 elites=2`, `ASHEN_TEST_CRITS crits=115`, exit 0, no leak warning |
| Sprite contact sheets viewed (dark backdrops) | PASS | `qa/v12-poses-sheet.png`, `v12-terrain-sheet.png`, `v12-icons-sheet.png` — all viewed; no class contaminated, no regeneration pass used |
| Terrain layout + edge continuity + zones | PASS | Layout counts powder 5 / cracks 5 / scorch 4 / gravel 4 / ember-web 4 / pale-drift 3, zero adjacent-equal pairs, zero runs of 3 (script audit); new variants edge MAD 0.0 / 0.0; `ASHEN_V12_ZONES ember=16 scorch=16 gravel=16 global=18` |
| Save round-trip (v1.1 profile → v1.2) | PASS | v1.1-format profile (shards 261, meta 0) loaded under v1.2 and banked to 348 (= 261 + 87), meta/settings intact; format unchanged |
| Pool discipline (no mid-run instantiation) | PASS by construction | All nodes pre-created in `build_world()`/`build_pools()`; pose swaps, shadow follows, icon swaps are pooled-node reuse only; census 423 |
| ObjectDB leak investigation | FIXED (was benign) | v1.1's warning reproduced as 2 instances, identified via `--verbose` as one AudioStreamWAV + its playback held by a still-playing sfx player at quit(); `stop_all_sfx()` before every test quit removes it — v1.2 gate/anim runs print no leak warning |
| APK export + badging + signature | PASS | See EXPORT-REPORT.md v1.2: 52,843,787 bytes, v3/1.2, apksigner Verifies (v2+v3, 1 signer), zipalign PASS, 367 entries, 43 v12 entries, 0 raw/tools/qa entries, launcher verified via xmltree |

## What the v1.2 gates cover (beyond v1.1)
Dasher spawn/kill path (spawned close-in, telegraphed, dashed,
killed — all counted), dasher in the random pool from 120 s and in
elite waves, lance offer-pool membership + sampled offer + firing +
real-run loadout, hurt/attack/death pose swaps in-engine (not just
textures on a sheet), crit render path (demo) + natural crits in the
short run (5), zone overlay tallies, 6-variant terrain in the boot
path, level-up icon preloading (icons load at boot; per-offer swap
is TextureRect reuse).

## Playtest variance — same warning as v1.1
Short-test numbers are one observation of a noisy harness (frame
pacing shifts timer integration; level-up offers amplify it).
Compare bands: v1.1 short 82–93 s / level 4 / 81–96 kills; v1.2
short 90.2 s / level 4 / 92 kills — inside the band. No tuning
change was made. Lance in the loadout did not collapse difficulty:
kills/s ≈ 1.02, in line with v1.1's ~1.0–1.1.

## What the playtests do NOT cover (honest gaps, v1.2)
- Real touch input: unchanged from v1.1 (joystick handles
  ScreenTouch/ScreenDrag + mouse-drag fallback; no headless run
  exercises a real touch stream).
- Pose pixels in-game: pose swaps are counted in-engine, but no
  headless run screenshots them (no framebuffer). Contact sheets
  + swap counters are the evidence.
- Hero death pose in a real losing run: the texture loads and the
  assignment code path runs (gate sets it and prints hero_death=1),
  but test HP is 9999 so no test run actually kills the hero.
- Dasher dash damage feel (whether the 182 px lunge reads as fair
  on a phone screen): needs a human playtest; numbers are tuned
  conservatively (0.6 s windup, 3.0 s cooldown, contact damage
  unchanged from its 16 base).
- Crits in the 6 s gate were 0 (only ~8 bullet hits at 10% — P ≈
  0.43, not a failure signal); natural crits proven by the short
  run (5) and reported per run from `ASHEN_TEST_CRITS`.
- Derived poses, not drawn poses — see DESIGN.md v1.2 art note.
  The dasher silhouette is a re-proportioned cinderling.
- Menu backdrop (terrain + ghosted hero): code-level only, no
  screenshot — headless has no framebuffer. Readability (alpha
  0.6 terrain, 0.32 hero) is by construction, not verified pixels.
- Real-device fps, OLED colour, portrait/landscape resize, audio
  on device speakers, install/launch on the S25: NOT verifiable
  here. These remain the user's verdicts by design.
- No screenshot evidence from the game itself: headless Godot has
  no framebuffer. Contact sheets + test logs + tile data are the
  evidence pack.

---

# QA Report v1.3 (2026-11-01)

## Gates
| Gate | Result | Evidence |
|---|---|---|
| Headless menu boot, zero script errors | PASS | `ASHEN_V13_FRAMES dasher_drawn=8 dasher_gold=8` + `ASHEN_V13_CENSUS tiles=25 scatter=190 overlays=66 shadows=142 ring=1 total=424` + `ASHEN_HEADLESS_OK menu_built pools=140/200`, exit 0 |
| Animation gate regression (`--ashen-anim-check`) | PASS | `ASHEN_ANIM_OK hero_changes=29 enemy_swaps=34 hero_frame=2`, exit 0 |
| V12 gate regression (`--ashen-v12-check`, now on drawn dasher) | PASS | `ASHEN_V12_OK hero_changes=43 enemy_swaps=152 attack=3 hurt=6 death=6 dash_telegraph=1 lance=4 crits=1 crit_demo=1 dasher_spawns=1 dasher_kills=1 hero_death=1`, exit 0 |
| V13 gate (`--ashen-v13-check`, 6 s, deterministic enrage) | PASS | `ASHEN_V13_SETUP dasher=v13 ring=true`, `ASHEN_V13_ENRAGE hp=720.0 max=1800.0`, `ASHEN_V13_OK enrage=true dash_telegraph=1 enemy_swaps=163 ring=true shadows=142`, exit 0 |
| LIVE hero-death test (`--ashen-death-check`) — v1.2 gap closed | PASS | `ASHEN_DEATH_PASS lose_screen=true label=THE FIELD FALLS shards_earned=1 total_before=779 total_after=780 hero_death_tex=true time=24.3 level=1 kills=23`, exit 0 |
| Shadow toggle gate (`--ashen-shadow-check`) | PASS | `ASHEN_SHADOW_OK on=true off_hidden=true persist_off=true on_again=true`, exit 0 (see leak note below) |
| Short playtest (seed 1337, 120 s, boss 75 s, 3x) | PASS (x2) | `time=86.6 level=4 kills=93 shards=87` (boss-time loadout bolt 2 / nova 1, enrage at 864/1800) and round-trip run `time=83.2 level=4 kills=85 shards=86`, exit 0 |
| Long playtest (420 s sim, boss 390 s) incl. elite waves + NATURAL enrage | PASS | `ASHEN_TEST_ELITE t=180.0 wave=1`, `t=360.0 wave=2`, `ASHEN_TEST_BOSS t=390.0 level=26 weapons={ "bolt": 2, "nova": 5, "lance": 4, "storm": 1, "frost": 2, "orbit": 1 }`, `ASHEN_V13_ENRAGE hp=701.8 max=1800.0`, `ASHEN_TEST_PASS time=393.7 level=27 kills=1504 shards=356 elites=2`, `ASHEN_TEST_CRITS crits=119`, exit 0, no leak warning |
| Sprite contact sheets viewed (dark backdrops) | PASS | `qa/v13-dasher-sheet.png`, `v13-dasher-gold-sheet.png` — both viewed; no class contaminated, no regeneration pass used |
| Save round-trip (v1.2 profile → v1.3) | PASS | Synthetic v1.2-format profile (shards 500, settings WITHOUT `shadows` key) loaded under v1.3 and banked to 586 (= 500 + 86), `shadows` key added default true, meta/settings intact, format version still 1; the synthetic profile was then replaced by the real accumulated profile (1136 shards) |
| Pool discipline (no mid-run instantiation) | PASS by construction | All nodes pre-created in `build_world()`/`build_pools()`; the boundary ring is 1 built-time Line2D; pose swaps, shadow follows, toggle visibility and enrage aura are pooled-node reuse only; census 424 |
| APK export + badging + signature | PASS | See EXPORT-REPORT.md v1.3: 54,571,931 bytes, v4/1.3, apksigner Verifies (v2+v3, 1 signer), zipalign PASS, 401 entries, 16 v13 entries, 0 raw/tools/qa entries, launcher verified via xmltree, older APKs untouched |

## What the v1.3 gates cover (beyond v1.2)
- Drawn dasher in-engine: the v12 gate's dasher spawn/kill/telegraph
  path now runs on the v13 hound frames (walk/telegraph/attack/
  death/hurt swaps counted), and the v13 gate asserts the v13
  setup + ring + shadow census explicitly.
- Boss enrage, twice over: deterministically in the v13 gate
  (spawn + one damage call driving HP 1800 → 720) and naturally
  in the long run (701.8/1800 = 39%) and the short run (864/1800
  = 48%) — the marker, the aura code path and the cadence
  numbers are all exercised, not just present in code.
- LIVE hero death: the hero (100 HP, no damage boost, bolt only)
  fights normal spawns for 20 s sim, then a cinderling stream
  overwhelms; death is by contact damage, the lose screen shows
  ("THE FIELD FALLS"), the hero death texture is assigned, and
  partial banking is real (23 kills → 1 shard, 779 → 780).
  This replaces v1.2's labelled texture-assignment demo.
- Shadow toggle end-to-end: on → off hides every shadow node →
  save + reload keeps it off → on restores visibility, all
  asserted in one run.
- Boundary ring: asserted present (`ring=true`) in the v13 gate
  and counted in the v13 census; it is 1 built-time node.

## Playtest variance — same warning as v1.1/v1.2
Short-test numbers are one observation of a noisy harness. Compare
bands: v1.2 short 90.2 s / level 4 / 92 kills / 87 shards; v1.3
short 83–87 s / level 4 / 85–93 kills / 86–87 shards — inside the
band. Long: v1.2 397.4 s / 26 / 1444 / 344; v1.3 393.7 s / 27 /
1504 / 356 — slightly higher kills/shards, tracking the
boss-time loadout shuffle (nova 5 / lance 4 vs storm 5 / lance
2), not a balance change. No damage/HP/speed change was made.

## Leak note (shadow gate only, benign, same family as v1.2)
The shadow gate prints a `3–5 ObjectDB instances leaked at exit`
warning (count varies run to run: 3, 5, 4 observed). Re-run with
`--verbose` identified the leaked objects as AudioStreamWAV +
AudioStreamPlaybackWAV pairs only — the same benign sfx-pair
pattern documented in v1.2 (a still-playing sfx player's stream
at quit; exit code is 0 and the PASS line prints). No other gate
leaks. Per the v1.2 rule, the leak was checked, not assumed: it
is the sfx pair again, not a node leak. No gameplay leak exists
(pools are intentionally never freed during a run).

## What the playtests do NOT cover (honest gaps, v1.3)
- Real touch input: unchanged from v1.2 (joystick handles
  ScreenTouch/ScreenDrag + mouse-drag fallback; no headless run
  exercises a real touch stream).
- Pose pixels in-game: dasher frame swaps are counted in-engine,
  but no headless run screenshots them (no framebuffer). Contact
  sheets + swap counters are the evidence.
- Enrage feel on a phone (whether the aura + faster cadence reads
  as fair with telegraphs unchanged): needs a human playtest;
  numbers are tuned conservatively (chase 115 < surge 128,
  telegraph/charge durations untouched).
- Dasher hound readability at phone scale (longer, thinner body
  than the old cinderling-derived dasher): needs the user's eye;
  the sheet reads clearly at card size.
- Hero hurt/attack drawn frames: not shipped (poses grid failed,
  not retried) — see GRAPHICS-PASS.md v1.3 provenance table.
- Menu backdrop, boundary ring pixels: code-level only, no
  screenshot — headless has no framebuffer. Ring readability
  (26 px additive ember line) is by construction, not verified
  pixels.
- Real-device fps, OLED colour, portrait/landscape resize, audio
  on device speakers, install/launch on the S25: NOT verifiable
  here. These remain the user's verdicts by design.
- No screenshot evidence from the game itself: headless Godot has
  no framebuffer. Contact sheets + test logs + tile data are the
  evidence pack.


---

# QA Report v1.4 (2026-11-01)

## Gates
| Gate | Result | Evidence |
|---|---|---|
| Headless menu boot, zero script errors | PASS | `ASHEN_V14_FRAMES portal=true transitions=true` + `ASHEN_V14_CENSUS tiles=25 scatter=190 overlays=66 bridges=12 shadows=142 ring=1 transitions=40 portal=3 total=479` + `ASHEN_HEADLESS_OK menu_built pools=140/200`, exit 0 |
| Portal gate (`--ashen-portal-check`, x3) | PASS | `ASHEN_V14_PORTAL_OK ok=true spawns=347 violations=0 max_dist=96.9 relocs=1 warns=1 elite_portal=true boss_portal=true spawns_after_reloc=181 anchor=(1800.0, 600.0) early_win=true`, exit 0; anchor sequence identical across all 3 runs (WARN next_idx=1 → RELOC idx=1) |
| Animation gate regression | PASS | `ASHEN_ANIM_OK hero_changes=30 enemy_swaps=27 hero_frame=2`, exit 0 |
| V12 gate regression | PASS | `ASHEN_V12_OK hero_changes=43 enemy_swaps=92 attack=3 hurt=4 death=4 dash_telegraph=1 lance=3 crits=0 crit_demo=1 dasher_spawns=1 dasher_kills=1 hero_death=1`, exit 0 |
| V13 gate regression | PASS | `ASHEN_V13_ENRAGE hp=720.0 max=1800.0`, `ASHEN_V13_OK enrage=true dash_telegraph=1 enemy_swaps=106 ring=true shadows=142`, exit 0 |
| Shadow toggle regression | PASS | `ASHEN_SHADOW_OK on=true off_hidden=true persist_off=true on_again=true`, exit 0 |
| Short playtest (seed 1337, 120 s, boss 75 s, 3x) | PASS (x2) | `time=92.2 level=4 kills=97 shards=88` and round-trip run `time=86.0 level=4 kills=93 shards=87`, exit 0 |
| Long playtest (420 s sim, boss 390 s) incl. elite waves + 3 relocations | PASS (x2) | `ASHEN_TEST_ELITE t=180.1 wave=1` (portal, anchor (1800,600)), `t=363.2 wave=2` (deferred through the 360 s warning, portal, anchor (1800,1800)), `ASHEN_TEST_BOSS t=390.0 level=25`, `ASHEN_V13_ENRAGE hp=873.4 max=1800.0`, `ASHEN_TEST_PASS time=392.6 level=25 kills=1391 shards=333 elites=2`, `ASHEN_TEST_CRITS crits=122`, exit 0, no leak warning |
| Live hero-death test (regression) | PASS | `ASHEN_DEATH_PASS lose_screen=true label=THE FIELD FALLS shards_earned=1 total_before=1414 total_after=1415 hero_death_tex=true time=25.4 level=2 kills=33`, exit 0 |
| Sprite / blend sheets viewed (dark backdrops) | PASS | `qa/v14-portal-sheet.png`, `qa/v14-blend-sheet.png` — both viewed; portal clean, no contamination, no regeneration pass used |
| Seam metric (layout-audited) | PASS | Differing edges 40 → unblended hard edges 40 → 0, coverage 40/40 = 100%, zone edge alpha factor 0.55 → 0.15, bridges 12 |
| Save round-trip (v1.3 profile → v1.4) | PASS | Synthetic v1.3-format profile (shards 500) loaded under v1.4 and banked to 587 (= 500 + 87), meta/settings intact, format version still 1; real profile (1891 shards) restored after |
| Pool discipline (no mid-run instantiation) | PASS by construction | All nodes pre-created in `build_world()`/`build_pools()`; portal nodes (3), transition strips (40) and bridges (12) are built-time; burst/relocation/emerge are pooled-node reuse only; census 479 |
| APK export + badging + signature | PASS | See EXPORT-REPORT.md v1.4 |

## What the v1.4 gates cover (beyond v1.3)
- Portal spawning end-to-end: every normal-run spawn position
  asserted within 100 px of the current anchor (347 spawns, 0
  violations, max 96.9 px in the gate run); relocation warning
  exercised (3 s, portal collapsed, spawns held) and spawns
  resumed at the new anchor (181 after the gate's relocation);
  elite waves and the boss through the portal, including a wave
  deferred through a relocation warning and fired from the new
  anchor — the deferral path, not just the happy path.
- Tile blending by metric + sheet, not by claim: 40/40 edges
  covered, zone fade widened, bridges placed.
- Two real bugs caught by the gates and fixed, not waived:
  serialised telegraph halving spawn rate, and elite double-
  counting on deferral (see BUILD-LOG.md v1.4).

## Playtest variance — same warning as v1.1/v1.2/v1.3
Short-test numbers are one observation of a noisy harness. Compare
bands: v1.3 short 83–87 s / level 4 / 85–93 kills / 86–87 shards;
v1.4 short 86–92 s / level 4 / 93–97 kills / 87–88 shards — inside
the band (the 97-kill observation sits just above it, within
loadout-shuffle noise: storm in the boss-time loadout). Long:
v1.3 393.7 s / 27 / 1504 / 356; v1.4 392.6–393.8 s / 25 / 1391–
1396 / 333–334 — ~7% below v1.3 on kills/shards across TWO runs,
so this is portal geometry (single-direction pressure, longer
travel, relocation holds), not noise — but the run still wins
comfortably at ~393 s, so per the standing rule no damage/HP/
interval change was made to chase it. Spawn rate formula is
unchanged; only the geometry changed, and the geometry change
is the requested feature.

## What the playtests do NOT cover (honest gaps, v1.4)
- Real touch input: unchanged from v1.3.
- Portal/blend pixels in-game: portal markers, strips and bridges
  are asserted in code and viewed on contact/blend sheets, but no
  headless run screenshots them (no framebuffer). Portal
  readability at phone scale and tile-blend readability in play
  are human verdicts.
- Boss arrival surge feel (whether the large portal surge reads
  as a boss arrival rather than a big elite burst on a phone
  screen): needs a human playtest; the surge scale (1.2) and
  anchor print are the headless evidence.
- Real-device fps, OLED colour, portrait/landscape resize, audio
  on device speakers, install/launch on the S25: NOT verifiable
  here. These remain the user's verdicts by design.
- No screenshot evidence from the game itself: headless Godot has
  no framebuffer. Contact/blend sheets + test logs + tile data
  are the evidence pack.
