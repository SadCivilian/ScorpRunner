extends Node

@onready var Player = get_tree().get_first_node_in_group(&"Player");
@onready var BossFightTrigger = $BossFightTrigger;
@onready var AnubisSpawnPos = $AnubisSpawn.global_position;
@onready var Lava1 = $Lava;
@onready var Lava2 = $Lava2;
@onready var Blockade = $Blockade;
@onready var Blockade2 = $Blockade2;
@onready var Hitbox = $Blockade/Hitbox;
@onready var Hitbox2 = $Blockade2/Hitbox;

var PortalScene = preload("res://ending_portal.tscn");
var AnubisScene = preload("res://anubis.tscn");
var BossfightTriggered = false;

func _ready() -> void:
	BossFightTrigger.area_entered.connect(func(area : Area2D):
		if Global.isPlayerArea(area) and BossfightTriggered == false:
			Blockade.area_entered.connect(func(who : Area2D):
				if Global.isPlayerArea(who):
					Player.takeDamage(1, 1.0, true);	
					Player.applyKnockback((Player.global_position - Blockade.global_position).normalized() + Vector2(0, -2.5), -400.0)
			);
			Blockade2.area_entered.connect(func(who : Area2D):
				print("sure");
				if Global.isPlayerArea(who):
					Player.takeDamage(1, 1.0, true);
					Player.applyKnockback((Player.global_position - Blockade2.global_position).normalized() + Vector2(0, -2.5), 400.0)
			);
			BossfightTriggered = true;
			# tweens
			get_tree().create_tween().set_parallel()
			get_tree().create_tween().tween_property(Lava1, "scale:y", -4.0, 1.5);
			get_tree().create_tween().tween_property(Lava2, "scale:y", -4.0, 1.5);
			get_tree().create_tween().tween_property(Lava1, "modulate:a", 255, 0.5);
			get_tree().create_tween().tween_property(Lava2, "modulate:a", 255, 0.5);
			# spawn
			var anubis = Global.Create(AnubisScene);
			anubis.global_position = AnubisSpawnPos;
			Global._GBOSSFIGHTVARS(anubis);
			add_child(anubis);
			anubis.killed.connect(func():
				var pos = get_tree().current_scene.find_child(&"PortalSpawn").global_position;
				var portal = Global.Create(PortalScene);
				var model = portal.get_child(0);
				model.modulate.a = 0;
				portal.global_position = pos;
				add_child(portal);
				get_tree().create_tween().set_parallel();
				create_tween().tween_property(model, "modulate:a", 1.0, 0.5);
				get_tree().create_tween().tween_property(Lava1, "scale:y", 0, 1.5).set_ease(Tween.EASE_IN);
				get_tree().create_tween().tween_property(Lava2, "scale:y", 0, 1.5).set_ease(Tween.EASE_IN);
				create_tween().tween_property(Lava1, "modulate:a", 0, 1.5);
				create_tween().tween_property(Lava2, "modulate:a", 0, 1.5);
				Blockade.monitoring = false;
				Blockade2.monitoring = false;
				Hitbox.disabled = true;
				Hitbox2.disabled = true;
			);
			# override bossfight music
	);
	
