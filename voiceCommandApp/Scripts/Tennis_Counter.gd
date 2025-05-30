extends Control

# Opciones de puntaje para el juego
var score_options = ["0", "15", "30", "40", "D", "AD"]
# Puntaje del jugador 1
var player1_score = 0
# Puntaje del jugador 2
var player2_score = 0
# Label que muestra el puntaje del jugador 1
var label_p1
# Label que muestra el puntaje del jugador 2
var label_p2
# Puntos de los juegos del jugador 1
var game_scores_p1 = [0, 0, 0, 0, 0]
# Puntos de los juegos del jugador 2
var game_scores_p2 = [0, 0, 0, 0, 0]
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

# Estados posibles para los sets
enum SetState { NO_INICIADO, EN_PROGRESO, FINALIZADO }
# Array para trackear el estado de cada set
var set_states = [SetState.NO_INICIADO, SetState.NO_INICIADO, SetState.NO_INICIADO, SetState.NO_INICIADO, SetState.NO_INICIADO]
var set_timers = [0.0, 0.0, 0.0, 0.0, 0.0]  # Tiempo acumulado por set en segundos
var active_set = -1  # Set actualmente en juego
var timer_labels = []  # Labels para mostrar los tiempos

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
	for i in range(1, 6):
		timer_labels.append(timer_container.get_node("Set_Timer" + str(i)))
	
	# Obtenemos el contenedor de labels de juegos
	var games_container1 = get_node("Games_Container/VBoxContainer")
	var games_container2 = get_node("Games_Container/VBoxContainer2")

	# Obtenemos los labels para los sets de cada jugador
	for i in range(1, 6):
		game_labels_p1.append(games_container1.get_node("Game" + str(i) + "_P1"))
		game_labels_p2.append(games_container2.get_node("Game" + str(i) + "_P2"))

	# Inicializamos los arreglos de puntaje con ceros
	game_scores_p1 = [0, 0, 0, 0, 0]
	game_scores_p2 = [0, 0, 0, 0, 0]

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

# Función para formatear el tiempo
func _format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]
	
func _update_serve_indicator():
	# Mueve el indicador a la posición correspondiente
	if serving_player == 1:
		serve_indicator.position = Vector2(408, -184)  # Posición izquierda
	else:
		serve_indicator.position = Vector2(408, -16)  # Posición derecha

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
		if score_diff >= 2:
			if player1_score > player2_score:
				# Jugador 1 gana el punto
				game_scores_p1[current_game_index] += 1
				player1_score = 5
				player2_score = 0
			else:
				# Jugador 2 gana el punto
				game_scores_p2[current_game_index] += 1
				player1_score = 0
				player2_score = 5
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
		if sets_ganados_p1 >= 3 or sets_ganados_p2 >= 3:
			_end_game()
			return
			
		# Si no hay victoria, manejar el cambio de set
		# Marcar el set actual como finalizado
		set_states[current_game_index] = SetState.FINALIZADO
		timer_labels[current_game_index].modulate = Color(1, 1, 1, 0.5)  # Hacer transparente
		
		# Si no es el último set, preparar el siguiente
		if current_game_index < 4:  # 4 es el índice del último set (0-4)
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
	# Inicializar el marcador del tie-break
	tbreak_scores_p1 = 0
	tbreak_scores_p2 = 0

	# Habilitar la visualización de los marcadores del tie-break
	tbreak_label_p1.text = str(tbreak_scores_p1)
	tbreak_label_p2.text = str(tbreak_scores_p2)
	tbreak_label_p1.show()
	tbreak_label_p2.show()
	get_node("TBreak_P1_btn").show()
	get_node("TBreak_P2_btn").show()
	get_node("Button_P1").hide()
	get_node("Button_P2").hide()
	# Lógica adicional del tie-break (incrementar puntos y determinar ganador).
	# Esto va en otro método que se ejecutara cuando se asigne un punto
	_check_tiebreak_win_condition()

func _check_tiebreak_win_condition():
	# Verificar si un jugador gano el tie-break
	if (tbreak_scores_p1 >= 7 or tbreak_scores_p2 >= 7) and abs(tbreak_scores_p1 - tbreak_scores_p2) >= 2:
		# En este punto un jugador gano el set, por tiebreak
		if tbreak_scores_p1 > tbreak_scores_p2:
			print("Jugador 1 gano el Tie-Break")
			game_scores_p1[current_game_index] = 7  # Incrementa el puntaje del set
			sets_ganados_p1 += 1
			update_game_labels()
		else:
			print("Jugador 2 gano el Tie-Break")
			game_scores_p2[current_game_index] = 7  # Incrementa el puntaje del set
			sets_ganados_p2 += 1
			update_game_labels()
		# Ocultar la visualización de los labels
		tbreak_label_p1.hide()
		tbreak_label_p2.hide()
		get_node("TBreak_P1_btn").hide()
		get_node("TBreak_P2_btn").hide()
		get_node("Button_P1").show()
		get_node("Button_P2").show()
		update_game_labels()
		_end_game()
	else:
		# El tiebreak continua
		print("El tie-break continua")

