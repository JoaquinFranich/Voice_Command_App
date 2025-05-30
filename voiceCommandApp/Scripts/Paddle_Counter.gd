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
	
	
	# Obtenemos el contenedor de labels de juegos
	var games_container1 = get_node("Games_Container/VBoxContainer")
	var games_container2 = get_node("Games_Container/VBoxContainer2")

	# Obtenemos los labels para los sets de cada jugador
	for i in range(1, 4):
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
		_end_game()

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
	if sets_ganados_p1 >= 2 or sets_ganados_p2 >= 2:
		# Determinar quien gano el juego
		if sets_ganados_p1 > sets_ganados_p2:
			print("Juego terminado. Ganador: Jugador 1")
		else:
			print("Juego terminado. Ganador: Jugador 2")
		# Aquí puedes implementar lógica adicional para finalizar el juego o reiniciarlo
		current_game_index = 0
		game_scores_p1 = [0, 0, 0]
		game_scores_p2 = [0, 0, 0]
		sets_ganados_p1 = 0
		sets_ganados_p2 = 0
		serving_player = 1  # Reiniciamos el saque al jugador 1 al iniciar un nuevo partido
		_update_serve_indicator()
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
	game_scores_p1 = [0, 0, 0]
	game_scores_p2 = [0, 0, 0]

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
