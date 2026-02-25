extends Node

@onready var Player = get_tree().get_first_node_in_group(&"Player");
@onready var BossFightTrigger = $BossFightTrigger;
@onready var AnubisSpawnPos = $AnubisSpawn.global_position;
var PortalScene = preload("res://ending_portal.tscn");
var AnubisScene = preload("res://anubis.tscn");
var BossfightTriggered = false;

func _ready() -> void:
	BossFightTrigger.area_entered.connect(func(area : Area2D):
		if Global.isPlayerArea(area) and BossfightTriggered == false:
			BossfightTriggered = true;
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
				create_tween().tween_property(model, "modulate:a", 1.0, 0.5);
			);
			# override bossfight music
	);
	
