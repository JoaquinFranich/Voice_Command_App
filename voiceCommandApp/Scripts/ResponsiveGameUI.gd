extends Control
class_name ResponsiveGameUI

# Signals to communicate with Game Logic (BaseSportCounter)
signal point_added(player)
signal point_removed(player)
signal reset_requested
signal menu_requested
signal pause_requested
signal resume_requested
signal timer_toggle_requested

# Configuration
@export var current_theme: UIConfig.ThemeColor = UIConfig.ThemeColor.GREEN:
	set(value):
		current_theme = value
		_update_theme_color()

# State
var serving_player_idx = 1 # 1 or 2

# Visual Config
var bg_color = Color("#121212")
var accent_color = Color("#CCFF00")
var white_color = Color.WHITE
var font_path = "res://Assets/Fonts/DS-DIGI.TTF"

# References
var score_label: Label
var sets_label: Label
var games_label: Label
var timer_label: Label
var btn_p1: Button
var btn_p2: Button
var main_layout: Container
var controls_area: BoxContainer
var p1_box: BoxContainer
var p2_box: BoxContainer
var menu_overlay: Control

func _ready():
	_update_theme_color()
	_build_ui()
	# Connect to resize signal to handle layout changes
	get_tree().get_root().connect("size_changed", Callable(self, "_on_viewport_size_changed"))
	_on_viewport_size_changed() # Initial check

func _update_theme_color():
	match current_theme:
		UIConfig.ThemeColor.GREEN:
			accent_color = Color("#CCFF00")
		UIConfig.ThemeColor.BLUE:
			accent_color = Color("#007AFF")
		UIConfig.ThemeColor.ORANGE:
			accent_color = Color("#FF9500")
	
	# Update existing elements if they exist
	if score_label: score_label.add_theme_color_override("font_color", accent_color)
	if btn_p1: _update_button_style(btn_p1, accent_color, true, serving_player_idx == 1)
	if btn_p2: _update_button_style(btn_p2, accent_color, true, serving_player_idx == 2)

func _build_ui():
	# Clean
	for child in get_children():
		child.queue_free()
		
	# 1. Background
	var background = ColorRect.new()
	background.name = "Background"
	background.color = bg_color
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	
	# 2. Safe Area Margin
	var margin_container = MarginContainer.new()
	margin_container.name = "SafeArea"
	margin_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin_container.add_theme_constant_override("margin_top", 40)
	margin_container.add_theme_constant_override("margin_left", 20)
	margin_container.add_theme_constant_override("margin_right", 20)
	margin_container.add_theme_constant_override("margin_bottom", 40)
	add_child(margin_container)
	
	# 3. Main Layout Holder
	# We switch between VBox and HBox based on orientation, but let's start with VBox
	main_layout = VBoxContainer.new()
	main_layout.name = "MainLayout"
	margin_container.add_child(main_layout)
	
	# 4. Top Bar
	var top_bar = HBoxContainer.new()
	main_layout.add_child(top_bar)
	
	var menu_btn = _create_styled_button("MENU", Color.WHITE, false, false)
	menu_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	menu_btn.custom_minimum_size = Vector2(100, 50)
	menu_btn.add_theme_font_size_override("font_size", 24)
	menu_btn.pressed.connect(show_menu)
	top_bar.add_child(menu_btn)
	
	var spacer1 = Control.new()
	spacer1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer1)
	
	timer_label = Label.new()
	timer_label.text = "00:00"
	timer_label.add_theme_color_override("font_color", white_color)
	timer_label.add_theme_font_size_override("font_size", 48)
	# Make timer clickable to toggle?
	top_bar.add_child(timer_label)
	
	var spacer2 = Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer2)
	
	var reset_btn = _create_styled_button("RESET", Color.RED, false, false)
	reset_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	reset_btn.custom_minimum_size = Vector2(100, 50)
	reset_btn.add_theme_font_size_override("font_size", 24)
	reset_btn.pressed.connect(func(): reset_requested.emit())
	top_bar.add_child(reset_btn)
	
	# 5. Score Section
	var score_area = VBoxContainer.new()
	score_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	score_area.alignment = BoxContainer.ALIGNMENT_CENTER
	main_layout.add_child(score_area)
	
	sets_label = Label.new()
	sets_label.text = "SETS: 0 - 0"
	sets_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sets_label.add_theme_font_size_override("font_size", 48)
	score_area.add_child(sets_label)
	
	games_label = Label.new()
	games_label.text = "GAMES: 0 - 0"
	games_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	games_label.add_theme_font_size_override("font_size", 48)
	score_area.add_child(games_label)
	
	score_label = Label.new()
	score_label.text = "0 - 0"
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var font = load(font_path)
	if font:
		score_label.add_theme_font_override("font", font)
	score_label.add_theme_font_size_override("font_size", 120)
	score_label.add_theme_color_override("font_color", accent_color)
	score_area.add_child(score_label)
	
	# 6. Controls Section
	controls_area = HBoxContainer.new()
	controls_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	controls_area.alignment = BoxContainer.ALIGNMENT_CENTER
	controls_area.add_theme_constant_override("separation", 20)
	main_layout.add_child(controls_area)
	
	# P1
	p1_box = VBoxContainer.new()
	p1_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls_area.add_child(p1_box)
	
	btn_p1 = _create_styled_button("P1 (+1)", accent_color, true, serving_player_idx == 1)
	btn_p1.pressed.connect(func(): point_added.emit(1))
	p1_box.add_child(btn_p1)
	
	var btn_p1_sub = _create_styled_button("-1", Color.BLACK, false, false)
	btn_p1_sub.pressed.connect(func(): point_removed.emit(1))
	p1_box.add_child(btn_p1_sub)
	
	# P2
	p2_box = VBoxContainer.new()
	p2_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls_area.add_child(p2_box)
	
	btn_p2 = _create_styled_button("P2 (+1)", accent_color, true, serving_player_idx == 2)
	btn_p2.pressed.connect(func(): point_added.emit(2))
	p2_box.add_child(btn_p2)

	var btn_p2_sub = _create_styled_button("-1", Color.BLACK, false, false)
	btn_p2_sub.pressed.connect(func(): point_removed.emit(2))
	p2_box.add_child(btn_p2_sub)
	
	# 7. Menu Overlay (Hidden by default)
	_create_menu_overlay()

