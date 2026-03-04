extends Area2D

@export var triggered = false;
@onready var Area = $".";
@onready var Player = get_tree().get_first_node_in_group(&"Player")
@onready var soundPlayer = $AudioStreamPlayer2D;
@onready var sprite = $Sprite2D;

func _ready() -> void:
	Area.area_entered.connect(func(area):
		if triggered == false and Global.isPlayerArea(area):
			Global.UsedCheckpoints.append(self.name);
			triggered = true;
			soundPlayer.play();
			create_tween().tween_property(sprite, "modulate:a", 0, 0.5);
			Global.TakenHearts.append_array(Global.TempTakenHearts);
			Global.TempTakenHearts.clear();
			Global.FelledEnemies.append_array(Global.TempFelledEnemies);
			Global.TempFelledEnemies.clear();
			Global.CollectedCoins.append_array(Global.TempCollectedCoins);
			Global.TempCollectedCoins.clear();
			Global.OpenedChests.append_array(Global.TempOpenedChests);
			Global.TempOpenedChests.clear();
			Global.SaveData[&"Checkpoint"] = self.name;
			Global.SaveData[&"Hearts"] = Player.Health;
			Global.SaveData[&"Coins"] = Player.Coins;
			Global.SaveData[&"Score"] = Player.Score;
			Global.SaveData[&"HasDoubleJump"] = Player.hasDoubleJump;
	);
