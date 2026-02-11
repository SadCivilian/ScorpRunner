extends Node2D

@export var direct = 1;
@export var move = true;
@export var speed = 500;
@onready var Player = get_tree().get_first_node_in_group(&"Player");
@onready var Sprite = $Model;
	
func _physics_process(delta: float) ->void:
	Sprite.flip_h = not Global.IntToBool(direct);
	if move:
		position.x -= speed * delta * -direct
		
func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	if body.name == "Player":
		Player.takeDamage(1, true);
		Player.applyKnockback(Vector2.ONE, 300); 