func _create_menu_overlay():
	menu_overlay = ColorRect.new()
	menu_overlay.name = "MenuOverlay"
	menu_overlay.color = Color(0, 0, 0, 0.9) # Semi-transparent black
	menu_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu_overlay.hide()
	add_child(menu_overlay)
	
	var center_container = CenterContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu_overlay.add_child(center_container)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 30)
	center_container.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "PAUSA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	vbox.add_child(title)
	
	# Resume Button
	var resume_btn = _create_menu_button("REANUDAR")
	resume_btn.pressed.connect(hide_menu)
	vbox.add_child(resume_btn)
	
	# Theme Selector
	var theme_label = Label.new()
	theme_label.text = "COLOR TEMA"
	theme_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(theme_label)
	
	var theme_box = HBoxContainer.new()
	theme_box.alignment = BoxContainer.ALIGNMENT_CENTER
	theme_box.add_theme_constant_override("separation", 20)
	vbox.add_child(theme_box)
	
	var green_btn = _create_color_button(Color("#CCFF00"), UIConfig.ThemeColor.GREEN)
	var blue_btn = _create_color_button(Color("#007AFF"), UIConfig.ThemeColor.BLUE)
	var orange_btn = _create_color_button(Color("#FF9500"), UIConfig.ThemeColor.ORANGE)
	
	theme_box.add_child(green_btn)
	theme_box.add_child(blue_btn)
	theme_box.add_child(orange_btn)
	
	# Exit Button
	var exit_btn = _create_menu_button("SALIR AL MENU")
	vbox.add_child(exit_btn)
	
	# Confirmation Panel (Hidden initially)
	var confirm_panel = VBoxContainer.new()
	confirm_panel.hide()
	confirm_panel.add_theme_constant_override("separation", 15)
	vbox.add_child(confirm_panel)
	
	var confirm_label = Label.new()
	confirm_label.text = "¿Estás seguro?\nSe perderá el progreso."
	confirm_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	confirm_label.add_theme_font_size_override("font_size", 48)
	confirm_panel.add_child(confirm_label)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 50)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	confirm_panel.add_child(hbox)
	
	var yes_btn = _create_styled_button("SALIR", Color.WHITE, true, false)
	yes_btn.add_theme_font_size_override("font_size", 32)
	yes_btn.custom_minimum_size = Vector2(300, 120)
	yes_btn.pressed.connect(func(): menu_requested.emit())
	hbox.add_child(yes_btn)
	
	var cancel_btn = _create_styled_button("CANCELAR", Color.RED, true, false)
	cancel_btn.add_theme_font_size_override("font_size", 32)
	cancel_btn.custom_minimum_size = Vector2(300, 120)
	cancel_btn.pressed.connect(func():
		confirm_panel.hide()
		exit_btn.show()
		resume_btn.show()
		theme_box.show()
		theme_label.show()
	)
	hbox.add_child(cancel_btn)
	
	# Logic to show confirmation
	exit_btn.pressed.connect(func():
		exit_btn.hide()
		resume_btn.hide()
		theme_box.hide()
		theme_label.hide()
		confirm_panel.show()
	)

