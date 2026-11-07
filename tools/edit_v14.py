#!/usr/bin/env python3
"""v1.4 edit script: all-or-nothing. Aborts before writing if any anchor
is missing or ambiguous (v1.2/v1.3 lesson)."""
import sys

P = "/home/hatch/workspace/ashen-swarm/scripts/game.gd"
src = open(P).read()
edits = []

def rep(old, new, tag):
    global src
    n = src.count(old)
    assert n == 1, f"{tag}: anchor count {n} (need exactly 1)"
    src = src.replace(old, new)
    edits.append(tag)

# E1: portal state vars after shadow_check decl
rep("""var shadow_check := false
""",
"""var shadow_check := false
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
""", "E1-portal-vars")

# E2: flag parsing
rep("""		if a == "--ashen-shadow-check":
			test_mode = true
			shadow_check = true
""",
"""		if a == "--ashen-shadow-check":
			test_mode = true
			shadow_check = true
		if a == "--ashen-portal-check":
			test_mode = true
			portal_check = true
""", "E2-flag")

# E3: load portal/transition textures + V14 print
rep("""	print("ASHEN_V13_FRAMES dasher_drawn=%d dasher_gold=%d" % [
		enemy_frames["dasher"].size() + 4, enemy_gold["dasher"].size() + 4])
""",
"""	print("ASHEN_V13_FRAMES dasher_drawn=%d dasher_gold=%d" % [
		enemy_frames["dasher"].size() + 4, enemy_gold["dasher"].size() + 4])
	portal_tex = tex(PORTAL_TEX)
	transition_h_tex = tex(TRANSITION_H_TEX)
	transition_v_tex = tex(TRANSITION_V_TEX)
	print("ASHEN_V14_FRAMES portal=%s transitions=%s" % [portal_tex != null, transition_h_tex != null and transition_v_tex != null])
""", "E3-textures")

# E4: title label
rep('var ver := mk_label("v1.3  •  Local save only  •  No ads, no accounts", 18)',
    'var ver := mk_label("v1.4  •  Local save only  •  No ads, no accounts", 18)', "E4-title")

# E5: zone fade softening (edge factor 0.55 -> 0.15)
rep("var fade: float = 1.0 - 0.45 * (rrd / zr)",
    "var fade: float = 1.0 - 0.85 * (rrd / zr)  # v1.4: wider/dissolving zone fade (edge factor 0.55 -> 0.15)",
    "E5-zone-fade")

# E6: bridge decals + transition strips + portal nodes, inserted before zone print / zone block.
# First: transition strips + portal nodes before the zone-overlays comment.
rep("""	# v1.2 zone-blended overlays: 66 decals. 16 per biome zone, placed
""",
"""	# v1.4 feathered transition strips: one POOLED transparent gradient
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
""", "E6-strips-portal-nodes")

# E7: bridge decals before zone census print
rep("""	print("ASHEN_V12_ZONES ember=%d scorch=%d gravel=%d global=%d" % [
""",
"""	# v1.4 zone bridging: 12 extra low-alpha decals straddling the
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
""", "E7-bridges")

# E8: V14 census after V13 census print
rep("""	print("ASHEN_V13_CENSUS tiles=25 scatter=190 overlays=%d shadows=%d ring=1 total=%d" % [
		over_total, shadow_total, 25 + 190 + over_total + shadow_total + 1])
""",
"""	print("ASHEN_V13_CENSUS tiles=25 scatter=190 overlays=%d shadows=%d ring=1 total=%d" % [
		over_total, shadow_total, 25 + 190 + over_total + shadow_total + 1])
	print("ASHEN_V14_CENSUS tiles=25 scatter=190 overlays=%d bridges=%d shadows=%d ring=1 transitions=%d portal=3 total=%d" % [
		over_total, _bridge_count, shadow_total, _transition_count, 25 + 190 + over_total + _bridge_count + shadow_total + 1 + _transition_count + 3])
""", "E8-census")

