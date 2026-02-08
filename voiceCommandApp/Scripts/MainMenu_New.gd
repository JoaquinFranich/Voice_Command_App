extends Control

# Configuration
var bg_color = Color("#121212")
var accent_color = Color("#CCFF00") # Green by default
var font_path = "res://Assets/Fonts/DS-DIGI.TTF"

# References
var main_layout: VBoxContainer

func _ready():
	_build_ui()

func _build_ui():
	# 1. Background
	var background = ColorRect.new()
	background.name = "Background"
	background.color = bg_color
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	
	# 2. Main Container
	var center_container = CenterContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center_container)
	
	main_layout = VBoxContainer.new()
	main_layout.add_theme_constant_override("separation", 40)
	main_layout.alignment = BoxContainer.ALIGNMENT_CENTER
	center_container.add_child(main_layout)
	
	# 3. Title
	var title = Label.new()
	title.text = "VOICE SPORT\nCOUNTER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 80)
	var font = load(font_path)
	if font:
		title.add_theme_font_override("font", font)
	title.add_theme_color_override("font_color", accent_color)
	main_layout.add_child(title)
	
	# 4. Buttons
	var btn_select = _create_styled_button("ELEGIR DISCIPLINA", accent_color)
	btn_select.pressed.connect(_on_select_discipline_pressed)
	main_layout.add_child(btn_select)
	
	var btn_exit = _create_styled_button("SALIR", Color.RED)
	btn_exit.pressed.connect(_on_exit_pressed)
	main_layout.add_child(btn_exit)
	
	# 5. Exit Confirmation (Hidden)
	_create_exit_confirmation()

func _create_styled_button(text: String, color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(400, 80)
	btn.add_theme_font_size_override("font_size", 32)
	
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
	
	return btn

var confirm_overlay: Control

func _create_exit_confirmation():
	confirm_overlay = ColorRect.new()
	confirm_overlay.name = "ConfirmOverlay"
	confirm_overlay.color = Color(0, 0, 0, 0.9)
	confirm_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	confirm_overlay.hide()
	add_child(confirm_overlay)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	confirm_overlay.add_child(center)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	center.add_child(vbox)
	
	var label = Label.new()
	label.text = "¿DESEA CERRAR LA APLICACION?"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 32)
	vbox.add_child(label)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(hbox)
	
	var yes_btn = _create_styled_button("SI", Color.WHITE)
	yes_btn.custom_minimum_size = Vector2(150, 60)
	yes_btn.pressed.connect(func(): get_tree().quit())
	hbox.add_child(yes_btn)
	
	var no_btn = _create_styled_button("NO", Color.RED)
	no_btn.custom_minimum_size = Vector2(150, 60)
	no_btn.pressed.connect(_hide_confirmation)
	hbox.add_child(no_btn)

func _on_select_discipline_pressed():
	SceneTransition.change_scene("res://Scenes/DisciplineSelection.tscn")

func _on_exit_pressed():
	_show_confirmation()

func _show_confirmation():
	confirm_overlay.show()
	var center_node = confirm_overlay.get_child(0) # CenterContainer
	# Start from above screen
	center_node.position.y = - get_viewport_rect().size.y
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUART)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(center_node, "position:y", 0.0, 0.5)

func _hide_confirmation():
	var center_node = confirm_overlay.get_child(0)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUART)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(center_node, "position:y", -get_viewport_rect().size.y, 0.5)
	tween.finished.connect(confirm_overlay.hide)
