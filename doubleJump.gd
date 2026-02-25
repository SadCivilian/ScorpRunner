extends Area2D

@onready var Player = get_tree().get_first_node_in_group(&"Player");

func _ready() -> void:
	self.area_entered.connect(func(area):
		if Global.isPlayerArea(area):
			Player.hasDoubleJump = true
			self.get_parent().queue_free();	
	)
