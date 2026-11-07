extends Node2D
# ASHEN SWARM v1 — original top-down roguelite survival shooter.
# Manual distance-based sim (no physics bodies): deterministic, pool-based,
# headless-testable. Juice reads sim events and never writes sim state.

const ARENA := 2400.0
const RUN_TIME := 600.0
const BOSS_TIME := 540.0
# v1.1 texture set: NEW 3D-look sprite family (assets/sprites/v11/).
# v1.0 files are untouched on disk; the game now loads only the v11 set.
const HERO_FRAMES := ["res://assets/sprites/v11/hero-walk-0-512.png",
	"res://assets/sprites/v11/hero-walk-1-512.png",
	"res://assets/sprites/v11/hero-walk-2-512.png",
	"res://assets/sprites/v11/hero-walk-3-512.png"]
const ENEMY_FRAMES := {"cinderling": ["res://assets/sprites/v11/cinderling-walk-0-512.png",
	"res://assets/sprites/v11/cinderling-walk-1-512.png",
	"res://assets/sprites/v11/cinderling-walk-2-512.png",
	"res://assets/sprites/v11/cinderling-walk-3-512.png"],
	"brute": ["res://assets/sprites/v11/brute-walk-0-512.png",
	"res://assets/sprites/v11/brute-walk-1-512.png",
	"res://assets/sprites/v11/brute-walk-2-512.png",
	"res://assets/sprites/v11/brute-walk-3-512.png"],
	"spitter": ["res://assets/sprites/v11/spitter-walk-0-512.png",
	"res://assets/sprites/v11/spitter-walk-1-512.png",
	"res://assets/sprites/v11/spitter-walk-2-512.png",
	"res://assets/sprites/v11/spitter-walk-3-512.png"],
	"dasher": ["res://assets/sprites/v13/dasher-walk-0-512.png",
	"res://assets/sprites/v13/dasher-walk-1-512.png",
	"res://assets/sprites/v13/dasher-walk-2-512.png",
	"res://assets/sprites/v13/dasher-walk-3-512.png"]}
const ENEMY_GOLD_FRAMES := {"cinderling": ["res://assets/sprites/v11/cinderling-gold-0-512.png",
	"res://assets/sprites/v11/cinderling-gold-1-512.png",
	"res://assets/sprites/v11/cinderling-gold-2-512.png",
	"res://assets/sprites/v11/cinderling-gold-3-512.png"],
	"brute": ["res://assets/sprites/v11/brute-gold-0-512.png",
	"res://assets/sprites/v11/brute-gold-1-512.png",
	"res://assets/sprites/v11/brute-gold-2-512.png",
	"res://assets/sprites/v11/brute-gold-3-512.png"],
	"spitter": ["res://assets/sprites/v11/spitter-gold-0-512.png",
	"res://assets/sprites/v11/spitter-gold-1-512.png",
	"res://assets/sprites/v11/spitter-gold-2-512.png",
	"res://assets/sprites/v11/spitter-gold-3-512.png"],
	"dasher": ["res://assets/sprites/v13/dasher-walk-0-gold-512.png",
	"res://assets/sprites/v13/dasher-walk-1-gold-512.png",
	"res://assets/sprites/v13/dasher-walk-2-gold-512.png",
	"res://assets/sprites/v13/dasher-walk-3-gold-512.png"]}
const BOSS_FRAMES := ["res://assets/sprites/v11/boss-walk-0-512.png",
	"res://assets/sprites/v11/boss-walk-1-512.png",
	"res://assets/sprites/v11/boss-walk-2-512.png",
	"res://assets/sprites/v11/boss-walk-3-512.png"]
const BOSS_TELEGRAPH_TEX := "res://assets/sprites/v11/boss-telegraph-512.png"
const BOSS_DEATH_TEX := "res://assets/sprites/v11/boss-death-512.png"
# v1.3 pose frames: DASHER poses are DRAWN (fresh v1.3 hound grid,
# assets/sprites/v13/); cinderling/brute/spitter/hero poses stay v1.2
# DERIVED (the v1.3 poses grid failed its integrity check and was NOT
# retried — see GRAPHICS-PASS.md v1.3 provenance table).
# Spitter has no separate attack frame: walk-3 pose-hold.
const ENEMY_ATTACK_FRAMES := {"cinderling": "res://assets/sprites/v12/cinderling-attack-512.png",
	"brute": "res://assets/sprites/v12/brute-attack-512.png",
	"dasher": "res://assets/sprites/v13/dasher-attack-512.png"}
const ENEMY_ATTACK_GOLD := {"cinderling": "res://assets/sprites/v12/cinderling-attack-gold-512.png",
	"brute": "res://assets/sprites/v12/brute-attack-gold-512.png",
	"dasher": "res://assets/sprites/v13/dasher-attack-gold-512.png"}
const ENEMY_HURT_FRAMES := {"cinderling": "res://assets/sprites/v12/cinderling-hurt-512.png",
	"brute": "res://assets/sprites/v12/brute-hurt-512.png",
	"spitter": "res://assets/sprites/v12/spitter-hurt-512.png",
	"dasher": "res://assets/sprites/v13/dasher-hurt-512.png"}
const ENEMY_HURT_GOLD := {"cinderling": "res://assets/sprites/v12/cinderling-hurt-gold-512.png",
	"brute": "res://assets/sprites/v12/brute-hurt-gold-512.png",
	"spitter": "res://assets/sprites/v12/spitter-hurt-gold-512.png",
	"dasher": "res://assets/sprites/v13/dasher-hurt-gold-512.png"}
const ENEMY_DEATH_FRAMES := {"cinderling": "res://assets/sprites/v12/cinderling-death-512.png",
	"brute": "res://assets/sprites/v12/brute-death-512.png",
	"spitter": "res://assets/sprites/v12/spitter-death-512.png",
	"dasher": "res://assets/sprites/v13/dasher-death-512.png"}
const ENEMY_DEATH_GOLD := {"cinderling": "res://assets/sprites/v12/cinderling-death-gold-512.png",
	"brute": "res://assets/sprites/v12/brute-death-gold-512.png",
	"spitter": "res://assets/sprites/v12/spitter-death-gold-512.png",
	"dasher": "res://assets/sprites/v13/dasher-death-gold-512.png"}
const DASHER_TELEGRAPH_TEX := "res://assets/sprites/v13/dasher-telegraph-512.png"
const DASHER_TELEGRAPH_GOLD_TEX := "res://assets/sprites/v13/dasher-telegraph-gold-512.png"
const HERO_DEATH_TEX := "res://assets/sprites/v12/hero-death-512.png"  # v1.2 DERIVED, kept (v1.3 hero pose grid failed, not retried)
const SHADOW_TEX := "res://assets/sprites/v12/shadow-blob-512.png"
const WEAPON_ICONS := {"bolt": "res://assets/sprites/v12/icon-bolt.png",
	"frost": "res://assets/sprites/v12/icon-frost.png",
	"storm": "res://assets/sprites/v12/icon-storm.png",
	"orbit": "res://assets/sprites/v12/icon-orbit.png",
	"nova": "res://assets/sprites/v12/icon-nova.png",
	"lance": "res://assets/sprites/v12/icon-lance.png"}
const EMBLEM_TEX := "res://assets/sprites/v12/icon-emblem.png"
const TERRAIN_TEXS := ["res://assets/sprites/v11/terrain-ash-powder-512.png",
	"res://assets/sprites/v11/terrain-ember-cracks-512.png",
	"res://assets/sprites/v11/terrain-scorch-drifts-512.png",
	"res://assets/sprites/v11/terrain-gravel-flecks-512.png",
	"res://assets/sprites/v12/terrain-ember-web-512.png",
	"res://assets/sprites/v12/terrain-pale-drift-512.png"]
const OVERLAY_TEXS := ["res://assets/sprites/v11/overlay-drift-512.png",
	"res://assets/sprites/v11/overlay-crack-512.png",
	"res://assets/sprites/v11/overlay-scorch-512.png"]
const TEX := {
	"glow_o": "res://assets/sprites/glow-orange.png",
	"glow_b": "res://assets/sprites/glow-blue.png",
	"glow_g": "res://assets/sprites/glow-green.png",
	"glow_p": "res://assets/sprites/glow-purple.png",
	"glow_w": "res://assets/sprites/glow-white.png",
	"gem": "res://assets/sprites/gem-ember.png",
	"gem_f": "res://assets/sprites/gem-frost.png",
	"gem_l": "res://assets/sprites/gem-life.png",
}
# kind -> [hp, speed, radius, dmg, xp, scale] — v1.1 speeds +11% (see DESIGN v1.1)
const ENEMIES := {
	"cinderling": [22.0, 117.0, 26.0, 10.0, 1, 0.55],
	"brute": [90.0, 61.0, 40.0, 22.0, 3, 0.85],
	"spitter": [38.0, 84.0, 30.0, 12.0, 2, 0.65],
	"dasher": [30.0, 95.0, 28.0, 16.0, 2, 0.62],
}

enum State { MENU, RUN, LEVELUP, PAUSE, WIN, LOSE }
var state: int = State.MENU
var test_mode := false
var long_test := false
var anim_check := false
var v12_check := false
var v13_check := false
var death_check := false
var shadow_check := false
var portal_check := false
# --- v1.4 portal state (DETERMINISTIC: fixed anchors, fixed cycle order) ---
# Spawn LOCATION is never random in v1.4: every normal-run enemy, elite
# and boss spawns from the current portal anchor. Kind selection stays
# weighted/time-gated (rng) — only LOCATION randomness was removed.
const PORTAL_ANCHORS := [Vector2(600.0, 600.0), Vector2(1800.0, 600.0),
	Vector2(600.0, 1800.0), Vector2(1800.0, 1800.0)]
const PORTAL_RADIUS := 100.0  # gate bound: portal spawns lie within this of the anchor
const PORTAL_TEX := "res://assets/sprites/v14/portal-ember-512.png"
const TRANSITION_H_TEX := "res://assets/sprites/v14/transition-h-512.png"
const TRANSITION_V_TEX := "res://assets/sprites/v14/transition-v-512.png"
var portal_idx := 0
var portal_pos := Vector2(600.0, 600.0)
var portal_next_reloc := 120.0
var portal_warn_t := 0.0
var portal_warn_anchor := Vector2.ZERO
var portal_surge_t := 0.0
var portal_burst_t := 0.0
var _portal_burst_kinds: Array = []
var _portal_burst_elite := false
var _portal_elite_deferred := false
var _portal_boss_deferred := false
var _portal_spawns := 0
var _portal_violations := 0
var _portal_max_dist := 0.0
var _portal_relocs := 0
var _portal_warns := 0
var _portal_spawns_after_reloc := 0
var _portal_elite_spawned := false
var _portal_boss_spawned := false
var _portal_boss_done := false
var _bridge_count := 0
var _transition_count := 0
var portal_sprite: Sprite2D
var portal_glow: Sprite2D
var portal_warn_glow: Sprite2D
var portal_ring: Line2D
var portal_tex: Texture2D
var transition_h_tex: Texture2D
var transition_v_tex: Texture2D
var _shadow_phase := 0
var _shadow_on_ok := false
var _shadow_off_ok := false
var _shadow_persist_ok := false
var _v13_boss_done := false
var _death_spawn_t := 0.0
var _death_before_shards := 0
var _hero_changes := 0
var _enemy_swaps := 0
var _attack_frames := 0
var _hurt_frames := 0
var _death_frames := 0
var _dash_telegraphs := 0
var _lance_shots := 0
var _crits := 0
var _dasher_spawns := 0
var _dasher_kills := 0
var _last_pool: Array = []
var _last_offers: Array = []
var headless := false
var run_seed := 1337
var rng := RandomNumberGenerator.new()

# --- run state ---
var player_pos := Vector2(ARENA / 2.0, ARENA / 2.0)
var player_hp := 100.0
var player_max_hp := 100.0
var player_speed := 245.0
var player_level := 1
var player_xp := 0
var player_xp_next := 14
var run_time := 0.0
var kills := 0
var gems_banked := 0
var trauma := 0.0
var hitstop := 0.0
var hurt_flash := 0.0
var spawn_timer := 1.0
var elite_done := [false, false]
var elite_waves_fired := 0
var boss_spawned := false
var boss_active := false
var boss_dying := false
var boss_death_t := 0.0
var boss_hp := 0.0
var boss_max_hp := 4000.0
var boss_pos := Vector2.ZERO
var boss_phase := 0.0
var boss_charge_t := 0.0
var boss_charge_dir := Vector2.ZERO
var boss_telegraph := 0.0
var boss_burst_t := 0.0
var boss_summon_t := 0.0
var boss_enraged := false
var magnet_radius := 110.0
var dmg_mult := 1.0
var regen := 0.0
var joy_vec := Vector2.ZERO
var joy_active := false
var joy_id := -1
var joy_origin := Vector2.ZERO
var joy_current := Vector2.ZERO
var free_rerolls := 1
var level_choices: Array = []

# weapons: id -> level ; timers dict id -> time left
var weapons := {"bolt": 1}
var weapon_timers := {"bolt": 0.0, "frost": 0.0, "storm": 0.0, "orbit": 0.0, "nova": 0.0, "lance": 0.0}
var orbit_angle := 0.0
var passives := {"speed": 0, "heart": 0, "magnet": 0, "core": 0, "spark": 0}

# --- profile / settings ---
var profile := {"version": 1, "shards": 0, "meta": {"hp": 0, "dmg": 0, "speed": 0, "magnet": 0},
	"settings": {"sound": true, "shake": true, "quality": "auto", "joy_side": "left"}}
var quality_mobile := false

# --- v1.1 animation textures (preloaded once; frame swaps are not instantiation) ---
var hero_frames: Array = []
var enemy_frames := {}
var enemy_gold := {}
var boss_frames: Array = []
var boss_telegraph_tex: Texture2D
var boss_death_tex: Texture2D
var terrain_texs: Array = []
var overlay_texs: Array = []
var enemy_attack: Dictionary = {}
var enemy_attack_gold: Dictionary = {}
var enemy_hurt: Dictionary = {}
var enemy_hurt_gold: Dictionary = {}
var enemy_death: Dictionary = {}
var enemy_death_gold: Dictionary = {}
var dasher_telegraph_tex: Texture2D
var dasher_telegraph_gold_tex: Texture2D
var hero_death_tex: Texture2D
var shadow_tex: Texture2D
var weapon_icons: Dictionary = {}
var emblem_tex: Texture2D
var _zone_counts: Array = [0, 0, 0, 0]
var _hero_anim := 0.0
var _hero_frame := 0
var _boss_anim := 0.0
var _boss_frame := 0

func build_anim_textures() -> void:
	for p in HERO_FRAMES:
		hero_frames.append(tex(p))
	for k in ENEMY_FRAMES.keys():
		var arr: Array = []
		for p in ENEMY_FRAMES[k]:
			arr.append(tex(p))
		enemy_frames[k] = arr
		var garr: Array = []
		for p in ENEMY_GOLD_FRAMES[k]:
			garr.append(tex(p))
		enemy_gold[k] = garr
	for p in BOSS_FRAMES:
		boss_frames.append(tex(p))
	boss_telegraph_tex = tex(BOSS_TELEGRAPH_TEX)
	boss_death_tex = tex(BOSS_DEATH_TEX)
	for p in TERRAIN_TEXS:
		terrain_texs.append(tex(p))
	for p in OVERLAY_TEXS:
		overlay_texs.append(tex(p))
	for k in ENEMY_ATTACK_FRAMES.keys():
		enemy_attack[k] = tex(ENEMY_ATTACK_FRAMES[k])
		enemy_attack_gold[k] = tex(ENEMY_ATTACK_GOLD[k])
	for k in ENEMY_HURT_FRAMES.keys():
		enemy_hurt[k] = tex(ENEMY_HURT_FRAMES[k])
		enemy_hurt_gold[k] = tex(ENEMY_HURT_GOLD[k])
	for k in ENEMY_DEATH_FRAMES.keys():
		enemy_death[k] = tex(ENEMY_DEATH_FRAMES[k])
		enemy_death_gold[k] = tex(ENEMY_DEATH_GOLD[k])
	dasher_telegraph_tex = tex(DASHER_TELEGRAPH_TEX)
	dasher_telegraph_gold_tex = tex(DASHER_TELEGRAPH_GOLD_TEX)
	hero_death_tex = tex(HERO_DEATH_TEX)
	shadow_tex = tex(SHADOW_TEX)
	for k in WEAPON_ICONS.keys():
		weapon_icons[k] = tex(WEAPON_ICONS[k])
	emblem_tex = tex(EMBLEM_TEX)
	print("ASHEN_V11_FRAMES hero=%d kinds=%d boss=%d terrain=%d overlays=%d" % [
		hero_frames.size(), enemy_frames.size(), boss_frames.size(), terrain_texs.size(), overlay_texs.size()])
	print("ASHEN_V12_FRAMES dasher=%d poses=%d terrain=%d icons=%d shadow=1" % [
		enemy_frames["dasher"].size() + 4, enemy_attack.size() + enemy_hurt.size() + enemy_death.size(),
		terrain_texs.size(), weapon_icons.size() + 1])
	print("ASHEN_V13_FRAMES dasher_drawn=%d dasher_gold=%d" % [
		enemy_frames["dasher"].size() + 4, enemy_gold["dasher"].size() + 4])
	portal_tex = tex(PORTAL_TEX)
	transition_h_tex = tex(TRANSITION_H_TEX)
	transition_v_tex = tex(TRANSITION_V_TEX)
	print("ASHEN_V14_FRAMES portal=%s transitions=%s" % [portal_tex != null, transition_h_tex != null and transition_v_tex != null])

