@tool
extends Control

enum ThemeColor {GREEN, BLUE, ORANGE}
@export var current_theme: ThemeColor = ThemeColor.GREEN:
	set(value):
		current_theme = value
		_update_theme_color()
		if has_node("MainLayout"):
			_build_ui()

# Variable para simular quien saca en el Mockup
@export var serving_player: int = 1:
	set(value):
		serving_player = value
		if has_node("MainLayout"):
			_build_ui()

# Configuración Visual
var bg_color = Color("#121212")
var accent_color = Color("#CCFF00")
var white_color = Color.WHITE
var font_path = "res://Assets/Fonts/DS-DIGI.TTF"

func _update_theme_color():
	match current_theme:
		ThemeColor.GREEN:
			accent_color = Color("#CCFF00")
		ThemeColor.BLUE:
			accent_color = Color("#007AFF")
		ThemeColor.ORANGE:
			accent_color = Color("#FF9500")

func _ready():
	# Limpiar hijos previos para reconstruir
	for child in get_children():
		child.queue_free()
	
	# Construir UI
	_build_ui()

func _build_ui():
	# 1. Fondo
	var background = ColorRect.new()
	background.name = "Background"
	background.color = bg_color
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	
	# 2. Contenedor Principal (Vertical por defecto)
	var main_layout = VBoxContainer.new()
	main_layout.name = "MainLayout"
	main_layout.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var margin_container = MarginContainer.new()
	margin_container.name = "SafeArea"
	margin_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin_container.add_theme_constant_override("margin_top", 40)
	margin_container.add_theme_constant_override("margin_left", 20)
	margin_container.add_theme_constant_override("margin_right", 20)
	margin_container.add_theme_constant_override("margin_bottom", 40)
	add_child(margin_container)
	margin_container.add_child(main_layout)
	
	# 3. Top Bar (Timer y Reset)
	var top_bar = HBoxContainer.new()
	top_bar.name = "TopBar"
	main_layout.add_child(top_bar)
	
	var menu_btn = Button.new()
	menu_btn.text = " MENU "
	menu_btn.flat = true
	top_bar.add_child(menu_btn)
	
	var spacer1 = Control.new()
	spacer1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer1)
	
	var timer_label = Label.new()
	timer_label.text = "00:00"
	timer_label.add_theme_color_override("font_color", white_color)
	top_bar.add_child(timer_label)
	
	var spacer2 = Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer2)
	
	var reset_btn = Button.new()
	reset_btn.text = " RESET "
	reset_btn.flat = true
	top_bar.add_child(reset_btn)
	
	# 4. Score Area (Grande)
	var score_area = VBoxContainer.new()
	score_area.name = "ScoreArea"
	score_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	score_area.alignment = BoxContainer.ALIGNMENT_CENTER
	main_layout.add_child(score_area)
	
	var sets_label = Label.new()
	sets_label.text = "SETS: 1 - 0"
	sets_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sets_label.add_theme_font_size_override("font_size", 24)
	score_area.add_child(sets_label)
	
	var score_label = Label.new()
	score_label.text = "15 - 30"
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var font = load(font_path)
	if font:
		score_label.add_theme_font_override("font", font)
	score_label.add_theme_font_size_override("font_size", 120)
	score_label.add_theme_color_override("font_color", accent_color)
	score_area.add_child(score_label)
	
	# INDICADOR DE SAQUE ELIMINADO DE AQUI (Ahora es brilllo en boton)
	
	# 5. Controls Area (Botones)
	var controls_area = HBoxContainer.new()
	controls_area.name = "ControlsArea"
	controls_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	controls_area.alignment = BoxContainer.ALIGNMENT_CENTER
	controls_area.add_theme_constant_override("separation", 20)
	main_layout.add_child(controls_area)
	
	# P1 Controls
	var p1_box = VBoxContainer.new()
	p1_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls_area.add_child(p1_box)
	
	var btn_p1 = _create_styled_button("P1 (+1)", accent_color, true, serving_player == 1)
	p1_box.add_child(btn_p1)
	
	var btn_p1_sub = _create_styled_button("-1", Color.BLACK, false, false)
	p1_box.add_child(btn_p1_sub)

	# P2 Controls
	var p2_box = VBoxContainer.new()
	p2_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls_area.add_child(p2_box)
	
	var btn_p2 = _create_styled_button("P2 (+1)", accent_color, true, serving_player == 2)
	p2_box.add_child(btn_p2)

	var btn_p2_sub = _create_styled_button("-1", Color.BLACK, false, false)
	p2_box.add_child(btn_p2_sub)

func _create_styled_button(text, color, is_big, is_serving):
	var btn = Button.new()
	btn.text = text
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	if is_big:
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 32)
	else:
		btn.custom_minimum_size = Vector2(0, 60)
	
	# Estilo Normal
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = color
	
	# Lógica de Borde (Indicador de Saque)
	if is_serving:
		# Borde "Neon" Grueso Brillante
		style_normal.border_width_left = 6
		style_normal.border_width_top = 6
		style_normal.border_width_right = 6
		style_normal.border_width_bottom = 6
		# Usamos blanco o una versión más brillante del acento para que resalte
		style_normal.border_color = Color.WHITE
		# Opcional: Podríamos añadir sombra para simular glow
		style_normal.shadow_color = accent_color
		style_normal.shadow_size = 8
	else:
		# Borde normal fino
		style_normal.border_width_left = 2
		style_normal.border_width_top = 2
		style_normal.border_width_right = 2
		style_normal.border_width_bottom = 2
		style_normal.border_color = accent_color.darkened(0.3)
		style_normal.shadow_size = 0

	style_normal.corner_radius_top_left = 16
	style_normal.corner_radius_top_right = 16
	style_normal.corner_radius_bottom_right = 16
	style_normal.corner_radius_bottom_left = 16
	
	if color == Color.BLACK:
		style_normal.border_color = Color("#333333")
		btn.add_theme_color_override("font_color", Color.WHITE)
		# override serving border logic for small buttons (usually they don't glow)
		style_normal.border_width_left = 1
		style_normal.border_width_top = 1
		style_normal.border_width_right = 1
		style_normal.border_width_bottom = 1
		style_normal.shadow_size = 0
	else:
		btn.add_theme_color_override("font_color", Color.BLACK)
	
	# Aplicar a todos los estados para consistencia visual rápida
	btn.add_theme_stylebox_override("normal", style_normal)
	btn.add_theme_stylebox_override("hover", style_normal)
	btn.add_theme_stylebox_override("pressed", style_normal)
	
	if is_serving and is_big:
		# Añadir un iconito de pelota al texto sería cool también, pero por ahora el borde basta.
		btn.text = "🎾 " + text
	
	return btn
