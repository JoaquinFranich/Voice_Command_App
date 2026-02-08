extends BaseSportCounter

# Opciones de puntaje para el juego (Paddle Logic)
var score_options = ["0", "15", "30", "40"]
# Labels específicos de Paddle/Tennis (Tie Break)
var tbreak_label_p1
var tbreak_label_p2

var tbreak_scores_p1 = 0
var tbreak_scores_p2 = 0

# Tie Break Control
var is_tiebreak_active = false
var tiebreak_initial_server = 1
var tiebreak_points_since_serve = 0

var _last_total_games := 0

func _ready():
	# Configurar valores antes del super._ready() si fuera necesario, 
	# o re-asignar después. Base usa max_sets=3 por defecto, ok para Paddle.
	super._ready()
	
	# Inicializar referencias UI específicas de Paddle
	if not game_ui:
		var container = get_node(score_container_name)
		tbreak_label_p1 = container.get_node("P1_Points_Container/TBreak_P1")
		tbreak_label_p2 = container.get_node("P2_Points_Container/TBreak_P2")

# Sobrescribir update_score_labels del Base
func update_score_labels():
	var p1_text = ""
	var p2_text = ""
	
	if player1_score >= score_options.size():
		p1_text = score_options[score_options.size() - 1]
	else:
		p1_text = score_options[player1_score]
		
	if player2_score >= score_options.size():
		p2_text = score_options[score_options.size() - 1]
	else:
		p2_text = score_options[player2_score]

	if game_ui:
		game_ui.update_scores(p1_text, p2_text)
	elif label_p1 and label_p2:
		label_p1.text = p1_text
		label_p2.text = p2_text

func update_game_labels():
	if game_ui:
		game_ui.update_sets(sets_ganados_p1, sets_ganados_p2)
		if current_game_index < game_scores_p1.size():
			game_ui.update_games(game_scores_p1[current_game_index], game_scores_p2[current_game_index])
	elif game_labels_p1.size() > 0:
		for i in range(game_labels_p1.size()):
			game_labels_p1[i].text = str(game_scores_p1[i])
			game_labels_p2[i].text = str(game_scores_p2[i])

func _decrement_score(player):
	if is_tiebreak_active:
		pass
	else:
		if player == 1:
			if player1_score > 0: player1_score -= 1
		else:
			if player2_score > 0: player2_score -= 1
		update_score_labels()

func _increment_score(player):
	if is_tiebreak_active:
		_increment_tiebreak_score(player)
		return
		
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
		if sets_ganados_p1 >= sets_to_win or sets_ganados_p2 >= sets_to_win:
			_end_game()
			return
			
		# Si no hay victoria, manejar el cambio de set
		set_states[current_game_index] = SetState.FINALIZADO
		if active_set < timer_labels.size():
			timer_labels[current_game_index].modulate = Color(1, 1, 1, 0.5)
		
		if current_game_index < max_sets - 1:
			serving_player = 2 if serving_player == 1 else 1
			_update_serve_indicator()
			
			current_game_index += 1
			_last_total_games = 0
			
			active_set = current_game_index
			set_states[active_set] = SetState.EN_PROGRESO
			if active_set < timer_labels.size():
				timer_labels[active_set].modulate = Color(1, 1, 1, 1)
				timer_labels[active_set].text = "00:00"
			
			if game_ui: game_ui.update_timer("00:00")

func _process(delta):
	# Llamar al proceso base para timers y STT
	super._process(delta)
	
	# Lógica extra de saque por juegos (exclusiva Paddle/Tennis)
	var current_total = game_scores_p1[current_game_index] + game_scores_p2[current_game_index]
	if current_total > _last_total_games:
		serving_player = 2 if serving_player == 1 else 1
		_update_serve_indicator()
		_last_total_games = current_total

# Tie Break Logic (Specífico Paddle/Tennis)
func _start_tie_break():
	print("Comienza el Tie-Break")
	is_tiebreak_active = true
	tiebreak_initial_server = 2 if serving_player == 1 else 1
	serving_player = tiebreak_initial_server
	_update_serve_indicator()
	
	tbreak_scores_p1 = 0
	tbreak_scores_p2 = 0
	tiebreak_points_since_serve = 0

	if game_ui:
		game_ui.update_scores(str(tbreak_scores_p1), str(tbreak_scores_p2))
	else:
		tbreak_label_p1.text = str(tbreak_scores_p1)
		tbreak_label_p2.text = str(tbreak_scores_p2)
		tbreak_label_p1.show()
		tbreak_label_p2.show()
		get_node("TBreak_P1_btn").show()
		get_node("TBreak_P2_btn").show()
		get_node("Button_P1").hide()
		get_node("Button_P2").hide()

