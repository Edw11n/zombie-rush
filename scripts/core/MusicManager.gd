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
var saved_position = 0.0
var saved_stream = null

func _ready():
	finished.connect(_on_song_finished)
	play_normal_music()

# --- FUNCIONES DE CONTROL ---
func play_normal_music():
	if current_state == State.NORMAL and playing: return
	
	current_state = State.NORMAL
	if normal_tracks.size() > 0:
		stream = normal_tracks.pick_random()
		play()

func play_horde_music():
	# Si ya está sonando la horda, no reiniciamos
	if current_state == State.HORDE and playing: return

	current_state = State.HORDE
	if horde_tracks.size() > 0:
		# USAMOS MÓDULO (%): Si solo hay 1 canción, el índice siempre será 0.
		# Si hay más, las irá intercalando.
		stream = horde_tracks[horde_index % horde_tracks.size()]
		
		# Preparamos el índice para la siguiente vez
		horde_index = (horde_index + 1) % horde_tracks.size()
		play()

func play_pause_music():
	if current_state != State.PAUSE:
		last_state_before_pause = current_state
		saved_position = get_playback_position()
		saved_stream = stream
	
	current_state = State.PAUSE
	if intro_track:
		stream = intro_track
		play()

func resume_game_music():
	current_state = last_state_before_pause
	
	if saved_stream != null:
		stream = saved_stream
		play()
		seek(saved_position)
	else:
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
				# Al terminar la canción de horda, vuelve a poner la que toca (o la misma)
				stream = horde_tracks[horde_index % horde_tracks.size()]
				horde_index = (horde_index + 1) % horde_tracks.size()
				play()
		State.PAUSE:
			# La música de pausa suele tener el Loop activado en la importación, 
			# pero esto asegura que reinicie si no lo tiene.
			play()
