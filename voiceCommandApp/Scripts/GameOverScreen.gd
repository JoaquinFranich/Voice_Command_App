extends Control

signal restart_requested
signal back_to_menu_requested

@onready var winner_label := $Panel/VBoxContainer/Winner
@onready var total_time_label := $Panel/VBoxContainer/TotalTimeGame
@onready var game_labels_p1 := _collect_game_labels($Panel/VBoxContainer/Games_Container/VBoxContainer)
@onready var game_labels_p2 := _collect_game_labels($Panel/VBoxContainer/Games_Container/VBoxContainer2)
@onready var back_button := $Panel/VBoxContainer/HBoxContainer/BackButton
@onready var restart_button := $Panel/VBoxContainer/HBoxContainer/RestartButton

func _ready():
	hide()
	back_button.pressed.connect(_on_back_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)

func show_summary(winner_name: String, p1_scores: Array, p2_scores: Array, total_time_seconds: float) -> void:
	_update_winner(winner_name)
	_update_total_time(total_time_seconds)
	_update_set_scores(p1_scores, p2_scores)
	show()

func _update_winner(winner_name: String) -> void:
	winner_label.text = "Ganador: %s" % winner_name

func _update_total_time(seconds: float) -> void:
	total_time_label.text = "Tiempo total de Juego: %s" % _format_time(seconds)

func _update_set_scores(p1_scores: Array, p2_scores: Array) -> void:
	for i in range(game_labels_p1.size()):
		game_labels_p1[i].text = str(_safe_score_lookup(p1_scores, i))
	for i in range(game_labels_p2.size()):
		game_labels_p2[i].text = str(_safe_score_lookup(p2_scores, i))

func _safe_score_lookup(scores: Array, index: int) -> int:
	return scores[index] if index < scores.size() else 0

func _format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]

func _on_back_button_pressed() -> void:
	hide()
	back_to_menu_requested.emit()

func _on_restart_button_pressed() -> void:
	hide()
	restart_requested.emit()

func _collect_game_labels(container: Node) -> Array:
	var labels := []
	for child in container.get_children():
		if child is Label and child.name.begins_with("Game"):
			labels.append(child)
	labels.sort_custom(func(a, b):
		return _extract_game_index(a.name) < _extract_game_index(b.name))
	return labels

func _extract_game_index(name: String) -> int:
	var prefix := "Game"
	var start := prefix.length()
	if not name.begins_with(prefix):
		return 0
	var digits := ""
	for i in range(start, name.length()):
		var char := name[i]
		if char >= "0" and char <= "9":
			digits += char
		elif char == "_":
			break
	if digits == "":
		return 0
	return int(digits)
