extends Control

# Opciones de puntaje para el juego
var score_options = ["0", "15", "30", "40"]
# Puntaje del jugador 1
var player1_score = 0
# Puntaje del jugador 2
var player2_score = 0
# Label que muestra el puntaje del jugador 1
var label_p1
# Label que muestra el puntaje del jugador 2
var label_p2
# Puntos de los juegos del jugador 1
var game_scores_p1 = [0, 0, 0]
# Puntos de los juegos del jugador 2
var game_scores_p2 = [0, 0, 0]
# Labels que muestran los puntajes de los juegos del jugador 1
var game_labels_p1 = []
# Labels que muestran los puntajes de los juegos del jugador 2
var game_labels_p2 = []
# Indice del juego actual
var current_game_index = 0

var tbreak_label_p1
var tbreak_label_p2

var tbreak_scores_p1 = 0
var tbreak_scores_p2 = 0

var sets_ganados_p1 = 0
var sets_ganados_p2 = 0
var current_set = 0

var serving_player := 1 # 1 = Jugador 1, 2 = Jugador 2

# Variables de control para el tie-break
var is_tiebreak_active = false
var tiebreak_initial_server = 1
var tiebreak_points_since_serve = 0

# Estados posibles para los sets
enum SetState { NO_INICIADO, EN_PROGRESO, FINALIZADO }
# Array para trackear el estado de cada set
var set_states = [SetState.NO_INICIADO, SetState.NO_INICIADO, SetState.NO_INICIADO]
var set_timers = [0.0, 0.0, 0.0]  # Tiempo acumulado por set en segundos
var active_set = -1  # Set actualmente en juego
var timer_labels = []  # Labels para mostrar los tiempos

const GAME_OVER_SCENE := preload("res://Scenes/Game_Over_Screen.tscn")
var game_over_screen

@onready var serve_indicator := $ServeIndicator  # Crear nodo TextureRect en escena

var STT
var is_listening_for_keyword = true  # Estado para escuchar la palabra clave
var keyword = "gana"  # Palabra clave para activar el modo de escucha
var is_listening_active = false  # Estado para verificar si la escucha está activa

func _ready():
	# Solicita permiso para usar el micrófono
	OS.request_permission("RECORD_AUDIO")
	
	# Verifica si el singleton "SpeechToText" está disponible
	if Engine.has_singleton("SpeechToText"):
		STT = Engine.get_singleton("SpeechToText")
		STT.setLanguage("es")
		STT.connect("error", self._on_error)
		STT.connect("listening_completed", self._on_listening_completed)
	
	# Inicia la escucha continua para detectar la palabra clave
		_start_listening()
	else:
		print("Error: El singleton 'SpeechToText' no está disponible.")
	
	# Inicializar labels de tiempo
	var timer_container = get_node("Games_Container/Timer_Container")
	for i in range(1, 4):  # 3 sets en pádel
		timer_labels.append(timer_container.get_node("Set_Timer" + str(i)))
	
	# Obtenemos el contenedor de labels de juegos
	var games_container1 = get_node("Games_Container/VBoxContainer")
	var games_container2 = get_node("Games_Container/VBoxContainer2")

	# Obtenemos los labels para los sets de cada jugador
	for i in range(1, 4):  # Modificado para 3 sets
		game_labels_p1.append(games_container1.get_node("Game" + str(i) + "_P1"))
		game_labels_p2.append(games_container2.get_node("Game" + str(i) + "_P2"))

	# Inicializamos los arreglos de puntaje con ceros
	game_scores_p1 = [0, 0, 0]
	game_scores_p2 = [0, 0, 0]

	# Obtenemos los labels de los puntos de cada jugador
	label_p1 = get_node("Games_Container/VBoxContainer/Points_P1")
	label_p2 = get_node("Games_Container/VBoxContainer2/Points_P2")
	tbreak_label_p1 = get_node("Games_Container/VBoxContainer/TBreak_P1")
	tbreak_label_p2 = get_node("Games_Container/VBoxContainer2/TBreak_P2")

	# Actualizamos los labels iniciales
	update_score_labels()
	update_game_labels()
	
	# Iniciamos el primer set
	_start_first_set()
	_init_game_over_screen()

