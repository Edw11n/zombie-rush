extends Area3D

var damage = 5.0
var explosion_radius_mult = 1.0

@onready var collision_shape = $CollisionShape3D
@onready var mesh = $MeshInstance3D

func launch(target_pos, duration):
	# 1. Calcular arco de movimiento con TWEEN
	var tween = create_tween()
	
	# Movimiento horizontal (X y Z) lineal
	tween.tween_property(self, "global_position:x", target_pos.x, duration)
	tween.parallel().tween_property(self, "global_position:z", target_pos.z, duration)
	
	# Movimiento vertical (Y) en arco (sube y baja)
	var peak_height = 3.0
	tween.parallel().tween_property(self, "position:y", peak_height, duration / 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "position:y", 0.0, duration / 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(duration / 2.0)
	
	# Cuando termine el tween, explota
	tween.tween_callback(explode)

func explode():
	# 1. Efecto visual (Crecer y ponerse rojo)
	var tween = create_tween()
	mesh.material_override = StandardMaterial3D.new()
	mesh.material_override.albedo_color = Color.RED
	tween.tween_property(mesh, "scale", Vector3(3,3,3) * explosion_radius_mult, 0.2)
	tween.tween_callback(queue_free)
	
	# 2. ACTIVAR EL ÁREA DE DAÑO
	collision_shape.disabled = false
	
	# --- EL TRUCO DE VETERANO ---
	# Esperamos DOS frames de física. 
	# El primero activa el objeto, el segundo actualiza las colisiones.
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	# 3. DETECTAR Y DAÑAR
	var bodies = get_overlapping_bodies()
	
	# DEBUG: Esto te dirá en la consola a cuántos enemigos detectó
	print("BUM! La bomba detectó ", bodies.size(), " cuerpos.") 
	
	for body in bodies:
		# Ignorar al jugador (Fuego amigo apagado)
		if body.is_in_group("player"):
			continue
			
		# Aplicar daño
		if body.has_method("take_damage"):
			body.take_damage(damage)
			print("Enemigo dañado por bomba: ", body.name)