func _create_menu_button(text: String) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.add_theme_font_size_override("font_size", 32)
	btn.custom_minimum_size = Vector2(300, 60)
	return btn

func _create_color_button(color: Color, theme_enum: int) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(60, 60)
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(30) # Circle
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.pressed.connect(func():
		self.current_theme = theme_enum
	)
	return btn

func show_menu():
	if menu_overlay:
		menu_overlay.show()
		pause_requested.emit()

func hide_menu():
	if menu_overlay:
		menu_overlay.hide()
		resume_requested.emit()

func _create_styled_button(text, color, is_big, is_serving):
	var btn = Button.new()
	btn.text = text
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	if is_big:
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 32)
	else:
		btn.custom_minimum_size = Vector2(0, 60)
	
	_update_button_style(btn, color, is_big, is_serving)
	return btn

func _update_button_style(btn: Button, color: Color, is_big: bool, is_serving: bool):
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = color
	
	if is_serving:
		style_normal.border_width_left = 6
		style_normal.border_width_top = 6
		style_normal.border_width_right = 6
		style_normal.border_width_bottom = 6
		style_normal.border_color = Color.WHITE
		style_normal.shadow_color = accent_color
		style_normal.shadow_size = 8
		if is_big and not "🎾" in btn.text:
			btn.text = "🎾 " + btn.text.replace("🎾 ", "")
	else:
		style_normal.border_width_left = 2
		style_normal.border_width_top = 2
		style_normal.border_width_right = 2
		style_normal.border_width_bottom = 2
		style_normal.border_color = accent_color.darkened(0.3)
		style_normal.shadow_size = 0
		if is_big:
			btn.text = btn.text.replace("🎾 ", "")
	
	style_normal.corner_radius_top_left = 16
	style_normal.corner_radius_top_right = 16
	style_normal.corner_radius_bottom_right = 16
	style_normal.corner_radius_bottom_left = 16
	
	if color == Color.BLACK:
		style_normal.border_color = Color("#333333")
		btn.add_theme_color_override("font_color", Color.WHITE)
		style_normal.border_width_left = 1
		style_normal.border_width_top = 1
		style_normal.border_width_right = 1
		style_normal.border_width_bottom = 1
		style_normal.shadow_size = 0
	else:
		btn.add_theme_color_override("font_color", Color.BLACK)
	
	btn.add_theme_stylebox_override("normal", style_normal)
	btn.add_theme_stylebox_override("hover", style_normal)
	btn.add_theme_stylebox_override("pressed", style_normal)

# --- Public API for Game Logic ---

func update_scores(p1_text: String, p2_text: String):
	if score_label:
		score_label.text = p1_text + " - " + p2_text

func update_sets(p1_sets: int, p2_sets: int):
	if sets_label:
		sets_label.text = "SETS: " + str(p1_sets) + " - " + str(p2_sets)

func update_games(p1_games: int, p2_games: int):
	if games_label:
		games_label.text = "GAMES: " + str(p1_games) + " - " + str(p2_games)

func update_timer(time_text: String):
	if timer_label:
		timer_label.text = time_text

func set_serving_player(player: int):
	serving_player_idx = player
	# Refresh buttons
	if btn_p1: _update_button_style(btn_p1, accent_color, true, serving_player_idx == 1)
	if btn_p2: _update_button_style(btn_p2, accent_color, true, serving_player_idx == 2)

# --- Responsiveness ---

func _on_viewport_size_changed():
	var screen_size = get_viewport_rect().size
	var is_portrait = screen_size.y > screen_size.x
	
	if not main_layout or not controls_area: return
	
	if is_portrait:
		# Vertical Layout
		# Controls at bottom
		if controls_area.get_parent() != main_layout:
			controls_area.get_parent().remove_child(controls_area)
			main_layout.add_child(controls_area) # Put back at bottom
		
		# Ensure P1 Left, P2 Right (in horizontal box inside vertical main)
		controls_area.alignment = BoxContainer.ALIGNMENT_CENTER
	else:
		# Horizontal Layout
		# We might need a different structure for Horizontal
		# But simplistic approach: Keep it side by side
		# Just adjust proportions
		pass
