extends Node

# --- REFERENCIA AL MÚSICO ---
@onready var music_player = get_parent().get_node_or_null("MusicPlayer")

# --- CONFIGURACIÓN ---
@export var enemy_normal_scene: PackedScene
@export var enemy_fast_scene: PackedScene
@export var enemy_miniboss_scene: PackedScene 

# --- REFERENCIAS ---
var spawn_path_follow = null

# --- VARIABLES DE LÓGICA ---
var game_time = 0.0
var spawn_timer = 0.0
var current_spawn_interval = 2.5
var chance_for_fast_enemy = 0.0
var is_horda_activa = false # Controla el spawn rápido

# --- CONTROL DE MINIBOSSES ---
var minibosses_spawned_h1 = false
var minibosses_spawned_h2 = false

# --- CONTROL DE MÚSICA ---
var music_horde_triggered = false

# --- MULTIPLICADOR DE SALUD ---
var hp_multiplier = 1.0

func _ready():
	randomize()
	await get_tree().process_frame
	spawn_path_follow = get_tree().get_first_node_in_group("enemy_spawn_point")
	
	if spawn_path_follow == null:
		print("ERROR CRÍTICO: No encuentro Path3D en el grupo 'enemy_spawn_point'")
		set_process(false)

func _process(delta):
	game_time += delta
	spawn_timer += delta
	
	calculate_difficulty()
	
	if spawn_timer >= current_spawn_interval:
		spawn_enemy()
		spawn_timer = 0.0

func calculate_difficulty():
	# Variables temporales para este frame
	var en_horda_spawn = false  # ¿Deben salir enemigos rápido?
	var en_horda_musica = false # ¿Debe sonar música de tensión? (Dura más)
	
	# --- PARTE 1: PROGRESIÓN (Dificultad base) ---
	if game_time < 30.0:
		current_spawn_interval = 1.5
		chance_for_fast_enemy = 0.0
		hp_multiplier = 1.0
	elif game_time < 60.0:
		current_spawn_interval = 1.0
		chance_for_fast_enemy = 0.2
		hp_multiplier = 1.1
	elif game_time < 120.0:
		current_spawn_interval = 0.8
		chance_for_fast_enemy = 0.4
		hp_multiplier = 1.3
	elif game_time < 180.0:
		current_spawn_interval = 0.5
		chance_for_fast_enemy = 0.5
		hp_multiplier = 2.3
	elif game_time < 300.0:
		current_spawn_interval = 0.3
		chance_for_fast_enemy = 0.8
		hp_multiplier = 3.0
	else:
		current_spawn_interval = 0.1
		chance_for_fast_enemy = 0.9
		hp_multiplier = 3.0 + ((game_time - 300.0) / 60.0) * 0.5

	# --- PARTE 2: DEFINICIÓN DE HORDAS ---
	
	# HORDA 1: Minuto 2:30 (150s)
	# Spawn: 10 segundos (150 a 160)
	# Música: 45 segundos (150 a 195)
	if game_time > 150.0:
		if game_time < 160.0: # 10 segs de spawn intenso
			en_horda_spawn = true
			current_spawn_interval = 0.05
			if game_time < 152.0: spawn_miniboss(2)
		
		if game_time < 195.0: # 45 segs de música
			en_horda_musica = true
	
	# HORDA 2: Minuto 5:00 (300s)
	# Spawn: 15 segundos (300 a 315)
	# Música: 45 segundos (300 a 345)
	if game_time > 300.0:
		if game_time < 315.0:
			en_horda_spawn = true
			current_spawn_interval = 0.03
			if game_time < 302.0: spawn_miniboss(4)
		
		if game_time < 345.0:
			en_horda_musica = true

	# --- ACTUALIZAR ESTADO DE SPAWN ---
	is_horda_activa = en_horda_spawn

	# --- GESTOR DE MÚSICA (Basado en el tiempo extendido) ---
	if en_horda_musica and not music_horde_triggered:
		# Entrando a modo música horda
		music_horde_triggered = true
		if music_player: music_player.play_horde_music()
		
	elif not en_horda_musica and music_horde_triggered:
		# Saliendo de modo música horda
		music_horde_triggered = false
		if music_player: music_player.play_normal_music()

func spawn_enemy():
	if not spawn_path_follow: return
	
	var enemy_scene_to_spawn = enemy_normal_scene
	if enemy_fast_scene and randf() < chance_for_fast_enemy:
		enemy_scene_to_spawn = enemy_fast_scene
	
	if enemy_scene_to_spawn == null: return
		
	var new_enemy = enemy_scene_to_spawn.instantiate()
	if new_enemy.has_method("take_damage"):
		new_enemy.max_health *= hp_multiplier
	
	spawn_path_follow.progress_ratio = randf()
	var spawn_pos = spawn_path_follow.global_position
	spawn_pos.y = 1.0
	
	get_parent().add_child(new_enemy)
	new_enemy.global_position = spawn_pos

func spawn_miniboss(count):
	if count == 2 and minibosses_spawned_h1: return
	if count == 4 and minibosses_spawned_h2: return
		
	print("¡ALERTA DE JEFE! Spawneando ", count)
	for i in range(count):
		if enemy_miniboss_scene:
			var new_miniboss = enemy_miniboss_scene.instantiate()
			if new_miniboss.has_method("take_damage"):
				new_miniboss.max_health *= hp_multiplier
			spawn_path_follow.progress_ratio = randf()
			var spawn_pos = spawn_path_follow.global_position
			spawn_pos.y = 3.0
			get_parent().add_child(new_miniboss)
			new_miniboss.global_position = spawn_pos
			
	if count == 2: minibosses_spawned_h1 = true
	if count == 4: minibosses_spawned_h2 = true
