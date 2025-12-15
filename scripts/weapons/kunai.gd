extends Area3D

var speed = 25.0 # Le subí un poco la velocidad para que se sienta mejor
var damage = 1.0

func _physics_process(delta):
	position -= transform.basis.z * speed * delta

func _on_body_entered(body):
	# 1. Ignorar al Jugador (Fuego amigo apagado)
	if body.is_in_group("player"):
		return 

	# 2. Si es un Enemigo -> Daño y Destruir
	if body.is_in_group("enemy") or body.has_method("take_damage"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free() # Destruir bala
		
	# 3. Si es un OBSTÁCULO (Barril, Pared, etc.) -> Solo Destruir
	# Como ya filtramos al "player" arriba, cualquier otra cosa sólida (StaticBody) cae aquí.
	else:
		# Opcional: Crear chispas o sonido de impacto contra muro aquí
		queue_free() # La bala choca y desaparece
