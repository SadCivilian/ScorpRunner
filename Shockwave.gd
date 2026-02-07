extends Area2D

@export var moving : bool = true;
@export var speed : int = 100;
@export var direction : int = 1;
@onready var Player = get_tree().get_first_node_in_group(&"Player");
@onready var Collision = $Collision;

func _ready() -> void:
	Collision.area_entered.connect(func(who):
		if who.parent.is_in_group(&"Player"):
			queue_free();
	)

func _physics_process(delta: float) -> void:
	if moving:
		position.x -= speed * delta * direction;
