#chest code which is made instead of lucky block
extends Area2D
#onreadiesss
@onready var Area = $".";
@onready var Animator = $"Animator";
@onready var Player = get_tree().get_first_node_in_group(&"Player");
@export var opened = false;

#the code
func _ready() -> void:
	Animator.animation_finished.connect(func(anim_name):
		var random = randi_range(10, 15);
		Player.addCoins(random);
	);
	Area.area_entered.connect(func(area):
		if area.name == &"Stinger" and opened == false:
			opened = true;
			Global.TempOpenedChests.append(self.name);
			Animator.play(&"Open");
	);
