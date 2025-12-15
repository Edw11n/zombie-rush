extends HBoxContainer

@onready var label = $Label
@onready var slots = $SlotsContainer.get_children()

# Colores para diferenciar estado
var color_empty = Color(0.2, 0.2, 0.2, 1.0) # Gris oscuro
var color_filled = Color(0.0, 0.8, 0.2, 1.0) # Verde brillante (Nivel actual)
var color_evo = Color(1.0, 0.8, 0.0, 1.0)    # Dorado (Evolución)

func update_row(weapon_name, current_level, _max_level):
	label.text = weapon_name
	
	# Recorremos los 5 cuadritos
	for i in range(slots.size()):
		var slot_level = i + 1
		
		if slot_level <= current_level:
			# Si es el nivel 5, ponerlo dorado, si no verde
			if slot_level == 5:
				slots[i].color = color_evo
			else:
				slots[i].color = color_filled
		else:
			# Nivel no alcanzado
			slots[i].color = color_empty
