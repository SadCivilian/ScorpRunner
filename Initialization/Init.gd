extends Node

@onready var FadeOutLayer = $Camera2D/FadeOutLayer;
@onready var FadeRect = $Camera2D/FadeOutLayer/FadeRect;
@onready var FadePlayer = $Camera2D/FadeOutLayer/FadePlayer;
@onready var Background = $Background;
@onready var LevelEnd : Area2D = $LevelEnd;
@onready var Player = get_tree().get_first_node_in_group(&"Player");
@onready var Test = $Test;
@onready var Camera = get_tree().get_first_node_in_group(&"Camera");
@onready var GameWin = Camera.get_child(3);
var anubisScript = preload("res://Anubis.gd")

func _ready() -> void:
	Player.loadPlayerState();
	Player.Disperse();
	FadeTransition.supply(FadeRect, FadePlayer);
	#var anubisTest = load("res://anubis.tscn").instantiate()
	#anubisTest.global_position = Test.global_position;
	#Global._GBOSSFIGHTVARS(anubisTest);
	#add_child(anubisTest);
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
		

	
