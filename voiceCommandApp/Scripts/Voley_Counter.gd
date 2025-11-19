extends Control

# VOLEY: Sistema numérico sin deuce/advantage
var score_options_voly = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
						"11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
						"21", "22", "23", "24", "25"]
var player1_score_voly = 0
var player2_score_voly = 0
var label_p1_voly
var label_p2_voly

# VOLEY: Máximo 5 sets (3 para ganar)
var set_scores_p1_voly = [0, 0, 0, 0, 0]
var set_scores_p2_voly = [0, 0, 0, 0, 0]
var set_labels_p1_voly = []
var set_labels_p2_voly = []
var current_set_voly = 0

# VOLEY: Eliminado tie-break (no aplica)
var sets_ganados_p1_voly = 0
var sets_ganados_p2_voly = 0

enum SetState { NO_INICIADO, EN_PROGRESO, FINALIZADO }
var set_states_voly = [SetState.NO_INICIADO, SetState.NO_INICIADO, SetState.NO_INICIADO, SetState.NO_INICIADO, SetState.NO_INICIADO]
var set_timers_voly = [0.0, 0.0, 0.0, 0.0, 0.0]
var active_set_voly = -1
var timer_labels_voly = []

const GAME_OVER_SCENE := preload("res://Scenes/Game_Over_Screen.tscn")
var game_over_screen

# VOLEY: Lógica de cambio de saque según reglas oficiales
var serving_player := 1 # 1 = Jugador 1, 2 = Jugador 2

@onready var serve_indicator := $ServeIndicator  # Crear nodo TextureRect en escena

# VOLEY: Mantenemos sistema de voz con nombres equipo
var STT_voly
var is_listening_for_keyword_voly = true
var keyword_voly = "gana"
var is_listening_active_voly = false

func _ready():
	OS.request_permission("RECORD_AUDIO")

	if Engine.has_singleton("SpeechToText"):
		STT_voly = Engine.get_singleton("SpeechToText")
		STT_voly.setLanguage("es")
		STT_voly.connect("error", self._on_error_voly)
		STT_voly.connect("listening_completed", self._on_listening_completed_voly)
		#_start_listening_voly()

	var timer_container = get_node("Sets_Container/Timer_Container")
	for i in range(1, 6):
		timer_labels_voly.append(timer_container.get_node("Set_Timer" + str(i)))

	# VOLEY: 5 sets máximo
	var sets_container1 = get_node("Sets_Container/VBoxContainer")
	var sets_container2 = get_node("Sets_Container/VBoxContainer2")

	for i in range(1, 6):
		set_labels_p1_voly.append(sets_container1.get_node("Set" + str(i) + "_P1"))
		set_labels_p2_voly.append(sets_container2.get_node("Set" + str(i) + "_P2"))

	set_scores_p1_voly = [0, 0, 0, 0, 0]
	set_scores_p2_voly = [0, 0, 0, 0, 0]

	label_p1_voly = get_node("Sets_Container/VBoxContainer/Points_P1")
	label_p2_voly = get_node("Sets_Container/VBoxContainer2/Points_P2")

	update_score_labels_voly()
	update_set_labels_voly()
	_start_first_set_voly()
	_init_game_over_screen()
	
func _process(delta):
	# Verifica si la escucha está activa y la reinicia si es necesario
	if not is_listening_active_voly:
		_start_listening_voly()
	
	# Actualizar timer del set actual
	if active_set_voly >= 0 and active_set_voly < timer_labels_voly.size() and set_states_voly[active_set_voly] == SetState.EN_PROGRESO:
		set_timers_voly[active_set_voly] += delta
		timer_labels_voly[active_set_voly].text = _format_time_voly(set_timers_voly[active_set_voly])
	
func _update_serve_indicator():
	# Mueve el indicador a la posición correspondiente
	if serving_player == 1:
		serve_indicator.position = Vector2(371, -216)  # Posición izquierda
	else:
		serve_indicator.position = Vector2(371, -28)  # Posición derecha

func update_score_labels_voly():
	# VOLEY: Mostrar puntuación numérica directa
	var max_score = score_options_voly.size() - 1
	label_p1_voly.text = str(min(player1_score_voly, max_score))
	label_p2_voly.text = str(min(player2_score_voly, max_score))

func update_set_labels_voly():
	for i in range(set_labels_p1_voly.size()):
		set_labels_p1_voly[i].text = str(set_scores_p1_voly[i])
		set_labels_p2_voly[i].text = str(set_scores_p2_voly[i])

# VOLEY: Modificar función de incremento de puntos
func _increment_score_voly(player):
	if player == 1:
		player1_score_voly += 1
	else:
		player2_score_voly += 1
	
	# VOLEY: Cambiar saque solo si el punto lo gana el equipo receptor
	if player != serving_player:
		serving_player = player
		_update_serve_indicator()
	
	_check_win_condition_voly()
	update_score_labels_voly()
 

