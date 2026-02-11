extends Area2D

@onready var Camera = get_tree().get_first_node_in_group(&"Camera");
@onready var GameWinUI = Camera.get_child(3);
@onready var Area = $".";
@onready var MusicPlayer = get_tree().get_first_node_in_group(&"BGMusicPlayer");

func _ready() -> void:
	Area.area_entered.connect(func(area):
		if area.get_parent().get_parent().is_in_group(&"Player"):
			EndGame()	
	)
	
func EndGame() -> void:
	GameWinUI.TriggerCutscene();
	MusicPlayer.FadeOutTrackPerm();
