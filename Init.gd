extends Node

@onready var FadeOutLayer = $PlayerCamera/FadeOutLayer;
@onready var FadeRect = $PlayerCamera/FadeOutLayer/FadeRect;
@onready var FadePlayer = $PlayerCamera/FadeOutLayer/FadePlayer;
@onready var Background = $Background;
@onready var LevelEnd : Area2D = $LevelEnd;
@onready var Player = get_tree().get_first_node_in_group(&"Player");
@onready var Test = $Test;
var anubisScript = preload("res://Anubis.gd")

func _ready() -> void:
	print(Global.SaveData);
	Global.SaveData[&"Health"] = 2;
	Global.SaveData[&"Coins"] = 10;
	FadeTransition.supply(FadeRect, FadePlayer);
	var anubisTest = load("res://anubis.tscn").instantiate()
	anubisTest.global_position = Test.global_position;
	Global._GBOSSFIGHTVARS(anubisTest);
	add_child(anubisTest);
	await Global.wait(1.0);
	#var box = Global.MakeHitbox(20.0,30.0, Test.global_position);
	#await Global.wait(2.0);
	#var visualizer = Global.visualizeArea(box);
	
	LevelEnd.body_entered.connect(func(body):
		if body.name == "Player":
			var curr = Global.GetCurrentScene();
			var scene = Global.GetSceneFromString(Global.SceneTransitions[curr]);
			Global.CurrentLevel = Global.SceneTransitions[curr];
			FadeTransition.transition(FadeTransition.TransitionType.ROOM_TRANSITION, scene);
	)
	var clbk1 = func():
		var player = get_tree().get_first_node_in_group("Player");
		player.speed = 0;
		await Global.wait(0.5);
		player.speed = 85;	
	var clbk2 = func():
		var player = get_tree().get_first_node_in_group("Player");
		player.speed = 0;
		await Global.wait(0.5);
		player.speed = 85;	
	FadeTransition.changeclbk(FadeTransition.TransitionType.OTHER, clbk1);
	FadeTransition.changeclbk(FadeTransition.TransitionType.ROOM_TRANSITION, clbk2);
		

	