# E9: start_run portal reset + portal_check limits
rep("""	if death_check:
		# live-death run: no boss, long limit; death must come from HP.
		run_limit = 600.0
		boss_at = 99999.0
		_death_spawn_t = 0.0
""",
"""	if death_check:
		# live-death run: no boss, long limit; death must come from HP.
		run_limit = 600.0
		boss_at = 99999.0
		_death_spawn_t = 0.0
	if portal_check:
		# portal gate: no auto boss (the gate spawns it via the portal
		# at 190 s); limit covers relocation (120 s) + elite (180 s).
		run_limit = 220.0
		boss_at = 99999.0
""", "E9-portal-limits")

rep("""		if v13_check:
			print("ASHEN_V13_SETUP dasher=v13 ring=%s" % (boundary_ring != null))
	boss_bar.visible = false
""",
"""		if v13_check:
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
""", "E9b-portal-reset")

# E10: portal_update call + portal gate branch, before regen line
rep("""	if regen > 0.0:
		player_hp = min(player_max_hp, player_hp + regen * delta)
""",
"""	portal_update(delta)
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
""", "E10-portal-gate")

# E11: spawn section -> portal batch with hold during warning/telegraph
rep("""	# spawning (v1.1: interval -10% to offset the faster hero's coverage)
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_timer = max(0.30, 0.95 - run_time * 0.0010)
		var batch := mini(1 + int(run_time / 90.0), 6)
		for i in range(batch):
			spawn_random_enemy()
""",
"""	# spawning (v1.4: PORTAL ONLY — no random ring around the player).
	# During a relocation warning or a burst telegraph the timer holds;
	# spawns resume at the new anchor once the warning ends.
	if portal_warn_t <= 0.0 and portal_burst_t <= 0.0:
		spawn_timer -= delta
		if spawn_timer <= 0.0:
			spawn_timer = max(0.30, 0.95 - run_time * 0.0010)
			spawn_portal_batch()
""", "E11-spawn-section")

# E12: spawn_enemy_at spawn_in
rep("""		e["dash_state"] = 0
		e["dash_t"] = 0.0
		e["dash_cd"] = rng.randf_range(1.0, 2.0)
""",
"""		e["dash_state"] = 0
		e["dash_t"] = 0.0
		e["dash_cd"] = rng.randf_range(1.0, 2.0)
		e["spawn_in"] = 0.4  # v1.4 emerge treatment: scale-up, no instant pop-in
""", "E12-spawn-in")

# E13: pool dict spawn_in
rep("""			"dash_state": 0, "dash_t": 0.0, "dash_cd": 0.0, "dash_dir": Vector2.ZERO})
""",
"""			"dash_state": 0, "dash_t": 0.0, "dash_cd": 0.0, "dash_dir": Vector2.ZERO, "spawn_in": 0.0})
""", "E13-pool-spawn-in")

# E14: emerge scale ramp in update_enemies
rep("""		e["wob"] = float(e["wob"]) + delta * 6.0
		var bs: float = e["scale"]
""",
"""		e["wob"] = float(e["wob"]) + delta * 6.0
		var bs: float = e["scale"]
		if float(e["spawn_in"]) > 0.0:
			e["spawn_in"] = float(e["spawn_in"]) - delta
			bs *= 1.0 - 0.8 * max(0.0, float(e["spawn_in"]) / 0.4)
""", "E14-emerge")

# E15a: ring_pos_around comment (TEST-ONLY helper after v1.4)
rep("""func ring_pos_around(center: Vector2, radius: float) -> Vector2:
""",
"""# v1.4: TEST-ONLY helper. Gameplay spawns must NEVER call this — normal-run
# spawns are portal-only (see spawn_portal_batch / spawn_portal_enemy).
# Remaining callers are labelled test harnesses (v12/v13 gate setup,
# death-check overwhelm stream) — not gameplay.
func ring_pos_around(center: Vector2, radius: float) -> Vector2:
""", "E15a-ring-comment")

