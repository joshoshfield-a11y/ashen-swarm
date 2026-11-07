# ASHEN SWARM — Export Report (v1.0, 2026-10-31)

## Artifact (verified)
- Path: `~/workspace/ashen-swarm/build/ashen-swarm.apk`
- Size: **38,094,517 bytes** (37 MB)
- SHA-256: `16687f97e55366f08f798d0c41ea3cd2989f1bd7ddf2f10b4e61596354242dbc`
- Package: `com.ashenswarm.game`, versionCode 1, versionName 1.0
- Label: ASHEN SWARM; minSdk 24, targetSdk 36, arm64-v8a only
- Signing: **debug-signed** (Godot debug keystore,
  `~/.local/share/godot/keystores/debug.keystore`, cert CN=Godot).
  Independent check: `apksigner verify --verbose` → Verifies; v2 true,
  v3 true, 1 signer. Release signing is a user-side step (no release key
  was supplied, and none was invented).
- Contents: 155 files; game assets under `assets/` as imported `.ctex`;
  `assets/raw/*`, `tools/*`, `qa/*` excluded from the package.
- Sidecar `ashen-swarm.apk.idsig` (298,610 bytes) sits beside the APK;
  it is not part of the installable artifact.

## Toolchain (all verified present before export)
- Godot 4.8 beta 1 (`~/tools/godot/godot`, `4.8.beta1.official.4d10419ca`)
- Export templates `~/.local/share/godot/export_templates/4.8.beta1/`
  (android_debug.apk 117 MB, pre-existing, not re-downloaded)
- Android SDK `~/android-sdk`: build-tools 36.1.0, platform android-36
  (editor settings already pointed at the SDK; no sdkmanager use)
- Java 17 (Temurin 17.0.20.1, `~/jdk17`) — required on PATH for apksigner;
  a bare shell lacks `java`, which made the first apksigner call fail
  with "java: not found" (Godot's own sign+verify step had already
  succeeded; the independent verify was re-run with JDK 17 on PATH).
- project.godot carries `textures/vram_compression/import_etc2_astc=true`;
  preset uses the non-Gradle template path (`use_gradle_build=false`).

## Export failures and fixes
1. First export failed: `"Compress Native Libraries" is only valid when
   "Use Gradle Build" is enabled.` → set
   `gradle_build/compress_native_libraries=false` in export_presets.cfg.
2. First export's reimport pass pulled `assets/raw/` (unkeyed AI raws,
   ~10 MB) into the candidate package → set
   `exclude_filter="assets/raw/*,tools/*,qa/*"`. Verified absent from
   the final APK listing.
3. aapt2 badging emits one benign warning: themed_icon XML reference
   without a file (Godot-generated adaptive icon stub). Cosmetic only;
   the icon itself ships as mipmap webp assets.

## What this does NOT prove
Packaging, badging, and signing are verified here. Runtime on a real
Galaxy S25 — launch, touch joystick feel, real fps, audio, portrait /
landscape — is NOT proven by any headless step and remains the user's
verdict. Do not present this APK to the user as "works on your phone"
until that check happens.

---

# Export Report v1.1 (2026-11-01)

## Artifact (verified)
- Path: `~/workspace/ashen-swarm/build/ashen-swarm-v1.1.apk`
- Size: **48,393,843 bytes** (46 MB; larger than v1.0 because it carries
  both sprite generations' imported textures — v1.0 art is still in the
  project tree, and 63 new v11 textures were added)
- SHA-256: `736340578c2e6b297cbf47768fd541b7cbe7e1f10351595d6f12c86766283ede`
- Package: `com.ashenswarm.game`, versionCode 2, versionName 1.1
- Label: ASHEN SWARM; minSdk 24, targetSdk 36, arm64-v8a only
- Signing: **debug-signed** (same Godot debug keystore as v1.0, so it
  installs over v1.0 in place). Independent check: `apksigner verify
  --verbose` → Verifies; v2 true, v3 true, 1 signer. Release signing is
  still a user-side step.
