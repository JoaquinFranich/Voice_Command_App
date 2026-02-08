class_name BaseSportCounter extends Control

# Configuración (Valores por defecto, se pueden sobreescribir en hijos)
var max_sets: int = 3
var sets_to_win: int = 2
var score_container_name: String = "Games_Container"
var serve_pos_p1: Vector2 = Vector2(371, -216)
var serve_pos_p2: Vector2 = Vector2(371, -28)

# Variables comunes de Puntuación
var player1_score = 0
var player2_score = 0
var game_scores_p1 = []
var game_scores_p2 = []
var sets_ganados_p1 = 0
var sets_ganados_p2 = 0
var current_game_index = 0 # En Voley/Tennis/Paddle esto rastrea el Set actual
var active_set = -1

# UI Elements
var label_p1
var label_p2
var game_labels_p1 = []
var game_labels_p2 = []
var timer_labels = []

# Servicio
var serving_player := 1 # 1 = Jugador 1, 2 = Jugador 2
@onready var serve_indicator := $ServeIndicator

# Timers y Estados
enum SetState {NO_INICIADO, EN_PROGRESO, FINALIZADO}
var set_states = []
var set_timers = []

# STT (Speech to Text)
var STT
var is_listening_active = false
var is_listening_for_keyword = true
var keyword = "gana"

# Game Over
const GAME_OVER_SCENE := preload("res://Scenes/Game_Over_Screen.tscn")
var game_over_screen

# UI Nueva
var game_ui
var is_game_paused = false

func _ready():
	_initialize_arrays()
	
	# Check for new UI
	game_ui = get_node_or_null("GameUI")
	if game_ui:
		print("New GameUI detected")
		game_ui.point_added.connect(_increment_score)
		game_ui.point_removed.connect(_decrement_score)
		game_ui.reset_requested.connect(_reset_game)
		game_ui.menu_requested.connect(_on_menu_requested)
		# New Pause/Resume signals
		if game_ui.has_signal("pause_requested"):
			game_ui.pause_requested.connect(_on_pause_requested)
		if game_ui.has_signal("resume_requested"):
			game_ui.resume_requested.connect(_on_resume_requested)
			
		# Initial UI sync
		game_ui.set_serving_player(serving_player)
		update_score_labels()
		update_game_labels()
	else:
		_setup_ui_common()
	
	_setup_stt()
	_start_first_set()
	_init_game_over_screen()

func _initialize_arrays():
	game_scores_p1.clear()
	game_scores_p2.clear()
	set_states.clear()
	set_timers.clear()
	for i in range(max_sets):
		game_scores_p1.append(0)
		game_scores_p2.append(0)
		set_states.append(SetState.NO_INICIADO)
		set_timers.append(0.0)

func _setup_ui_common():
	var container = get_node(score_container_name)
	var timer_container = container.get_node("Timer_Container")
	var p1_container = container.get_node("P1_Points_Container")
	var p2_container = container.get_node("P2_Points_Container")
	
	# Timers
	timer_labels.clear()
	for i in range(1, max_sets + 1):
		var timer_node = timer_container.get_node_or_null("Set_Timer" + str(i))
		if timer_node:
			timer_labels.append(timer_node)
	
	# Labels de Sets/Juegos
	game_labels_p1.clear()
	game_labels_p2.clear()
	for i in range(1, max_sets + 1):
		# Intenta encontrar "GameX_PX" primero, luego "SetX_PX"
		var lbl_p1 = p1_container.get_node_or_null("Game" + str(i) + "_P1")
		if not lbl_p1:
			lbl_p1 = p1_container.get_node_or_null("Set" + str(i) + "_P1")
		
		var lbl_p2 = p2_container.get_node_or_null("Game" + str(i) + "_P2")
		if not lbl_p2:
			lbl_p2 = p2_container.get_node_or_null("Set" + str(i) + "_P2")
			
		if lbl_p1: game_labels_p1.append(lbl_p1)
		if lbl_p2: game_labels_p2.append(lbl_p2)

	# Puntos
	label_p1 = p1_container.get_node("Points_P1")
	label_p2 = p2_container.get_node("Points_P2")
	
	update_score_labels()
	update_game_labels()
	_update_serve_indicator()

func _setup_stt():
	OS.request_permission("RECORD_AUDIO")
	if Engine.has_singleton("SpeechToText"):
		STT = Engine.get_singleton("SpeechToText")
		STT.setLanguage("es")
		if not STT.is_connected("error", self._on_error):
			STT.connect("error", self._on_error)
		if not STT.is_connected("listening_completed", self._on_listening_completed):
			STT.connect("listening_completed", self._on_listening_completed)
		_start_listening()
	else:
		print("Error: Singleton STT no disponible")