func _update_serve_indicator():
	# Mueve el indicador a la posición correspondiente
	if serving_player == 1:
		serve_indicator.position = Vector2(371, -216)  # Posición izquierda
	else:
		serve_indicator.position = Vector2(371, -28)  # Posición derecha

var _last_total_games := 0  # Para detectar cambios en juegos

func update_score_labels():
	if player1_score >= score_options.size():
		label_p1.text = score_options[score_options.size()-1]
	else:
		label_p1.text = score_options[player1_score]
	if player2_score >= score_options.size():
		label_p2.text = score_options[score_options.size()-1]
	else:
		label_p2.text = score_options[player2_score]

func update_game_labels():
	for i in range(game_labels_p1.size()):
		game_labels_p1[i].text = str(game_scores_p1[i])
		game_labels_p2[i].text = str(game_scores_p2[i])

# Botón del jugador 1
func _on_button_p_1_pressed():
	_increment_score(1)

# Botón del jugador 2
func _on_button_p_2_pressed():
	_increment_score(2)

func _increment_score(player):
	if player == 1:
		player1_score += 1
	elif player == 2:
		player2_score += 1
	_check_win_condition()
	update_score_labels()

func _check_win_condition():
	var score_diff = abs(player1_score - player2_score)
	if player1_score >= 4 or player2_score >= 4:
		if score_diff >= 1:
			if player1_score > player2_score:
				# Jugador 1 gana el punto
				game_scores_p1[current_game_index] += 1
				player1_score = 3
				player2_score = 0
			else:
				# Jugador 2 gana el punto
				game_scores_p2[current_game_index] += 1
				player1_score = 0
				player2_score = 3
			# Verifica la condición de victoria del set
			_check_set_win_condition()
			update_game_labels()
			_reset_scores()
		elif player1_score == player2_score and player1_score >= 3:
			deuce()

func _check_set_win_condition():
	# Verificamos si el juego actual tiene un ganador o hay un empate a 6
	if (game_scores_p1[current_game_index] >= 6 and game_scores_p2[current_game_index] >= 6) and abs(game_scores_p1[current_game_index] - game_scores_p2[current_game_index]) < 2:
		# Hay un empate a 6, comienza el tie-break
		_start_tie_break()
	elif (game_scores_p1[current_game_index] >= 6 or game_scores_p2[current_game_index] >= 6) and abs(game_scores_p1[current_game_index] - game_scores_p2[current_game_index]) >= 2:
		# Hay un ganador en el juego actual
		if game_scores_p1[current_game_index] > game_scores_p2[current_game_index]:
			sets_ganados_p1 += 1
		else:
			sets_ganados_p2 += 1
		
		# Verificar primero si hay victoria del partido
		if sets_ganados_p1 >= 2 or sets_ganados_p2 >= 2:
			_end_game()
			return
			
		# Si no hay victoria, manejar el cambio de set
		# Marcar el set actual como finalizado
		set_states[current_game_index] = SetState.FINALIZADO
		timer_labels[current_game_index].modulate = Color(1, 1, 1, 0.5)  # Hacer transparente
		
		# Si no es el último set, preparar el siguiente
		if current_game_index < 2:  # 2 es el índice del último set (0-2)
			# Alternar el servicio para el siguiente set
			serving_player = 2 if serving_player == 1 else 1
			_update_serve_indicator()
			
			current_game_index += 1
			_last_total_games = 0  # Reiniciar contador para el nuevo set
			
			# Iniciar el nuevo set
			active_set = current_game_index
			set_states[active_set] = SetState.EN_PROGRESO
			timer_labels[active_set].modulate = Color(1, 1, 1, 1)  # Restaurar opacidad
			timer_labels[active_set].text = "00:00"

