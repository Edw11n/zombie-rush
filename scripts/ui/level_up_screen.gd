extends Control

var card_scene = preload("res://ui/UpgradeCard.tscn") # Ajusta la ruta si es necesario
@onready var container = $HBoxContainer

var all_upgrades = [
	{ "id": "heal", "title": "Poción", "description": "Recupera un 20% de salud.", "icon": preload("res://ui/icons/life.png") },
	{ "id": "kunai", "title": "Mejorar arma", "description": "Sube el nivel de tu arma.", "icon": preload("res://ui/icons/kunai.png") },
	{ "id": "blade", "title": "Cuchilla", "description": "Desbloquea/Mejora la cuchilla.", "icon": preload("res://ui/icons/blade.png") },
	{ "id": "bomb", "title": "Bomba", "description": "Desbloquea/Mejora la bomba.", "icon": preload("res://ui/icons/bomb.png") },
	{ "id": "speed_up", "title": "Botas Veloces", "description": "+10% Velocidad.", "icon": preload("res://ui/icons/boot.png") },
	{ "id": "regen_up", "title": "Corazón Troll", "description": "+0.5 regen/seg.", "icon": preload("res://ui/icons/regen.png") },
	{ "id": "max_hp_up", "title": "Vitalidad", "description": "+20 Salud Máxima.", "icon": preload("res://ui/icons/max_hp.png") },
	{ "id": "xp_up", "title": "Mente Maestra", "description": "+20% Ganancia XP.", "icon": preload("res://ui/icons/level_up.png") }
]

func _ready():
	visible = false

func show_upgrades():
	# 1. Limpiar UI
	for child in container.get_children():
		child.queue_free()
	
	# 2. Elegir cartas
	all_upgrades.shuffle()
	var options_to_show = all_upgrades.slice(0, 3) 
	
	for option in options_to_show:
		var card = card_scene.instantiate()
		container.add_child(card)
		card.set_card_data(option)
		card.pressed.connect(self._on_card_selected.bind(option["id"]))
	
	# 3. MÚSICA: Pausa
	# Buscamos el MusicPlayer en la raíz (Main) de forma segura
	var music = get_tree().root.get_node_or_null("Main/MusicPlayer")
	if music: music.play_pause_music()
	
	# 4. Mostrar y Pausar
	visible = true
	get_tree().paused = true

func _on_card_selected(id):
	# Aplicar mejora
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.apply_upgrade(id)
	
	# MÚSICA: Reanudar
	var music = get_tree().root.get_node_or_null("Main/MusicPlayer")
	if music: music.resume_game_music()
	
	# Ocultar y Reanudar
	visible = false
	get_tree().paused = false
