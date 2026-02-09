extends Area2D

@export var bridge_node : Control 
var triggered : bool = false
func _ready():
	if bridge_node:
		bridge_node.rotation = 0
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		
func tweenBridge() -> void:
	if bridge_node == null: return
	var hedef_aci = deg_to_rad(90.0);
	var tween = create_tween()
	tween.tween_property(bridge_node, "rotation", hedef_aci, 3.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	
func _on_body_entered(incoming_body):
	if incoming_body.name == "Player" and not triggered:
		triggered = true
		tweenBridge()