func frame_tex(kind: String, frame: int, elite: bool) -> Texture2D:
	var bank: Dictionary = enemy_gold if elite else enemy_frames
	if bank.has(kind):
		var arr: Array = bank[kind]
		if frame >= 0 and frame < arr.size():
			return arr[frame]
	return hero_frames[0] if hero_frames.size() > 0 else null

func pose_tex(bank: Dictionary, kind: String) -> Texture2D:
	if bank.has(kind):
		return bank[kind]
	return null

func attack_tex(kind: String, elite: bool) -> Texture2D:
	return pose_tex(enemy_attack_gold if elite else enemy_attack, kind)

func hurt_tex(kind: String, elite: bool) -> Texture2D:
	return pose_tex(enemy_hurt_gold if elite else enemy_hurt, kind)

func death_tex(kind: String, elite: bool) -> Texture2D:
	return pose_tex(enemy_death_gold if elite else enemy_death, kind)

# --- nodes ---
var cam: Camera2D
var world: Node2D
var ground_layer: Node2D
var entity_layer: Node2D
var fx_layer: Node2D
var ui: CanvasLayer
var title_panel: Control
var hud: Control
var hp_bar: ProgressBar
var xp_bar: ProgressBar
var timer_label: Label
var kill_label: Label
var level_label: Label
var boss_bar: ProgressBar
var boss_label: Label
var levelup_panel: Control
var levelup_buttons: Array = []
var levelup_icons: Array = []
var pause_panel: Control
var end_panel: Control
var end_label: Label
var end_stats: Label
var forge_panel: Control
var forge_shards: Label
var forge_rows := {}
var settings_panel: Control
var joy_base: Sprite2D
var joy_knob: Sprite2D
var flash_rect: ColorRect
var vignette_rect: ColorRect
var player_sprite: Sprite2D
var player_glow: Sprite2D
var player_shadow: Sprite2D
var boss_shadow: Sprite2D
var boundary_ring: Line2D
var menu_bg: Sprite2D
var menu_hero: Sprite2D
var boss_sprite: Sprite2D
var boss_glow: Sprite2D
var sfx: Dictionary = {}
var sfx_players: Array = []
var sfx_idx := 0

# pools: parallel arrays of dicts + pre-made Sprite2D nodes
var enemies: Array = []
var pbullets: Array = []
var ebullets: Array = []
var gems: Array = []
var dmgnums: Array = []
var parts: Array = []
var smoke: Array = []
var corpses: Array = []
var shadows: Array = []

func tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var t := load(path) as Texture2D
		if t != null:
			return t
	# fallback: 64px solid texture so headless/missing-asset runs never crash
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.9, 0.4, 0.1, 1.0))
	return ImageTexture.create_from_image(img)

func stop_all_sfx() -> void:
	# Leak fix (see QA-REPORT v1.2): an AudioStreamPlayer still holding a
	# playing stream at quit() leaks the stream + its playback (2 ObjectDB
	# instances). Stopping + clearing before every test quit removes it.
	for p in sfx_players:
		var pl: AudioStreamPlayer = p
		pl.stop()
		pl.stream = null

func _ready() -> void:
	headless = DisplayServer.get_name() == "headless"
	for a in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		if a == "--ashen-test":
			test_mode = true
		if a == "--ashen-test-long":
			test_mode = true
			long_test = true
		if a == "--ashen-anim-check":
			test_mode = true
			anim_check = true
		if a == "--ashen-v12-check":
			test_mode = true
			v12_check = true
		if a == "--ashen-v13-check":
			test_mode = true
			v13_check = true
		if a == "--ashen-death-check":
			test_mode = true
			death_check = true
		if a == "--ashen-shadow-check":
			test_mode = true
			shadow_check = true
		if a == "--ashen-portal-check":
			test_mode = true
			portal_check = true
	load_profile()
	quality_mobile = (OS.get_name() == "Android" or OS.get_name() == "iOS")
	if str(profile["settings"].get("quality", "auto")) == "desktop":
		quality_mobile = false
	elif str(profile["settings"].get("quality", "auto")) == "mobile":
		quality_mobile = true
	rng.seed = run_seed
	build_anim_textures()
	build_world()
	build_ui()
	build_pools()
	build_audio()
	show_menu()
	if test_mode:
		# boosted, shortened run for headless verification (3x wall speed)
		Engine.time_scale = 3.0
		if death_check:
			_death_before_shards = int(profile["shards"])
		start_run()
		if death_check:
			# LIVE death test: real (low, meta-flat) HP, no damage boost.
			# The hero must actually die to the swarm in this run.
			player_max_hp = 100.0
			player_hp = 100.0
			dmg_mult = 1.0
		else:
			dmg_mult = 3.0
			player_max_hp = 9999.0
			player_hp = 9999.0
		print("ASHEN_TEST_START seed=%d" % run_seed)
	elif headless:
		# plain headless smoke: prove the scene boots, then exit cleanly
		print("ASHEN_HEADLESS_OK menu_built pools=%d/%d" % [enemies.size(), pbullets.size()])

func _process(delta: float) -> void:
	if headless and not test_mode:
		# exit after one frame of menu boot (handled by counter below)
		_headless_frames += 1
		if _headless_frames > 3:
			stop_all_sfx()
			get_tree().quit(0)
		return
	# juice timers always tick (wall clock, not sim)
	if trauma > 0.0:
		trauma = max(0.0, trauma - delta * 1.7)
	if hurt_flash > 0.0:
		hurt_flash = max(0.0, hurt_flash - delta * 2.2)
		if flash_rect:
			flash_rect.modulate.a = hurt_flash * 0.45
	if state == State.RUN:
		if hitstop > 0.0:
			hitstop -= delta
			update_fx(delta)
			update_camera(delta)
			return
		var sim_dt := delta
		# test mode accelerates wall time via Engine.time_scale set by harness;
		# sim itself uses plain delta so behaviour stays identical.
		update_run(sim_dt)
		update_fx(delta)
		update_camera(delta)
		_hud_tick += delta
		if _hud_tick > 0.25:
			_hud_tick = 0.0
			refresh_hud()
	elif state in [State.MENU, State.LEVELUP, State.PAUSE, State.WIN, State.LOSE]:
		update_fx(delta)
		update_camera(delta)
	# v1.1 hero walk cycle: frame-driven, speed-tied; squash is secondary only.
	if player_sprite and state == State.RUN:
		_bob += delta * 8.0
		var mv := joy_vec
		if mv.length() < 0.05:
			mv = _keys_vec()
		var moving := mv.length() > 0.1
		if moving:
			_hero_anim += delta * clamp(player_speed / 28.0, 6.0, 12.0)
			var hf := int(_hero_anim) % 4
			if hf != _hero_frame:
				_hero_frame = hf
				_hero_changes += 1
				player_sprite.texture = hero_frames[hf]
		elif _hero_frame != 0:
			_hero_frame = 0
			player_sprite.texture = hero_frames[0]
		var s := 1.0 + (0.02 * sin(_bob) if moving else 0.01 * sin(_bob * 0.5))
		player_sprite.scale = Vector2(0.62 * s, 0.62 / s)
		player_sprite.rotation = mv.x * 0.05 if moving else 0.0
		if mv.x < -0.1:
			player_sprite.flip_h = true
		elif mv.x > 0.1:
			player_sprite.flip_h = false

var _headless_frames := 0
var _hud_tick := 0.0
var _bob := 0.0

func _keys_vec() -> Vector2:
	var v := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		v.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		v.y += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		v.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		v.x += 1
	return v.normalized() if v.length() > 0 else v

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_P:
			if state == State.RUN:
				pause_game()
			elif state == State.PAUSE:
				resume_game()
	if event is InputEventScreenTouch:
		if event.pressed and not joy_active and state == State.RUN:
			joy_active = true
			joy_id = event.index
			joy_origin = event.position
			joy_current = event.position
			joy_vec = Vector2.ZERO
			position_joystick()
		elif not event.pressed and event.index == joy_id:
			joy_active = false
			joy_id = -1
			joy_vec = Vector2.ZERO
			hide_joystick()
	if event is InputEventScreenDrag and event.index == joy_id:
		joy_current = event.position
		var d := joy_current - joy_origin
		if d.length() > 90.0:
			d = d.normalized() * 90.0
			joy_origin = joy_current - d
		joy_vec = d / 90.0
		if joy_vec.length() > 1.0:
			joy_vec = joy_vec.normalized()
		position_joystick()
	if event is InputEventMouseButton and event.pressed and state == State.RUN and not joy_active:
		# desktop mouse-drag joystick (also lets headless-adjacent tests drive)
		joy_active = true
		joy_id = 999
		joy_origin = event.position
		joy_current = event.position
	if event is InputEventMouseButton and not event.pressed and joy_id == 999:
		joy_active = false
		joy_id = -1
		joy_vec = Vector2.ZERO
		hide_joystick()
	if event is InputEventMouseMotion and joy_id == 999:
		joy_current = event.position
		var d2 := joy_current - joy_origin
		if d2.length() > 90.0:
			d2 = d2.normalized() * 90.0
		joy_vec = d2 / 90.0
		position_joystick()

func position_joystick() -> void:
	if joy_base:
		joy_base.visible = true
		joy_base.position = joy_origin
		joy_knob.visible = true
		joy_knob.position = joy_origin + joy_vec * 55.0

func hide_joystick() -> void:
	if joy_base:
		joy_base.visible = false
		joy_knob.visible = false

# ================= world =================
var scatter_nodes: Array = []
var add_mat: CanvasItemMaterial

func build_world() -> void:
	world = Node2D.new()
	add_child(world)
	ground_layer = Node2D.new()
	entity_layer = Node2D.new()
	fx_layer = Node2D.new()
	world.add_child(ground_layer)
	world.add_child(entity_layer)
	world.add_child(fx_layer)
	add_mat = CanvasItemMaterial.new()
	add_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	# v1.2 terrain: 6 seamless variants, NO adjacent-equal tiles anywhere.
	# Fixed verified 5x5 table (counts powder 5, cracks 5, scorch 4,
	# gravel 4, ember-web 4, pale-drift 3; zero adjacent-equal pairs,
	# zero runs of 3 — audited in QA-REPORT v1.2). 4 = ember web, 5 =
	# pale drift (both new v1.2 AI art, edge MAD 0.0). Pale drift is
	# graded 0.72x in code so its bright ash sits in the dusk palette.
	# No baked paths/crosses/junctions.
	var layout := [[0, 1, 4, 2, 3], [2, 3, 0, 5, 1], [1, 4, 2, 3, 0], [3, 0, 5, 1, 4], [4, 5, 1, 0, 2]]
	for ix in range(5):
		for iy in range(5):
			var v := int(layout[ix][iy])
			var s := Sprite2D.new()
			s.texture = terrain_texs[v]
			s.position = Vector2(240.0 + ix * 480.0, 240.0 + iy * 480.0)
			s.scale = Vector2(480.0 / 512.0, 480.0 / 512.0)
			s.rotation = float((ix * ix * 3 + iy * iy * 5 + ix * iy * 7) % 4) * PI / 2.0
			s.flip_h = (ix * 3 + iy * 7 + ix * iy) % 2 == 1
			var bright := 0.88 + float((ix * 29 + iy * 17) % 21) / 100.0
			if v == 5:
				bright *= 0.72
			var warm := 0.03 if (ix + iy) % 3 == 0 else 0.0
			s.modulate = Color(bright + warm, bright, bright - warm * 0.5, 1.0)
			s.z_index = 0
			ground_layer.add_child(s)
	# scatter: pebble blobs + ember dots (visual only, no collision)
	for i in range(190):
		var s2 := Sprite2D.new()
		if i < 130:
			s2.texture = tex(TEX["glow_w"])
			s2.modulate = Color(0.10, 0.09, 0.08, 0.55)
			s2.scale = Vector2(rng.randf_range(0.08, 0.30), rng.randf_range(0.08, 0.30))
		else:
			s2.texture = tex(TEX["glow_o"])
			s2.material = add_mat
			s2.modulate = Color(1.0, 0.55, 0.15, rng.randf_range(0.25, 0.7))
			s2.scale = Vector2(rng.randf_range(0.03, 0.10), rng.randf_range(0.03, 0.10))
		s2.position = Vector2(rng.randf_range(0.0, ARENA), rng.randf_range(0.0, ARENA))
		s2.z_index = 0
		ground_layer.add_child(s2)
		scatter_nodes.append(s2)
	# v1.3 scorched boundary ring: ONE built-time Line2D (never
	# instantiated mid-run) tracing the arena edge so the limits read
	# in play. Additive ember line, 26 px wide.
	boundary_ring = Line2D.new()
	boundary_ring.points = PackedVector2Array([Vector2(0.0, 0.0), Vector2(ARENA, 0.0),
		Vector2(ARENA, ARENA), Vector2(0.0, ARENA), Vector2(0.0, 0.0)])
	boundary_ring.width = 26.0
	boundary_ring.default_color = Color(1.0, 0.45, 0.12, 0.85)
	boundary_ring.material = add_mat
	boundary_ring.z_index = 0
	ground_layer.add_child(boundary_ring)
	# v1.4 feathered transition strips: one POOLED transparent gradient
	# overlay per adjacent differing tile pair (40 edges, all differ —
	# zero adjacent-equal pairs in the layout). Strips are gradient
	# overlays only: never baked crosses/junctions/lines in a base tile,
	# never specific to one base tile (standing tile-overlay rule).
	for ix in range(5):
		for iy in range(5):
			if ix < 4 and int(layout[ix][iy]) != int(layout[ix + 1][iy]):
				var vs := Sprite2D.new()
				vs.texture = transition_v_tex
				vs.position = Vector2((ix + 1) * 480.0, 240.0 + iy * 480.0)
				vs.scale = Vector2(1.0, 480.0 / 512.0)
				vs.z_index = 0
				ground_layer.add_child(vs)
				_transition_count += 1
			if iy < 4 and int(layout[ix][iy]) != int(layout[ix][iy + 1]):
				var hs := Sprite2D.new()
				hs.texture = transition_h_tex
				hs.position = Vector2(240.0 + ix * 480.0, (iy + 1) * 480.0)
				hs.scale = Vector2(480.0 / 512.0, 1.0)
				hs.z_index = 0
				ground_layer.add_child(hs)
				_transition_count += 1
	# v1.4 Ember Portal nodes (built-time only, never instantiated mid-run):
	# drawn swirl sprite + additive glow + ring + relocation-warning glow.
	portal_glow = Sprite2D.new()
	portal_glow.texture = tex(TEX["glow_o"])
	portal_glow.material = add_mat
	portal_glow.scale = Vector2(1.6, 1.6)
	portal_glow.z_index = 1
	entity_layer.add_child(portal_glow)
	portal_sprite = Sprite2D.new()
	portal_sprite.texture = portal_tex
	portal_sprite.scale = Vector2(0.43, 0.43)
	portal_sprite.z_index = 1
	entity_layer.add_child(portal_sprite)
	portal_ring = Line2D.new()
	var ring_pts := PackedVector2Array()
	for k in range(33):
		var a := float(k) / 32.0 * TAU
		ring_pts.append(Vector2(cos(a), sin(a)) * 110.0)
	portal_ring.points = ring_pts
	portal_ring.width = 8.0
	portal_ring.default_color = Color(1.0, 0.45, 0.12, 0.9)
	portal_ring.material = add_mat
	portal_ring.z_index = 1
	entity_layer.add_child(portal_ring)
	portal_warn_glow = Sprite2D.new()
	portal_warn_glow.texture = tex(TEX["glow_o"])
	portal_warn_glow.material = add_mat
	portal_warn_glow.scale = Vector2(1.2, 1.2)
	portal_warn_glow.visible = false
	portal_warn_glow.z_index = 1
	entity_layer.add_child(portal_warn_glow)
	# v1.2 zone-blended overlays: 66 decals. 16 per biome zone, placed
	# inside a zone disc with alpha fading toward the zone edge (soft
	# transition, no hard grid lines), + 18 global decals anywhere.
	# Zones: NW ember-crack field, centre scorch drifts, SE gravel plain.
	# Zone textures: crack / scorch / grey-tinted drift respectively.
	var zone_defs: Array = [
		{"c": Vector2(600.0, 600.0), "r": 950.0, "tex": 1, "tint": Color(1, 1, 1)},
		{"c": Vector2(1200.0, 1200.0), "r": 1050.0, "tex": 2, "tint": Color(1, 1, 1)},
		{"c": Vector2(1800.0, 1800.0), "r": 950.0, "tex": 0, "tint": Color(0.75, 0.75, 0.8)}]
	_zone_counts = [0, 0, 0, 0]
	for zi in range(3):
		var zd: Dictionary = zone_defs[zi]
		var zc: Vector2 = zd["c"]
		var zr: float = zd["r"]
		var ztint: Color = zd["tint"]
		for j in range(16):
			var ang: float = rng.randf_range(0.0, TAU)
			var rrd: float = sqrt(rng.randf()) * zr
			var pos := zc + Vector2(cos(ang), sin(ang)) * rrd
			pos.x = clamp(pos.x, 0.0, ARENA)
			pos.y = clamp(pos.y, 0.0, ARENA)
			var s3 := Sprite2D.new()
			s3.texture = overlay_texs[int(zd["tex"])]
			s3.position = pos
			var sc: float = rng.randf_range(0.4, 1.1)
			s3.scale = Vector2(sc, sc)
			s3.rotation = rng.randf_range(0.0, TAU)
			s3.flip_h = rng.randf() < 0.5
			var fade: float = 1.0 - 0.85 * (rrd / zr)  # v1.4: wider/dissolving zone fade (edge factor 0.55 -> 0.15)
			s3.modulate = Color(ztint.r, ztint.g, ztint.b, rng.randf_range(0.5, 0.85) * fade)
			s3.z_index = 0
			ground_layer.add_child(s3)
			scatter_nodes.append(s3)
			_zone_counts[zi] = int(_zone_counts[zi]) + 1
	for i in range(18):
		var s3 := Sprite2D.new()
		s3.texture = overlay_texs[i % 3]
		s3.position = Vector2(rng.randf_range(0.0, ARENA), rng.randf_range(0.0, ARENA))
		var sc := rng.randf_range(0.4, 1.1)
		s3.scale = Vector2(sc, sc)
		s3.rotation = rng.randf_range(0.0, TAU)
		s3.flip_h = rng.randf() < 0.5
		s3.modulate = Color(1, 1, 1, rng.randf_range(0.5, 0.85))
		s3.z_index = 0
		ground_layer.add_child(s3)
		scatter_nodes.append(s3)
		_zone_counts[3] = int(_zone_counts[3]) + 1
	# v1.4 zone bridging: 12 extra low-alpha decals straddling the
	# boundaries between zones (4 per zone-pair segment, jittered),
	# so zones dissolve into each other instead of ending at a disc edge.
	var bridge_pairs := [[Vector2(600.0, 600.0), Vector2(1200.0, 1200.0)],
		[Vector2(1200.0, 1200.0), Vector2(1800.0, 1800.0)],
		[Vector2(600.0, 600.0), Vector2(1800.0, 1800.0)]]
	for bp in bridge_pairs:
		for j in range(4):
			var t: float = 0.25 + 0.166 * float(j)
			var pos: Vector2 = bp[0].lerp(bp[1], t) + Vector2(rng.randf_range(-120, 120), rng.randf_range(-120, 120))
			pos.x = clamp(pos.x, 0.0, ARENA)
			pos.y = clamp(pos.y, 0.0, ARENA)
			var s4 := Sprite2D.new()
			s4.texture = overlay_texs[j % 3]
			s4.position = pos
			var sc4: float = rng.randf_range(0.8, 1.2)
			s4.scale = Vector2(sc4, sc4)
			s4.rotation = rng.randf_range(0.0, TAU)
			s4.flip_h = rng.randf() < 0.5
			s4.modulate = Color(1, 1, 1, rng.randf_range(0.30, 0.50))
			s4.z_index = 0
			ground_layer.add_child(s4)
			scatter_nodes.append(s4)
			_bridge_count += 1
	print("ASHEN_V12_ZONES ember=%d scorch=%d gravel=%d global=%d" % [
		int(_zone_counts[0]), int(_zone_counts[1]), int(_zone_counts[2]), int(_zone_counts[3])])
	player_glow = Sprite2D.new()
	player_glow.texture = tex(TEX["glow_o"])
	player_glow.material = add_mat
	player_glow.scale = Vector2(0.9, 0.9)
	player_glow.z_index = 1
	entity_layer.add_child(player_glow)
	player_sprite = Sprite2D.new()
	player_sprite.texture = hero_frames[0]
	player_sprite.scale = Vector2(0.62, 0.62)
	player_sprite.z_index = 3
	entity_layer.add_child(player_sprite)
	boss_glow = Sprite2D.new()
	boss_glow.texture = tex(TEX["glow_o"])
	boss_glow.material = add_mat
	boss_glow.scale = Vector2(2.6, 2.6)
	boss_glow.visible = false
	boss_glow.z_index = 1
	entity_layer.add_child(boss_glow)
	boss_sprite = Sprite2D.new()
	boss_sprite.texture = boss_frames[0]
	boss_sprite.scale = Vector2(1.7, 1.7)
	boss_sprite.visible = false
	boss_sprite.z_index = 3
	entity_layer.add_child(boss_sprite)
	# v1.2 pooled blob shadows: procedural soft ellipse (NOT baked into
	# keyed art — dark-on-black keys out). Player + boss shadows here;
	# one per enemy slot in build_pools. z 1 = above ground, below chars.
	player_shadow = Sprite2D.new()
	player_shadow.texture = shadow_tex
	player_shadow.modulate = Color(1, 1, 1, 0.7)
	player_shadow.visible = false
	player_shadow.z_index = 1
	entity_layer.add_child(player_shadow)
	boss_shadow = Sprite2D.new()
	boss_shadow.texture = shadow_tex
	boss_shadow.modulate = Color(1, 1, 1, 0.7)
	boss_shadow.visible = false
	boss_shadow.z_index = 1
	entity_layer.add_child(boss_shadow)
	cam = Camera2D.new()
	cam.position_smoothing_enabled = false
	var vp := get_viewport().get_visible_rect().size
	cam.zoom = Vector2(0.85, 0.85) if vp.y > vp.x else Vector2(1.0, 1.0)
	add_child(cam)

