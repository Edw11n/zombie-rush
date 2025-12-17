extends CharacterBody3D

# --- CONFIGURACIÓN BASE ---
@export var base_speed = 5.0
var current_move_speed = base_speed
@export var gravity = 10.0

# --- VARIABLES DE SALUD ---
var max_health = 100.0
var current_health = 100.0
var is_invulnerable = false

# --- ESTADÍSTICAS PASIVAS ---
var speed_multiplier = 1.0   # Multiplicador de velocidad (1.0 = 100%)
var xp_multiplier = 1.0      # Multiplicador de experiencia
var health_regen = 0.0       # Puntos de vida recuperados por segundo

# --- REFERENCIAS ---
var blade_scene = preload("res://scenes/weapons/Blade.tscn")
var bomb_scene = preload("res://scenes/weapons/bomb.tscn")
var kunai_scene = preload("res://scenes/weapons/kunai.tscn")

# Referencias a nodos
@onready var attack_timer = $AttackTimer
@onready var blade_container = $BladeContainer 
@onready var bomb_timer = $BombTimer

# --- REFERENCIAS UI ---
var exp_bar: ProgressBar
var level_label: Label
var hp_bar: ProgressBar 

# --- SISTEMA DE NIVELES ---
var level = 0
var current_xp = 0
var max_xp = 5 
var xp_scaler = 1.33

# --- ESTADÍSTICAS DE COMBATE ---
var attack_cooldown = 1.5      
var projectiles_per_burst = 1 
var shoot_front = true        
var shoot_back = false        
var shoot_sides = false        

# --- ANIMACIONES Y MODELO (NUEVO) ---
var visual_model = null
var anim_player = null

# --- SEÑALES ---
signal stats_changed

# --- DICCIONARIO MAESTRO DE ARMAS ---
var weapons = {
	"kunai": {
		"unlocked": true, "level": 1, "max_level": 5, "name": "Kunai",
		"stats": { "damage": 1, "cooldown": 1.5, "projectiles": 1, "piercing": 0, "spread_arc": false, "rapid_fire": false }
	},
	"blade": {
		"unlocked": false, "level": 0, "max_level": 5, "name": "Cuchilla Giratoria",
		"stats": { "count": 0, "damage": 2, "cooldown": 2.0, "duration": 3.0, "is_permanent": false, "radius_mult": 1.0 }
	},
	"bomb": {
		"unlocked": false, "level": 0, "max_level": 5, "name": "Bomba Explosiva",
		"stats": { "count": 0, "damage": 3, "cooldown": 3.0, "area_mult": 1.0, "is_flower": false, "fire_pool": false }
	}
}

func _ready():
	# 1. Conectar UI
	exp_bar = get_tree().get_first_node_in_group("ui_xp")
	level_label = get_tree().get_first_node_in_group("ui_level")
	hp_bar = get_tree().get_first_node_in_group("ui_hp") 
	
	update_ui()
	if hp_bar:
		hp_bar.max_value = max_health
		hp_bar.value = current_health
	
	# 2. CONFIGURACIÓN DE ANIMACIÓN (Automática)
	# Buscamos el AnimationPlayer recursivamente
	anim_player = find_child("AnimationPlayer", true, false)
	
	if anim_player:
		# El modelo visual suele ser el padre del AnimationPlayer en los GLTF
		visual_model = anim_player.get_parent()
		
		# Configuramos bucles para correr e idle
		if anim_player.has_animation("Run"):
			anim_player.get_animation("Run").loop_mode = Animation.LOOP_LINEAR
		if anim_player.has_animation("Idle"):
			anim_player.get_animation("Idle").loop_mode = Animation.LOOP_LINEAR
	else:
		# Fallback por si sigues usando el MeshInstance3D antiguo
		if has_node("MeshInstance3D"):
			visual_model = $MeshInstance3D
	
	# 3. Inicializar Stats del Arma
	apply_weapon_stats("kunai", 1)
	
	# 4. Arrancar Timer
	attack_timer.start()

