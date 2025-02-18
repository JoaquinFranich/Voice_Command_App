#extends Control
#
## Opciones de puntaje para el juego
#var score_options = ["0", "15", "30", "40", "Deuce", "Advantage"]
## Puntaje del jugador 1
#var player1_score = 0
## Puntaje del jugador 2
#var player2_score = 0
## Label que muestra el puntaje del jugador 1
#var label_p1
## Label que muestra el puntaje del jugador 2
#var label_p2
## Puntos de los juegos del jugador 1
#var game_scores_p1 = [0, 0, 0, 0, 0]
## Puntos de los juegos del jugador 2
#var game_scores_p2 = [0, 0, 0, 0, 0]
## Labels que muestran los puntajes de los juegos del jugador 1
#var game_labels_p1 = []
## Labels que muestran los puntajes de los juegos del jugador 2
#var game_labels_p2 = []
## Indice del juego actual
#var current_game_index = 0
#
#var tbreak_label_p1
#var tbreak_label_p2
#
#var tbreak_scores_p1 = 0
#var tbreak_scores_p2 = 0
#
#var sets_ganados_p1 = 0
#var sets_ganados_p2 = 0
#var current_set = 0
#
#func _ready():
	## Obtenemos el contenedor de labels de juegos
	#var games_container = get_node("Games_Container")
#
	## Obtenemos los labels para los sets de cada jugador
	#for i in range(1, 6):
		#game_labels_p1.append(games_container.get_node("Game" + str(i) + "_P1"))
		#game_labels_p2.append(games_container.get_node("Game" + str(i) + "_P2"))
#
	## Inicializamos los arreglos de puntaje con ceros
	#game_scores_p1 = [0, 0, 0, 0, 0]
	#game_scores_p2 = [0, 0, 0, 0, 0]
#
	## Obtenemos los labels de los puntos de cada jugador
	#label_p1 = get_node("Points_P1")
	#label_p2 = get_node("Points_P2")
	#tbreak_label_p1 = get_node("Games_Container/TBreak_P1")
	#tbreak_label_p2 = get_node("Games_Container/TBreak_P2")
#
	## Actualizamos los labels iniciales
	#update_score_labels()
	#update_game_labels()
#
#func update_score_labels():
	#if player1_score >= score_options.size():
		#label_p1.text = score_options[score_options.size()-1]
	#else:
		#label_p1.text = score_options[player1_score]
	#if player2_score >= score_options.size():
		#label_p2.text = score_options[score_options.size()-1]
	#else:
		#label_p2.text = score_options[player2_score]
#
#func update_game_labels():
	#for i in range(game_labels_p1.size()):
		#game_labels_p1[i].text = str(game_scores_p1[i])
		#game_labels_p2[i].text = str(game_scores_p2[i])
#
## Botón del jugador 1
#func _on_button_p_1_pressed():
	#_increment_score(1)
#
## Botón del jugador 2
#func _on_button_p_2_pressed():
	#_increment_score(2)
#
#func _increment_score(player):
	#if player == 1:
		#player1_score += 1
	#elif player == 2:
		#player2_score += 1
	#_check_win_condition()
	#update_score_labels()
#
#func _check_win_condition():
	#var score_diff = abs(player1_score - player2_score)
	#if player1_score >= 4 or player2_score >= 4:
		#if score_diff >= 2:
			#if player1_score > player2_score:
				## Jugador 1 gana el punto
				#game_scores_p1[current_game_index] += 1
				#player1_score = 5
				#player2_score = 0
			#else:
				## Jugador 2 gana el punto
				#game_scores_p2[current_game_index] += 1
				#player1_score = 0
				#player2_score = 5
			## Verifica la condición de victoria del set
			#_check_set_win_condition()
			#update_game_labels()
			#_reset_scores()
		#elif player1_score == player2_score and player1_score >= 3:
			#deuce()
