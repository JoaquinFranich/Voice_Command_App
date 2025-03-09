extends Control

var STT

# Called when the node enters the scene tree for the first time.
func _ready():
	OS.request_permission("RECORD_AUDIO")
	if Engine.has_singleton("SpeechToText"):
		STT = Engine.get_singleton("SpeechToText")
		STT.setLanguage("es")
		STT.connect("error", self, "_on_error")
		STT.connect("listening_completed", self, "_on_listening_completed")
	pass # Replace with function body.

func _on_listening_completed(args):
	$TextEdit.text = str(args)

func _on_error(errorcode):
	print("Error: " + errorcode)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_listen_btn_button_down():
	STT.listen()
	pass # Replace with function body.


func _on_stop_btn_button_down():
	STT.Stop()
	pass # Replace with function body.


func _on_get_output_btn_button_down():
	var words = STT.getWords()
	$TextEdit2.text = words
	pass # Replace with function body.
