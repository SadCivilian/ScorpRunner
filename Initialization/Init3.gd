extends Node2D

@onready var LevelEnd : Area2D = $LevelEnd;
@onready var Player = get_tree().get_first_node_in_group(&"Player");

func _ready() -> void:
	Player.loadPlayerState();
	Player.Disperse();
	LevelEnd.body_entered.connect(func(body):
		if body.name == &"Player":
			var curr = Global.GetCurrentScene();
			var scene = Global.GetSceneFromString(Global.SceneTransitions[curr]);
			Global.CurrentLevel = Global.SceneTransitions[curr];
			FadeTransition.transition(FadeTransition.TransitionType.ROOM_TRANSITION, scene);
	)
	
	
