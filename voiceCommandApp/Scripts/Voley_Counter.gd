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

# VOLEY: Lógica de cambio de saque según reglas oficiales
var _last_serving_team := 1  # Para controlar saque inicial por set
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
	
func _process(delta):
	# Verifica si la escucha está activa y la reinicia si es necesario
	if not is_listening_active_voly:
		_start_listening_voly()
		
	 # VOLEY: Cambio automático de saque al iniciar nuevo set
	if _last_serving_team != current_set_voly:
		serving_player = 2 if (current_set_voly % 2 == 0) else 1
		_update_serve_indicator()
		_last_serving_team = current_set_voly
	
func _update_serve_indicator():
	# Mueve el indicador a la posición correspondiente
	if serving_player == 1:
		serve_indicator.position = Vector2(371, -216)  # Posición izquierda
	else:
		serve_indicator.position = Vector2(371, -28)  # Posición derecha

var _last_total_games := 0  # Para detectar cambios en juegos

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

	if (p1 >= target || p2 >= target) && diff >= 2:
		if p1 > p2:
			set_scores_p1_voly[current_set_voly] = 1
			sets_ganados_p1_voly += 1
		else:
			set_scores_p2_voly[current_set_voly] = 1
			sets_ganados_p2_voly += 1
		
		_check_match_win_condition_voly()
		update_set_labels_voly()
		_reset_scores_voly()

func _check_match_win_condition_voly():
	# VOLEY: 3 sets ganados para victoria
	if sets_ganados_p1_voly >= 3 || sets_ganados_p2_voly >= 3:
		print("Partido terminado. Ganador: %s" % ["Equipo 1" if sets_ganados_p1_voly > sets_ganados_p2_voly else "Equipo 2"])
		_reset_game_voly()
	else:
		current_set_voly += 1
		if current_set_voly >= 5:
			print("Máximo de sets alcanzado")
			_reset_game_voly()

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
	_reset_scores_voly()

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