func build_pools() -> void:
	for i in range(140):
		var s := Sprite2D.new()
		s.visible = false
		s.z_index = 2
		entity_layer.add_child(s)
		enemies.append({"active": false, "node": s, "kind": "cinderling", "pos": Vector2.ZERO,
			"hp": 0.0, "max_hp": 0.0, "speed": 0.0, "radius": 26.0, "dmg": 10.0, "xp": 1,
			"scale": 0.55, "elite": false, "atk_cd": 0.0, "flash": 0.0, "orbit_cd": 0.0,
			"shoot_cd": 0.0, "slow": 0.0, "slow_t": 0.0, "wob": rng.randf() * TAU,
			"anim": 0.0, "frame": 0, "pose_hold": 0.0,
			"hurt_t": 0.0, "attack_t": 0.0,
			"dash_state": 0, "dash_t": 0.0, "dash_cd": 0.0, "dash_dir": Vector2.ZERO, "spawn_in": 0.0})
	for i in range(200):
		var s := Sprite2D.new()
		s.visible = false
		s.z_index = 4
		s.material = add_mat
		entity_layer.add_child(s)
		pbullets.append({"active": false, "node": s, "pos": Vector2.ZERO, "vel": Vector2.ZERO,
			"dmg": 0.0, "pierce": 0, "element": "ember", "life": 0.0, "radius": 14.0, "hit": []})
	for i in range(120):
		var s := Sprite2D.new()
		s.visible = false
		s.z_index = 4
		s.material = add_mat
		entity_layer.add_child(s)
		ebullets.append({"active": false, "node": s, "pos": Vector2.ZERO, "vel": Vector2.ZERO,
			"dmg": 0.0, "life": 0.0})
	for i in range(300):
		var s := Sprite2D.new()
		s.visible = false
		s.z_index = 1
		s.material = add_mat
		entity_layer.add_child(s)
		gems.append({"active": false, "node": s, "pos": Vector2.ZERO, "value": 1, "age": 0.0})
	for i in range(48):
		var l := Label.new()
		l.visible = false
		l.z_index = 5
		l.add_theme_font_size_override("font_size", 22)
		l.add_theme_color_override("font_color", Color(1, 0.85, 0.4, 1))
		l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		l.add_theme_constant_override("outline_size", 4)
		fx_layer.add_child(l)
		dmgnums.append({"active": false, "node": l, "pos": Vector2.ZERO, "life": 0.0})
	var pcount := 180 if quality_mobile else 256
	for i in range(pcount):
		var s := Sprite2D.new()
		s.visible = false
		s.z_index = 4
		s.material = add_mat
		fx_layer.add_child(s)
		parts.append({"active": false, "node": s, "pos": Vector2.ZERO, "vel": Vector2.ZERO,
			"life": 0.0, "max": 1.0, "scale": 0.2})
	var scount := 90 if quality_mobile else 128
	for i in range(scount):
		var s := Sprite2D.new()
		s.visible = false
		s.z_index = 4
		fx_layer.add_child(s)
		smoke.append({"active": false, "node": s, "pos": Vector2.ZERO, "vel": Vector2.ZERO,
			"life": 0.0, "max": 1.0, "scale": 0.2})
	# v1.2 pooled blob shadows, one per enemy slot (parallel to enemies).
	for i in range(140):
		var sh := Sprite2D.new()
		sh.texture = shadow_tex
		sh.modulate = Color(1, 1, 1, 0.7)
		sh.visible = false
		sh.z_index = 1
		entity_layer.add_child(sh)
		shadows.append(sh)
	# v1.1 death-frame corpses: pooled, hold the killed enemy's death pose
	# (v1.2) and fade out (no mid-run instantiation).
	for i in range(16):
		var s := Sprite2D.new()
		s.visible = false
		s.z_index = 2
		fx_layer.add_child(s)
		corpses.append({"active": false, "node": s, "life": 0.0})
	var over_total: int = int(_zone_counts[0]) + int(_zone_counts[1]) + int(_zone_counts[2]) + int(_zone_counts[3])
	var shadow_total: int = shadows.size() + 2
	print("ASHEN_V12_CENSUS tiles=25 scatter=190 overlays=%d shadows=%d total=%d" % [
		over_total, shadow_total, 25 + 190 + over_total + shadow_total])
	print("ASHEN_V13_CENSUS tiles=25 scatter=190 overlays=%d shadows=%d ring=1 total=%d" % [
		over_total, shadow_total, 25 + 190 + over_total + shadow_total + 1])
	print("ASHEN_V14_CENSUS tiles=25 scatter=190 overlays=%d bridges=%d shadows=%d ring=1 transitions=%d portal=3 total=%d" % [
		over_total, _bridge_count, shadow_total, _transition_count, 25 + 190 + over_total + _bridge_count + shadow_total + 1 + _transition_count + 3])

func build_audio() -> void:
	var AudioSynth = load("res://scripts/audio_synth.gd")
	sfx = AudioSynth.build_bank()
	for i in range(4):
		var p := AudioStreamPlayer.new()
		add_child(p)
		sfx_players.append(p)

func play_sfx(name: String, pitch := 1.0) -> void:
	if not bool(profile["settings"].get("sound", true)):
		return
	if not sfx.has(name):
		return
	var p: AudioStreamPlayer = sfx_players[sfx_idx % sfx_players.size()]
	sfx_idx += 1
	p.stream = sfx[name]
	p.pitch_scale = pitch
	p.play()

# ================= profile =================
func load_profile() -> void:
	if not FileAccess.file_exists("user://profile.json"):
		return
	var f := FileAccess.open("user://profile.json", FileAccess.READ)
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed is Dictionary:
		var d: Dictionary = parsed
		if int(d.get("version", 0)) == 1:
			profile["shards"] = int(d.get("shards", 0))
			if d.get("meta") is Dictionary:
				for k in ["hp", "dmg", "speed", "magnet"]:
					profile["meta"][k] = int(d["meta"].get(k, 0))
			if d.get("settings") is Dictionary:
				for k in ["sound", "shake", "quality", "dmgnums", "shadows"]:
					if d["settings"].has(k):
						profile["settings"][k] = d["settings"][k]
	# defaults for keys added after v1
	if not profile["settings"].has("dmgnums"):
		profile["settings"]["dmgnums"] = true
	# v1.3 additive key: a v1.2 profile loads with shadows ON (default).
	if not profile["settings"].has("shadows"):
		profile["settings"]["shadows"] = true

func save_profile() -> void:
	var txt := JSON.stringify(profile)
	var tmp := FileAccess.open("user://profile.tmp", FileAccess.WRITE)
	if tmp == null:
		return
	tmp.store_string(txt)
	tmp.close()
	var dir := DirAccess.open("user://")
	if dir != null and dir.file_exists("profile.tmp"):
		if dir.file_exists("profile.json"):
			dir.remove("profile.bak")
			dir.rename("profile.json", "profile.bak")
		dir.rename("profile.tmp", "profile.json")
	else:
		var f2 := FileAccess.open("user://profile.json", FileAccess.WRITE)
		if f2 != null:
			f2.store_string(txt)
			f2.close()

# ================= UI =================
func mk_label(text: String, size := 26) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

func mk_button(text: String, w := 420, h := 72) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(w, h)
	b.add_theme_font_size_override("font_size", 24)
	return b

func full_rect(c: Control) -> void:
	c.anchor_left = 0.0; c.anchor_top = 0.0; c.anchor_right = 1.0; c.anchor_bottom = 1.0
	c.offset_left = 0.0; c.offset_top = 0.0; c.offset_right = 0.0; c.offset_bottom = 0.0

func center_box(parent: Control, w := 520, h := 560) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.anchor_left = 0.5; v.anchor_top = 0.5; v.anchor_right = 0.5; v.anchor_bottom = 0.5
	v.offset_left = -w / 2.0; v.offset_top = -h / 2.0; v.offset_right = w / 2.0; v.offset_bottom = h / 2.0
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 14)
	parent.add_child(v)
	return v