func _start_tie_break():
	print("Comienza el Tie-Break")
	# Activar modo tie-break
	is_tiebreak_active = true
	
	# Guardar el servidor inicial del tie-break (el que recibiría en el juego normal)
	tiebreak_initial_server = 2 if serving_player == 1 else 1
	serving_player = tiebreak_initial_server
	_update_serve_indicator()
	
	# Reiniciar contadores
	tbreak_scores_p1 = 0
	tbreak_scores_p2 = 0
	tiebreak_points_since_serve = 0

	# Actualizar UI
	tbreak_label_p1.text = str(tbreak_scores_p1)
	tbreak_label_p2.text = str(tbreak_scores_p2)
	tbreak_label_p1.show()
	tbreak_label_p2.show()
	get_node("TBreak_P1_btn").show()
	get_node("TBreak_P2_btn").show()
	get_node("Button_P1").hide()
	get_node("Button_P2").hide()

func _increment_tiebreak_score(player):
	if not is_tiebreak_active:
		return
		
	if player == 1:
		tbreak_scores_p1 += 1
		tbreak_label_p1.text = str(tbreak_scores_p1)
	elif player == 2:
		tbreak_scores_p2 += 1
		tbreak_label_p2.text = str(tbreak_scores_p2)
	
	# Incrementar contador de puntos desde último cambio de servicio
	tiebreak_points_since_serve += 1
	
	# En el tie-break, el servicio cambia cada 2 puntos
	# Excepto el primer punto donde solo sirve una vez
	if (tbreak_scores_p1 + tbreak_scores_p2 == 1) or (tiebreak_points_since_serve >= 2):
		serving_player = 2 if serving_player == 1 else 1
		tiebreak_points_since_serve = 0
		_update_serve_indicator()
	
	_check_tiebreak_win_condition()

func _check_tiebreak_win_condition():
	if not is_tiebreak_active:
		return
		
	# Verificar si un jugador ganó el tie-break
	if (tbreak_scores_p1 >= 7 or tbreak_scores_p2 >= 7) and abs(tbreak_scores_p1 - tbreak_scores_p2) >= 2:
		# Determinar ganador
		var winner = 1 if tbreak_scores_p1 > tbreak_scores_p2 else 2
		print("Jugador " + str(winner) + " ganó el Tie-Break")
		
		# Actualizar marcador del set
		if winner == 1:
			game_scores_p1[current_game_index] = 7
			sets_ganados_p1 += 1
		else:
			game_scores_p2[current_game_index] = 7
			sets_ganados_p2 += 1
			
		# Finalizar el set actual
		set_states[current_game_index] = SetState.FINALIZADO
		timer_labels[current_game_index].modulate = Color(1, 1, 1, 0.5)
		
		# Restaurar UI
		tbreak_label_p1.hide()
		tbreak_label_p2.hide()
		get_node("TBreak_P1_btn").hide()
		get_node("TBreak_P2_btn").hide()
		get_node("Button_P1").show()
		get_node("Button_P2").show()
		
		# Actualizar marcadores
		update_game_labels()
		
		# Desactivar modo tie-break
		is_tiebreak_active = false
		
		# Preparar servicio para el siguiente set
		serving_player = tiebreak_initial_server
		
		# Verificar si el partido ha terminado o continuar con el siguiente set
		if sets_ganados_p1 >= 2 or sets_ganados_p2 >= 2:
			_end_game()
		else:
			# Preparar siguiente set si el partido continúa
			if current_game_index < 2:  # Modificado para pádel (3 sets)
				current_game_index += 1
				_last_total_games = 0
				active_set = current_game_index
				set_states[active_set] = SetState.EN_PROGRESO
				timer_labels[active_set].modulate = Color(1, 1, 1, 1)
				timer_labels[active_set].text = "00:00"
				_update_serve_indicator()

