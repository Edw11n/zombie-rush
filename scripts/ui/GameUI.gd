extends Control

@onready var label_time = $CanvasLayer/HUD/LabelTime
@onready var label_kills = $CanvasLayer/HUD/LabelKills

@onready var pause_menu = $CanvasLayer/PauseMenu
@onready var game_over_menu = $CanvasLayer/GameOverMenu
@onready var label_final_stats = $CanvasLayer/GameOverMenu/LabelFinalStats

func _ready():
	# Conectamos este script con el Global para que nos encuentre
	Global.game_ui = self
	
	# Ocultamos menús al inicio
	pause_menu.visible = false
	game_over_menu.visible = false
	
	# Reiniciamos stats al empezar escena
	Global.reset_stats()

func _process(_delta):
	# Si estamos en Game Over, no actualizamos el HUD
	if game_over_menu.visible: return
	
	# INPUT DE PAUSA (Tecla ESC)
	if Input.is_action_just_pressed("ui_cancel") and not game_over_menu.visible:
		toggle_pause()
	
	# ACTUALIZAR HUD
	update_hud()

func update_hud():
	# Formatear tiempo (Segundos -> MM:SS)
	var minutes = int(Global.time_survived / 60)
	var seconds = int(Global.time_survived) % 60
	label_time.text = "%02d:%02d" % [minutes, seconds]
	
	label_kills.text = "Kills: " + str(Global.enemies_killed)

func toggle_pause():
	var is_paused = not get_tree().paused
	get_tree().paused = is_paused
	pause_menu.visible = is_paused
	
	# Si pausamos, mostramos el cursor. Si no, lo ocultamos (opcional según tu juego)
	# Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if is_paused else Input.MOUSE_MODE_CONFINED

# --- FUNCIONES DE BOTONES (CONÉCTALAS DESDE EL EDITOR) ---

func _on_btn_resume_pressed():
	toggle_pause()

func _on_btn_restart_pressed():
	toggle_pause() # Despausar primero
	Global.reset_stats()
	get_tree().reload_current_scene()

func _on_btn_quit_pressed():
	get_tree().quit()

# --- FUNCIÓN DE GAME OVER (Llamada desde el Player) ---
func show_game_over():
	get_tree().paused = true # Congela el juego
	
	var minutes = int(Global.time_survived / 60)
	var seconds = int(Global.time_survived) % 60
	var time_str = "%02d:%02d" % [minutes, seconds]
	
	label_final_stats.text = "Sobreviviste: " + time_str + "\nEnemigos Derrotados: " + str(Global.enemies_killed)
	
	game_over_menu.visible = true