#
#func _check_set_win_condition():
	## Verificamos si el juego actual tiene un ganador o hay un empate a 6
	#if (game_scores_p1[current_game_index] >= 6 and game_scores_p2[current_game_index] >= 6) and abs(game_scores_p1[current_game_index] - game_scores_p2[current_game_index]) < 2:
		## Hay un empate a 6, comienza el tie-break
		#_start_tie_break()
	#elif (game_scores_p1[current_game_index] >= 6 or game_scores_p2[current_game_index] >= 6) and abs(game_scores_p1[current_game_index] - game_scores_p2[current_game_index]) >= 2:
		## Hay un ganador en el juego actual
		#if game_scores_p1[current_game_index] > game_scores_p2[current_game_index]:
			#sets_ganados_p1 += 1
		#else:
			#sets_ganados_p2 += 1
		#_end_game()
#
#func _start_tie_break():
	#print("Comienza el Tie-Break")
	## Inicializar el marcador del tie-break
	#tbreak_scores_p1 = 0
	#tbreak_scores_p2 = 0
#
	## Habilitar la visualización de los marcadores del tie-break
	#tbreak_label_p1.text = str(tbreak_scores_p1)
	#tbreak_label_p2.text = str(tbreak_scores_p2)
	#tbreak_label_p1.show()
	#tbreak_label_p2.show()
	#get_node("TBreak_P1_btn").show()
	#get_node("TBreak_P2_btn").show()
	## Lógica adicional del tie-break (incrementar puntos y determinar ganador).
	## Esto va en otro método que se ejecutara cuando se asigne un punto
	#_check_tiebreak_win_condition()
#
#func _check_tiebreak_win_condition():
	## Verificar si un jugador gano el tie-break
	#if (tbreak_scores_p1 >= 7 or tbreak_scores_p2 >= 7) and abs(tbreak_scores_p1 - tbreak_scores_p2) >= 2:
		## En este punto un jugador gano el set, por tiebreak
		#if tbreak_scores_p1 > tbreak_scores_p2:
			#print("Jugador 1 gano el Tie-Break")
			#game_scores_p1[current_game_index] = 7  # Incrementa el puntaje del set
			#sets_ganados_p1 += 1
			#update_game_labels()
		#else:
			#print("Jugador 2 gano el Tie-Break")
			#game_scores_p2[current_game_index] = 7  # Incrementa el puntaje del set
			#sets_ganados_p2 += 1
			#update_game_labels()
		## Ocultar la visualización de los labels
		#tbreak_label_p1.hide()
		#tbreak_label_p2.hide()
		#get_node("TBreak_P1_btn").hide()
		#get_node("TBreak_P2_btn").hide()
		#_end_game()
	#else:
		## El tiebreak continua
		#print("El tie-break continua")
#
#func _increment_tiebreak_score(player):
	#if player == 1:
		#tbreak_scores_p1 += 1
		#tbreak_label_p1.text = str(tbreak_scores_p1)
	#elif player == 2:
		#tbreak_scores_p2 += 1
		#tbreak_label_p2.text = str(tbreak_scores_p2)
	#_check_tiebreak_win_condition()
#
#func _end_game():
	## Verificar si algún jugador ya ganó el partido
	#if sets_ganados_p1 >= 3 or sets_ganados_p2 >= 3:
		## Determinar quien gano el juego
		#if sets_ganados_p1 > sets_ganados_p2:
			#print("Juego terminado. Ganador: Jugador 1")
		#else:
			#print("Juego terminado. Ganador: Jugador 2")
		## Aquí puedes implementar lógica adicional para finalizar el juego o reiniciarlo
		#current_game_index = 0
		#game_scores_p1 = [0, 0, 0, 0, 0]
		#game_scores_p2 = [0, 0, 0, 0, 0]
		#sets_ganados_p1 = 0
		#sets_ganados_p2 = 0
		#return  # Finalizamos la función aqui
#
	## Avanzamos al siguiente juego si la condición de victoria no se cumplió
	#current_game_index += 1
#
	## Si ya se jugaron todos los sets, se reinicia el juego
	#if current_game_index >= 5:
		#print("Juego terminado por completar todos los sets")
		## Aquí puedes implementar lógica para finalizar el juego o reiniciarlo
		#current_game_index = 0
		#game_scores_p1 = [0, 0, 0, 0, 0]
		#game_scores_p2 = [0, 0, 0, 0, 0]
		#sets_ganados_p1 = 0
		#sets_ganados_p2 = 0
