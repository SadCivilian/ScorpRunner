extends Area2D

@onready var Area = $".";

func _ready() -> void:
	Area.area_entered.connect(func(area):
		if area.get_parent().get_parent().is_in_group(&"Player"):
			Global.CurrentCheckpoint = self.name;
			print("checkpoint is now:" + Global.CurrentCheckpoint);
	);
