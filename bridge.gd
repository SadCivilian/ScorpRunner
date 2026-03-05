#code for the bridge which changed for 3 serious times :/
extends Node2D

@onready var bridge_node : Control = $Control;
@onready var collision = $Control/Bridge/Collision;
var triggered : bool = false


func _ready():
	collision.body_entered.connect(func(body):
		if body.name == &"Player":
			tweenBridge();
	);
	
#the bridge animiation
func tweenBridge() -> void:
	triggered = true;
	if bridge_node == null: return
	var hedef_aci = deg_to_rad(90.0);
	var tween = create_tween()
	tween.tween_property(bridge_node, "rotation", hedef_aci, 3.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	