# --- FÍSICAS Y ANIMACIÓN ---
func _physics_process(delta):
	# A. REGENERACIÓN DE VIDA
	if health_regen > 0 and current_health < max_health:
		current_health += health_regen * delta
		current_health = min(current_health, max_health)
		if hp_bar: hp_bar.value = current_health

	# B. GRAVEDAD
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# C. MOVIMIENTO
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Calculamos velocidad final
	var final_speed = base_speed * speed_multiplier 
	
	if direction:
		velocity.x = direction.x * final_speed
		velocity.z = direction.z * final_speed
		
		# ANIMACIÓN: CORRER
		if anim_player and anim_player.current_animation != "Run":
			anim_player.play("Run", 0.2)
	else:
		velocity.x = move_toward(velocity.x, 0, final_speed)
		velocity.z = move_toward(velocity.z, 0, final_speed)
		
		# ANIMACIÓN: IDLE
		if anim_player and anim_player.current_animation != "Idle":
			anim_player.play("Idle", 0.2)

	look_at_cursor() 
	move_and_slide()
	
	if blade_container:
		blade_container.rotation.y += 2.0 * delta

func look_at_cursor():
	if not visual_model: return 
	
	var camera = get_viewport().get_camera_3d()
	if not camera: return
	
	var mouse_pos = get_viewport().get_mouse_position()
	var drop_plane = Plane(Vector3.UP, 0)
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_normal = camera.project_ray_normal(mouse_pos)
	var intersection_point = drop_plane.intersects_ray(ray_origin, ray_normal)
	
	if intersection_point:
		var look_target = Vector3(intersection_point.x, position.y, intersection_point.z)
		
		# 1. Mirar al objetivo (esto lo pone de espaldas)
		visual_model.look_at(look_target, Vector3.UP)
		
		# 2. ¡CORRECCIÓN! Girar 180 grados inmediatamente
		visual_model.rotate_y(PI) 
		
		visual_model.rotation.x = 0 
		visual_model.rotation.z = 0

# --- COMBATE ---
func _on_attack_timer_timeout():
	perform_shooting_routine()

func perform_shooting_routine():
	for i in range(projectiles_per_burst):
		spawn_projectile(0)
		if shoot_back: spawn_projectile(PI) 
		if shoot_sides:
			spawn_projectile(PI / 2)  
			spawn_projectile(-PI / 2) 
		
		await get_tree().create_timer(0.1).timeout

func spawn_projectile(angle_offset):
	var kunai = kunai_scene.instantiate()
	kunai.damage = weapons["kunai"]["stats"]["damage"]
	get_parent().add_child(kunai)
	
	# Posición: Desde el pecho del jugador
	kunai.global_position = global_position + Vector3(0, 0.5, 0)
	
	# Rotación: Basada en la rotación del modelo visual
	if visual_model:
		var current_rot = visual_model.global_rotation.y
		
		# --- CORRECCIÓN FINAL ---
		# Sumamos PI (180 grados) para compensar el giro del personaje.
		# Ahora el Kunai saldrá por donde el personaje está "mirando" visualmente.
		kunai.rotation.y = current_rot + angle_offset + PI 
		
		kunai.rotation.x = 0 
		kunai.rotation.z = 0

# --- DAÑO Y SALUD ---
func take_damage(amount):
	if is_invulnerable: return
	current_health -= amount
	if hp_bar: hp_bar.value = current_health
	
	if current_health <= 0:
		die()
	else:
		is_invulnerable = true
		$InvulnerabilityTimer.start()
		# Parpadeo simple
		if visual_model: visual_model.visible = false
		await get_tree().create_timer(0.1).timeout
		if visual_model: visual_model.visible = true

func die():
	print("MURIENDO...")
	
	# 1. Desactivar físicas
	set_physics_process(false)
	
	# 2. Reproducir animación de muerte
	if anim_player and anim_player.has_animation("Death"):
		anim_player.play("Death")
		# Esperar a que termine la animación
		await anim_player.animation_finished
	else:
		# Espera de seguridad si no hay animación
		await get_tree().create_timer(1.0).timeout

	print("GAME OVER")
	# 3. Mostrar pantalla de fin
	if get_node_or_null("/root/Global") and Global.game_ui:
		Global.game_ui.show_game_over()
	else:
		get_tree().reload_current_scene()

func heal(percent):
	var amount = max_health * (percent / 100.0)
	current_health = min(current_health + amount, max_health)
	if hp_bar: hp_bar.value = current_health

func _on_invulnerability_timer_timeout():
	is_invulnerable = false

# --- NIVEL Y EXPERIENCIA ---
func gain_experience(amount):
	current_xp += amount * xp_multiplier
	if current_xp >= max_xp:
		level_up()
	update_ui()

func level_up():
	current_xp -= max_xp
	level += 1
	max_xp = int(max_xp * xp_scaler)
	
	var menu = get_tree().get_first_node_in_group("ui_levelup")
	if menu:
		menu.show_upgrades()
	update_ui()

func update_ui():
	if exp_bar:
		exp_bar.max_value = max_xp
		exp_bar.value = current_xp
	if level_label:
		level_label.text = "Nivel: " + str(level)