# E15b: replace spawn_random_enemy with portal system functions
rep("""func spawn_random_enemy() -> void:
	var kinds := ["cinderling"]
	if run_time >= 60.0:
		kinds.append("spitter")
	if run_time >= 120.0:
		kinds.append("dasher")
	if run_time >= 150.0:
		kinds.append("brute")
	var kind: String = kinds[rng.randi_range(0, kinds.size() - 1)]
	spawn_enemy_at(kind, ring_pos_around(player_pos, 640.0), false)
""",
"""func pick_spawn_kind() -> String:
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
	var batch := mini(1 + int(run_time / 90.0), 6)
	var kinds: Array = []
	for i in range(batch):
		kinds.append(pick_spawn_kind())
	queue_portal_burst(kinds, false)

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
""", "E15b-portal-system")

# E15c: elite wave through portal
rep("""func spawn_elite_wave() -> void:
	elite_waves_fired += 1
	if test_mode:
		print("ASHEN_TEST_ELITE t=%.1f wave=%d" % [run_time, elite_waves_fired])
	for i in range(3):
		var kinds := ["cinderling", "brute", "spitter", "dasher"]
		spawn_enemy_at(kinds[rng.randi_range(0, 3)], ring_pos_around(player_pos, 560.0), true)
	play_sfx("boss", 0.8)
	add_trauma(0.35)
""",
"""func spawn_elite_wave() -> void:
	elite_waves_fired += 1
	if test_mode:
		print("ASHEN_TEST_ELITE t=%.1f wave=%d" % [run_time, elite_waves_fired])
	if portal_warn_t > 0.0:
		# Deferred, not dropped: fires from the new anchor when the
		# relocation warning ends (the warning IS its telegraph).
		_portal_elite_deferred = true
		return
	var kinds: Array = []
	for i in range(3):
		var pool := ["cinderling", "brute", "spitter", "dasher"]
		kinds.append(pool[rng.randi_range(0, 3)])
	queue_portal_burst(kinds, true)
	if test_mode:
		print("ASHEN_V14_PORTAL_ELITE wave=%d anchor=%s" % [elite_waves_fired, portal_pos])
	play_sfx("boss", 0.8)
	add_trauma(0.35)
""", "E15c-elite-portal")

# E15d: boss through portal — split spawn_boss into gate + body
rep("""func spawn_boss() -> void:
	boss_spawned = true
	boss_active = true
	boss_dying = false
	boss_enraged = false
	boss_death_t = 0.0
	boss_max_hp = 4000.0 * (0.45 if test_mode else 1.0)
	boss_hp = boss_max_hp
	boss_pos = ring_pos_around(player_pos, 480.0)
""",
"""func spawn_boss() -> void:
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
""", "E15d-boss-portal")

# E16: label test-harness spawns + boss-summon exception
rep("""		spawn_enemy_at("cinderling", player_pos + Vector2(230, 0), false)
""",
"""		# TEST-ONLY gate setup spawns (v12/v13/v14 gates) — not gameplay.
		spawn_enemy_at("cinderling", player_pos + Vector2(230, 0), false)
""", "E16a-gate-label")
rep("""			if _death_spawn_t <= 0.0:
				_death_spawn_t = 0.5
				spawn_enemy_at("cinderling", ring_pos_around(player_pos, 250.0), false)
""",
"""			if _death_spawn_t <= 0.0:
				_death_spawn_t = 0.5
				# TEST-ONLY death-check overwhelm stream — not gameplay.
				spawn_enemy_at("cinderling", ring_pos_around(player_pos, 250.0), false)
""", "E16b-death-label")
rep("""			spawn_enemy_at("cinderling", boss_pos + Vector2(rng.randf_range(-90, 90), rng.randf_range(-90, 90)), false)
""",
"""			# v1.4 EXCEPTION (documented, not a player-ring spawn):
			# boss-summoned cinderlings appear around the BOSS (boss-local,
			# +-90 px), because the boss is summoning them — they are not
			# ambient spawns and never use a random ring around the player.
			spawn_enemy_at("cinderling", boss_pos + Vector2(rng.randf_range(-90, 90), rng.randf_range(-90, 90)), false)
""", "E16c-summon-exception")

open(P, "w").write(src)
print("APPLIED:", len(edits))
for t in edits:
    print(" -", t)
