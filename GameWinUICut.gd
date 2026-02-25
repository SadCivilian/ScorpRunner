extends CanvasLayer

@onready var FadeOut : ColorRect = $FadeOut;
@onready var FinishLabel : RichTextLabel = $FinishLabel;
@onready var ScoreLabel : RichTextLabel = $ScoreLabel;
@onready var Score : RichTextLabel = $Score;
@onready var Thanks : RichTextLabel = $Thanks;
@onready var Logo : Sprite2D = $Logo;
@onready var ReplayButton : Button = $ReplayButton;

@onready var Player = get_tree().get_first_node_in_group(&"Player");

func _ready() -> void:
	ReplayButton.pressed.connect(func():
		Player.dead = true;
		var packed = Global.GetSceneFromString(&"shn1");
		get_tree().change_scene_to_packed(packed);
	);
	ScoreLabel.text = "Score: ";

func TriggerCutscene() -> void:
	self.show();
	Player.dead = true;
	Score.text = str(Player.getUserData()[&"Score"]);
	var tween = create_tween().tween_property(FadeOut, "modulate:a", 1.0, 0.5);
	tween.finished.connect(func():
		var text_tween = create_tween().set_parallel(true)
		text_tween.tween_property(ScoreLabel, "modulate:a", 1.0, 0.5);
		text_tween.tween_property(Score, "modulate:a", 1.0, 0.5);
		text_tween.tween_property(FinishLabel, "modulate:a", 1.0, 0.5); 
		text_tween.tween_property(Thanks, "modulate:a", 1.0, 0.5);     
		text_tween.tween_property(Logo, "modulate:a", 1.0, 0.5);
		text_tween.tween_property(ReplayButton, "modulate:a", 1.0, 0.5);
	)