func build_ui() -> void:
	ui = CanvasLayer.new()
	ui.layer = 10
	add_child(ui)
	# v1.2 title/menu background: fullscreen terrain + ghosted hero
	# watermark behind the menu text (alpha keeps text readable).
	# Created first in the layer so everything else draws above it.
	var vp0 := get_viewport().get_visible_rect().size
	if vp0.x < 10.0 or vp0.y < 10.0:
		vp0 = Vector2(1152, 648)
	menu_bg = Sprite2D.new()
	menu_bg.texture = terrain_texs[4]
	menu_bg.position = vp0 / 2.0
	var cov: float = max(vp0.x / 512.0, vp0.y / 512.0)
	menu_bg.scale = Vector2(cov, cov)
	menu_bg.modulate = Color(1, 1, 1, 0.6)
	menu_bg.z_index = -10
	menu_bg.visible = false
	ui.add_child(menu_bg)
	menu_hero = Sprite2D.new()
	menu_hero.texture = hero_frames[0]
	menu_hero.position = vp0 / 2.0
	menu_hero.scale = Vector2(1.15, 1.15)
	menu_hero.modulate = Color(1, 1, 1, 0.32)
	menu_hero.z_index = -9
	menu_hero.visible = false
	ui.add_child(menu_hero)
	if not headless:
		vignette_rect = ColorRect.new()
		full_rect(vignette_rect)
		var sh := Shader.new()
		sh.code = "shader_type canvas_item;\nvoid fragment() { float d = distance(UV, vec2(0.5)); float vig = smoothstep(0.78, 0.32, d); COLOR = vec4(vec3(0.0), (1.0 - vig) * 0.55); }\n"
		var mat := ShaderMaterial.new()
		mat.shader = sh
		vignette_rect.material = mat
		vignette_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.add_child(vignette_rect)
	flash_rect = ColorRect.new()
	full_rect(flash_rect)
	flash_rect.color = Color(1, 0.15, 0.1, 1)
	flash_rect.modulate.a = 0.0
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(flash_rect)
	# HUD
	hud = Control.new()
	full_rect(hud)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(hud)
	hp_bar = ProgressBar.new()
	hp_bar.anchor_left = 0.03; hp_bar.anchor_top = 0.02; hp_bar.anchor_right = 0.55; hp_bar.anchor_bottom = 0.02
	hp_bar.offset_top = 0; hp_bar.offset_bottom = 26; hp_bar.offset_left = 0; hp_bar.offset_right = 0
	hp_bar.max_value = 100.0; hp_bar.value = 100.0; hp_bar.show_percentage = false
	hud.add_child(hp_bar)
	xp_bar = ProgressBar.new()
	xp_bar.anchor_left = 0.03; xp_bar.anchor_top = 0.02; xp_bar.anchor_right = 0.55; xp_bar.anchor_bottom = 0.02
	xp_bar.offset_top = 30; xp_bar.offset_bottom = 44; xp_bar.offset_left = 0; xp_bar.offset_right = 0
	xp_bar.max_value = 14.0; xp_bar.value = 0.0; xp_bar.show_percentage = false
	hud.add_child(xp_bar)
	timer_label = mk_label("10:00", 30)
	timer_label.anchor_left = 0.5; timer_label.anchor_top = 0.02; timer_label.anchor_right = 0.5; timer_label.anchor_bottom = 0.02
	timer_label.offset_left = -80; timer_label.offset_right = 80; timer_label.offset_top = 0; timer_label.offset_bottom = 34
	hud.add_child(timer_label)
	kill_label = mk_label("Kills 0", 22)
	kill_label.anchor_left = 0.97; kill_label.anchor_top = 0.02; kill_label.anchor_right = 0.97; kill_label.anchor_bottom = 0.02
	kill_label.offset_left = -160; kill_label.offset_right = -10; kill_label.offset_top = 34; kill_label.offset_bottom = 62
	hud.add_child(kill_label)
	level_label = mk_label("Lv 1", 22)
	level_label.anchor_left = 0.03; level_label.anchor_top = 0.02; level_label.anchor_right = 0.03; level_label.anchor_bottom = 0.02
	level_label.offset_left = 0; level_label.offset_right = 90; level_label.offset_top = 48; level_label.offset_bottom = 74
	hud.add_child(level_label)
	var pause_btn := mk_button("II", 64, 56)
	pause_btn.anchor_left = 0.97; pause_btn.anchor_top = 0.02; pause_btn.anchor_right = 0.97; pause_btn.anchor_bottom = 0.02
	pause_btn.offset_left = -74; pause_btn.offset_right = -10; pause_btn.offset_top = 0; pause_btn.offset_bottom = 56
	pause_btn.pressed.connect(pause_game)
	hud.add_child(pause_btn)
	boss_bar = ProgressBar.new()
	boss_bar.anchor_left = 0.2; boss_bar.anchor_top = 0.02; boss_bar.anchor_right = 0.8; boss_bar.anchor_bottom = 0.02
	boss_bar.offset_top = 58; boss_bar.offset_bottom = 76
	boss_bar.visible = false; boss_bar.show_percentage = false
	hud.add_child(boss_bar)
	boss_label = mk_label("EMBER MATRIARCH", 20)
	boss_label.anchor_left = 0.5; boss_label.anchor_top = 0.02; boss_label.anchor_right = 0.5; boss_label.anchor_bottom = 0.02
	boss_label.offset_left = -160; boss_label.offset_right = 160; boss_label.offset_top = 78; boss_label.offset_bottom = 104
	boss_label.visible = false
	hud.add_child(boss_label)
	# joystick visuals
	joy_base = Sprite2D.new()
	joy_base.texture = tex(TEX["glow_w"])
	joy_base.modulate = Color(1, 1, 1, 0.25)
	joy_base.scale = Vector2(1.1, 1.1)
	joy_base.visible = false
	joy_base.z_index = 6
	ui.add_child(joy_base)
	joy_knob = Sprite2D.new()
	joy_knob.texture = tex(TEX["glow_o"])
	joy_knob.material = add_mat
	joy_knob.scale = Vector2(0.55, 0.55)
	joy_knob.visible = false
	joy_knob.z_index = 6
	ui.add_child(joy_knob)
	# title
	title_panel = Control.new()
	full_rect(title_panel)
	ui.add_child(title_panel)
	var tv := center_box(title_panel, 560, 640)
	tv.add_child(mk_label("ASHEN SWARM", 54))
	tv.add_child(mk_label("Hold the field. Slay the Matriarch.", 22))
	var start_btn := mk_button("START RUN")
	start_btn.pressed.connect(func(): play_sfx("click"); start_run())
	tv.add_child(start_btn)
	var forge_btn := mk_button("FORGE (Meta Upgrades)")
	forge_btn.pressed.connect(func(): play_sfx("click"); show_forge())
	tv.add_child(forge_btn)
	var set_btn := mk_button("SETTINGS")
	set_btn.pressed.connect(func(): play_sfx("click"); show_settings())
	tv.add_child(set_btn)
	var how := mk_label("Left stick to move. Weapons fire on their own.\nGrab ember gems. Survive 10 minutes.", 20)
	tv.add_child(how)
	var ver := mk_label("v1.4  •  Local save only  •  No ads, no accounts", 18)
	tv.add_child(ver)
	# level-up
	levelup_panel = Control.new()
	full_rect(levelup_panel)
	levelup_panel.visible = false
	ui.add_child(levelup_panel)
	var dim := ColorRect.new()
	full_rect(dim)
	dim.color = Color(0, 0, 0, 0.65)
	levelup_panel.add_child(dim)
	var lv := center_box(levelup_panel, 560, 620)
	lv.add_child(mk_label("LEVEL UP — Choose one", 30))
	for i in range(3):
		var row := HBoxContainer.new()
		var ic := TextureRect.new()
		ic.custom_minimum_size = Vector2(72, 72)
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(ic)
		levelup_icons.append(ic)
		var b := mk_button("", 440, 96)
		b.pressed.connect(_on_level_choice.bind(i))
		levelup_buttons.append(b)
		row.add_child(b)
		lv.add_child(row)
	var rr := mk_button("Reroll", 520, 56)
	rr.pressed.connect(_on_reroll)
	rr.name = "RerollBtn"
	lv.add_child(rr)
	# pause
	pause_panel = Control.new()
	full_rect(pause_panel)
	pause_panel.visible = false
	ui.add_child(pause_panel)
	var pdim := ColorRect.new()
	full_rect(pdim)
	pdim.color = Color(0, 0, 0, 0.6)
	pause_panel.add_child(pdim)
	var pv := center_box(pause_panel, 520, 480)
	pv.add_child(mk_label("PAUSED", 40))
	var res_btn := mk_button("RESUME")
	res_btn.pressed.connect(resume_game)
	pv.add_child(res_btn)
	var restart_btn := mk_button("RESTART RUN")
	restart_btn.pressed.connect(func(): play_sfx("click"); start_run())
	pv.add_child(restart_btn)
	var quit_btn := mk_button("QUIT TO MENU")
	quit_btn.pressed.connect(func(): play_sfx("click"); show_menu())
	pv.add_child(quit_btn)
	# end
	end_panel = Control.new()
	full_rect(end_panel)
	end_panel.visible = false
	ui.add_child(end_panel)
	var edim := ColorRect.new()
	full_rect(edim)
	edim.color = Color(0, 0, 0, 0.7)
	end_panel.add_child(edim)
	var ev := center_box(end_panel, 560, 560)
	end_label = mk_label("VICTORY", 48)
	ev.add_child(end_label)
	end_stats = mk_label("", 22)
	ev.add_child(end_stats)
	var retry_btn := mk_button("RUN AGAIN")
	retry_btn.pressed.connect(func(): play_sfx("click"); start_run())
	ev.add_child(retry_btn)
	var menu_btn := mk_button("MENU")
	menu_btn.pressed.connect(func(): play_sfx("click"); show_menu())
	ev.add_child(menu_btn)
	# forge
	forge_panel = Control.new()
	full_rect(forge_panel)
	forge_panel.visible = false
	ui.add_child(forge_panel)
	var fdim := ColorRect.new()
	full_rect(fdim)
	fdim.color = Color(0, 0, 0, 0.7)
	forge_panel.add_child(fdim)
	var fv := center_box(forge_panel, 560, 640)
	fv.add_child(mk_label("FORGE", 40))
	forge_shards = mk_label("Shards: 0", 24)
	fv.add_child(forge_shards)
	for id in ["hp", "dmg", "speed", "magnet"]:
		var row := HBoxContainer.new()
		var lab := mk_label("", 20)
		lab.custom_minimum_size = Vector2(340, 56)
		var b := mk_button("BUY", 140, 56)
		b.pressed.connect(_on_forge_buy.bind(id))
		row.add_child(lab)
		row.add_child(b)
		fv.add_child(row)
		forge_rows[id] = {"label": lab, "button": b}
	var fback := mk_button("BACK")
	fback.pressed.connect(func(): play_sfx("click"); show_menu())
	fv.add_child(fback)
	# settings
	settings_panel = Control.new()
	full_rect(settings_panel)
	settings_panel.visible = false
	ui.add_child(settings_panel)
	var sdim := ColorRect.new()
	full_rect(sdim)
	sdim.color = Color(0, 0, 0, 0.7)
	settings_panel.add_child(sdim)
	var sv := center_box(settings_panel, 560, 560)
	sv.add_child(mk_label("SETTINGS", 40))
	var snd_btn := mk_button("Sound: ON", 520, 64)
	snd_btn.name = "SndBtn"
	snd_btn.pressed.connect(_on_toggle_sound)
	sv.add_child(snd_btn)
	var shk_btn := mk_button("Shake: ON", 520, 64)
	shk_btn.name = "ShkBtn"
	shk_btn.pressed.connect(_on_toggle_shake)
	sv.add_child(shk_btn)
	var q_btn := mk_button("Quality: AUTO", 520, 64)
	q_btn.name = "QBtn"
	q_btn.pressed.connect(_on_cycle_quality)
	sv.add_child(q_btn)
	var dmg_btn := mk_button("Damage numbers: ON", 520, 64)
	dmg_btn.name = "DmgBtn"
	dmg_btn.pressed.connect(_on_toggle_dmgnums)
	sv.add_child(dmg_btn)
	var shd_btn := mk_button("Shadows: ON", 520, 64)
	shd_btn.name = "ShdBtn"
	shd_btn.pressed.connect(_on_toggle_shadows)
	sv.add_child(shd_btn)
	var sback := mk_button("BACK")
	sback.pressed.connect(func(): play_sfx("click"); show_menu())
	sv.add_child(sback)

func show_menu() -> void:
	state = State.MENU
	hide_all_panels()
	title_panel.visible = true
	menu_bg.visible = true
	menu_hero.visible = true
	hud.visible = false
	player_sprite.visible = false
	player_glow.visible = false
	player_shadow.visible = false
	boss_sprite.visible = false
	boss_glow.visible = false
	boss_shadow.visible = false
	for sh in shadows:
		sh.visible = false
	for e in enemies:
		e["active"] = false
		e["node"].visible = false
	for b in pbullets + ebullets:
		b["active"] = false
		b["node"].visible = false
	for g in gems:
		g["active"] = false
		g["node"].visible = false
	for c in corpses:
		c["active"] = false
		c["node"].visible = false
	refresh_settings_labels()

func hide_all_panels() -> void:
	menu_bg.visible = false
	menu_hero.visible = false
	title_panel.visible = false
	levelup_panel.visible = false
	pause_panel.visible = false
	end_panel.visible = false
	forge_panel.visible = false
	settings_panel.visible = false

# ================= run lifecycle =================
var run_limit := 600.0
var boss_at := 540.0
var pending_levels := 0
var _test_reported := false

func start_run() -> void:
	hide_all_panels()
	hud.visible = true
	rng.seed = run_seed + (int(Time.get_unix_time_from_system()) % 100000) if not test_mode else run_seed
	state = State.RUN
	run_limit = 420.0 if long_test else (120.0 if test_mode else RUN_TIME)
	bonus_shards = 0
	boss_at = 390.0 if long_test else (75.0 if test_mode else BOSS_TIME)
	if death_check:
		# live-death run: no boss, long limit; death must come from HP.
		run_limit = 600.0
		boss_at = 99999.0
		_death_spawn_t = 0.0
	if portal_check:
		# portal gate: no auto boss (the gate spawns it via the portal
		# at 190 s); limit covers relocation (120 s) + elite (180 s).
		run_limit = 220.0
		boss_at = 99999.0
	var meta: Dictionary = profile["meta"]
	player_max_hp = 100.0 * (1.0 + 0.10 * int(meta["hp"]))
	player_hp = player_max_hp
	player_speed = 245.0 * (1.0 + 0.05 * int(meta["speed"]))
	dmg_mult = 1.0 + 0.08 * int(meta["dmg"])
	magnet_radius = 110.0 * (1.0 + 0.15 * int(meta["magnet"]))
	regen = 0.0
	player_pos = Vector2(ARENA / 2.0, ARENA / 2.0)
	player_level = 1
	player_xp = 0
	player_xp_next = 14
	run_time = 0.0
	kills = 0
	gems_banked = 0
	trauma = 0.0
	hitstop = 0.0
	hurt_flash = 0.0
	spawn_timer = 0.8
	elite_done = [false, false]
	elite_waves_fired = 0
	boss_spawned = false
	boss_active = false
	boss_dying = false
	boss_enraged = false
	boss_death_t = 0.0
	boss_hp = 0.0
	pending_levels = 0
	free_rerolls = 1
	weapons = {"bolt": 1}
	weapon_timers = {"bolt": 0.0, "frost": 0.0, "storm": 0.0, "orbit": 0.0, "nova": 0.0, "lance": 0.0}
	orbit_angle = 0.0
	passives = {"speed": 0, "heart": 0, "magnet": 0, "core": 0, "spark": 0}
	joy_vec = Vector2.ZERO
	joy_active = false
	for e in enemies:
		e["active"] = false
		e["node"].visible = false
	for b in pbullets + ebullets:
		b["active"] = false
		b["node"].visible = false
	for g in gems:
		g["active"] = false
		g["node"].visible = false
	for p in parts + smoke:
		p["active"] = false
		p["node"].visible = false
	for d in dmgnums:
		d["active"] = false
		d["node"].visible = false
	for c in corpses:
		c["active"] = false
		c["node"].visible = false
	for sh in shadows:
		sh.visible = false
	player_shadow.visible = shadows_enabled()
	boss_shadow.visible = false
	_attack_frames = 0
	_hurt_frames = 0
	_death_frames = 0
	_dash_telegraphs = 0
	_lance_shots = 0
	_crits = 0
	_dasher_spawns = 0
	_dasher_kills = 0
	player_sprite.visible = true
	player_glow.visible = true
	player_sprite.position = player_pos
	player_glow.position = player_pos
	player_shadow.position = player_pos + Vector2(0, 22)
	player_shadow.scale = Vector2(0.38, 0.38)
	boss_sprite.visible = false
	boss_glow.visible = false
	if v12_check or v13_check or shadow_check:
		# v12/v13/shadow gate setup: one of each kind close in, lance
		# granted, and the level-up offer pool printed for the
		# offer-path assertion.
		weapons["lance"] = 1
		weapon_timers["lance"] = 0.0
		build_choices()
		print("ASHEN_V12_OFFERS offers=%s pool_has_lance=%s" % [_last_offers, _last_pool.has("lance")])
		# TEST-ONLY gate setup spawns (v12/v13/v14 gates) — not gameplay.
		spawn_enemy_at("cinderling", player_pos + Vector2(230, 0), false)
		spawn_enemy_at("brute", player_pos + Vector2(-230, 0), false)
		spawn_enemy_at("spitter", player_pos + Vector2(0, 230), false)
		spawn_enemy_at("dasher", player_pos + Vector2(0, -230), false)
		# Prime the check dasher to telegraph on its first update (its
		# spawn dash_cd of 1-2 s would otherwise let one-shot test bolts
		# kill it before it ever winds up — the gate must see the windup).
		for e in enemies:
			if e["active"] and str(e["kind"]) == "dasher":
				e["dash_cd"] = 0.0
		apply_choice({"kind": "weapon", "id": "lance"})
		if v13_check:
			print("ASHEN_V13_SETUP dasher=v13 ring=%s" % (boundary_ring != null))
	# v1.4 portal reset (deterministic): anchor 0, fixed cycle, schedule reset.
	portal_idx = 0
	portal_pos = PORTAL_ANCHORS[0]
	portal_next_reloc = 120.0
	portal_warn_t = 0.0
	portal_burst_t = 0.0
	portal_surge_t = 0.0
	_portal_burst_kinds = []
	_portal_elite_deferred = false
	_portal_boss_deferred = false
	_portal_spawns = 0
	_portal_violations = 0
	_portal_max_dist = 0.0
	_portal_relocs = 0
	_portal_warns = 0
	_portal_spawns_after_reloc = 0
	_portal_elite_spawned = false
	_portal_boss_spawned = false
	_portal_boss_done = false
	if portal_sprite != null:
		portal_sprite.position = portal_pos
		portal_sprite.visible = true
		portal_glow.position = portal_pos
		portal_glow.visible = true
		portal_ring.position = portal_pos
		portal_warn_glow.visible = false
	if portal_check:
		print("ASHEN_V14_ANCHORS anchors=%s order=NW,NE,SW,SE reloc_every=120 warn=3.0" % [PORTAL_ANCHORS])
	boss_bar.visible = false
	boss_label.visible = false
	cam.position = player_pos
	refresh_hud()

func pause_game() -> void:
	if state != State.RUN:
		return
	state = State.PAUSE
	pause_panel.visible = true
	play_sfx("click")

func resume_game() -> void:
	if state != State.PAUSE:
		return
	state = State.RUN
	pause_panel.visible = false
	play_sfx("click")

