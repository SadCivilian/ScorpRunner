extends Node2D

@onready var LevelEnd : Area2D = $LevelEnd;
@onready var Player = get_tree().get_first_node_in_group(&"Player");
@onready var FadeRect = $PlayerCamera/FadeOutLayer/FadeRect;
@onready var FadePlayer = $PlayerCamera/FadeOutLayer/FadePlayer;

func _ready() -> void:
	Player.loadPlayerState();
	Player.Disperse();
	FadeTransition.supply(FadeRect, FadePlayer);
	LevelEnd.body_entered.connect(func(body):
		if body.name == &"Player":
			Global.SaveData[&"Coins"] = Player.Coins;
			Global.SaveData[&"Score"] = Player.Score;
			Global.SaveData[&"Hearts"] = Player.Health;
			Global.SaveData[&"HasDoubleJump"] = Player.hasDoubleJump;
			var curr = Global.GetCurrentScene();
			var scene = Global.GetSceneFromString(Global.SceneTransitions[curr]);
			Global.CurrentLevel = Global.SceneTransitions[curr];
			FadeTransition.transition(FadeTransition.TransitionType.ROOM_TRANSITION, scene);
	)
	
	
