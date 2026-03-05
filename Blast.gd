#A port ooops part of anubis attack 
extends Node2D
#setup
@export var direct : int = 1;
@export var moving : bool = true;
@export var speed : int = 100;
@onready var Player = get_tree().get_first_node_in_group(&"Player");
@onready var Sprite = $Model;
@onready var Collision = $"Collision";

func _ready() -> void:
	Collision.area_entered.connect(func(who):
		if Global.isPlayerArea(who):
			Player.takeDamage(1, true, 2.0);
			queue_free();
	);

func _physics_process(delta: float) -> void:
	Sprite.flip_h = Global.IntToBool(direct);
	if moving:
		position.x -= speed * delta * -direct;
