extends Area2D

@onready var label = $InteractionArea/InteractionLabel 

func _ready():
	if label: label.hide()
	body_entered.connect(func(body): if body.is_in_group(&"Player"): label.show())
	body_exited.connect(func(body): if body.is_in_group(&"Player"): label.hide())

func _input(event):
	if label and label.visible and not get_tree().paused:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var note = self.find_child("NoteUI");
			if note:
				print(note);
				note.show()
				get_tree().call_deferred("set_pause", true) 
				get_viewport().set_input_as_handled()