# --- SISTEMA DE MEJORAS ---
func apply_upgrade(id):
	print("Intentando mejorar ID: ", id)
	
	if id in weapons:
		upgrade_weapon(id)
	else:
		match id:
			"heal": heal(25)
			"speed_up": speed_multiplier += 0.10
			"regen_up": health_regen += 0.5
			"max_hp_up":
				max_health += 20.0
				current_health += 20.0
				if hp_bar: hp_bar.max_value = max_health
				if hp_bar: hp_bar.value = current_health
			"xp_up": xp_multiplier += 0.20

	if current_xp >= max_xp:
		level_up()

func upgrade_weapon(weapon_id):
	var w = weapons[weapon_id]
	if not w["unlocked"]:
		w["unlocked"] = true
		w["level"] = 1
		apply_weapon_stats(weapon_id, 1)
		emit_signal("stats_changed")
		return

	if w["level"] >= w["max_level"]: return

	w["level"] += 1
	apply_weapon_stats(weapon_id, w["level"])
	emit_signal("stats_changed")

func apply_weapon_stats(id, weapon_level):
	var s = weapons[id]["stats"]
	
	match id:
		"kunai":
			match weapon_level:
				2: 
					s["projectiles"] = 2
					s["rapid_fire"] = true
				3: s["cooldown"] = 1.0
				4: 
					s["projectiles"] = 3
					s["damage"] = 2
				5: 
					s["projectiles"] = 4
					s["cooldown"] = 0.5
					s["piercing"] = 3
					s["spread_arc"] = true
			projectiles_per_burst = s["projectiles"]
			attack_cooldown = s["cooldown"]
			attack_timer.wait_time = attack_cooldown
			
		"blade":
			match weapon_level:
				1: s["count"] = 1
				2: s["count"] = 2
				3: 
					s["count"] = 3
					s["cooldown"] = 1.0
				4: s["count"] = 4
				5: 
					s["count"] = 5
					s["is_permanent"] = true
					s["radius_mult"] = 1.5
			update_blades()
		"bomb":
			match weapon_level:
				1: 
					s["count"] = 1
					s["cooldown"] = 2
				2: 
					s["cooldown"] = 1.85
					s["damage"] = 5
				3: 
					s["damage"] = 6.0
					s["area_mult"] = 1.5
				4: 
					s["count"] = 2
					s["cooldown"] = 1.7
				5: 
					s["area_mult"] = 2.5
					s["damage"] = 7.0
					s["is_flower"] = true
					s["fire_pool"] = true
			bomb_timer.wait_time = s["cooldown"]
			if bomb_timer.is_stopped():
				bomb_timer.start()

# --- GESTIÓN DE CUCHILLAS ---
func update_blades():
	for child in blade_container.get_children():
		child.queue_free()
	
	var stats = weapons["blade"]["stats"]
	var count = stats["count"]
	if count == 0: return

	var radius = 3.0 * stats["radius_mult"]
	var angle_step = 2 * PI / count
	
	for i in range(count):
		var blade = blade_scene.instantiate()
		blade_container.add_child(blade)
		var angle = i * angle_step
		blade.position = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
		blade.damage = stats["damage"]

# --- GESTIÓN DE BOMBAS ---
func _on_bomb_timer_timeout():
	var stats = weapons["bomb"]["stats"]
	for i in range(stats["count"]):
		spawn_bomb(stats)
		await get_tree().create_timer(0.2).timeout

func spawn_bomb(stats):
	var bomb = bomb_scene.instantiate()
	get_parent().add_child(bomb)
	
	bomb.global_position = global_position
	bomb.damage = stats["damage"]
	bomb.explosion_radius_mult = stats["area_mult"]
	
	var mouse_world_pos = get_cursor_position()
	var direction = (mouse_world_pos - global_position).normalized()
	var throw_distance = 3.0
	var target = global_position + (direction * throw_distance)
	
	target.x += randf_range(-1.5, 1.5)
	target.z += randf_range(-1.5, 1.5)
	
	bomb.launch(target, 1.0)

# Función auxiliar
func get_cursor_position():
	var camera = get_viewport().get_camera_3d()
	if not camera: return global_position
	var mouse_pos = get_viewport().get_mouse_position()
	var drop_plane = Plane(Vector3.UP, 0)
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_normal = camera.project_ray_normal(mouse_pos)
	var intersection = drop_plane.intersects_ray(ray_origin, ray_normal)
	return intersection if intersection else global_position