func _end_game():
	# Verificar si algún jugador ya ganó el partido
	if sets_ganados_p1 >= 2 or sets_ganados_p2 >= 2:
		# Asegurar que el último set quede marcado como finalizado
		if active_set >= 0:
			set_states[active_set] = SetState.FINALIZADO
			timer_labels[active_set].modulate = Color(1, 1, 1, 0.5)
		
		# Determinar quien gano el juego
		var winner = 1 if sets_ganados_p1 > sets_ganados_p2 else 2
		print("Juego terminado. Ganador: Jugador " + str(winner))
		active_set = -1
		_show_game_over_screen(winner)
		return  # Finalizamos la función aqui

	# Cambiamos el saque al terminar el set
	serving_player = 2 if serving_player == 1 else 1
	_update_serve_indicator()
	_last_total_games = 0  # Reiniciamos el contador de juegos para el nuevo set
	
	# Avanzamos al siguiente juego si la condición de victoria no se cumplió
	current_game_index += 1

	# Si ya se jugaron todos los sets, se reinicia el juego
	if current_game_index >= 3:
		print("Juego terminado por completar todos los sets")
		# Aquí puedes implementar lógica para finalizar el juego o reiniciarlo
		current_game_index = 0
		game_scores_p1 = [0, 0, 0]
		game_scores_p2 = [0, 0, 0]
		sets_ganados_p1 = 0
		sets_ganados_p2 = 0
		serving_player = 1  # Reiniciamos el saque al jugador 1 al iniciar un nuevo partido
		_update_serve_indicator()

func _reset_game():
	sets_ganados_p1 = 0
	sets_ganados_p2 = 0
	current_set = 0
	current_game_index = 0
	game_scores_p1 = [0, 0, 0]
	game_scores_p2 = [0, 0, 0]
	_last_total_games = 0  # Reiniciar el contador de juegos totales
	serving_player = 1  # Reiniciar al jugador que saca al inicio del partido
	_update_serve_indicator()

	# Reiniciar todos los timers y estados
	set_timers = [0.0, 0.0, 0.0]
	set_states = [SetState.NO_INICIADO, SetState.NO_INICIADO, SetState.NO_INICIADO]
	active_set = -1

	for label in timer_labels:
		label.text = "00:00"
		label.modulate = Color(1, 1, 1, 0.5)

	# Reiniciar estado del tie-break
	is_tiebreak_active = false
	tiebreak_points_since_serve = 0
	tbreak_scores_p1 = 0
	tbreak_scores_p2 = 0
	tbreak_label_p1.hide()
	tbreak_label_p2.hide()
	get_node("TBreak_P1_btn").hide()
	get_node("TBreak_P2_btn").hide()

	update_score_labels()
	update_game_labels()

	# Iniciar el primer set
	_start_first_set()

# Un ejemplo de llamada a _check_set_win_condition()
func _jugar_set(puntos_p1, puntos_p2):
	game_scores_p1[current_set] = puntos_p1
	game_scores_p2[current_set] = puntos_p2
	_check_set_win_condition()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_jugar_set(2, 4)
	if event.is_action_pressed("ui_cancel"):
		_jugar_set(4, 2)

func deuce():
	player1_score = 3
	player2_score = 3

func _reset_scores():
	player1_score = 0
	player2_score = 0
	update_score_labels()
	
#Función para iniciar la escucha
func _start_listening():
	if STT and not is_listening_active:
		STT.listen() # Escucha continuamente
		is_listening_active = true
	
