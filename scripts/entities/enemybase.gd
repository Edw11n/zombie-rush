extends CharacterBody3D

# --- CONFIGURACIÓN ---
@export var max_health: float = 2.0
@export var move_speed: float = 3.0
@export var xp_value: int = 2
@export var damage_amount: int = 10 

# --- VARIABLES ---
var current_health: float
var player_node: CharacterBody3D = null
var anim_player: AnimationPlayer = null # Lo buscaremos dinámicamente

# --- REFERENCIAS ---
@onready var damage_zone = $DamageZone 
@onready var collision_shape = $CollisionShape3D

func _ready():
	current_health = max_health
	
	# 1. BUSCAR AL JUGADOR
	player_node = get_tree().get_first_node_in_group("player")
	if player_node == null:
		print("ERROR: ", name, "se borró porque no encontró al jugador")
		queue_free()
		return

	# 2. BUSCAR AUTOMÁTICAMENTE EL ANIMATION PLAYER
	# Esto busca en todos los hijos y nietos, así que no importa si 
	# el modelo se llama Model_Normal_Root o Model_Fast_Root.
	anim_player = find_child("AnimationPlayer", true, false)
	
	# 3. INICIAR ANIMACIÓN DE CORRER
	if anim_player:
		# Configuramos el bucle por código por si acaso
		var run_anim = "Run" # O usa "Run_Arms" si prefieres que corra agresivo
		
		if anim_player.has_animation(run_anim):
			# Aseguramos que se repita (Loop)
			anim_player.get_animation(run_anim).loop_mode = Animation.LOOP_LINEAR
			anim_player.play(run_anim)
		else:
			print("ADVERTENCIA: No encontré la animación 'Run' en " + name)
	else:
		print("ERROR: No encontré ningún AnimationPlayer en el enemigo " + name)

func _physics_process(_delta):
	if player_node:
		# --- MOVIMIENTO ---
		var direction = (player_node.global_position - global_position).normalized()
		velocity = direction * move_speed
		move_and_slide()
		
		# --- ROTACIÓN (Mirar al jugador) ---
		look_at(player_node.global_position, Vector3.UP)
		rotation.x = 0 # No inclinarse arriba/abajo
		rotation.z = 0
		
		# --- LÓGICA DE DAÑO ---
		if damage_zone: # Verificación de seguridad
			var cuerpos_en_rango = damage_zone.get_overlapping_bodies()
			for cuerpo in cuerpos_en_rango:
				if cuerpo.is_in_group("player"):
					if cuerpo.has_method("take_damage"):
						cuerpo.take_damage(damage_amount)

func take_damage(amount: float):
	current_health -= amount
	
	# Aquí podrías poner un sonido de golpe o un flash rojo
	
	if current_health <= 0:
		die()

func die():
	# 1. Dar XP y sumar kill
	if player_node and player_node.has_method("gain_experience"):
		player_node.gain_experience(xp_value)
		# Verificamos si existe el Global antes de sumar
		if get_node_or_null("/root/Global"): 
			Global.enemies_killed += 1
	
	# 2. APAGAR EL CEREBRO DEL ENEMIGO (Corrección del Error C++)
	set_physics_process(false)
	
	# --- AQUÍ ESTÁ EL CAMBIO IMPORTANTE ---
	# En lugar de: collision_shape.disabled = true
	# Usamos set_deferred("propiedad", valor)
	collision_shape.set_deferred("disabled", true)
	
	# En lugar de: damage_zone.monitoring = false
	if damage_zone: 
		damage_zone.set_deferred("monitoring", false)
	# -------------------------------------
	
	# 3. ANIMACIÓN DRAMÁTICA DE MUERTE
	if anim_player and anim_player.has_animation("Death"):
		anim_player.play("Death")
		await anim_player.animation_finished
	else:
		await get_tree().create_timer(0.1).timeout
	
	# 4. ELIMINAR
	queue_free()