func end_run(win: bool, reason: String) -> void:
	if state == State.WIN or state == State.LOSE:
		return
	state = State.WIN if win else State.LOSE
	var shards := 0
	if win:
		shards = 60 + kills / 8 + player_level * 4 + bonus_shards
	else:
		shards = kills / 20 + bonus_shards
	gems_banked = shards
	profile["shards"] = int(profile["shards"]) + shards
	save_profile()
	end_label.text = "VICTORY" if win else "THE FIELD FALLS"
	end_stats.text = "%s\nTime %s  •  Level %d  •  Kills %d\nShards earned: %d  •  Total shards: %d" % [
		reason, fmt_time(run_time), player_level, kills, shards, int(profile["shards"])]
	end_panel.visible = true
	if not win and hero_death_tex != null:
		player_sprite.texture = hero_death_tex
	play_sfx("levelup" if win else "boss")
	if test_mode and not _test_reported:
		_test_reported = true
		if win:
			if portal_check:
				# Portal gate verdict on early victory: the boss was
				# already killed via the portal, so the gate's checks
				# are all decidable now — do not wait for 200 s.
				var ok2 := _portal_violations == 0 and _portal_spawns > 0 and _portal_relocs >= 1 and _portal_warns >= 1 and _portal_elite_spawned and _portal_boss_spawned and _portal_spawns_after_reloc > 0
				print("ASHEN_V14_PORTAL_OK ok=%s spawns=%d violations=%d max_dist=%.1f relocs=%d warns=%d elite_portal=%s boss_portal=%s spawns_after_reloc=%d anchor=%s early_win=true" % [
					ok2, _portal_spawns, _portal_violations, _portal_max_dist, _portal_relocs, _portal_warns, _portal_elite_spawned, _portal_boss_spawned, _portal_spawns_after_reloc, portal_pos])
				stop_all_sfx()
				get_tree().quit(0 if ok2 else 1)
				return
			print("ASHEN_TEST_PASS time=%.1f level=%d kills=%d shards=%d elites=%d" % [run_time, player_level, kills, shards, elite_waves_fired])
			print("ASHEN_TEST_CRITS crits=%d" % _crits)
			stop_all_sfx()
			get_tree().quit(0)
		else:
			if death_check:
				print("ASHEN_DEATH_PASS lose_screen=%s label=%s shards_earned=%d total_before=%d total_after=%d hero_death_tex=%s time=%.1f level=%d kills=%d" % [
					end_panel.visible, end_label.text, shards, _death_before_shards, int(profile["shards"]),
					player_sprite.texture == hero_death_tex, run_time, player_level, kills])
				stop_all_sfx()
				get_tree().quit(0)
			else:
				print("ASHEN_TEST_FAIL reason=%s time=%.1f level=%d kills=%d" % [reason, run_time, player_level, kills])
				stop_all_sfx()
				get_tree().quit(1)

func fmt_time(t: float) -> String:
	var m := int(t) / 60
	var s := int(t) % 60
	return "%d:%02d" % [m, s]

func refresh_hud() -> void:
	if hp_bar:
		hp_bar.max_value = player_max_hp
		hp_bar.value = player_hp
	if xp_bar:
		xp_bar.max_value = float(player_xp_next)
		xp_bar.value = float(player_xp)
	if timer_label:
		timer_label.text = "%s / %s" % [fmt_time(run_time), fmt_time(run_limit)]
	if kill_label:
		kill_label.text = "Kills %d" % kills
	if level_label:
		level_label.text = "Lv %d" % player_level
	if boss_bar and boss_active:
		boss_bar.max_value = boss_max_hp
		boss_bar.value = boss_hp

# ================= sim =================
func update_run(delta: float) -> void:
	run_time += delta
	if anim_check:
		# dedicated animation gate: drive the joystick in a slow circle
		# (separate run from the playtest, so baseline numbers are untouched)
		joy_vec = Vector2(cos(run_time * 0.7), sin(run_time * 0.7))
		if run_time >= 4.0:
			print("ASHEN_ANIM_OK hero_changes=%d enemy_swaps=%d hero_frame=%d" % [_hero_changes, _enemy_swaps, _hero_frame])
			stop_all_sfx()
			get_tree().quit(0)
			return
	if v12_check:
		# v1.2 gate: circle drive + close-in enemies + lance, 6 s. The
		# crit demo + hero-death assignment at the end prove those two
		# render paths (labelled demo, not natural-run observations).
		joy_vec = Vector2(cos(run_time * 0.7), sin(run_time * 0.7))
		if run_time >= 6.0:
			if hero_death_tex != null:
				player_sprite.texture = hero_death_tex
			spawn_dmgnum(player_pos, 99.0, Color(1, 0.85, 0.3, 1), true)
			print("ASHEN_V12_OK hero_changes=%d enemy_swaps=%d attack=%d hurt=%d death=%d dash_telegraph=%d lance=%d crits=%d crit_demo=1 dasher_spawns=%d dasher_kills=%d hero_death=1" % [_hero_changes, _enemy_swaps, _attack_frames, _hurt_frames, _death_frames, _dash_telegraphs, _lance_shots, _crits, _dasher_spawns, _dasher_kills])
			stop_all_sfx()
			get_tree().quit(0)
			return
	portal_update(delta)
	if portal_check:
		# portal gate: boss through the portal at 190 s, verdict at 200 s.
		# Relocation (120 s) + elite wave (180 s) must already have fired.
		if run_time >= 190.0 and not _portal_boss_done:
			_portal_boss_done = true
			spawn_boss()
		if run_time >= 200.0:
			var ok := _portal_violations == 0 and _portal_spawns > 0 and _portal_relocs >= 1 and _portal_warns >= 1 and _portal_elite_spawned and _portal_boss_spawned and _portal_spawns_after_reloc > 0
			print("ASHEN_V14_PORTAL_OK ok=%s spawns=%d violations=%d max_dist=%.1f relocs=%d warns=%d elite_portal=%s boss_portal=%s spawns_after_reloc=%d anchor=%s" % [
				ok, _portal_spawns, _portal_violations, _portal_max_dist, _portal_relocs, _portal_warns, _portal_elite_spawned, _portal_boss_spawned, _portal_spawns_after_reloc, portal_pos])
			stop_all_sfx()
			get_tree().quit(0 if ok else 1)
			return
	if regen > 0.0:
		player_hp = min(player_max_hp, player_hp + regen * delta)
	# v1.3 gates (run after the v12 branch above, before normal sim).
	if v13_check:
		# deterministic enrage exercise: spawn the boss, then drive it
		# below 50% HP with one honest damage call (telegraphs, charge
		# and burst cadence are untouched by the enrage itself).
		joy_vec = Vector2(cos(run_time * 0.7), sin(run_time * 0.7))
		if run_time >= 2.0 and not _v13_boss_done:
			_v13_boss_done = true
			spawn_boss()
			damage_boss(boss_max_hp * 0.6)
		if run_time >= 6.0:
			print("ASHEN_V13_OK enrage=%s dash_telegraph=%d enemy_swaps=%d ring=%s shadows=%d" % [
				boss_enraged, _dash_telegraphs, _enemy_swaps, boundary_ring != null, shadows.size() + 2])
			stop_all_sfx()
			get_tree().quit(0)
			return
	if death_check:
		# live-death stream, two phases: first the hero fights normal
		# spawns alone (banking real kills), then from 20 s the swarm
		# stream overwhelms. Death itself is always real combat damage.
		if run_time >= 20.0:
			_death_spawn_t -= delta
			if _death_spawn_t <= 0.0:
				_death_spawn_t = 0.5
				# TEST-ONLY death-check overwhelm stream — not gameplay.
				spawn_enemy_at("cinderling", ring_pos_around(player_pos, 250.0), false)
				spawn_enemy_at("cinderling", ring_pos_around(player_pos, 250.0), false)
		if run_time >= 300.0:
			print("ASHEN_DEATH_FAIL reason=timeout_still_alive time=%.1f" % run_time)
			stop_all_sfx()
			get_tree().quit(1)
			return
	if shadow_check:
		# staged toggle gate; falls through so shadow nodes update.
		if run_time >= 1.0 and _shadow_phase == 0:
			_shadow_on_ok = player_shadow.visible
			_on_toggle_shadows()
			_shadow_phase = 1
		elif run_time >= 2.0 and _shadow_phase == 1:
			_shadow_off_ok = (not player_shadow.visible) and not _any_shadow_visible()
			save_profile()
			load_profile()
			_shadow_persist_ok = not shadows_enabled()
			_on_toggle_shadows()
			_shadow_phase = 2
		elif run_time >= 3.0 and _shadow_phase == 2:
			print("ASHEN_SHADOW_OK on=%s off_hidden=%s persist_off=%s on_again=%s" % [
				_shadow_on_ok, _shadow_off_ok, _shadow_persist_ok, player_shadow.visible])
			stop_all_sfx()
			get_tree().quit(0)
			return
	# movement
	var dir := joy_vec
	if dir.length() < 0.05:
		dir = _keys_vec()
	if dir.length() > 1.0:
		dir = dir.normalized()
	player_pos += dir * player_speed * delta
	player_pos.x = clamp(player_pos.x, 40.0, ARENA - 40.0)
	player_pos.y = clamp(player_pos.y, 40.0, ARENA - 40.0)
	player_sprite.position = player_pos
	player_glow.position = player_pos
	player_shadow.position = player_pos + Vector2(0, 22)
	player_shadow.scale = Vector2(0.38, 0.38)
	player_shadow.visible = shadows_enabled()
	player_glow.scale = Vector2(0.9 + 0.08 * sin(run_time * 4.0), 0.9 + 0.08 * sin(run_time * 4.0))
	# time triggers
	if run_time >= 180.0 and not elite_done[0]:
		elite_done[0] = true
		spawn_elite_wave()
	if run_time >= 360.0 and not elite_done[1]:
		elite_done[1] = true
		spawn_elite_wave()
	if run_time >= boss_at and not boss_spawned:
		spawn_boss()
	if boss_dying:
		boss_death_t -= delta
		if boss_death_t <= 0.0:
			boss_dying = false
			end_run(true, "The Ember Matriarch falls. Dawn breaks over the ash field.")
			return
	if run_time >= run_limit:
		if boss_active:
			# surge: boss enrages instead of a silent timer kill
			end_run(false, "The swarm surge overwhelms the field.")
		else:
			end_run(false, "The swarm surge overwhelms the field.")
		return
	# spawning (v1.4: PORTAL ONLY — no random ring around the player).
	# Surge-ahead telegraph: when the timer is within 0.8 s of firing,
	# the portal glow surges, so the burst is telegraphed before it
	# emerges without serialising (and slowing) the spawn rate. During
	# a relocation warning, or an elite burst telegraph, the timer
	# holds; spawns resume at the new anchor once the warning ends.
	if portal_warn_t <= 0.0 and portal_burst_t <= 0.0:
		spawn_timer -= delta
		if spawn_timer <= 0.8 and portal_surge_t <= 0.0:
			portal_surge_t = 0.8
		if spawn_timer <= 0.0:
			spawn_timer = max(0.30, 0.95 - run_time * 0.0010)
			spawn_portal_batch()
	# weapons
	for id in weapon_timers.keys():
		weapon_timers[id] -= delta
	if weapons.has("bolt") and weapon_timers["bolt"] <= 0.0:
		weapon_timers["bolt"] = max(0.38, 0.55 - 0.03 * weapons["bolt"])
		fire_bolt()
	if weapons.has("frost") and weapon_timers["frost"] <= 0.0:
		weapon_timers["frost"] = max(0.6, 1.05 - 0.06 * weapons["frost"])
		fire_frost()
	if weapons.has("storm") and weapon_timers["storm"] <= 0.0:
		weapon_timers["storm"] = max(1.1, 1.9 - 0.12 * weapons["storm"])
		fire_storm()
	if weapons.has("nova") and weapon_timers["nova"] <= 0.0:
		weapon_timers["nova"] = max(1.9, 3.2 - 0.22 * weapons["nova"])
		fire_nova()
	if weapons.has("lance") and weapon_timers["lance"] <= 0.0:
		weapon_timers["lance"] = max(1.1, 2.0 - 0.15 * weapons["lance"])
		fire_lance()
	update_orbit(delta)
	update_enemies(delta)
	update_pbullets(delta)
	update_ebullets(delta)
	update_gems(delta)
	update_boss(delta)
	# level-ups (queue-safe: one panel at a time)
	while player_xp >= player_xp_next:
		player_xp -= player_xp_next
		player_level += 1
		player_xp_next = 10 + player_level * 7
		pending_levels += 1
	if pending_levels > 0 and state == State.RUN:
		pending_levels -= 1
		show_levelup()
	if player_hp <= 0.0:
		end_run(false, "The Ember Warden falls.")
		return
	refresh_hud_if_needed()

var _hud_acc := 0.0
func refresh_hud_if_needed() -> void:
	_hud_acc += 1.0
	# cheap: HUD text refresh already runs at 4 Hz from _process; bars update here
	if hp_bar:
		hp_bar.value = player_hp
	if xp_bar:
		xp_bar.value = float(player_xp)

func nearest_target(from: Vector2, max_dist := 900.0) -> Vector2:
	var best := Vector2.INF
	var bd := max_dist
	for e in enemies:
		if not e["active"]:
			continue
		var d := from.distance_to(e["pos"])
		if d < bd:
			bd = d
			best = e["pos"]
	if boss_active:
		var d := from.distance_to(boss_pos)
		if d < bd:
			bd = d
			best = boss_pos
	return best

func nearest_enemy_index(from: Vector2, max_dist := 900.0, exclude: Array = []) -> int:
	var bi := -1
	var bd := max_dist
	for i in range(enemies.size()):
		var e: Dictionary = enemies[i]
		if not e["active"] or exclude.has(i):
			continue
		var d := from.distance_to(e["pos"])
		if d < bd:
			bd = d
			bi = i
	return bi

func spawn_enemy_at(kind: String, pos: Vector2, elite := false) -> void:
	for ei in range(enemies.size()):
		var e: Dictionary = enemies[ei]
		if e["active"]:
			continue
		var st: Array = ENEMIES[kind]
		var hp_mult := 1.0 + run_time / 60.0 * 0.18
		if test_mode:
			hp_mult *= 0.6
		e["active"] = true
		e["kind"] = kind
		e["pos"] = pos
		e["max_hp"] = st[0] * hp_mult * (3.0 if elite else 1.0)
		e["hp"] = e["max_hp"]
		e["speed"] = st[1] * (1.0 + min(0.35, run_time / 600.0 * 0.35))
		e["radius"] = st[2]
		e["dmg"] = st[3]
		e["xp"] = st[4]
		e["scale"] = st[5] * (1.25 if elite else 1.0)
		e["elite"] = elite
		e["atk_cd"] = 0.0
		e["flash"] = 0.0
		e["orbit_cd"] = 0.0
		e["shoot_cd"] = rng.randf_range(0.5, 1.5)
		e["slow"] = 0.0
		e["slow_t"] = 0.0
		e["anim"] = 0.0
		e["frame"] = 0
		e["pose_hold"] = 0.0
		e["hurt_t"] = 0.0
		e["attack_t"] = 0.0
		e["dash_state"] = 0
		e["dash_t"] = 0.0
		e["dash_cd"] = rng.randf_range(1.0, 2.0)
		e["spawn_in"] = 0.4  # v1.4 emerge treatment: scale-up, no instant pop-in
		e["dash_dir"] = Vector2.ZERO
		if kind == "dasher":
			_dasher_spawns += 1
		var node: Sprite2D = e["node"]
		node.texture = frame_tex(kind, 0, elite)
		node.scale = Vector2(e["scale"], e["scale"])
		node.position = pos
		node.visible = true
		node.modulate = Color(1, 1, 1, 1)
		return

# v1.4: TEST-ONLY helper. Gameplay spawns must NEVER call this — normal-run
# spawns are portal-only (see spawn_portal_batch / spawn_portal_enemy).
# Remaining callers are labelled test harnesses (v12/v13 gate setup,
# death-check overwhelm stream) — not gameplay.
func ring_pos_around(center: Vector2, radius: float) -> Vector2:
	for attempt in range(8):
		var a := rng.randf_range(0.0, TAU)
		var p := center + Vector2(cos(a), sin(a)) * radius
		if p.x > 30.0 and p.x < ARENA - 30.0 and p.y > 30.0 and p.y < ARENA - 30.0:
			return p
	return Vector2(clamp(center.x + radius, 30.0, ARENA - 30.0), clamp(center.y, 30.0, ARENA - 30.0))

func pick_spawn_kind() -> String:
	# Kind selection stays weighted/time-gated (rng) — only LOCATION
	# was de-randomised in v1.4. Same gates as the old random spawner.
	var kinds := ["cinderling"]
	if run_time >= 60.0:
		kinds.append("spitter")
	if run_time >= 120.0:
		kinds.append("dasher")
	if run_time >= 150.0:
		kinds.append("brute")
	return kinds[rng.randi_range(0, kinds.size() - 1)]

