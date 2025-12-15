extends Control

# Ruta a tu escena principal de juego
# ¡CONFIRMA QUE ESTA RUTA SEA CORRECTA EN TU PROYECTO!

# Si tu Main.tscn está suelto en la carpeta raíz, usa: "res://Main.tscn"

func _ready():
	# Conectar los botones
	$PlayButton.pressed.connect(_on_play_pressed)
	
	# Verifica si creaste el botón de salir antes de conectarlo
	if has_node("QuitButton"):
		$QuitButton.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	# Cambiar a la escena del juego
	# Al cambiar de escena, este menú se destruye y la música se corta,
	# dando paso al MusicManager del juego.
	get_tree().change_scene_to_file("res://scenes/main_levels/main.tscn")

func _on_quit_pressed():
	# Cerrar el juego
	get_tree().quit()
