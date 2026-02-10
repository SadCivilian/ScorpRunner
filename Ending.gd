extends Area2D

@onready var Camera = get_tree().get_first_node_in_group(&"Camera");
@onready var GameWinUI = Camera.get_child(3);
@onready var Area = $".";

func _ready() -> void:
	Area.area_entered.connect(func(area_name):
		if area_name == "Player":
			EndGame()	
	)
	
func EndGame() -> void:
	GameWinUI.TriggerCutscene();
