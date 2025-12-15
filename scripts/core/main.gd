extends Node3D

# --- CONFIGURACIÓN DEL MAPA ---
@export var map_size: float = 500.0

# --- LISTAS DE OBJETOS ---
# Aquí arrastraremos las escenas .tscn desde el Inspector
@export_category("Decoración")
@export var obstacles_scenes: Array[PackedScene] # Barriles, Torres, Contenedores
@export var floor_details_scenes: Array[PackedScene] # Sangre, Papeles

@export var obstacle_count: int = 50   # Cantidad de objetos sólidos
@export var detail_count: int = 100    # Cantidad de manchas de sangre

func _ready():
	randomize()
	print("Generando decoración...")
	
	# 1. Generar Obstáculos (Tienen colisión)
	spawn_objects(obstacles_scenes, obstacle_count, true)
	
	# 2. Generar Detalles (Suelo, sin colisión)
	spawn_objects(floor_details_scenes, detail_count, false)

func spawn_objects(list_of_scenes: Array[PackedScene], amount: int, _random_rotation: bool):
	# Si la lista está vacía, no hacemos nada para evitar errores
	if list_of_scenes.is_empty(): return

	var limit = map_size / 2.0
	var spawn_range = limit - 10.0 # Margen para no salir del mapa

	for i in range(amount):
		# A. ELEGIR UN OBJETO AL AZAR DE LA LISTA
		# pick_random() es una función mágica de Godot 4
		var scene_template = list_of_scenes.pick_random()
		var new_object = scene_template.instantiate()
		
		# B. POSICIÓN ALEATORIA
		var pos_x = randf_range(-spawn_range, spawn_range)
		var pos_z = randf_range(-spawn_range, spawn_range)
		
		# C. ZONA SEGURA (No spawnear encima del jugador en el centro)
		if Vector2(pos_x, pos_z).length() < 8.0:
			i -= 1 # Reintentar
			continue
			
		add_child(new_object)
		new_object.global_position = Vector3(pos_x, 0, pos_z)
		
		# D. ROTACIÓN ALEATORIA (Para que no se vean todos iguales)
		new_object.rotation_degrees.y = randf_range(0, 360)
		
		# E. ESCALA ALEATORIA (Opcional, da mucha variedad)
		# Variamos el tamaño entre el 80% y el 120% del original
		var scale_mod = randf_range(0.8, 1.2)
		new_object.scale = Vector3(scale_mod, scale_mod, scale_mod)
