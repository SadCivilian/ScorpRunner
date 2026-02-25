extends Node2D

@onready var ReadLabel = $ReadLabel 
@onready var DetectionArea = $DetectionArea
@onready var PaperPanel = $UI/PaperPanel

var player_near = false

func _ready():
	ReadLabel.visible = false
	PaperPanel.visible = false
	DetectionArea.body_entered.connect(_on_player_entered)
	DetectionArea.body_exited.connect(_on_player_exited)

func _on_player_entered(body):
	if body.is_in_group(&"Player"):
		player_near = true
		ReadLabel.visible = true

func _on_player_exited(body):
	if body.is_in_group(&"Player"):
		print("exited");
		player_near = false
		PaperPanel.visible = false

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if PaperPanel.visible:
				get_viewport().set_input_as_handled();
				PaperPanel.visible = false
			elif player_near:
				get_viewport().set_input_as_handled();
				PaperPanel.visible = true
