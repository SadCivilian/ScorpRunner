extends Area2D

@export var triggered = false;
@onready var Area = $".";

func _ready() -> void:
	Area.area_entered.connect(func(area):
		if triggered == false and area.get_parent().get_parent().is_in_group(&"Player"):
			triggered = true;
			Global.SaveData[&"Checkpoint"] = self.name;
			print("checkpoint is now:" + Global.SaveData[&"Checkpoint"]);
	);
