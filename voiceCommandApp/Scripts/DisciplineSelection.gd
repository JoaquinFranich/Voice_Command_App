extends Control

# Configuration
var bg_color = Color("#121212")
var accent_color = Color("#CCFF00")
var font_path = "res://Assets/Fonts/DS-DIGI.TTF"

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
	
	var main_layout = VBoxContainer.new()
	main_layout.add_theme_constant_override("separation", 30)
	main_layout.alignment = BoxContainer.ALIGNMENT_CENTER
	center_container.add_child(main_layout)
	
	# 3. Title
	var title = Label.new()
	title.text = "ELIGE DEPORTE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 64)
	var font = load(font_path)
	if font:
		title.add_theme_font_override("font", font)
	title.add_theme_color_override("font_color", Color.WHITE)
	main_layout.add_child(title)
	
	# 4. Discipline Buttons
	var btn_paddle = _create_styled_button("PADDLE", Color("#CCFF00")) # Green
	btn_paddle.pressed.connect(func(): _load_scene("res://Scenes/Paddle_Counter_New.tscn"))
	main_layout.add_child(btn_paddle)
	
	var btn_tennis = _create_styled_button("TENNIS", Color("#007AFF")) # Blue
	btn_tennis.pressed.connect(func(): _load_scene("res://Scenes/Tennis_Counter_New.tscn"))
	main_layout.add_child(btn_tennis)
	
	var btn_voley = _create_styled_button("VOLEY", Color("#FF9500")) # Orange
	btn_voley.pressed.connect(func(): _load_scene("res://Scenes/Voley_Counter_New.tscn"))
	main_layout.add_child(btn_voley)
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	main_layout.add_child(spacer)
	
	# 5. Back Button
	var btn_back = _create_styled_button("ATRAS", Color.WHITE)
	btn_back.pressed.connect(_on_back_pressed)
	main_layout.add_child(btn_back)

func _create_styled_button(text: String, color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(400, 70)
	btn.add_theme_font_size_override("font_size", 28)
	
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
	
	if color == Color.WHITE:
		style.border_color = Color.GRAY
	
	return btn

func _load_scene(path: String):
	SceneTransition.change_scene(path)

func _on_back_pressed():
	SceneTransition.change_scene("res://Scenes/MainMenu_New.tscn")
