extends AudioStreamPlayer

# --- BIBLIOTECA DE MUSICA ---
@export var intro_track: AudioStream        
@export var normal_tracks: Array[AudioStream] 
@export var horde_tracks: Array[AudioStream]  

# --- ESTADOS ---
enum State { NORMAL, HORDE, PAUSE }
var current_state = State.NORMAL
var horde_index = 0

# --- VARIABLES DE MEMORIA (BOOKMARK) ---
var last_state_before_pause = State.NORMAL
var saved_position = 0.0        # Aquí guardaremos el segundo exacto
var saved_stream = null         # Aquí guardaremos qué canción sonaba

func _ready():
	finished.connect(_on_song_finished)
	play_normal_music()

# --- FUNCIONES DE CONTROL ---
func play_normal_music():
	# Si ya estamos tocando música normal y está sonando, no reiniciar
	if current_state == State.NORMAL and playing: return
	
	current_state = State.NORMAL
	if normal_tracks.size() > 0:
		stream = normal_tracks.pick_random()
		play()

func play_horde_music():
	if current_state == State.HORDE and playing: return

	current_state = State.HORDE
	if horde_tracks.size() > 0:
		stream = horde_tracks[horde_index]
		horde_index = 1 - horde_index 
		play()

func play_pause_music():
	# 1. GUARDAR ESTADO ACTUAL (EL BOOKMARK)
	if current_state != State.PAUSE:
		last_state_before_pause = current_state
		saved_position = get_playback_position() # Guardamos el segundo actual (ej: 00:45)
		saved_stream = stream                    # Guardamos la canción actual
	
	# 2. PONER MÚSICA DE PAUSA
	current_state = State.PAUSE
	if intro_track:
		stream = intro_track
		play()

func resume_game_music():
	# 1. RESTAURAR ESTADO
	current_state = last_state_before_pause
	
	# 2. RESTAURAR CANCIÓN Y POSICIÓN
	if saved_stream != null:
		stream = saved_stream    # Volvemos a poner la canción que estaba
		play()                   # La iniciamos
		seek(saved_position)     # ¡SALTAMOS AL SEGUNDO DONDE QUEDÓ!
	else:
		# Por si acaso falló el guardado, volvemos a la lógica normal
		if current_state == State.HORDE:
			play_horde_music()
		else:
			play_normal_music()

# --- AUTOMATIZACIÓN ---
func _on_song_finished():
	match current_state:
		State.NORMAL:
			if normal_tracks.size() > 0:
				stream = normal_tracks.pick_random()
				play()
		State.HORDE:
			if horde_tracks.size() > 0:
				stream = horde_tracks[horde_index]
				horde_index = 0 - horde_index
				play()
		State.PAUSE:
			play()
