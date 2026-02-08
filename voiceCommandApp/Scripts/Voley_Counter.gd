extends BaseSportCounter

func _ready():
	# Configuración específica de Voley
	max_sets = 5
	sets_to_win = 3
	score_container_name = "Sets_Container"
	
	super._ready() # Inicializa todo con la nueva configuración

# Sobrescribir lógica de labels (Voley muestra números directos)
func update_score_labels():
	if game_ui:
		game_ui.update_scores(str(player1_score), str(player2_score))
	elif label_p1 and label_p2:
		label_p1.text = str(player1_score)
		label_p2.text = str(player2_score)

func update_game_labels():
	if game_ui:
		game_ui.update_sets(sets_ganados_p1, sets_ganados_p2)
	elif game_labels_p1.size() > 0:
		for i in range(game_labels_p1.size()):
			game_labels_p1[i].text = str(game_scores_p1[i])
			game_labels_p2[i].text = str(game_scores_p2[i])

func _decrement_score(player):
	if player == 1:
		if player1_score > 0: player1_score -= 1
	else:
		if player2_score > 0: player2_score -= 1
	update_score_labels()

# VOLEY: Incremento modifica el saque inmediatamente si ganas punto
func _increment_score(player):
	if player == 1:
		player1_score += 1
	else:
		player2_score += 1
	
	# Cambiar saque si el punto lo gana el equipo que NO estaba sirviendo (Rally Point)
	# Y se convierte en el nuevo servidor.
	if player != serving_player:
		serving_player = player
		_update_serve_indicator()
	
	_check_win_condition()
	update_score_labels()

func _check_win_condition():
	# Reglas: Sets 1-4 a 25 puntos. Set 5 a 15 puntos.
	# Diferencia mínima de 2 puntos.
	var target = 25
	if active_set == 4: # 5to set (índice 4)
		target = 15

	var diff = abs(player1_score - player2_score)
	
	if (player1_score >= target or player2_score >= target) and diff >= 2:
		var winner = 1 if player1_score > player2_score else 2
		
		# Guardar score del set
		game_scores_p1[active_set] = player1_score
		game_scores_p2[active_set] = player2_score
		
		if winner == 1:
			sets_ganados_p1 += 1
		else:
			sets_ganados_p2 += 1
		
		set_states[active_set] = SetState.FINALIZADO
		if active_set < timer_labels.size():
			timer_labels[active_set].modulate = Color(1, 1, 1, 0.5)
		
		update_game_labels()
		
		# Check Match Win
		if sets_ganados_p1 >= sets_to_win or sets_ganados_p2 >= sets_to_win:
			_end_match()
		else:
			_prepare_next_set()

func _end_match():
	var winner = 1 if sets_ganados_p1 > sets_ganados_p2 else 2
	active_set = -1
	_show_game_over_screen(winner)

func _prepare_next_set():
	# Voley resetea puntajes en cada set nueva
	player1_score = 0
	player2_score = 0
	update_score_labels()
	
	var next_set_index = active_set + 1
	if next_set_index >= max_sets:
		_end_match() # Seguridad
		return
		
	active_set = next_set_index
	current_game_index = active_set # Sync
	
	set_states[active_set] = SetState.EN_PROGRESO
	set_timers[active_set] = 0.0
	
	if active_set < timer_labels.size():
		timer_labels[active_set].modulate = Color(1, 1, 1, 1)
		timer_labels[active_set].text = "00:00"
	
	# Regla de saque en nuevo set:
	# "El primer saque del set lo realiza el equipo que no sacó primero en el set anterior"
	# O alternado. La implementación original usaba:
	# serving_player = 2 if (set_index % 2 == 0) else 1
	serving_player = 2 if (active_set % 2 == 0) else 1
	_update_serve_indicator()

func _reset_game():
	super._reset_game()
	# Reinicia lógica especifica de Voley si hubiera
	# El super ya resetea scores, timers, y llama a _start_first_set
	
# Override start first set to apply specific serve rule if needed
func _start_first_set():
	super._start_first_set()
	# En set 0 (impar index 1? No, index 0 es par), serving 2?
	# Original: serving_player = 2 if (set_index % 2 == 0) else 1
	# Set 0 -> 2. Set 1 -> 1.
	serving_player = 2
	_update_serve_indicator()

# Input handlers
func _on_button_p_1_pressed():
	_increment_score(1)

func _on_button_p_2_pressed():
	_increment_score(2)

func _input(event):
	# Debug keys
	if event.is_action_pressed("ui_accept"):
		pass
