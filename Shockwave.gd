extends Area2D

@export var moving : bool = true;
@export var speed : int = 100;
@export var direction : int = 1;
@onready var Player = get_tree().get_first_node_in_group(&"Player");

func _ready() -> void:
	pass
	
func _init() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	position.x -= speed * delta * direction;