func _process(delta):
	# Actualizar timer del set actual
	# ERROR FIX: Check against set_timers size, NOT timer_labels size (which is 0 in new UI)
	if active_set >= 0 and active_set < set_timers.size() and set_states[active_set] == SetState.EN_PROGRESO and not is_game_paused:
		set_timers[active_set] += delta
		var time_str = _format_time(set_timers[active_set])
		
		if game_ui:
			game_ui.update_timer(time_str)
		elif active_set < timer_labels.size():
			timer_labels[active_set].text = time_str
	
	# Verifica si la escucha está activa y la reinicia si es necesario
	if not is_listening_active:
		_start_listening()

func _update_serve_indicator():
	if game_ui:
		game_ui.set_serving_player(serving_player)
	elif serve_indicator:
		if serving_player == 1:
			serve_indicator.position = serve_pos_p1
		else:
			serve_indicator.position = serve_pos_p2

# Métodos Virtuales (Para sobrescribir)
func update_score_labels():
	pass

func update_game_labels():
	for i in range(game_labels_p1.size()):
		if i < game_scores_p1.size():
			game_labels_p1[i].text = str(game_scores_p1[i])
			game_labels_p2[i].text = str(game_scores_p2[i])

func _increment_score(player):
	pass

func _check_win_condition():
	pass

# Timers y Sets
func _start_first_set():
	sets_ganados_p1 = 0
	sets_ganados_p2 = 0
	current_game_index = 0
	_initialize_arrays() # Reset arrays
	serving_player = 1
	_update_serve_indicator()
	
	active_set = 0
	if set_states.size() > 0:
		set_states[0] = SetState.EN_PROGRESO
	
	if game_ui:
		game_ui.update_timer("00:00")
	elif timer_labels.size() > 0:
		timer_labels[0].modulate = Color(1, 1, 1, 1)
		timer_labels[0].text = "00:00"

func _format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]

# Game Over Handling
func _init_game_over_screen():
	if GAME_OVER_SCENE:
		game_over_screen = GAME_OVER_SCENE.instantiate()
		add_child(game_over_screen)
		game_over_screen.connect("restart_requested", Callable(self, "_on_game_over_restart_requested"))
		game_over_screen.connect("back_to_menu_requested", Callable(self, "_on_game_over_back_to_menu_requested"))

func _show_game_over_screen(winner: int):
	if not game_over_screen: return
	var total_time := 0.0
	for time_value in set_timers:
		total_time += time_value
	var winner_label := "Equipo " + str(winner) # Usamos "Equipo" genérico
	game_over_screen.show_summary(winner_label, game_scores_p1.duplicate(), game_scores_p2.duplicate(), total_time)

func _on_game_over_restart_requested():
	_reset_game()

func _on_game_over_back_to_menu_requested():
	_reset_game() # Importante resetear antes de salir para limpiar
	SceneTransition.change_scene("res://Scenes/MainMenu_New.tscn")

func _reset_game():
	# Reiniciar lógica común
	_start_first_set()
	
	if game_ui:
		game_ui.update_timer("00:00")
	else:
		for label in timer_labels:
			label.text = "00:00"
			label.modulate = Color(1, 1, 1, 0.5)
			
	update_score_labels()
	update_game_labels()

# STT Logic Common
func _start_listening():
	if STT and not is_listening_active:
		STT.listen()
		is_listening_active = true

func _on_listening_completed(args):
	var recognized_text = str(args).to_lower()
	
	if is_listening_for_keyword:
		if keyword in recognized_text:
			print("Palabra clave detectada")
			is_listening_for_keyword = false
			# Asumimos que existe $TextEdit si se usa esta lógica, o override
			if has_node("TextEdit"):
				$TextEdit.text = "Quien gano el punto? ('Di EQUIPO 1 o EQUIPO 2')"
	else:
		if "equipo 1" in recognized_text:
			_handle_voice_command(1)
		elif "equipo 2" in recognized_text:
			_handle_voice_command(2)
		else:
			print("Frase no reconocida: ", recognized_text)
		
		is_listening_for_keyword = true
		if has_node("TextEdit"):
			$TextEdit.text = "Di la palabra clave 'GANA'."
	
	is_listening_active = false
	_start_listening()

func _on_error(errorcode):
	print("Error STT: " + errorcode)
	is_listening_active = false
	_start_listening()

func _handle_voice_command(player):
	# Método virtual para manejar acciones de voz (puntos o botones especiales)
	# Por defecto, suma punto. Hijos pueden sobreescribir para TieBreak buttons etc.
	_increment_score(player)

func _decrement_score(player):
	pass

func _on_menu_requested():
	print("Menu requested")
	SceneTransition.change_scene("res://Scenes/MainMenu_New.tscn")

func _on_pause_requested():
	is_game_paused = true

func _on_resume_requested():
	is_game_paused = false

func _on_button_p_1_pressed():
	_increment_score(1)

func _on_button_p_2_pressed():
	_increment_score(2)

func _on_listen_btn_button_down():
	_start_listening()

func _on_stop_btn_button_down():
	if STT:
		STT.Stop()
		is_listening_active = false

func _on_get_output_btn_button_down():
	if STT and has_node("TextEdit2"):
		$TextEdit2.text = STT.getWords()
