extends Area3D

var damage = 2.0
var knockback_force = 2.0

func _on_body_entered(body):
	# --- PROTECCIÓN ANTI-SUICIDIO ---
	# Si el cuerpo que toca es el Jugador, ignorarlo inmediatamente.
	if body.is_in_group("player"):
		return

	# Lógica normal de daño a enemigos
	if body.has_method("take_damage"):
		body.take_damage(damage)
		
		# Efecto de empuje
		if body is CharacterBody3D:
			var direction = (body.global_position - global_position).normalized()
			body.velocity += direction * knockback_force
