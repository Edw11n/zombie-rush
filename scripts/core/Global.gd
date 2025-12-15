extends Node

# Estadísticas de la partida
var time_survived = 0.0
var enemies_killed = 0

# Referencia a la UI para poder llamarla
var game_ui = null

func _process(delta):
	# Solo contamos el tiempo si el jugador está vivo (la UI le dirá cuándo parar)
	if get_tree().paused == false:
		time_survived += delta

func reset_stats():
	time_survived = 0.0
	enemies_killed = 0
	get_tree().paused = false # Despausar por si acaso
