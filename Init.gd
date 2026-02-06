extends Node

@onready var FadeOutLayer = $PlayerCamera/FadeOutLayer;
@onready var FadeRect = $PlayerCamera/FadeOutLayer/FadeRect;
@onready var FadePlayer = $PlayerCamera/FadeOutLayer/FadePlayer;
@onready var Background = $Background;
@onready var LevelEnd : Area2D = $LevelEnd;

func _ready() -> void:
	# var new = load("res://archeon.tscn").instantiate();
	# print(new);
	LevelEnd.body_entered.connect(func(body):
		if body.name == "Player":
			var curr = Global.GetCurrentScene();
			var scene = Global.GetSceneFromString(Global.SceneTransitions[curr]);
			FadeTransition.transition(FadeTransition.TransitionType.ROOM_TRANSITION, scene);
	)
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
		
	
