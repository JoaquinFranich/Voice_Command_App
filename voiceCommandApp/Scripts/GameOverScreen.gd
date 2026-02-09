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
	_apply_neon_style()
	back_button.pressed.connect(_on_back_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)

func _apply_neon_style():
	# Background
	var panel = $Panel
	if panel:
		var style = StyleBoxFlat.new()
		style.bg_color = Color("#121212")
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color("#CCFF00")
		style.corner_radius_top_left = 16
		style.corner_radius_top_right = 16
		style.corner_radius_bottom_right = 16
		style.corner_radius_bottom_left = 16
		panel.add_theme_stylebox_override("panel", style)
	
	# Font
	var font = load("res://Assets/Fonts/DS-DIGI.TTF")
	
	# Winner Label
	if winner_label:
		if font: winner_label.add_theme_font_override("font", font)
		winner_label.add_theme_color_override("font_color", Color("#CCFF00"))
		winner_label.add_theme_font_size_override("font_size", 48)
		
	# Total Time
	if total_time_label:
		# if font: total_time_label.add_theme_font_override("font", font) # Keep standard font if preferred for readability
		total_time_label.add_theme_color_override("font_color", Color.WHITE)
		
	# Buttons
	_style_button(restart_button, Color("#CCFF00"))
	_style_button(back_button, Color.WHITE)

func _style_button(btn: Button, color: Color):
	if not btn: return
	var style = StyleBoxFlat.new()
	style.bg_color = Color.BLACK
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = color
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_right = 16
	style.corner_radius_bottom_left = 16
	
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_color_override("font_color", Color.WHITE)
	if color == Color("#CCFF00"):
		btn.add_theme_color_override("font_color", color)
	
	btn.flat = false

func show_summary(winner_name: String, p1_scores: Array, p2_scores: Array, total_time_seconds: float) -> void:
	_update_winner(winner_name)
	_update_total_time(total_time_seconds)
	_update_set_scores(p1_scores, p2_scores)
	
	# Reset state
	var panel = $Panel
	if panel:
		panel.scale = Vector2.ZERO
		# Ensure pivot is correct in case of resize
		panel.pivot_offset = panel.size / 2
	
	show()
	
	# Delay 1.5s
	await get_tree().create_timer(1.5).timeout
	
	if panel:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_ELASTIC)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(panel, "scale", Vector2.ONE, 0.8)

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
	var minutes = int(seconds / 60)
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

func _extract_game_index(node_name: String) -> int:
	var prefix := "Game"
	var start := prefix.length()
	if not node_name.begins_with(prefix):
		return 0
	var digits := ""
	for i in range(start, node_name.length()):
		var character := node_name[i]
		if character >= "0" and character <= "9":
			digits += character
		elif character == "_":
			break
	if digits == "":
		return 0
	return int(digits)
