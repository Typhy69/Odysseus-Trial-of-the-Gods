extends Node
class_name AudioManager

var music := {}
var sfx := {}
var voice := {}

var a: AudioStreamPlayer
var b: AudioStreamPlayer
var active_a := true
var sfxp: AudioStreamPlayer
var vop: AudioStreamPlayer
var wavesp: AudioStreamPlayer
var attract_timer: Timer

func _ready():
	a = AudioStreamPlayer.new(); add_child(a); a.bus = "Music"
	b = AudioStreamPlayer.new(); add_child(b); b.bus = "Music"
	sfxp = AudioStreamPlayer.new(); add_child(sfxp); sfxp.bus = "SFX"
	vop = AudioStreamPlayer.new(); add_child(vop); vop.bus = "Voice"
	wavesp = AudioStreamPlayer.new(); add_child(wavesp); wavesp.bus = "SFX"
	attract_timer = Timer.new(); attract_timer.wait_time = 20.0; attract_timer.one_shot = true; add_child(attract_timer)

	music = {
		"title": load("res://audio/music/title_theme_bgm.wav"),
		"attract": load("res://audio/music/attract_mode_bgm.wav"),
		"cyclops": load("res://audio/music/island_cyclops_bgm.wav"),
		"sirens": load("res://audio/music/island_sirens_bgm.wav"),
		"talos": load("res://audio/music/island_talos_bgm.wav"),
		"hydra": load("res://audio/music/island_hydra_bgm.wav"),
		"heroes": load("res://audio/music/island_heroes_bgm.wav"),
		"skeleton": load("res://audio/music/island_skeleton_bgm.wav"),
		"boss_cyclops": load("res://audio/music/boss_cyclops_bgm.wav"),
		"boss_sirens": load("res://audio/music/boss_sirens_bgm.wav"),
		"boss_talos": load("res://audio/music/boss_talos_bgm.wav"),
		"boss_hydra": load("res://audio/music/boss_hydra_bgm.wav"),
		"boss_heroes": load("res://audio/music/boss_heroes_bgm.wav"),
		"boss_skeleton": load("res://audio/music/boss_skeleton_bgm.wav"),
		"victory": load("res://audio/music/victory_stinger.wav"),
		"gameover": load("res://audio/music/game_over_theme.wav"),
		"reunion": load("res://audio/music/reunion_theme_bgm.wav"),
	}

	sfx = {
		"swing": load("res://audio/sfx/sword_swing.wav"),
		"block": load("res://audio/sfx/sword_block.wav"),
		"hit": load("res://audio/sfx/hit_enemy.wav"),
		"pickup_armor": load("res://audio/sfx/pickup_armor.wav"),
		"pickup_weapon": load("res://audio/sfx/pickup_weapon.wav"),
		"pickup_relic": load("res://audio/sfx/pickup_god_relic.wav"),
		"ui_confirm": load("res://audio/sfx/ui_confirm.wav"),
		"ui_cancel": load("res://audio/sfx/ui_cancel.wav"),
		"ui_select": load("res://audio/sfx/ui_select.wav"),
		"waves_loop": load("res://audio/sfx/wave_ambient_loop.wav"),
		"wind_loop": load("res://audio/sfx/wind_ambient_loop.wav"),
	}

	voice = {
		"logo": load("res://audio/voices/studio_logo_vo.wav"),
		"odys_a1": load("res://audio/voices/odysseus_attack1.wav"),
		"odys_a2": load("res://audio/voices/odysseus_attack2.wav"),
		"odys_a3": load("res://audio/voices/odysseus_attack3.wav"),
		"odys_a4": load("res://audio/voices/odysseus_attack4.wav"),
		"odys_a5": load("res://audio/voices/odysseus_attack5.wav"),
		"odys_v1": load("res://audio/voices/odysseus_victory1.wav"),
		"odys_v2": load("res://audio/voices/odysseus_victory2.wav"),
		"odys_v3": load("res://audio/voices/odysseus_victory3.wav"),
		"odys_h1": load("res://audio/voices/odysseus_hurt1.wav"),
		"odys_h2": load("res://audio/voices/odysseus_hurt2.wav"),
		"taunt_cyclops": load("res://audio/voices/boss_cyclops_taunt.wav"),
		"taunt_talos": load("res://audio/voices/boss_talos_taunt.wav"),
		"taunt_hydra": load("res://audio/voices/boss_hydra_taunt.wav"),
		"taunt_sirens": load("res://audio/voices/boss_sirens_taunt.wav"),
		"taunt_skeleton": load("res://audio/voices/boss_skeleton_taunt.wav"),
		"taunt_heroes": load("res://audio/voices/boss_heroes_taunt.wav"),
	}

	play_title_sequence()

func _players() -> Array:
	return [a, b] if active_a else [b, a]

func _crossfade(to_stream: AudioStream, t := 1.2):
	var cur = _players()[0]; var nxt = _players()[1]
	nxt.stop(); nxt.stream = to_stream; nxt.volume_db = -24.0; nxt.play()
	var steps := 24; var dt := t / steps
	for i in range(steps):
		cur.volume_db = lerp(0.0, -24.0, float(i)/steps)
		nxt.volume_db = lerp(-24.0, 0.0, float(i)/steps)
		await get_tree().create_timer(dt).timeout
	cur.stop(); active_a = not active_a

func play_title_sequence():
	vop.stream = voice["logo"]; vop.play()
	wavesp.stream = sfx["waves_loop"]; wavesp.volume_db = -12.0; wavesp.play()
	await get_tree().create_timer(1.0).timeout
	_crossfade(music["title"], 1.5)
	attract_timer.timeout.connect(_on_attract_timeout)
	attract_timer.start()

func fade_waves_out():
	var steps := 16
	for i in range(steps):
		wavesp.volume_db = lerp(0.0, -24.0, float(i)/steps)
		await get_tree().create_timer(0.08).timeout
	wavesp.stop()

func _on_attract_timeout():
	_crossfade(music["attract"], 1.0)
	a.volume_db = -3.0; b.volume_db = -3.0

func on_stage_start(island: String):
	fade_waves_out()
	if music.has(island):
		_crossfade(music[island], 1.0)

func on_boss_start(name: String="boss_cyclops"):
	if music.has(name):
		_crossfade(music[name], 0.9)

func on_boss_defeated():
	_crossfade(music["victory"], 0.5)
	await get_tree().create_timer(1.0).timeout
	_players()[0].stop()

func on_game_over():
	_crossfade(music["gameover"], 0.6)

func on_final_cutscene():
	_crossfade(music["reunion"], 1.2)