func _increment_tiebreak_score(player):
	if player == 1:
		tbreak_scores_p1 += 1
		tbreak_label_p1.text = str(tbreak_scores_p1)
	elif player == 2:
		tbreak_scores_p2 += 1
		tbreak_label_p2.text = str(tbreak_scores_p2)
	_check_tiebreak_win_condition()

func _end_game():
	# Verificar si algún jugador ya ganó el partido
	if sets_ganados_p1 >= 3 or sets_ganados_p2 >= 3:
		# Asegurar que el último set quede marcado como finalizado
		if active_set >= 0:
			set_states[active_set] = SetState.FINALIZADO
			timer_labels[active_set].modulate = Color(1, 1, 1, 0.5)
		
		# Determinar quien gano el juego
		if sets_ganados_p1 > sets_ganados_p2:
			print("Juego terminado. Ganador: Jugador 1")
		else:
			print("Juego terminado. Ganador: Jugador 2")
			
		# Reiniciar el juego usando la función _reset_game
		_reset_game()
		return  # Finalizamos la función aqui

	# Si el juego no ha terminado, el cambio de set ya se manejó en _check_set_win_condition

func _reset_game():
	sets_ganados_p1 = 0
	sets_ganados_p2 = 0
	current_set = 0
	game_scores_p1 = [0, 0, 0, 0, 0]
	game_scores_p2 = [0, 0, 0, 0, 0]
	_last_total_games = 0  # Reiniciar el contador de juegos totales
	serving_player = 1  # Reiniciar al jugador que saca al inicio del partido
	_update_serve_indicator()
	
	# Reiniciar todos los timers y estados
	set_timers = [0.0, 0.0, 0.0, 0.0, 0.0]
	set_states = [SetState.NO_INICIADO, SetState.NO_INICIADO, SetState.NO_INICIADO, SetState.NO_INICIADO, SetState.NO_INICIADO]
	active_set = -1
	for label in timer_labels:
		label.text = "00:00"
		label.modulate = Color(1, 1, 1, 0.5)
	
	# Iniciar el primer set
	_start_first_set()

# Un ejemplo de llamada a _check_set_win_condition()
func _jugar_set(puntos_p1, puntos_p2):
	game_scores_p1[current_set] = puntos_p1
	game_scores_p2[current_set] = puntos_p2
	_check_set_win_condition()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_test_serve_indicator()
	if event.is_action_pressed("ui_cancel"):
		_jugar_set(4, 2)

func deuce():
	player1_score = 4
	player2_score = 4

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
	if active_set >= 0 && active_set < 5 && set_states[active_set] == SetState.EN_PROGRESO:
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

# Función para iniciar el primer set
func _start_first_set():
	active_set = 0  # Activamos el primer set
	set_states[0] = SetState.EN_PROGRESO  # Marcamos el primer set como en progreso
	timer_labels[0].modulate = Color(1, 1, 1, 1)  # Opacidad normal para el primer timer
	timer_labels[0].text = "00:00"  # Inicializamos el texto del timer

# Función para probar el ServeIndicator
func _test_serve_indicator():
	print("Iniciando prueba del ServeIndicator")
	print("Servicio inicial: Jugador ", serving_player)
	
	# Simular primer set
	var points_sequence = [
		[1, 0], # Jugador 1 gana
		[1, 1], # Jugador 2 gana
		[2, 1], # Jugador 1 gana
		[3, 1], # Jugador 1 gana
		[3, 2], # Jugador 2 gana
		[4, 2], # Jugador 1 gana
		[4, 3], # Jugador 2 gana
		[5, 3], # Jugador 1 gana
		[5, 4], # Jugador 2 gana
		[6, 4]  # Jugador 1 gana el set
	]
	
	print("\nSimulando Primer Set:")
	for points in points_sequence:
		game_scores_p1[current_game_index] = points[0]
		game_scores_p2[current_game_index] = points[1]
		print("Puntuación: ", points[0], "-", points[1], " | Sirve: Jugador ", serving_player)
		if points[0] == 6 or points[1] == 6:
			_check_set_win_condition()
			print("\nFin del Set | Nuevo servidor: Jugador ", serving_player)
	
	print("\nIniciando Segundo Set | Sirve: Jugador ", serving_player)
