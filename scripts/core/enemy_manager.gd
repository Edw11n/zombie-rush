extends Node

# --- REFERENCIA AL MÚSICO ---
@onready var music_player = get_parent().get_node_or_null("MusicPlayer")

# --- REFERENCIA A UI DE AVISO ---
# Buscamos el Label que pusiste en el grupo 'ui_warning'
@onready var warning_label = get_tree().get_first_node_in_group("ui_warning")

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
var is_horda_activa = false 

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
		
	# Limpiar texto de aviso al iniciar
	if warning_label: warning_label.text = ""

func _process(delta):
	game_time += delta
	spawn_timer += delta
	
	calculate_difficulty()
	
	if spawn_timer >= current_spawn_interval:
		spawn_enemy()
		spawn_timer = 0.0

func calculate_difficulty():
	var en_horda_spawn = false
	var en_horda_musica = false
	
	# Contamos cuántos jefes hay vivos en este momento exacto
	var bosses_vivos = get_tree().get_nodes_in_group("miniboss").size()
	
	# --- PARTE 1: PROGRESIÓN ---
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

	# --- PARTE 2: AVISOS Y HORDAS ---
	
	# === HORDA 1 (Minuto 2:30 / 150s) ===
	
	# A. AVISO (10 segundos antes: 140s a 150s)
	if game_time > 140.0 and game_time < 150.0:
		var countdown = int(150.0 - game_time)
		update_warning("¡HORDA EN " + str(countdown) + "!")
	
	# B. LÓGICA DE HORDA
	elif game_time >= 150.0 and game_time < 200.0: # Rango de seguridad
		hide_warning() # Borrar texto
		
		# Spawn Intenso (5 segundos)
		if game_time < 155.0:
			en_horda_spawn = true
			current_spawn_interval = 0.07
			if game_time < 152.0: spawn_miniboss(2)
			
		# Música: Suena si estamos en tiempo de spawn O si quedan jefes vivos
		if game_time < 155.0 or bosses_vivos > 0:
			en_horda_musica = true

	# === HORDA 2 (Minuto 5:00 / 300s) ===
	
	# A. AVISO (10 segundos antes: 290s a 300s)
	elif game_time > 290.0 and game_time < 300.0:
		var countdown = int(300.0 - game_time)
		update_warning("¡JEFE FINAL EN " + str(countdown) + "!")

	# B. LÓGICA DE HORDA
	elif game_time >= 300.0:
		hide_warning()
		
		# Spawn Intenso (15 segundos)
		if game_time < 315.0:
			en_horda_spawn = true
			current_spawn_interval = 0.04
			if game_time < 302.0: spawn_miniboss(4)
		
		# Música: Suena si estamos en spawn O si quedan jefes vivos
		if game_time < 315.0 or bosses_vivos > 0:
			en_horda_musica = true
	
	# Si no estamos en rango de aviso, aseguramos que el texto esté borrado
	else:
		hide_warning()

	# --- ACTUALIZAR ESTADOS ---
	is_horda_activa = en_horda_spawn

	# GESTOR DE MÚSICA
	if en_horda_musica and not music_horde_triggered:
		music_horde_triggered = true
		if music_player: music_player.play_horde_music()
		
	elif not en_horda_musica and music_horde_triggered:
		music_horde_triggered = false
		if music_player: music_player.play_normal_music()

# --- FUNCIONES AUXILIARES PARA UI ---
func update_warning(text):
	if warning_label:
		warning_label.text = text
		warning_label.visible = true

func hide_warning():
	if warning_label and warning_label.text != "":
		warning_label.text = ""
		warning_label.visible = false

# --- SPAWNERS ---
func spawn_enemy():
	if not spawn_path_follow: return
	var enemy_scene = enemy_normal_scene
	if enemy_fast_scene and randf() < chance_for_fast_enemy:
		enemy_scene = enemy_fast_scene
	if not enemy_scene: return
		
	var new_enemy = enemy_scene.instantiate()
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
			
			# ¡AQUÍ ESTÁ LA MAGIA! Metemos al jefe al grupo para contarlo luego
			new_miniboss.add_to_group("miniboss") 
			
			if new_miniboss.has_method("take_damage"):
				new_miniboss.max_health *= hp_multiplier
			
			spawn_path_follow.progress_ratio = randf()
			var spawn_pos = spawn_path_follow.global_position
			spawn_pos.y = 3.0
			get_parent().add_child(new_miniboss)
			new_miniboss.global_position = spawn_pos
			
	if count == 2: minibosses_spawned_h1 = true
	if count == 4: minibosses_spawned_h2 = true
