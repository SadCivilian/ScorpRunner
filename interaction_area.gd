#A part of paper actually
extends Area2D

@export var note_node: CanvasLayer 
@onready var insidetext = $"../../NoteUI/Label"


func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if note_node and not note_node.visible:
			note_node.show()
			insidetext.visible = true
			get_tree().paused = true 
			get_viewport().set_input_as_handled()
