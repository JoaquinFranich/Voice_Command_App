extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	var menuButton = get_node("Panel/VBoxContainer/MenuButton")
	var popup = menuButton.get_popup()
	
	popup.id_pressed.connect(file_menu)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func file_menu(id):
	print(id)
	match(id):
		0:
			get_tree().change_scene_to_file("res://Scenes/Paddle_Counter.tscn")
		1:
			get_tree().change_scene_to_file("res://Scenes/Tennis_Counter.tscn")
		2:
			get_tree().change_scene_to_file("res://Scenes/Voley_Counter.tscn")
