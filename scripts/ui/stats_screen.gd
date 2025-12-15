extends Control

@onready var row_kunai = $ScrollContainer/VBoxContainer/RowKunai
@onready var row_blade = $ScrollContainer/VBoxContainer/RowBlade
@onready var row_bomb = $ScrollContainer/VBoxContainer/RowBomb

func _ready():
	# Conectarse a la señal del jugador para actualizarse solo
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# Conectamos la señal "stats_changed"
		player.stats_changed.connect(update_all_stats)
		# Primera actualización
		update_all_stats()

func update_all_stats():
	var player = get_tree().get_first_node_in_group("player")
	if not player: return
	
	# Actualizamos cada fila leyendo el diccionario del jugador
	var w = player.weapons
	
	row_kunai.update_row(w["kunai"]["name"], w["kunai"]["level"], 5)
	row_blade.update_row(w["blade"]["name"], w["blade"]["level"], 5)
	row_bomb.update_row(w["bomb"]["name"], w["bomb"]["level"], 5)
