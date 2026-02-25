extends Area2D

@export var triggered = false;
@onready var Area = $".";
@onready var Player = get_tree().get_first_node_in_group(&"Player")

func _ready() -> void:
	Area.area_entered.connect(func(area):
		if triggered == false and Global.isPlayerArea(area):
			triggered = true;
			Global.SaveData[&"Checkpoint"] = self.name;
			Global.SaveData[&"Hearts"] = Player.Health;
			Global.SaveData[&"Coins"] = Player.Coins;
			Global.SaveData[&"Score"] = Player.Score;
			Global.SaveData[&"HasDoubleJump"] = Player.hasDoubleJump;
	);
