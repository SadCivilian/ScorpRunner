extends Node2D

@export var direct = -1;
@export var move = true;
@export var speed = 400;
@onready var Player = get_tree().get_first_node_in_group(&"Player");

func _init(direction : int):
	self.direct = direction;
	
func _ready():
	print("ready")
	visible = false

func _physics_process(delta: float) -> void:
	if move:
		print(position.x);
		position.x -= speed * delta * direct
		
func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	if body.name == "Player":
		Player.takeDamage(1, true);
		Player.applyKnockback(Vector2.ONE, 500); 
