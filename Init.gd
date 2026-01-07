extends Node

@onready var FadeOutLayer = $PlayerCamera/FadeOutLayer;
@onready var FadeRect = $PlayerCamera/FadeOutLayer/FadeRect;
@onready var FadePlayer = $PlayerCamera/FadeOutLayer/FadePlayer;
@onready var Background = $Background;
@onready var lever = $Lever;


func _ready() -> void:
	FadeTransition.supply(FadeRect, FadePlayer);
	var clbk1 = func():
		var player = get_tree().get_first_node_in_group("Player");
		player.set("Speed", 0);
		await Global.wait(0.5);
		player.set("Speed", 100);	
	var clbk2 = func():
		var player = get_tree().get_first_node_in_group("Player");
		player.set("Speed", 0);
		print("speed set to 0");
		await Global.wait(0.5);
		player.set("Speed", 100);	
	FadeTransition.changeclbk(FadeTransition.TransitionType.OTHER, clbk1);
	FadeTransition.changeclbk(FadeTransition.TransitionType.ROOM_TRANSITION, clbk2);
		
	
