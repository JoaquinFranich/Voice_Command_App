#extends Control
#
## Array que almacena las opciones de puntaje para el tenis/pÃ¡del
#var score_options = ["0", "15", "30", "40", "Deuce", "Advantage"]
## Variable que almacena el Ã­ndice actual del puntaje del jugador 1
##var player1_score_index = 0
#var player1_score = 0
## Variable que almacena el Ã­ndice actual del puntaje del jugador 2
##var player2_score_index = 0
#var player2_score = 0
## Variable para referenciar el nodo Label que muestra el puntaje del jugador 1
#var label_p1
## Variable para referenciar el nodo Label que muestra el puntaje del jugador 2
#var label_p2
#
## Funcion que se llama cuando el nodo entra en el Arbol de la escena
#func _ready():
	## Obtiene las referencias a los nodos Label utilizando sus nombres
	#label_p1 = get_node("Points_P1")
	#label_p2 = get_node("Points_P2")
	## Llama a la funcion para inicializar la visualizacion de los puntajes
	#update_score_labels()
#
## Funcion que actualiza los nodos Label con los puntajes actuales
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
## Funcion que se llama cuando se presiona el boton del jugador 1
#func _on_button_p_1_pressed():
	## Llama a la funcion para incrementar el puntaje del jugador 1
	#_increment_score(1)
#
## Funcion que se llama cuando se presiona el boton del jugador 2
#func _on_button_p_2_pressed():
	## Llama a la funcion para incrementar el puntaje del jugador 2
	#_increment_score(2)
#
#func _increment_score(player):
	#if player == 1:
		#player1_score += 1
	#elif player == 2:
		#player2_score += 1
	#
	#_check_win_condition()
	#update_score_labels()
#
#func _check_win_condition():
	#var score_diff = abs(player1_score - player2_score)
#
	#if player1_score >= 4 or player2_score >= 4:
		#if score_diff >= 2:
			#if player1_score > player2_score:
				#player1_score = 5
				#player2_score = 0
			#else:
				#player1_score = 0
				#player2_score = 5
			#_reset_scores() # Reseteamos si uno gano para la proxima partida
		#elif player1_score == player2_score and player1_score >= 3:
			#deuce()
			#
#
#func deuce():
	#player1_score = 4
	#player2_score = 4
#
## Funcion que restablece los puntajes de ambos jugadores a 0
#func _reset_scores():
	#player1_score = 0
	#player2_score = 0
	#update_score_labels()


#extends Control
#
## Opciones de puntaje para el juego
#var score_options = ["0", "15", "30", "40", "Deuce", "Advantage"]
## Puntaje del jugador 1
#var player1_score = 0
## Puntaje del jugador 2
#var player2_score = 0
## Puntos del juego del jugador 1
#var game1_p1_score = 0
## Puntos del juego del jugador 2
#var game1_p2_score = 0
## Label que muestra el puntaje del jugador 1
#var label_p1
## Label que muestra el puntaje del jugador 2
#var label_p2
## Label que muestra el puntaje de los juegos del jugador 1
#var game1_label_p1
## Label que muestra el puntaje de los juegos del jugador 2
#var game1_label_p2
#
#func _ready():
	#label_p1 = get_node("Points_P1")
	#label_p2 = get_node("Points_P2")
	#game1_label_p1 = get_node("Games_Container/Game1_P1") # Obtenemos el nodo Label para el puntaje de juegos del jugador 1
	#game1_label_p2 = get_node("Games_Container/Game1_P2") # Obtenemos el nodo Label para el puntaje de juegos del jugador 2
	#update_score_labels()
	#update_game_labels() # Inicializamos los labels de juegos
#
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
	#game1_label_p1.text = str(game1_p1_score) # Actualizamos el label del puntaje de juegos del jugador 1
	#game1_label_p2.text = str(game1_p2_score) # Actualizamos el label del puntaje de juegos del jugador 2
	#
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
#
#func _check_win_condition():
	#var score_diff = abs(player1_score - player2_score)
	#if player1_score >= 4 or player2_score >= 4:
		#if score_diff >= 2:
			#if player1_score > player2_score:
				## Jugador 1 gana la partida
				#player1_score = 5
				#player2_score = 0
				#game1_p1_score += 1 # Incrementamos el puntaje de juegos del jugador 1
			#else:
				## Jugador 2 gana la partida
				#player1_score = 0
				#player2_score = 5
				#game1_p2_score += 1 # Incrementamos el puntaje de juegos del jugador 2
			#_reset_scores()
			#update_game_labels() # Actualizamos los labels de juegos
		#elif player1_score == player2_score and player1_score >= 3:
			#deuce()
			#
#
#func deuce():
	#player1_score = 4
	#player2_score = 4
#
#func _reset_scores():
	#player1_score = 0
	#player2_score = 0
	#update_score_labels()


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
var game_scores_p1
# Puntos de los juegos del jugador 2
var game_scores_p2 
# Labels que muestran los puntajes de los juegos del jugador 1
var game_labels_p1 = []
# Labels que muestran los puntajes de los juegos del jugador 2
var game_labels_p2 = []
# Indice del juego actual
var current_game_index = 0

var current_set = 0
var sets_ganados_p1 = 0
var sets_ganados_p2 = 0

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

#func _check_set_win_condition():
	## Verificamos si el juego actual tiene un ganador
	#if (game_scores_p1[current_game_index] >= 6 or game_scores_p2[current_game_index] >= 6) and abs(game_scores_p1[current_game_index] - game_scores_p2[current_game_index]) >= 2:
		## Avanzamos al siguiente juego
		#current_game_index += 1
		## Si ya se jugaron todos los sets, puedes agregar una lógica para finalizar el juego
		#if current_game_index >= 5:
			#print("Juego terminado")
			## Aquí puedes implementar lógica para finalizar el juego o reiniciarlo
			#current_game_index = 0
			#game_scores_p1 = [0, 0, 0, 0, 0]
			#game_scores_p2 = [0, 0, 0, 0, 0]
		
		
func _check_set_win_condition():
	if game_scores_p1[current_set] > game_scores_p2[current_set]:
		sets_ganados_p1 += 1
		print("Jugador 1 ganó el set ", current_set + 1)
	elif game_scores_p2[current_set] > game_scores_p1[current_set]:
		sets_ganados_p2 += 1
		print("Jugador 2 ganó el set ", current_set + 1)

	if sets_ganados_p1 == 3:
		print("El Jugador 1 gano el partido!")
		_reset_game() # O cualquier otra lógica para finalizar el juego
	elif sets_ganados_p2 == 3:
		print("El Jugador 2 gano el partido!")
		_reset_game() # O cualquier otra lógica para finalizar el juego
	else:
		current_set += 1
		if current_set >= 5:
			if sets_ganados_p1 > sets_ganados_p2:
				print("El Jugador 1 gano el partido por default!")
			elif sets_ganados_p2 > sets_ganados_p1:
				print("El Jugador 2 gano el partido por default!")
			else:
				print("Empate!")
			_reset_game()


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
		_jugar_set(2,4)
	if event.is_action_pressed("ui_cancel"):
		_jugar_set(4,2)
		
func deuce():
	player1_score = 4
	player2_score = 4

func _reset_scores():
	player1_score = 0
	player2_score = 0
	update_score_labels()