# Función que se llama cuando se completa la escucha
func _on_listening_completed(args):
	var recognized_text = str(args).to_lower()  # Convierte el texto a minúsculas
	
	if is_listening_for_keyword:
		# Verifica si el texto reconocido contiene la palabra clave
		if keyword in recognized_text:
			print("Palabra clave detectada. Activando modo de escucha...")
			is_listening_for_keyword = false  # Deja de escuchar la palabra clave
			$TextEdit.text = "Quien gano el punto? ('Di EQUIPO 1 o EQUIPO 2')"
	else:
		# Verifica si la frase es "equipo 1" o "equipo 2"
		if "equipo 1" in recognized_text:
			# Verifica qué botón está visible y activa la función correspondiente
			if $Button_P1.visible:
				print("Activando función del botón 'Button_P1'")
				_on_button_p_1_pressed()  # Llama a la función del botón "Button_P1"
			elif $TBreak_P1_btn.visible:
				print("Activando función del botón 'TBreak_P1_btn'")
				_on_t_break_p_1_btn_pressed()  # Llama a la función del botón "TBreak_P1_btn"
			else:
				print("Ningún botón del equipo 1 está visible.")
		
		elif "equipo 2" in recognized_text:
			# Verifica qué botón está visible y activa la función correspondiente
			if $Button_P2.visible:
				print("Activando función del botón 'Button_P2'")
				_on_button_p_2_pressed()  # Llama a la función del botón "Button_P2"
			elif $TBreak_P2_btn.visible:
				print("Activando función del botón 'TBreak_P2_btn'")
				_on_t_break_p_2_btn_pressed()  # Llama a la función del botón "TBreak_P2_btn"
			else:
				print("Ningún botón del equipo 2 está visible.")
		
		else:
			print("Frase no reconocida: ", recognized_text)
		
		# Vuelve a escuchar la palabra clave
		is_listening_for_keyword = true
		$TextEdit.text = "Di la palabra clave 'GANA'."
	
	# Reinicia la escucha después de procesar el texto
	is_listening_active = false  # Marca la escucha como inactiva
	_start_listening()  # Reinicia la escucha

func _on_error(errorcode):
	print("Error: " + errorcode)
	#Reinicia la escucha en caso de error
	is_listening_active = false  # Marca la escucha como inactiva
	_start_listening()
	
# Función que se llama cada frame
func _process(delta):
	# Actualizar timer del set actual
	if active_set >= 0 and active_set < 3 and set_states[active_set] == SetState.EN_PROGRESO:
		set_timers[active_set] += delta
		timer_labels[active_set].text = _format_time(set_timers[active_set])
	
	# Verifica si la escucha está activa y la reinicia si es necesario
	if not is_listening_active:
		_start_listening()
		
	# Lógica para detectar cambio de saque cada juego
	var current_total = game_scores_p1[current_game_index] + game_scores_p2[current_game_index]
	
	if current_total > _last_total_games:
		serving_player = 2 if serving_player == 1 else 1
		_update_serve_indicator()
		_last_total_games = current_total
	
##Botón de tie-breal del jugador 1
func _on_t_break_p_1_btn_pressed():
	_increment_tiebreak_score(1)

#Botón de tie-breal del jugador 2
func _on_t_break_p_2_btn_pressed():
	_increment_tiebreak_score(2)

func _on_listen_btn_button_down():
	_start_listening()
	pass # Replace with function body.

func _on_stop_btn_button_down():
	#STT.Stop()
	if STT:
		STT.Stop()
		is_listening_active = false  # Marca la escucha como inactiva
	pass # Replace with function body.

func _on_get_output_btn_button_down():
	#var words = STT.getWords()
	#$TextEdit2.text = words
	if STT:
		var words = STT.getWords()
		$TextEdit2.text = words
	pass # Replace with function body.

func _start_first_set():
	# Reiniciar variables del juego
	sets_ganados_p1 = 0
	sets_ganados_p2 = 0
	current_set = 0
	game_scores_p1 = [0, 0, 0]
	game_scores_p2 = [0, 0, 0]
	serving_player = 1  # Reiniciamos el saque al jugador 1 al iniciar un nuevo partido
	_update_serve_indicator()
	
	# Inicializar el primer set y su timer
	active_set = 0  # Activamos el primer set
	set_states[0] = SetState.EN_PROGRESO  # Marcamos el primer set como en progreso
	timer_labels[0].modulate = Color(1, 1, 1, 1)  # Opacidad normal para el primer timer
	timer_labels[0].text = "00:00"  # Inicializamos el texto del timer

func _format_time(seconds: float) -> String:
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
	for time_value in set_timers:
		total_time += time_value
	var winner_label := "Jugador " + str(winner)
	game_over_screen.show_summary(winner_label, game_scores_p1.duplicate(), game_scores_p2.duplicate(), total_time)

func _on_game_over_restart_requested():
	_reset_game()

func _on_game_over_back_to_menu_requested():
	_reset_game()
	get_tree().change_scene_to_file("res://Scenes/Main_Menu.tscn")