- Contents: 281 entries; 85 `.ctex` (63 v11-family + v1.0 assets), 0
  entries matching `assets/raw/*`, `assets/raw-v11/*`, `tools/*`,
  `qa/*`. The 63 v11 `.import` metadata files are also present in the
  package (same as v1.0's package, which carried its `.import` files).
- Manifest launcher (via `aapt2 dump xmltree`, NOT badging — see below):
  `com.godot.game.GodotAppLauncher` activity-alias → target
  `com.godot.game.GodotApp`, intent-filter MAIN + LAUNCHER.
- Sidecar `ashen-swarm-v1.1.apk.idsig` (386,528 bytes) sits beside the
  APK; it is not part of the installable artifact.
- v1.0 APK untouched: `build/ashen-swarm.apk` still 38,094,517 bytes,
  SHA-256 `16687f97e55366f08f798d0c41ea3cd2989f1bd7ddf2f10b4e61596354242dbc`
  (byte-identical to the v1.0 record).

## Toolchain (unchanged from v1.0)
Godot 4.8 beta 1, templates `4.8.beta1`, SDK build-tools 36.1.0 +
platform android-36, Java 17 on PATH for apksigner, non-Gradle template
path (`use_gradle_build=false`, `compress_native_libraries=false`),
`textures/vram_compression/import_etc2_astc=true`. Preset changes only:
`version/code` 1 → 2, `version/name` "1.0" → "1.1", `export_path` →
`build/ashen-swarm-v1.1.apk`, `exclude_filter` gained `assets/raw-v11/*`.

## Export failures and fixes (v1.1)
1. `--export-release` failed: "Could not find release keystore" — v1.0
   was debug-signed, so the correct command is `--export-debug
   "Android"`. A partial 46,739,343-byte APK from the failed release
   attempt was overwritten by the successful debug export (verified by
   final byte count + SHA).
2. v11 sprites had no `.import` files after the headless game runs
   (Godot loads raw PNGs directly in-editor, so the game ran fine, but
   export-time inclusion is only guaranteed via the import cache).
   Fix: ran `godot --headless --path . --import` before exporting —
   63 v11 `.import` files + 4 raw-v11 `.import` files created, 101
   `.ctex` in `.godot/imported/`. Re-ran boot green, then exported.
   Lesson for rebuilds: always run the `--import` pass after adding
   sprites, before exporting; do not rely on game-run loading.
3. `aapt2 dump badging` prints NO `launchable-activity` line for this
   APK — but the v1.0 APK shows the identical output (empty
   `other-activities`, no launchable line), so this is an aapt2 quirk
   with Godot's activity-alias launcher, not a v1.1 regression. The
   launcher was verified via `aapt2 dump xmltree` instead (see above).
   The benign themed_icon warning is unchanged from v1.0.

## What this does NOT prove
Same as v1.0: packaging, badging, and signing only. S25 runtime remains
the user's verdict.

---

# Export Report v1.2 (2026-11-01)

## Artifact (verified)
- Path: `~/workspace/ashen-swarm/build/ashen-swarm-v1.2.apk`
- Size: **52,843,787 bytes** (50 MB; larger than v1.1 because it
  carries three sprite generations' imported textures plus 43 new
  v12 files)
- SHA-256: `9e62c2c7873c4340bbd1296b8bf019e979ee0e10de7e4a7e88d2e563c3241b64`
- Package: `com.ashenswarm.game`, versionCode 3, versionName 1.2
- Label: ASHEN SWARM; minSdk 24, targetSdk 36, arm64-v8a only
- Signing: **debug-signed** (same Godot debug keystore as v1.0/v1.1,
  so it installs over v1.1 in place). Independent check: `apksigner
  verify --verbose` → Verifies; v2 true, v3 true, 1 signer.
  Release signing is still a user-side step.
- Contents: 367 entries; 43 entries under `assets/sprites/v12/`
  (all v12 files present); 0 entries matching `assets/raw/*`,
  `assets/raw-v11/*`, `assets/raw-v12/*`, `tools/*`, `qa/*`.
- Manifest launcher (via `aapt2 dump xmltree --file`):
  `com.godot.game.GodotAppLauncher` activity-alias → target
  `com.godot.game.GodotApp`, intent-filter MAIN + LAUNCHER.
- Sidecar `ashen-swarm-v1.2.apk.idsig` (419,296 bytes) sits beside
  the APK; it is not part of the installable artifact.
- v1.0 APK untouched: `build/ashen-swarm.apk` still 38,094,517 bytes,
  SHA-256 `16687f97e55366f08f798d0c41ea3cd2989f1bd7ddf2f10b4e61596354242dbc`
  (re-checked after the v1.2 export).
- v1.1 APK untouched: `build/ashen-swarm-v1.1.apk` still 48,393,843
  bytes, SHA-256
  `736340578c2e6b297cbf47768fd541b7cbe7e1f10351595d6f12c86766283ede`
  (re-checked after the v1.2 export).

## Toolchain (unchanged from v1.1)
Godot 4.8 beta 1, templates `4.8.beta1`, SDK build-tools 36.1.0 +
platform android-36, Java 17 on PATH for apksigner, non-Gradle
template path (`use_gradle_build=false`,
`compress_native_libraries=false`),
`textures/vram_compression/import_etc2_astc=true`. Preset changes
only: `version/code` 2 → 3, `version/name` "1.1" → "1.2",
`export_path` → `build/ashen-swarm-v1.2.apk`, `exclude_filter`
gained `assets/raw-v12/*`.

## Export failures and fixes (v1.2)
None on the export itself: `--export-debug "Android"` succeeded
first try after the mandatory `--import` pass (43 v12 `.import`
files + 3 qa-sheet `.import` files created; boot re-verified
green before exporting). Verification-tool notes, not failures:
- `aapt2 dump xmltree` in build-tools 36.1.0 requires the
  `--file AndroidManifest.xml` flag (bare positional form errors
  "missing required flag --file").
- Badging prints the floor SDK as `minSdkVersion:'24'` (not
  `sdkVersion`), and prints no `launchable-activity` line — the
  same aapt2 quirk as v1.0/v1.1, not a regression; the launcher
  was verified via xmltree instead.
- The export log echoes its internal apksigner invocation; that
  line is not reproduced here (it carries keystore credentials
  for the debug keystore, which are Godot's own defaults).

## What this does NOT prove
Same as v1.0/v1.1: packaging, badging, and signing only. S25
runtime remains the user's verdict. Additionally, v1.2's poses are
derived transforms, not drawn art (see GRAPHICS-PASS.md v1.2) —
the APK proves the code paths and the derived frames, not a new
hand-drawn sprite family.

---

# Export Report v1.3 (2026-11-01)

## Artifact (verified)
- Path: `~/workspace/ashen-swarm/build/ashen-swarm-v1.3.apk`
- Size: **54,571,931 bytes** (52 MB; larger than v1.2 because it
  carries four sprite generations' imported textures plus 16 new
  v13 files — and the v12 dasher files remain in the tree as the
  fallback record)
- SHA-256: `574b371c21cc525fb7da8d1869a30548547c42c542385098a23c82045c19306b`
- Package: `com.ashenswarm.game`, versionCode 4, versionName 1.3
- Label: ASHEN SWARM; minSdk 24, targetSdk 36, arm64-v8a only
- Signing: **debug-signed** (same Godot debug keystore as
  v1.0/v1.1/v1.2, so it installs over v1.2 in place).
  Independent check: `apksigner verify --verbose` → Verifies;
  v2 true, v3 true, 1 signer. Release signing is still a
  user-side step.
- Contents: 401 entries; 16 entries under
  `assets/sprites/v13/` (all v13 files present) + 16 v13 `.ctex`
  under `assets/.godot/imported/` (32 dasher `.ctex` total: 16
  v13 + 16 v12 fallback); 0 entries matching `assets/raw/*`,
  `assets/raw-v11/*`, `assets/raw-v12/*`, `assets/raw-v13/*`,
  `tools/*`, `qa/*` (the only `raw` substring hits in the
  listing are Android `res/drawable-*` notification images,
  not project folders).
- Manifest launcher (via `aapt2 dump xmltree --file`):
  `com.godot.game.GodotAppLauncher` activity-alias → target
  `com.godot.game.GodotApp`, intent-filter MAIN + LAUNCHER.
- Sidecar `ashen-swarm-v1.3.apk.idsig` (435,680 bytes) sits
  beside the APK; it is not part of the installable artifact.
- v1.0 APK untouched: `build/ashen-swarm.apk` still 38,094,517
  bytes, SHA-256
  `16687f97e55366f08f798d0c41ea3cd2989f1bd7ddf2f10b4e61596354242dbc`
  (re-checked after the v1.3 export).
- v1.1 APK untouched: `build/ashen-swarm-v1.1.apk` still
  48,393,843 bytes, SHA-256
  `736340578c2e6b297cbf47768fd541b7cbe7e1f10351595d6f12c86766283ede`
  (re-checked after the v1.3 export).
- v1.2 APK untouched: `build/ashen-swarm-v1.2.apk` still
  52,843,787 bytes, SHA-256
  `9e62c2c7873c4340bbd1296b8bf019e979ee0e10de7e4a7e88d2e563c3241b64`
  (re-checked after the v1.3 export).

## Toolchain (unchanged from v1.2)
Godot 4.8 beta 1, templates `4.8.beta1`, SDK build-tools 36.1.0 +
platform android-36, Java 17 on PATH for apksigner, non-Gradle
template path (`use_gradle_build=false`,
`compress_native_libraries=false`),
`textures/vram_compression/import_etc2_astc=true`. Preset changes
only: `version/code` 3 → 4, `version/name` "1.2" → "1.3",
`export_path` → `build/ashen-swarm-v1.3.apk`, `exclude_filter`
gained `assets/raw-v13/*`.

## Export failures and fixes (v1.3)
None on the export itself: `--export-debug "Android"` succeeded
first try after the mandatory `--import` pass (16 v13 `.import`
files created; boot re-verified green before exporting).
Verification-tool notes, not failures:
- Badging prints the floor SDK as `minSdkVersion:'24'` (not
  `sdkVersion`), and prints no `launchable-activity` line — the
  same aapt2 quirk as v1.0/v1.1/v1.2, not a regression; the
  launcher was verified via xmltree instead.
- APK listing paths carry an `assets/` prefix (e.g.
  `assets/assets/sprites/v13/...`); an unprefixed grep for
  `assets/sprites/v13/` returns nothing — check with the prefix
  or a `sprites/v13` substring instead. Same prefixing applies
  to the exclusion check (a bare `raw` grep also matches
  `res/drawable-*` images; use `raw-v` / `/raw/` patterns).
- The export log echoes its internal apksigner invocation; that
  line is not reproduced here (it carries keystore credentials
  for the debug keystore, which are Godot's own defaults).

## What this does NOT prove
Same as v1.0/v1.1/v1.2: packaging, badging, and signing only.
S25 runtime remains the user's verdict. Additionally, v1.3's
drawn art covers the dasher only — cinderling/brute/spitter/
hero poses remain v1.2 derivatives (see GRAPHICS-PASS.md v1.3) —
the APK proves the code paths, the drawn dasher, and the
derived fallback frames, not a fully redrawn pose set.


---

# Export Report v1.4 (2026-11-01)

## Artifact (verified)
- Path: `~/workspace/ashen-swarm/build/ashen-swarm-v1.4.apk`
- Size: **54,953,537 bytes** (52 MB; larger than v1.3 because it
  carries five sprite generations' imported textures plus 3 new
  v14 textures)
- SHA-256: `5bc98603e9bce63acf1c49f061f1ffa0998cc0390b1b928536e014bf5da39ff8`
- Package: `com.ashenswarm.game`, versionCode 5, versionName 1.4
- Label: ASHEN SWARM; minSdk 24, targetSdk 36, arm64-v8a only
- Signing: **debug-signed** (same Godot debug keystore as
  v1.0/v1.1/v1.2/v1.3, so it installs over v1.3 in place).
  Independent check: `apksigner verify --verbose` → Verifies;
  v2 true, v3 true, 1 signer. Release signing is still a
  user-side step.
- Contents: 405 entries; 3 v14 `.ctex` under
  `assets/.godot/imported/` (portal-ember, transition-h,
  transition-v) + 3 v14 `.import` files under
  `assets/assets/sprites/v14/`; 0 entries matching
  `assets/raw/*`, `assets/raw-v11/*`, `assets/raw-v12/*`,
  `assets/raw-v13/*`, `assets/raw-v14/*`, `tools/*`, `qa/*`
  (checked with the `raw-v` / `/raw/` patterns — a bare `raw`
  grep would also match nothing here, since no `res/drawable-*`
  raw hits appeared in this listing).
- Manifest launcher (via `aapt2 dump xmltree --file`):
  `com.godot.game.GodotAppLauncher` activity-alias → target
  `com.godot.game.GodotApp`, intent-filter MAIN + LAUNCHER.
- Sidecar `ashen-swarm-v1.4.apk.idsig` (435,680 bytes) sits
  beside the APK; it is not part of the installable artifact.
- v1.0 APK untouched: `build/ashen-swarm.apk` still 38,094,517
  bytes, SHA-256
  `16687f97e55366f08f798d0c41ea3cd2989f1bd7ddf2f10b4e61596354242dbc`
  (re-checked after the v1.4 export).
- v1.1 APK untouched: `build/ashen-swarm-v1.1.apk` still
  48,393,843 bytes, SHA-256
  `736340578c2e6b297cbf47768fd541b7cbe7e1f10351595d6f12c86766283ede`
  (re-checked after the v1.4 export).
- v1.2 APK untouched: `build/ashen-swarm-v1.2.apk` still
  52,843,787 bytes, SHA-256
  `9e62c2c7873c4340bbd1296b8bf019e979ee0e10de7e4a7e88d2e563c3241b64`
  (re-checked after the v1.4 export).
- v1.3 APK untouched: `build/ashen-swarm-v1.3.apk` still
  54,571,931 bytes, SHA-256
  `574b371c21cc525fb7da8d1869a30548547c42c542385098a23c82045c19306b`
  (re-checked after the v1.4 export).

## Toolchain (unchanged from v1.3)
Godot 4.8 beta 1, templates `4.8.beta1`, SDK build-tools 36.1.0 +
platform android-36, Java 17 on PATH for apksigner, non-Gradle
template path (`use_gradle_build=false`,
`compress_native_libraries=false`),
`textures/vram_compression/import_etc2_astc=true`. Preset changes
only: `version/code` 4 → 5, `version/name` "1.3" → "1.4",
`export_path` → `build/ashen-swarm-v1.4.apk`, `exclude_filter`
gained `assets/raw-v14/*`.

## Export failures and fixes (v1.4)
None on the export itself: `--export-debug "Android"` succeeded
first try after the mandatory `--import` pass (3 v14 `.import`
files created; boot re-verified green before exporting). The
export log's `cannot connect to daemon at tcp:5037` line is
benign (no Android device attached for one-click deploy; the
export itself printed DONE and the APK verifies). Verification-
tool notes, not failures:
- Badging prints the floor SDK as `minSdkVersion:'24'` (not
  `sdkVersion`), and prints no `launchable-activity` line — the
  same aapt2 quirk as v1.0–v1.3, not a regression; the launcher
  was verified via xmltree instead (MAIN + LAUNCHER present).
- APK listing paths carry an `assets/` prefix (e.g.
  `assets/assets/sprites/v14/...`); check with the prefix or a
  `sprites/v14` substring instead of an unprefixed
  `assets/sprites/` grep. Same prefixing applies to the
  exclusion check (use `raw-v` / `/raw/` patterns).
- The export log echoes its internal apksigner invocation; that
  line is not reproduced here (it carries keystore credentials
  for the debug keystore, which are Godot's own defaults).

## What this does NOT prove
Same as v1.0–v1.3: packaging, badging, and signing only. S25
runtime remains the user's verdict. Additionally, v1.4's portal
readability at phone scale and tile-blend readability in play
are human verdicts — headless runs prove the portal markers,
the anchor sequence, the spawn positions, the seam metric and
the blend sheet, not the in-play feel.