func queue_portal_burst(kinds: Array, elite: bool) -> void:
	# Telegraph: the portal surges ~0.8 s BEFORE the burst emerges.
	_portal_burst_kinds = kinds
	_portal_burst_elite = elite
	portal_burst_t = 0.8
	portal_surge_t = 0.8

func spawn_portal_batch() -> void:
	# Normal batches emerge IMMEDIATELY at the portal (no serialising
	# delay — a delayed burst per batch nearly halved the spawn rate in
	# the first v1.4 short run: 54 kills vs the v1.3 band 85–93). The
	# telegraph for normal batches is the surge-ahead pulse: the portal
	# glow surges during the 0.8 s before the timer fires (see the spawn
	# section), and every enemy gets the scale-up emerge treatment.
	var batch := mini(1 + int(run_time / 90.0), 6)
	for i in range(batch):
		spawn_portal_enemy(pick_spawn_kind(), false)
	portal_surge_t = 0.3

func spawn_portal_enemy(kind: String, elite: bool) -> void:
	# Portal-determined location: within PORTAL_RADIUS of the current
	# anchor. The small in-portal offset is dispersal, not a random
	# spawn location — the anchor is the location.
	var pos := portal_pos + Vector2(rng.randf_range(-70.0, 70.0), rng.randf_range(-70.0, 70.0))
	pos.x = clamp(pos.x, 20.0, ARENA - 20.0)
	pos.y = clamp(pos.y, 20.0, ARENA - 20.0)
	spawn_enemy_at(kind, pos, elite)
	_portal_spawns += 1
	_portal_spawns_after_reloc += 1
	var d: float = pos.distance_to(portal_pos)
	_portal_max_dist = max(_portal_max_dist, d)
	if d > PORTAL_RADIUS:
		_portal_violations += 1
	if elite:
		_portal_elite_spawned = true

func portal_update(delta: float) -> void:
	# Swirl + surge glow (juice only: reads sim state, never writes it).
	if portal_surge_t > 0.0:
		portal_surge_t -= delta
	if portal_sprite != null:
		portal_sprite.rotation += delta * 0.6
		var surge: float = 0.25 if portal_surge_t > 0.0 else 0.0
		var s: float = 0.43 + 0.05 * sin(run_time * 3.0) + surge
		portal_sprite.scale = Vector2(s, s)
		portal_glow.scale = Vector2(1.6 + 0.3 * sin(run_time * 3.0) + surge * 2.0, 1.6 + 0.3 * sin(run_time * 3.0) + surge * 2.0)
	if portal_warn_t > 0.0:
		# Relocation warning: 3 s telegraph at the NEW anchor, portal
		# collapsed, spawns held. Anti-camp: the swarm's source moves on
		# a fixed schedule, so camping one corner never stays safe.
		portal_warn_t -= delta
		portal_warn_glow.scale = Vector2(1.2 + 0.4 * sin(run_time * 10.0), 1.2 + 0.4 * sin(run_time * 10.0))
		if portal_warn_t <= 0.0:
			portal_idx = (portal_idx + 1) % PORTAL_ANCHORS.size()
			portal_pos = PORTAL_ANCHORS[portal_idx]
			portal_sprite.position = portal_pos
			portal_sprite.visible = true
			portal_glow.position = portal_pos
			portal_glow.visible = true
			portal_ring.position = portal_pos
			portal_warn_glow.visible = false
			_portal_relocs += 1
			_portal_spawns_after_reloc = 0
			if test_mode:
				print("ASHEN_V14_RELOC idx=%d pos=%s" % [portal_idx, portal_pos])
			if _portal_elite_deferred:
				_portal_elite_deferred = false
				spawn_elite_wave()
			if _portal_boss_deferred:
				_portal_boss_deferred = false
				_spawn_boss_at_portal()
		return
	if run_time >= portal_next_reloc:
		portal_next_reloc += 120.0
		portal_warn_anchor = PORTAL_ANCHORS[(portal_idx + 1) % PORTAL_ANCHORS.size()]
		portal_warn_t = 3.0
		portal_sprite.visible = false
		portal_glow.visible = false
		portal_warn_glow.position = portal_warn_anchor
		portal_warn_glow.visible = true
		_portal_warns += 1
		if test_mode:
			print("ASHEN_V14_WARN next_idx=%d next_pos=%s" % [(portal_idx + 1) % PORTAL_ANCHORS.size(), portal_warn_anchor])
		return
	if portal_burst_t > 0.0:
		portal_burst_t -= delta
		if portal_burst_t <= 0.0:
			var kinds: Array = _portal_burst_kinds
			var elite: bool = _portal_burst_elite
			_portal_burst_kinds = []
			for kind in kinds:
				spawn_portal_enemy(str(kind), elite)

func spawn_elite_wave() -> void:
	if portal_warn_t > 0.0:
		# Deferred, not dropped and NOT counted yet: fires (and counts)
		# from the new anchor when the relocation warning ends (the
		# warning IS its telegraph). Counting here would double-count
		# the wave when the deferred re-call fires it.
		_portal_elite_deferred = true
		return
	elite_waves_fired += 1
	if test_mode:
		print("ASHEN_TEST_ELITE t=%.1f wave=%d" % [run_time, elite_waves_fired])
	var kinds: Array = []
	for i in range(3):
		var pool := ["cinderling", "brute", "spitter", "dasher"]
		kinds.append(pool[rng.randi_range(0, 3)])
	queue_portal_burst(kinds, true)
	if test_mode:
		print("ASHEN_V14_PORTAL_ELITE wave=%d anchor=%s" % [elite_waves_fired, portal_pos])
	play_sfx("boss", 0.8)
	add_trauma(0.35)

func spawn_boss() -> void:
	# Boss arrives via a large portal surge at boss time — never a
	# random ring around the player. If a relocation warning is active
	# the arrival defers to the new anchor (warning = telegraph).
	boss_spawned = true
	if portal_warn_t > 0.0:
		_portal_boss_deferred = true
		return
	_spawn_boss_at_portal()

func _spawn_boss_at_portal() -> void:
	boss_active = true
	boss_dying = false
	boss_enraged = false
	boss_death_t = 0.0
	boss_max_hp = 4000.0 * (0.45 if test_mode else 1.0)
	boss_hp = boss_max_hp
	boss_pos = portal_pos
	portal_surge_t = 1.2
	_portal_boss_spawned = true
	if test_mode:
		print("ASHEN_V14_PORTAL_BOSS anchor=%s" % [portal_pos])
	boss_sprite.visible = true
	boss_glow.visible = true
	boss_shadow.visible = shadows_enabled()
	boss_shadow.position = boss_pos + Vector2(0, 60)
	boss_shadow.scale = Vector2(1.05, 1.05)
	boss_sprite.texture = boss_frames[0]
	_boss_anim = 0.0
	_boss_frame = 0
	boss_sprite.position = boss_pos
	boss_glow.position = boss_pos
	boss_bar.visible = true
	boss_label.visible = true
	if test_mode:
		print("ASHEN_TEST_BOSS t=%.1f level=%d weapons=%s" % [run_time, player_level, weapons])
	boss_phase = 0.0
	boss_telegraph = 0.0
	boss_charge_t = 0.0
	boss_burst_t = 2.0
	boss_summon_t = 8.0
	play_sfx("boss")
	add_trauma(0.6)
	spawn_burst(boss_pos, Color(1, 0.5, 0.1, 1), 40, 260.0)

func _any_shadow_visible() -> bool:
	for sh in shadows:
		var s: Sprite2D = sh
		if s.visible:
			return true
	return false

func update_enemies(delta: float) -> void:
	# spatial hash (cell 64) for separation + bullet queries
	var grid := {}
	for i in range(enemies.size()):
		var e: Dictionary = enemies[i]
		if not e["active"]:
			continue
		var key := Vector2i(int(e["pos"].x / 64.0), int(e["pos"].y / 64.0))
		if not grid.has(key):
			grid[key] = []
		grid[key].append(i)
	_enemy_grid = grid
	for i in range(enemies.size()):
		var e: Dictionary = enemies[i]
		if not e["active"]:
			continue
		var node: Sprite2D = e["node"]
		if e["slow_t"] > 0.0:
			e["slow_t"] -= delta
		else:
			e["slow"] = 0.0
		if e["atk_cd"] > 0.0:
			e["atk_cd"] -= delta
		if e["orbit_cd"] > 0.0:
			e["orbit_cd"] -= delta
		if e["flash"] > 0.0:
			e["flash"] -= delta
			node.modulate = Color(2.5, 2.5, 2.5, 1.0) if e["flash"] > 0.05 else Color(1, 1, 1, 1)
		var to_player: Vector2 = player_pos - Vector2(e["pos"])
		var dist: float = to_player.length()
		var dir: Vector2 = to_player.normalized() if dist > 0.01 else Vector2.ZERO
		var spd: float = e["speed"] * (1.0 - float(e["slow"]))
		if e["kind"] == "dasher":
			# v1.2 charger: stalk, telegraphed windup (locked dir), dash.
			if int(e["dash_state"]) == 1:
				e["dash_t"] = float(e["dash_t"]) - delta
				if float(e["dash_t"]) <= 0.0:
					e["dash_state"] = 2
					e["dash_t"] = 0.35
					var atk: Texture2D = attack_tex("dasher", bool(e["elite"]))
					if atk != null:
						node.texture = atk
					_attack_frames += 1
			elif int(e["dash_state"]) == 2:
				e["pos"] = Vector2(e["pos"]) + Vector2(e["dash_dir"]) * 520.0 * delta
				e["dash_t"] = float(e["dash_t"]) - delta
				if float(e["dash_t"]) <= 0.0:
					e["dash_state"] = 0
					e["dash_cd"] = 3.0
			else:
				e["pos"] = Vector2(e["pos"]) + dir * spd * delta
				if float(e["dash_cd"]) > 0.0:
					e["dash_cd"] = float(e["dash_cd"]) - delta
				elif dist < 340.0:
					e["dash_state"] = 1
					e["dash_t"] = 0.6
					e["dash_dir"] = dir
					var tel: Texture2D = dasher_telegraph_gold_tex if bool(e["elite"]) else dasher_telegraph_tex
					if tel != null:
						node.texture = tel
					_dash_telegraphs += 1
		elif e["kind"] == "spitter":
			if dist > 300.0:
				e["pos"] += dir * spd * delta
			elif dist < 200.0:
				e["pos"] -= dir * spd * 0.8 * delta
			e["shoot_cd"] -= delta
			if e["shoot_cd"] <= 0.0 and dist < 460.0:
				e["shoot_cd"] = 2.4
				# attack pose: hold the lunge frame briefly (frame 3)
				e["pose_hold"] = 0.3
				e["frame"] = 3
				node.texture = frame_tex("spitter", 3, bool(e["elite"]))
				_attack_frames += 1
				spawn_ebullet(e["pos"], dir * 234.0, float(e["dmg"]) * 0.7)
		else:
			e["pos"] += dir * spd * delta
		# separation from neighbours (3x3 cells)
		var cell := Vector2i(int(e["pos"].x / 64.0), int(e["pos"].y / 64.0))
		for cx in range(cell.x - 1, cell.x + 2):
			for cy in range(cell.y - 1, cell.y + 2):
				var k := Vector2i(cx, cy)
				if not grid.has(k):
					continue
				for j in grid[k]:
					if j == i:
						continue
					var o: Dictionary = enemies[j]
					if not o["active"]:
						continue
					var dvec: Vector2 = Vector2(e["pos"]) - Vector2(o["pos"])
					var dd: float = dvec.length()
					var min_d := float(e["radius"]) + float(o["radius"])
					if dd > 0.01 and dd < min_d:
						e["pos"] += dvec.normalized() * (min_d - dd) * 0.4
		e["pos"].x = clamp(e["pos"].x, 20.0, ARENA - 20.0)
		e["pos"].y = clamp(e["pos"].y, 20.0, ARENA - 20.0)
		node.position = e["pos"]
		# v1.2 blob shadow follows the pooled node (never instantiated).
		var shn: Sprite2D = shadows[i]
		shn.position = Vector2(e["pos"]) + Vector2(0, float(e["radius"]) * 0.7)
		var shsc: float = float(e["scale"]) * 0.62
		shn.scale = Vector2(shsc, shsc)
		shn.visible = shadows_enabled()
		# v1.2 animation priority: hurt > dasher telegraph/dash > attack
		# > spitter pose-hold > walk cycle. Pose branches re-assign on
		# change only, so an interrupted pose resumes cleanly.
		if float(e["hurt_t"]) > 0.0:
			e["hurt_t"] = float(e["hurt_t"]) - delta
			var ht: Texture2D = hurt_tex(str(e["kind"]), bool(e["elite"]))
			if ht != null and node.texture != ht:
				node.texture = ht
				_enemy_swaps += 1
		elif str(e["kind"]) == "dasher" and int(e["dash_state"]) == 1:
			var tel2: Texture2D = dasher_telegraph_gold_tex if bool(e["elite"]) else dasher_telegraph_tex
			if tel2 != null and node.texture != tel2:
				node.texture = tel2
				_enemy_swaps += 1
		elif str(e["kind"]) == "dasher" and int(e["dash_state"]) == 2:
			var atk2: Texture2D = attack_tex("dasher", bool(e["elite"]))
			if atk2 != null and node.texture != atk2:
				node.texture = atk2
				_enemy_swaps += 1
		elif float(e["attack_t"]) > 0.0:
			e["attack_t"] = float(e["attack_t"]) - delta
			var at: Texture2D = attack_tex(str(e["kind"]), bool(e["elite"]))
			if at != null and node.texture != at:
				node.texture = at
				_enemy_swaps += 1
		elif float(e["pose_hold"]) > 0.0:
			e["pose_hold"] = float(e["pose_hold"]) - delta
			var ph: Texture2D = frame_tex("spitter", 3, bool(e["elite"]))
			if node.texture != ph:
				node.texture = ph
				_enemy_swaps += 1
		else:
			# v1.1 walk cycle: frame-driven, speed-tied; wobble secondary.
			var fps_e: float = clamp(float(e["speed"]) / 12.0, 5.0, 11.0)
			if e["kind"] == "spitter" and dist >= 200.0 and dist <= 300.0:
				fps_e = 2.0
			e["anim"] = float(e["anim"]) + delta * fps_e
			var nf := int(e["anim"]) % 4
			if nf != int(e["frame"]):
				e["frame"] = nf
				_enemy_swaps += 1
				node.texture = frame_tex(str(e["kind"]), nf, bool(e["elite"]))
		e["wob"] = float(e["wob"]) + delta * 6.0
		var bs: float = e["scale"]
		if float(e["spawn_in"]) > 0.0:
			e["spawn_in"] = float(e["spawn_in"]) - delta
			bs *= 1.0 - 0.8 * max(0.0, float(e["spawn_in"]) / 0.4)
		node.scale = Vector2(bs * (1.0 + 0.02 * sin(float(e["wob"]))), bs * (1.0 - 0.02 * sin(float(e["wob"]))))
		node.flip_h = dir.x < 0.0
		# contact damage (v1.2: chaser/brute flash their attack frame)
		if dist < float(e["radius"]) + 26.0 and e["atk_cd"] <= 0.0:
			e["atk_cd"] = 0.7
			if str(e["kind"]) in ["cinderling", "brute"]:
				e["attack_t"] = 0.25
				_attack_frames += 1
			damage_player(float(e["dmg"]), e["pos"])

var _enemy_grid := {}

func damage_player(amount: float, from_pos: Vector2) -> void:
	player_hp -= amount
	hurt_flash = 1.0
	add_trauma(0.35)
	play_sfx("hurt", rng.randf_range(0.9, 1.1))
	spawn_burst(player_pos, Color(1, 0.2, 0.1, 1), 10, 160.0)
	spawn_dmgnum(player_pos, amount, Color(1, 0.35, 0.25, 1))
	var away := (player_pos - from_pos).normalized()
	player_pos += away * 18.0

func damage_enemy(idx: int, amount: float, element := "ember", knock_dir := Vector2.ZERO, crit := false) -> void:
	var e: Dictionary = enemies[idx]
	if not e["active"]:
		return
	e["hp"] = float(e["hp"]) - amount
	e["flash"] = 0.12
	e["hurt_t"] = 0.15
	_hurt_frames += 1
	if element == "frost":
		e["slow"] = 0.5
		e["slow_t"] = 1.2
	if knock_dir.length() > 0.01:
		e["pos"] += knock_dir.normalized() * 10.0
	spawn_dmgnum(e["pos"], amount, Color(1, 0.8, 0.3, 1) if element == "ember" else Color(0.6, 0.85, 1, 1), crit)
	if e["hp"] <= 0.0:
		kill_enemy(idx)