#
#func _reset_game():
	#sets_ganados_p1 = 0
	#sets_ganados_p2 = 0
	#current_set = 0
	#game_scores_p1 = [0, 0, 0, 0, 0]
	#game_scores_p2 = [0, 0, 0, 0, 0]
#
## Un ejemplo de llamada a _check_set_win_condition()
#func _jugar_set(puntos_p1, puntos_p2):
	#game_scores_p1[current_set] = puntos_p1
	#game_scores_p2[current_set] = puntos_p2
	#_check_set_win_condition()
#
#func _input(event):
	#if event.is_action_pressed("ui_accept"):
		#_jugar_set(2, 4)
	#if event.is_action_pressed("ui_cancel"):
		#_jugar_set(4, 2)
#
#func deuce():
	#player1_score = 4
	#player2_score = 4
#
#func _reset_scores():
	#player1_score = 0
	#player2_score = 0
	#update_score_labels()
#
#func _on_t_break_p_1_btn_pressed():
	#_increment_tiebreak_score(1)
#
#func _on_t_break_p_2_btn_pressed():
	#_increment_tiebreak_score(2)


extends Control

# Opciones de puntaje para el juego
var score_options = ["0", "15", "30", "40", "Deuce", "Advantage"]
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

func _ready():
	# Obtenemos el contenedor de labels de juegos
	var games_container = get_node("Games_Container")

	# Obtenemos los labels para los sets de cada jugador
	for i in range(1, 6):
		game_labels_p1.append(games_container.get_node("Game" + str(i) + "_P1"))
		game_labels_p2.append(games_container.get_node("Game" + str(i) + "_P2"))

	# Inicializamos los arreglos de puntaje con ceros
	game_scores_p1 = [0, 0, 0, 0, 0]
	game_scores_p2 = [0, 0, 0, 0, 0]

	# Obtenemos los labels de los puntos de cada jugador
	label_p1 = get_node("Points_P1")
	label_p2 = get_node("Points_P2")
	tbreak_label_p1 = get_node("Games_Container/TBreak_P1")
	tbreak_label_p2 = get_node("Games_Container/TBreak_P2")

	# Actualizamos los labels iniciales
	update_score_labels()
	update_game_labels()

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
	if sets_ganados_p1 >= 3 or sets_ganados_p2 >= 3:
		# Determinar quien gano el juego
		if sets_ganados_p1 > sets_ganados_p2:
			print("Juego terminado. Ganador: Jugador 1")
		else:
			print("Juego terminado. Ganador: Jugador 2")
		# Aquí puedes implementar lógica adicional para finalizar el juego o reiniciarlo
		current_game_index = 0
		game_scores_p1 = [0, 0, 0, 0, 0]
		game_scores_p2 = [0, 0, 0, 0, 0]
		sets_ganados_p1 = 0
		sets_ganados_p2 = 0
		return  # Finalizamos la función aqui

	# Avanzamos al siguiente juego si la condición de victoria no se cumplió
	current_game_index += 1

	# Si ya se jugaron todos los sets, se reinicia el juego
	if current_game_index >= 5:
		print("Juego terminado por completar todos los sets")
		# Aquí puedes implementar lógica para finalizar el juego o reiniciarlo
		current_game_index = 0
		game_scores_p1 = [0, 0, 0, 0, 0]
		game_scores_p2 = [0, 0, 0, 0, 0]
		sets_ganados_p1 = 0
		sets_ganados_p2 = 0

func _reset_game():
	sets_ganados_p1 = 0
	sets_ganados_p2 = 0
	current_set = 0
	game_scores_p1 = [0, 0, 0, 0, 0]
	game_scores_p2 = [0, 0, 0, 0, 0]

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
	player1_score = 4
	player2_score = 4

func _reset_scores():
	player1_score = 0
	player2_score = 0
	update_score_labels()

func _on_t_break_p_1_btn_pressed():
	_increment_tiebreak_score(1)

func _on_t_break_p_2_btn_pressed():
	_increment_tiebreak_score(2)