func _check_win_condition_voly():
	var target = 25
	# VOLEY: Set decisivo (5to) a 15 puntos
	if current_set_voly == 4:  
		target = 15

	var diff = abs(player1_score_voly - player2_score_voly)
	var p1 = player1_score_voly
	var p2 = player2_score_voly

	if (p1 >= target or p2 >= target) and diff >= 2:
		var winner = 1 if p1 > p2 else 2
		set_scores_p1_voly[current_set_voly] = p1
		set_scores_p2_voly[current_set_voly] = p2
		if winner == 1:
			sets_ganados_p1_voly += 1
		else:
			sets_ganados_p2_voly += 1
		
		set_states_voly[current_set_voly] = SetState.FINALIZADO
		if current_set_voly < timer_labels_voly.size():
			timer_labels_voly[current_set_voly].modulate = Color(1, 1, 1, 0.5)
		
		update_set_labels_voly()
		var match_finished = _check_match_win_condition_voly()
		_reset_scores_voly()
		
		if not match_finished:
			_prepare_next_set_voly()

func _check_match_win_condition_voly() -> bool:
	# VOLEY: 3 sets ganados para victoria
	if sets_ganados_p1_voly >= 3 or sets_ganados_p2_voly >= 3:
		_end_match_voly()
		return true
	return false

func _reset_scores_voly():
	player1_score_voly = 0
	player2_score_voly = 0
	update_score_labels_voly()

func _reset_game_voly():
	current_set_voly = 0
	set_scores_p1_voly = [0, 0, 0, 0, 0]
	set_scores_p2_voly = [0, 0, 0, 0, 0]
	sets_ganados_p1_voly = 0
	sets_ganados_p2_voly = 0
	set_states_voly = [SetState.NO_INICIADO, SetState.NO_INICIADO, SetState.NO_INICIADO, SetState.NO_INICIADO, SetState.NO_INICIADO]
	set_timers_voly = [0.0, 0.0, 0.0, 0.0, 0.0]
	for label in timer_labels_voly:
		label.text = "00:00"
		label.modulate = Color(1, 1, 1, 0.5)
	update_set_labels_voly()
	_reset_scores_voly()
	_start_first_set_voly()

func _start_first_set_voly():
	current_set_voly = 0
	active_set_voly = 0
	if set_states_voly.size() > 0:
		set_states_voly[0] = SetState.EN_PROGRESO
	if timer_labels_voly.size() > 0:
		timer_labels_voly[0].modulate = Color(1, 1, 1, 1)
		timer_labels_voly[0].text = "00:00"
		set_timers_voly[0] = 0.0
	_apply_serving_rules_for_set(0)

func _end_match_voly():
	var winner = 1 if sets_ganados_p1_voly > sets_ganados_p2_voly else 2
	active_set_voly = -1
	_show_game_over_screen(winner)

func _prepare_next_set_voly():
	current_set_voly += 1
	if current_set_voly >= set_labels_p1_voly.size():
		_end_match_voly()
		return
	active_set_voly = current_set_voly
	set_states_voly[current_set_voly] = SetState.EN_PROGRESO
	set_timers_voly[current_set_voly] = 0.0
	if current_set_voly < timer_labels_voly.size():
		timer_labels_voly[current_set_voly].modulate = Color(1, 1, 1, 1)
		timer_labels_voly[current_set_voly].text = "00:00"
	_apply_serving_rules_for_set(current_set_voly)

func _apply_serving_rules_for_set(set_index: int):
	serving_player = 2 if (set_index % 2 == 0) else 1
	_update_serve_indicator()

func _format_time_voly(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]

func _init_game_over_screen():
	if GAME_OVER_SCENE:
		game_over_screen = GAME_OVER_SCENE.instantiate()
		add_child(game_over_screen)
		game_over_screen.connect("restart_requested", Callable(self, "_on_game_over_restart_requested"))
		game_over_screen.connect("back_to_menu_requested", Callable(self, "_on_game_over_back_to_menu_requested"))

func _show_game_over_screen(winner: int):
	if not game_over_screen:
		return
	var total_time := 0.0
	for time_value in set_timers_voly:
		total_time += time_value
	var winner_label := "Equipo " + str(winner)
	game_over_screen.show_summary(winner_label, set_scores_p1_voly.duplicate(), set_scores_p2_voly.duplicate(), total_time)

func _on_game_over_restart_requested():
	_reset_game_voly()

func _on_game_over_back_to_menu_requested():
	_reset_game_voly()
	get_tree().change_scene_to_file("res://Scenes/Main_Menu.tscn")

func _start_listening_voly():
	if STT_voly and not is_listening_active_voly:
		STT_voly.listen() # Escucha continuamente
		is_listening_active_voly = true

# VOLEY: Funciones de voz adaptadas a equipos
func _on_listening_completed_voly(args):
	var texto = str(args).to_lower()

	if is_listening_for_keyword_voly:
		if keyword_voly in texto:
			$TextEdit.text = "¿Quién ganó el punto? (Di EQUIPO 1 o EQUIPO 2)"
			is_listening_for_keyword_voly = false
	else:
		if "equipo 1" in texto:
			_increment_score_voly(1)
		elif "equipo 2" in texto:
			_increment_score_voly(2)
		
		is_listening_for_keyword_voly = true
		$TextEdit.text = "Di la palabra clave 'GANA'."
	_start_listening_voly()


func _on_button_p_1_pressed():
	_increment_score_voly(1)


func _on_button_p_2_pressed():
	_increment_score_voly(2)


func _on_listen_btn_button_down():
	_start_listening_voly()