func kill_enemy(idx: int) -> void:
	var e: Dictionary = enemies[idx]
	# v1.2 death treatment: drawn collapse pose + fade + burst + smoke.
	var last_tex: Texture2D = death_tex(str(e["kind"]), bool(e["elite"]))
	if last_tex == null:
		last_tex = e["node"].texture
	var last_pos: Vector2 = e["pos"]
	var last_scale: float = e["scale"]
	var last_flip: bool = e["node"].flip_h
	e["active"] = false
	e["node"].visible = false
	shadows[idx].visible = false
	_death_frames += 1
	if str(e["kind"]) == "dasher":
		_dasher_kills += 1
	# pooled death frame: hold the collapse pose, fading + shrinking
	for c in corpses:
		if c["active"]:
			continue
		c["active"] = true
		c["life"] = 0.45
		var cn: Sprite2D = c["node"]
		cn.texture = last_tex
		cn.position = last_pos
		cn.scale = Vector2(last_scale, last_scale)
		cn.flip_h = last_flip
		cn.modulate = Color(1, 1, 1, 1)
		cn.visible = true
		break
	kills += 1
	var gem_n := 5 if e["elite"] else int(e["xp"])
	for i in range(mini(gem_n, 5)):
		spawn_gem(e["pos"] + Vector2(rng.randf_range(-24, 24), rng.randf_range(-24, 24)), 1)
	spawn_burst(e["pos"], Color(1, 0.5, 0.1, 1), 14 if e["elite"] else 8, 200.0)
	spawn_smoke(e["pos"], 4)
	play_sfx("die", rng.randf_range(0.9, 1.2))
	if e["elite"]:
		add_trauma(0.3)
		hitstop = max(hitstop, 0.06)

func spawn_gem(pos: Vector2, value: int) -> void:
	for g in gems:
		if g["active"]:
			continue
		g["active"] = true
		g["pos"] = pos
		g["value"] = value
		g["age"] = 0.0
		var node: Sprite2D = g["node"]
		node.texture = tex(TEX["gem"])
		node.scale = Vector2(0.35, 0.35)
		node.position = pos
		node.visible = true
		return

func update_gems(delta: float) -> void:
	for g in gems:
		if not g["active"]:
			continue
		g["age"] = float(g["age"]) + delta
		var d := player_pos.distance_to(g["pos"])
		if d < magnet_radius or float(g["age"]) > 8.0:
			var dir: Vector2 = (player_pos - Vector2(g["pos"])).normalized()
			var pull := 420.0 * (1.0 - d / magnet_radius) + 140.0
			if float(g["age"]) > 8.0:
				pull = max(pull, 130.0)
			g["pos"] += dir * pull * delta
			g["node"].position = g["pos"]
		if d < 30.0:
			g["active"] = false
			g["node"].visible = false
			player_xp += int(g["value"])
			play_sfx("pickup", rng.randf_range(1.0, 1.4))
			spawn_burst(g["pos"], Color(1, 0.7, 0.2, 1), 3, 90.0)

# ================= weapons =================
var boss_atk_cd := 0.0
var boss_cycle := 0.0
var boss_flash := 0.0
var bonus_shards := 0

func add_trauma(amount: float) -> void:
	if bool(profile["settings"].get("shake", true)):
		trauma = min(1.0, trauma + amount)

func spawn_pbullet(pos: Vector2, vel: Vector2, dmg: float, pierce: int, element: String, radius := 14.0, life := 2.2) -> void:
	for b in pbullets:
		if b["active"]:
			continue
		b["active"] = true
		b["pos"] = pos
		b["vel"] = vel
		b["dmg"] = dmg
		b["pierce"] = pierce
		b["element"] = element
		b["life"] = life
		b["radius"] = radius
		b["hit"] = []
		var node: Sprite2D = b["node"]
		node.texture = tex(TEX["glow_b"]) if element == "frost" else (tex(TEX["glow_p"]) if element == "storm" else (tex(TEX["glow_w"]) if element == "lance" else tex(TEX["glow_o"])))
		node.scale = Vector2(radius / 64.0, radius / 64.0)
		node.position = pos
		node.visible = true
		return

func spawn_ebullet(pos: Vector2, vel: Vector2, dmg: float) -> void:
	for b in ebullets:
		if b["active"]:
			continue
		b["active"] = true
		b["pos"] = pos
		b["vel"] = vel
		b["dmg"] = dmg
		b["life"] = 4.0
		var node: Sprite2D = b["node"]
		node.texture = tex(TEX["glow_o"])
		node.scale = Vector2(0.28, 0.28)
		node.position = pos
		node.visible = true
		return

func fire_bolt() -> void:
	var tgt := nearest_target(player_pos, 900.0)
	if tgt == Vector2.INF:
		weapon_timers["bolt"] = 0.15
		return
	var lvl: int = weapons["bolt"]
	var count := 1 + (1 if lvl >= 3 else 0) + (1 if lvl >= 5 else 0)
	var dmg := (14.0 + 6.0 * lvl) * dmg_mult
	var pierce := 1 if lvl >= 4 else 0
	var base := (tgt - player_pos).normalized()
	for i in range(count):
		var ang := (float(i) - float(count - 1) / 2.0) * 0.14
		spawn_pbullet(player_pos, base.rotated(ang) * 540.0, dmg, pierce, "ember", 15.0)
	play_sfx("shoot", rng.randf_range(0.95, 1.05))

func fire_lance() -> void:
	# v1.2 weapon: Ember Lance — slow, piercing, long-range white-hot
	# lance(s). Single-target DPS below bolt, crowd DPS above: the trade
	# is pierce-everything + range, not raw damage.
	var tgt := nearest_target(player_pos, 1000.0)
	if tgt == Vector2.INF:
		weapon_timers["lance"] = 0.15
		return
	var lvl: int = weapons["lance"]
	var count := 1 + (1 if lvl >= 4 else 0)
	var dmg := (30.0 + 10.0 * lvl) * dmg_mult
	var base := (tgt - player_pos).normalized()
	for i in range(count):
		var ang := (float(i) - float(count - 1) / 2.0) * 0.12
		spawn_pbullet(player_pos, base.rotated(ang) * 720.0, dmg, 99, "lance", 18.0, 1.4)
		_lance_shots += 1
	play_sfx("shoot", rng.randf_range(0.85, 0.95))

func fire_frost() -> void:
	var tgt := nearest_target(player_pos, 800.0)
	if tgt == Vector2.INF:
		weapon_timers["frost"] = 0.15
		return
	var lvl: int = weapons["frost"]
	var count := 3 + lvl
	var dmg := (10.0 + 4.0 * lvl) * dmg_mult
	var base := (tgt - player_pos).normalized()
	for i in range(count):
		var ang := (float(i) - float(count - 1) / 2.0) * 0.16
		spawn_pbullet(player_pos, base.rotated(ang) * 400.0, dmg, 0, "frost", 13.0)
	play_sfx("shoot", 1.25)

func fire_storm() -> void:
	var lvl: int = weapons["storm"]
	var jumps := 2 + lvl
	var dmg := (16.0 + 6.0 * lvl) * dmg_mult
	var cur := player_pos
	var visited: Array = []
	for j in range(jumps):
		var bi := nearest_enemy_index(cur, 300.0, visited)
		if bi >= 0:
			visited.append(bi)
			var e: Dictionary = enemies[bi]
			spawn_lightning(cur, e["pos"])
			damage_enemy(bi, dmg, "storm", Vector2.ZERO)
			cur = e["pos"]
		elif boss_active and not visited.has(-1) and cur.distance_to(boss_pos) < 300.0:
			visited.append(-1)
			spawn_lightning(cur, boss_pos)
			damage_boss(dmg)
			cur = boss_pos
		else:
			break
	if visited.size() > 0:
		play_sfx("nova", 1.1)

func spawn_lightning(a: Vector2, b: Vector2) -> void:
	for i in range(6):
		var t := float(i) / 5.0
		var p := a.lerp(b, t) + Vector2(rng.randf_range(-14, 14), rng.randf_range(-14, 14))
		spawn_particle(p, Color(0.75, 0.5, 1, 1), 0.25, 0.22)

func fire_nova() -> void:
	var lvl: int = weapons["nova"]
	var radius := 210.0
	var dmg := (22.0 + 8.0 * lvl) * dmg_mult
	for i in range(enemies.size()):
		var e: Dictionary = enemies[i]
		if e["active"] and player_pos.distance_to(e["pos"]) < radius + float(e["radius"]):
			damage_enemy(i, dmg, "ember", (e["pos"] - player_pos).normalized())
	if boss_active and player_pos.distance_to(boss_pos) < radius + 70.0:
		damage_boss(dmg)
	for i in range(24):
		var a := float(i) / 24.0 * TAU
		spawn_particle(player_pos + Vector2(cos(a), sin(a)) * radius * 0.7, Color(1, 0.5, 0.1, 1), 0.45, 0.3)
	add_trauma(0.18)
	play_sfx("nova")

func update_orbit(delta: float) -> void:
	if not weapons.has("orbit"):
		return
	var lvl: int = weapons["orbit"]
	var blades := 1 + (1 if lvl >= 2 else 0) + (1 if lvl >= 4 else 0)
	var radius := 95.0 + 10.0 * lvl
	var dmg := (12.0 + 5.0 * lvl) * dmg_mult
	orbit_angle += delta * 2.8
	for b in range(blades):
		var ang := orbit_angle + float(b) * TAU / float(blades)
		var bp := player_pos + Vector2(cos(ang), sin(ang)) * radius
		if int(run_time * 60.0) % 6 == 0:
			spawn_particle(bp, Color(1, 0.6, 0.15, 1), 0.12, 0.18)
		for i in range(enemies.size()):
			var e: Dictionary = enemies[i]
			if e["active"] and float(e["orbit_cd"]) <= 0.0 and bp.distance_to(e["pos"]) < 36.0 + float(e["radius"]):
				e["orbit_cd"] = 0.5
				damage_enemy(i, dmg, "ember", (e["pos"] - player_pos).normalized())
		if boss_active and bp.distance_to(boss_pos) < 36.0 + 70.0 and boss_atk_cd <= 0.0:
			pass  # boss orbit damage handled below via cooldown-free tick guard
	# boss orbit hit: once per 0.5 s via a dedicated timer folded into boss_flash reuse is avoided;
	# use orbit damage on boss only when a blade is close and boss_cycle gate is open
	if boss_active:
		for b in range(blades):
			var ang2 := orbit_angle + float(b) * TAU / float(blades)
			var bp2 := player_pos + Vector2(cos(ang2), sin(ang2)) * radius
			if bp2.distance_to(boss_pos) < 100.0:
				# throttle: only damage if at least 0.5 s since last orbit tick
				if _orbit_boss_cd <= 0.0:
					_orbit_boss_cd = 0.5
					damage_boss(dmg)
				break
	if _orbit_boss_cd > 0.0:
		_orbit_boss_cd -= delta

var _orbit_boss_cd := 0.0

func update_pbullets(delta: float) -> void:
	for b in pbullets:
		if not b["active"]:
			continue
		b["life"] = float(b["life"]) - delta
		if b["life"] <= 0.0:
			b["active"] = false
			b["node"].visible = false
			continue
		b["pos"] = Vector2(b["pos"]) + Vector2(b["vel"]) * delta
		var p: Vector2 = b["pos"]
		if p.x < 0.0 or p.x > ARENA or p.y < 0.0 or p.y > ARENA:
			b["active"] = false
			b["node"].visible = false
			continue
		b["node"].position = p
		var hit_something := false
		var cell := Vector2i(int(p.x / 64.0), int(p.y / 64.0))
		for cx in range(cell.x - 1, cell.x + 2):
			for cy in range(cell.y - 1, cell.y + 2):
				var k := Vector2i(cx, cy)
				if not _enemy_grid.has(k):
					continue
				for idx in _enemy_grid[k]:
					if b["hit"].has(idx):
						continue
					var e: Dictionary = enemies[idx]
					if not e["active"]:
						continue
					if p.distance_to(e["pos"]) < float(b["radius"]) + float(e["radius"]):
						b["hit"].append(idx)
						var kd: Vector2 = (Vector2(e["pos"]) - player_pos).normalized() if b["element"] != "storm" else Vector2.ZERO
						# v1.2 juice pick: crit numbers (10%, x1.5, gold).
						var is_crit := rng.randf() < 0.10
						var c_dmg: float = float(b["dmg"]) * (1.5 if is_crit else 1.0)
						if is_crit:
							_crits += 1
						damage_enemy(idx, c_dmg, str(b["element"]), kd, is_crit)
						play_sfx("hit", rng.randf_range(0.9, 1.1))
						if int(b["pierce"]) <= 0:
							hit_something = true
						else:
							b["pierce"] = int(b["pierce"]) - 1
		if boss_active and not b["hit"].has(-1) and p.distance_to(boss_pos) < float(b["radius"]) + 70.0:
			b["hit"].append(-1)
			damage_boss(float(b["dmg"]))
			if int(b["pierce"]) <= 0:
				hit_something = true
			else:
				b["pierce"] = int(b["pierce"]) - 1
		if hit_something:
			b["active"] = false
			b["node"].visible = false

func update_ebullets(delta: float) -> void:
	for b in ebullets:
		if not b["active"]:
			continue
		b["life"] = float(b["life"]) - delta
		if b["life"] <= 0.0:
			b["active"] = false
			b["node"].visible = false
			continue
		b["pos"] = Vector2(b["pos"]) + Vector2(b["vel"]) * delta
		b["node"].position = b["pos"]
		if b["pos"].distance_to(player_pos) < 26.0:
			b["active"] = false
			b["node"].visible = false
			damage_player(float(b["dmg"]), b["pos"])

func damage_boss(amount: float) -> void:
	if not boss_active:
		return
	boss_hp -= amount
	if boss_hp > 0.0 and boss_hp < boss_max_hp * 0.5:
		trigger_boss_enrage()
	boss_flash = 0.12
	spawn_dmgnum(boss_pos + Vector2(rng.randf_range(-30, 30), -60), amount, Color(1, 0.6, 0.2, 1))
	spawn_burst(boss_pos, Color(1, 0.5, 0.1, 1), 4, 150.0)
	if boss_hp <= 0.0:
		boss_active = false
		boss_dying = true
		boss_death_t = 0.6
		boss_shadow.visible = false
		boss_sprite.texture = boss_death_tex
		boss_glow.visible = true
		spawn_burst(boss_pos, Color(1, 0.5, 0.1, 1), 60, 320.0)
		spawn_smoke(boss_pos, 20)
		add_trauma(1.0)
		hitstop = 0.09
		kills += 1
		# victory fires from update_run once the death pose has played 0.6 s

func trigger_boss_enrage() -> void:
	# v1.3: below 50% HP the Matriarch enrages — aura flares, attack
	# cadence quickens, but telegraph/charge durations NEVER shorten
	# (cadence between attacks speeds up, not the readable windup).
	if boss_enraged or not boss_active:
		return
	boss_enraged = true
	print("ASHEN_V13_ENRAGE hp=%.1f max=%.1f" % [boss_hp, boss_max_hp])
	spawn_burst(boss_pos, Color(1.0, 0.4, 0.1, 1.0), 30, 260.0)
	add_trauma(0.4)

