extends Button

var upgrade_id = "" # Identificador interno (ej: "heal", "speed")

# Referencia a los nodos hijos
@onready var title_lbl = $NameLabel
@onready var desc_lbl = $DescriptionLabel
@onready var icon_rect = $Icon # Asegúrate de haber creado este TextureRect

func set_card_data(data):
	upgrade_id = data["id"]
	title_lbl.text = data["title"]
	desc_lbl.text = data["description"]
	
	# --- CORRECCIÓN AQUÍ ---
	# Antes decías "item_data", pero el argumento se llama "data"
	if data.has("icon") and data["icon"] != null:
		icon_rect.texture = data["icon"]
	else:
		# Icono por defecto si no hay imagen
		icon_rect.texture = preload("res://icon.svg")

func _pressed():
	# Esto es solo para debug, la conexión real la hace el menú
	print("¡CLICK DETECTADO EN LA CARTA!: ", upgrade_id)
