extends Area2D

@onready var Player = get_tree().get_first_node_in_group(&"Player");
@export var picked = false

func _ready() -> void:
	self.area_entered.connect(func(area):
		if picked == false and Global.isPlayerArea(area) and Player.Health != 3:
			picked = true;
			Player.takeDamage(-1, false, 0.0);	
			Global.TempTakenHearts.append(self.name);
			print(Player.Health);
			queue_free();	
	);