func update_boss(delta: float) -> void:
	if not boss_active:
		return
	if boss_flash > 0.0:
		boss_flash -= delta
		boss_sprite.modulate = Color(2.5, 2.5, 2.5, 1.0) if boss_flash > 0.05 else Color(1, 1, 1, 1)
	if boss_atk_cd > 0.0:
		boss_atk_cd -= delta
	boss_cycle += delta
	if boss_telegraph > 0.0:
		boss_telegraph -= delta
		boss_sprite.modulate = Color(1.6, 0.4, 0.3, 1.0)
		boss_sprite.texture = boss_telegraph_tex
		if boss_telegraph <= 0.0:
			boss_charge_t = 0.7
			play_sfx("boss", 0.6)
	elif boss_charge_t > 0.0:
		boss_charge_t -= delta
		boss_pos += boss_charge_dir * 578.0 * delta
		_boss_anim += delta * 16.0
		var cf := int(_boss_anim) % 4
		if cf != _boss_frame:
			_boss_frame = cf
			boss_sprite.texture = boss_frames[cf]
	else:
		# surge enrage (last 30 s) still exists; v1.3 HP enrage is separate
		# and strictly slower than the surge so the two never stack up.
		if not boss_enraged and boss_hp < boss_max_hp * 0.5:
			trigger_boss_enrage()
		var surge := run_time > run_limit - 30.0
		var spd := 128.0 if surge else (115.0 if boss_enraged else 78.0)
		var dir := (player_pos - boss_pos).normalized()
		boss_pos += dir * spd * delta
		_boss_anim += delta * clamp(spd / 12.0, 5.0, 9.0)
		var bf := int(_boss_anim) % 4
		if bf != _boss_frame:
			_boss_frame = bf
			boss_sprite.texture = boss_frames[bf]
		if boss_cycle > (5.0 if boss_enraged else 7.0):
			boss_cycle = 0.0
			boss_telegraph = 0.8
			boss_charge_dir = dir
	boss_burst_t -= delta
	if boss_burst_t <= 0.0:
		boss_burst_t = 2.8 if boss_enraged else 4.0
		for i in range(14):
			var a := float(i) / 14.0 * TAU
			spawn_ebullet(boss_pos, Vector2(cos(a), sin(a)) * 175.0, 14.0)
		play_sfx("nova", 0.8)
	boss_summon_t -= delta
	if boss_summon_t <= 0.0:
		boss_summon_t = 10.0 if boss_enraged else 15.0
		for i in range(4):
			# v1.4 EXCEPTION (documented, not a player-ring spawn):
			# boss-summoned cinderlings appear around the BOSS (boss-local,
			# +-90 px), because the boss is summoning them — they are not
			# ambient spawns and never use a random ring around the player.
			spawn_enemy_at("cinderling", boss_pos + Vector2(rng.randf_range(-90, 90), rng.randf_range(-90, 90)), false)
	boss_pos.x = clamp(boss_pos.x, 40.0, ARENA - 40.0)
	boss_pos.y = clamp(boss_pos.y, 40.0, ARENA - 40.0)
	boss_sprite.position = boss_pos
	boss_glow.position = boss_pos
	boss_shadow.position = boss_pos + Vector2(0, 60)
	boss_shadow.visible = shadows_enabled()
	var glow_base := 3.6 if boss_enraged else 2.6
	boss_glow.scale = Vector2(glow_base + 0.15 * sin(run_time * 5.0), glow_base + 0.15 * sin(run_time * 5.0))
	boss_glow.modulate = Color(1.6, 0.7, 0.3, 1.0) if boss_enraged else Color(1.0, 1.0, 1.0, 1.0)
	if boss_pos.distance_to(player_pos) < 80.0 and boss_atk_cd <= 0.0:
		boss_atk_cd = 0.8
		damage_player(25.0, boss_pos)
	refresh_hud()

# ================= fx (cosmetic only) =================
func spawn_particle(pos: Vector2, color: Color, life: float, scale_v: float) -> void:
	for p in parts:
		if p["active"]:
			continue
		p["active"] = true
		p["pos"] = pos
		var a := rng.randf_range(0.0, TAU)
		var sp := rng.randf_range(40.0, 180.0)
		p["vel"] = Vector2(cos(a), sin(a)) * sp
		p["life"] = life
		p["max"] = life
		p["scale"] = scale_v
		var node: Sprite2D = p["node"]
		node.texture = tex(TEX["glow_w"])
		node.modulate = color
		node.position = pos
		node.visible = true
		return

func spawn_burst(pos: Vector2, color: Color, n: int, speed: float) -> void:
	var budget := n if not quality_mobile else int(n * 0.7)
	for i in range(budget):
		spawn_particle(pos, color, rng.randf_range(0.3, 0.65), rng.randf_range(0.15, 0.35))

func spawn_smoke(pos: Vector2, n: int) -> void:
	for i in range(n):
		for s in smoke:
			if s["active"]:
				continue
			s["active"] = true
			s["pos"] = pos + Vector2(rng.randf_range(-16, 16), rng.randf_range(-16, 16))
			s["vel"] = Vector2(rng.randf_range(-20, 20), rng.randf_range(-50, -10))
			s["life"] = rng.randf_range(0.7, 1.3)
			s["max"] = float(s["life"])
			s["scale"] = rng.randf_range(0.3, 0.6)
			var node: Sprite2D = s["node"]
			node.texture = tex(TEX["glow_w"])
			node.modulate = Color(0.35, 0.32, 0.30, 0.5)
			node.position = s["pos"]
			node.visible = true
			break

func spawn_dmgnum(pos: Vector2, amount: float, color: Color, crit := false) -> void:
	if not bool(profile["settings"].get("dmgnums", true)):
		return
	for d in dmgnums:
		if d["active"]:
			continue
		d["active"] = true
		d["pos"] = pos + Vector2(rng.randf_range(-12, 12), rng.randf_range(-8, 8))
		d["life"] = 0.7
		var node: Label = d["node"]
		if crit:
			node.text = str(int(amount)) + "!"
			node.add_theme_font_size_override("font_size", 30)
			node.add_theme_color_override("font_color", Color(1, 0.85, 0.3, 1))
		else:
			node.text = str(int(amount))
			node.add_theme_font_size_override("font_size", 22)
			node.add_theme_color_override("font_color", color)
		node.position = d["pos"]
		node.visible = true
		return

func update_fx(delta: float) -> void:
	for c in corpses:
		if not c["active"]:
			continue
		c["life"] = float(c["life"]) - delta
		if c["life"] <= 0.0:
			c["active"] = false
			c["node"].visible = false
			continue
		var cn: Sprite2D = c["node"]
		var f0 := float(c["life"]) / 0.45
		cn.modulate.a = f0
		cn.scale = cn.scale * (1.0 - 0.4 * delta)
	for p in parts:
		if not p["active"]:
			continue
		p["life"] = float(p["life"]) - delta
		if p["life"] <= 0.0:
			p["active"] = false
			p["node"].visible = false
			continue
		p["pos"] = Vector2(p["pos"]) + Vector2(p["vel"]) * delta
		p["vel"] = Vector2(p["vel"]) * (1.0 - 2.0 * delta)
		var node: Sprite2D = p["node"]
		node.position = p["pos"]
		var f := float(p["life"]) / float(p["max"])
		node.scale = Vector2(float(p["scale"]) * f, float(p["scale"]) * f)
		node.modulate.a = f
	for s in smoke:
		if not s["active"]:
			continue
		s["life"] = float(s["life"]) - delta
		if s["life"] <= 0.0:
			s["active"] = false
			s["node"].visible = false
			continue
		s["pos"] = Vector2(s["pos"]) + Vector2(s["vel"]) * delta
		var node2: Sprite2D = s["node"]
		node2.position = s["pos"]
		var f2 := float(s["life"]) / float(s["max"])
		node2.scale = Vector2(float(s["scale"]) * (1.6 - f2), float(s["scale"]) * (1.6 - f2))
		node2.modulate.a = f2 * 0.5
	for d in dmgnums:
		if not d["active"]:
			continue
		d["life"] = float(d["life"]) - delta
		if d["life"] <= 0.0:
			d["active"] = false
			d["node"].visible = false
			continue
		d["pos"] = Vector2(d["pos"]) + Vector2(0, -46.0) * delta
		var node3: Label = d["node"]
		node3.position = d["pos"]
		node3.modulate.a = clamp(float(d["life"]) / 0.7, 0.0, 1.0)

func update_camera(delta: float) -> void:
	if cam == null:
		return
	var off := Vector2.ZERO
	if trauma > 0.0 and bool(profile["settings"].get("shake", true)):
		var m := trauma * trauma * 20.0
		off = Vector2(rng.randf_range(-m, m), rng.randf_range(-m, m))
	var vp := get_viewport().get_visible_rect().size
	var half := vp / cam.zoom / 2.0
	var cx := player_pos.x + off.x
	var cy := player_pos.y + off.y
	if half.x < ARENA / 2.0:
		cx = clamp(cx, half.x, ARENA - half.x)
	else:
		cx = ARENA / 2.0
	if half.y < ARENA / 2.0:
		cy = clamp(cy, half.y, ARENA - half.y)
	else:
		cy = ARENA / 2.0
	cam.position = Vector2(cx, cy)

# ================= level-up / forge / settings =================
func find_by_name(node: Node, nm: String) -> Node:
	if node.name == nm:
		return node
	for c in node.get_children():
		var r := find_by_name(c, nm)
		if r != null:
			return r
	return null

func choice_icon(c: Dictionary) -> Array:
	# [texture, modulate]: weapons get their own icon; passives/heal/
	# shards get the generic emblem tinted per kind. Icons are the 3
	# preloaded TextureRects created in build_ui (pooled UI, not spawned).
	if c["kind"] == "weapon" and weapon_icons.has(c["id"]):
		return [weapon_icons[c["id"]], Color(1, 1, 1, 1)]
	var tint := Color(1, 1, 1, 1)
	if c["id"] == "heart" or c["kind"] == "heal":
		tint = Color(1, 0.45, 0.4, 1)
	elif c["id"] == "magnet" or c["kind"] == "shards":
		tint = Color(1, 0.85, 0.3, 1)
	elif c["id"] == "core":
		tint = Color(1, 0.6, 0.2, 1)
	elif c["id"] == "spark":
		tint = Color(0.5, 1, 0.6, 1)
	return [emblem_tex, tint]

func show_levelup() -> void:
	state = State.LEVELUP
	build_choices()
	if test_mode:
		# headless test has no one to tap a card: take the first offer.
		if level_choices.size() > 0:
			apply_choice(level_choices[0])
		levelup_panel.visible = false
		state = State.RUN
		if pending_levels > 0:
			pending_levels -= 1
			show_levelup()
		return
	for i in range(3):
		if i < level_choices.size():
			var c: Dictionary = level_choices[i]
			levelup_buttons[i].text = "%s\n%s" % [c["title"], c["desc"]]
			var icpair: Array = choice_icon(c)
			var ict: TextureRect = levelup_icons[i]
			ict.texture = icpair[0]
			ict.modulate = icpair[1]
		else:
			levelup_buttons[i].text = "—"
			var ict2: TextureRect = levelup_icons[i]
			ict2.texture = null
	var rr := find_by_name(levelup_panel, "RerollBtn") as Button
	if rr != null:
		rr.text = "Reroll (free left: %d)" % free_rerolls
		rr.disabled = free_rerolls <= 0
	levelup_panel.visible = true
	play_sfx("levelup")

func build_choices() -> void:
	var pool: Array = []
	var wnames := {"bolt": "Ember Bolt", "frost": "Frost Shard", "storm": "Storm Arc", "orbit": "Cinder Orbit", "nova": "Ember Nova", "lance": "Ember Lance"}
	for id in wnames.keys():
		if not weapons.has(id):
			pool.append({"kind": "weapon", "id": id, "title": "NEW: " + wnames[id], "desc": "Adds a new auto-weapon."})
		elif int(weapons[id]) < 5:
			pool.append({"kind": "weapon", "id": id, "title": wnames[id] + " Lv %d → %d" % [int(weapons[id]), int(weapons[id]) + 1], "desc": "Stronger, faster, more."})
	var pnames := {"speed": "Swift Boots", "heart": "Ember Heart", "magnet": "Magnet Charm", "core": "Sharpened Core", "spark": "Vital Spark"}
	var pdescs := {"speed": "+20 move speed.", "heart": "+20 max HP, heal 20.", "magnet": "+40 pickup radius.", "core": "+12% damage.", "spark": "+0.7 HP regen / s."}
	for id in pnames.keys():
		if int(passives[id]) < 5:
			pool.append({"kind": "passive", "id": id, "title": pnames[id] + " Lv %d → %d" % [int(passives[id]), int(passives[id]) + 1], "desc": pdescs[id]})
	# shuffle (salted run rng)
	for i in range(pool.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = pool[i]
		pool[i] = pool[j]
		pool[j] = tmp
	_last_pool = []
	for pc in pool:
		_last_pool.append(pc["id"])
	level_choices = []
	for i in range(mini(3, pool.size())):
		level_choices.append(pool[i])
	_last_offers = []
	for lc in level_choices:
		_last_offers.append(lc["id"])
	while level_choices.size() < 3:
		if level_choices.size() % 2 == 0:
			level_choices.append({"kind": "heal", "id": "", "title": "Ember Feast", "desc": "Heal 50 HP now."})
		else:
			level_choices.append({"kind": "shards", "id": "", "title": "Shard Hoard", "desc": "+25 shards at run end."})

func _on_level_choice(i: int) -> void:
	if i >= level_choices.size():
		return
	apply_choice(level_choices[i])
	play_sfx("click")
	if pending_levels > 0:
		pending_levels -= 1
		show_levelup()
	else:
		levelup_panel.visible = false
		state = State.RUN
		refresh_hud()

func _on_reroll() -> void:
	if free_rerolls <= 0:
		return
	free_rerolls -= 1
	show_levelup()

func apply_choice(c: Dictionary) -> void:
	if c["kind"] == "weapon":
		var id: String = c["id"]
		if weapons.has(id):
			weapons[id] = int(weapons[id]) + 1
		else:
			weapons[id] = 1
			weapon_timers[id] = 0.0
	elif c["kind"] == "passive":
		var id2: String = c["id"]
		passives[id2] = int(passives[id2]) + 1
		if id2 == "speed":
			player_speed += 20.0
		elif id2 == "heart":
			player_max_hp += 20.0
			player_hp = min(player_max_hp, player_hp + 20.0)
		elif id2 == "magnet":
			magnet_radius += 40.0
		elif id2 == "core":
			dmg_mult += 0.12
		elif id2 == "spark":
			regen += 0.7
	elif c["kind"] == "heal":
		player_hp = min(player_max_hp, player_hp + 50.0)
	elif c["kind"] == "shards":
		bonus_shards += 25

func show_forge() -> void:
	hide_all_panels()
	forge_panel.visible = true
	refresh_forge()

func refresh_forge() -> void:
	forge_shards.text = "Shards: %d" % int(profile["shards"])
	var names := {"hp": "Ember Heart", "dmg": "Sharpened Core", "speed": "Swift Boots", "magnet": "Magnet Charm"}
	var descs := {"hp": "+10% HP", "dmg": "+8% damage", "speed": "+5% speed", "magnet": "+15% pickup"}
	var costs := [20, 45, 80, 130, 200]
	for id in forge_rows.keys():
		var lvl: int = int(profile["meta"][id])
		var row: Dictionary = forge_rows[id]
		var lab: Label = row["label"]
		var btn: Button = row["button"]
		if lvl >= 5:
			lab.text = "%s — MAX (%s)" % [names[id], descs[id]]
			btn.text = "MAX"
			btn.disabled = true
		else:
			lab.text = "%s Lv %d/5 — %s (cost %d)" % [names[id], lvl, descs[id], costs[lvl]]
			btn.text = "BUY %d" % costs[lvl]
			btn.disabled = int(profile["shards"]) < costs[lvl]

func _on_forge_buy(id: String) -> void:
	var costs := [20, 45, 80, 130, 200]
	var lvl: int = int(profile["meta"][id])
	if lvl >= 5:
		return
	if int(profile["shards"]) < costs[lvl]:
		return
	profile["shards"] = int(profile["shards"]) - costs[lvl]
	profile["meta"][id] = lvl + 1
	save_profile()
	play_sfx("click")
	refresh_forge()

func show_settings() -> void:
	hide_all_panels()
	settings_panel.visible = true
	refresh_settings_labels()

func refresh_settings_labels() -> void:
	var snd := find_by_name(settings_panel, "SndBtn") as Button
	if snd != null:
		snd.text = "Sound: %s" % ("ON" if bool(profile["settings"].get("sound", true)) else "OFF")
	var shk := find_by_name(settings_panel, "ShkBtn") as Button
	if shk != null:
		shk.text = "Shake: %s" % ("ON" if bool(profile["settings"].get("shake", true)) else "OFF")
	var q := find_by_name(settings_panel, "QBtn") as Button
	if q != null:
		q.text = "Quality: %s" % str(profile["settings"].get("quality", "auto")).to_upper()
	var dm := find_by_name(settings_panel, "DmgBtn") as Button
	if dm != null:
		dm.text = "Damage numbers: %s" % ("ON" if bool(profile["settings"].get("dmgnums", true)) else "OFF")
	var sd := find_by_name(settings_panel, "ShdBtn") as Button
	if sd != null:
		sd.text = "Shadows: %s" % ("ON" if shadows_enabled() else "OFF")

func shadows_enabled() -> bool:
	return bool(profile["settings"].get("shadows", true))

func _on_toggle_shadows() -> void:
	profile["settings"]["shadows"] = not shadows_enabled()
	save_profile()
	refresh_settings_labels()

func _on_toggle_sound() -> void:
	profile["settings"]["sound"] = not bool(profile["settings"].get("sound", true))
	save_profile()
	play_sfx("click")
	refresh_settings_labels()

func _on_toggle_shake() -> void:
	profile["settings"]["shake"] = not bool(profile["settings"].get("shake", true))
	save_profile()
	refresh_settings_labels()

func _on_toggle_dmgnums() -> void:
	profile["settings"]["dmgnums"] = not bool(profile["settings"].get("dmgnums", true))
	save_profile()
	refresh_settings_labels()

func _on_cycle_quality() -> void:
	var cur := str(profile["settings"].get("quality", "auto"))
	var nxt := "mobile" if cur == "auto" else ("desktop" if cur == "mobile" else "auto")
	profile["settings"]["quality"] = nxt
	quality_mobile = (OS.get_name() == "Android" or OS.get_name() == "iOS") if nxt == "auto" else (nxt == "mobile")
	save_profile()
	refresh_settings_labels()