func _increment_tiebreak_score(player):
	if not is_tiebreak_active: return
		
	if player == 1:
		tbreak_scores_p1 += 1
	elif player == 2:
		tbreak_scores_p2 += 1
	
	if game_ui:
		game_ui.update_scores(str(tbreak_scores_p1), str(tbreak_scores_p2))
	else:
		if player == 1:
			tbreak_label_p1.text = str(tbreak_scores_p1)
		elif player == 2:
			tbreak_label_p2.text = str(tbreak_scores_p2)
	
	tiebreak_points_since_serve += 1
	
	if (tbreak_scores_p1 + tbreak_scores_p2 == 1) or (tiebreak_points_since_serve >= 2):
		serving_player = 2 if serving_player == 1 else 1
		tiebreak_points_since_serve = 0
		_update_serve_indicator()
	
	_check_tiebreak_win_condition()

func _check_tiebreak_win_condition():
	if not is_tiebreak_active: return
		
	if (tbreak_scores_p1 >= 7 or tbreak_scores_p2 >= 7) and abs(tbreak_scores_p1 - tbreak_scores_p2) >= 2:
		var winner = 1 if tbreak_scores_p1 > tbreak_scores_p2 else 2
		print("Jugador " + str(winner) + " ganó el Tie-Break")
		
		if winner == 1:
			game_scores_p1[current_game_index] = 7
			sets_ganados_p1 += 1
		else:
			game_scores_p2[current_game_index] = 7
			sets_ganados_p2 += 1
			
		set_states[current_game_index] = SetState.FINALIZADO
		if current_game_index < timer_labels.size():
			timer_labels[current_game_index].modulate = Color(1, 1, 1, 0.5)
		
		# Restaurar UI
		if game_ui:
			# Volvemos a modo normal, score labels se actualizaran en update_score_labels
			pass
		else:
			tbreak_label_p1.hide()
			tbreak_label_p2.hide()
			get_node("TBreak_P1_btn").hide()
			get_node("TBreak_P2_btn").hide()
			get_node("Button_P1").show()
			get_node("Button_P2").show()
		
		update_game_labels()
		is_tiebreak_active = false
		serving_player = tiebreak_initial_server
		
		if sets_ganados_p1 >= sets_to_win or sets_ganados_p2 >= sets_to_win:
			_end_game()
		else:
			if current_game_index < max_sets - 1:
				current_game_index += 1
				_last_total_games = 0
				active_set = current_game_index
				set_states[active_set] = SetState.EN_PROGRESO
				if active_set < timer_labels.size():
					timer_labels[active_set].modulate = Color(1, 1, 1, 1)
					timer_labels[active_set].text = "00:00"
				_update_serve_indicator()
				if game_ui: game_ui.update_timer("00:00")
				
		# Reset para nuevo set
		_reset_scores()
		update_game_labels()

func _end_game():
	# Verificar si algún jugador ya ganó el partido
	if sets_ganados_p1 >= sets_to_win or sets_ganados_p2 >= sets_to_win:
		# Asegurar que el último set quede marcado como finalizado
		if active_set >= 0:
			set_states[active_set] = SetState.FINALIZADO
			if active_set < timer_labels.size():
				timer_labels[active_set].modulate = Color(1, 1, 1, 0.5)
		
		# Determinar quien gano el juego
		var winner = 1 if sets_ganados_p1 > sets_ganados_p2 else 2
		print("Juego terminado. Ganador: Jugador " + str(winner))
		active_set = -1
		_show_game_over_screen(winner)
		return

	# Si el juego no termina, el cambio es manejado en check_set_win

func _reset_scores():
	player1_score = 0
	player2_score = 0
	update_score_labels()

func deuce():
	player1_score = 3
	player2_score = 3

func _reset_game():
	super._reset_game()
	_last_total_games = 0
	tbreak_scores_p1 = 0
	tbreak_scores_p2 = 0
	is_tiebreak_active = false
	
	if game_ui:
		game_ui.update_games(0, 0)
	else:
		if tbreak_label_p1:
			tbreak_label_p1.hide()
			tbreak_label_p2.hide()
		if has_node("TBreak_P1_btn"): get_node("TBreak_P1_btn").hide()
		if has_node("TBreak_P2_btn"): get_node("TBreak_P2_btn").hide()
		if has_node("Button_P1"): get_node("Button_P1").show()
		if has_node("Button_P2"): get_node("Button_P2").show()
	
	_reset_scores()

# Manejo de voz: override para manejar inputs de tiebreak
func _handle_voice_command(player):
	if is_tiebreak_active:
		_increment_tiebreak_score(player)
	else:
		_increment_score(player)

# Events from Buttons
func _on_t_break_p_1_btn_pressed():
	_increment_tiebreak_score(1)

func _on_t_break_p_2_btn_pressed():
	_increment_tiebreak_score(2)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		pass # Debug
	if event.is_action_pressed("ui_cancel"):
		pass # Debug
