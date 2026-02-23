extends CanvasLayer

@onready var FadeOut : ColorRect = $FadeOut;
@onready var FinishLabel : RichTextLabel = $FinishLabel;
@onready var ScoreLabel : RichTextLabel = $ScoreLabel;
@onready var Score : RichTextLabel = $Score;
@onready var Thanks : RichTextLabel = $Thanks;
@onready var Logo : Sprite2D = $Logo;

@onready var Player = get_tree().get_first_node_in_group(&"Player");
@onready var PlayerData = Player.getUserData()

func _ready() -> void:
	ScoreLabel.text = "Score: ";
	Score.text = str(PlayerData[&"Score"]);

func TriggerCutscene() -> void:
	self.show();
	var tween = create_tween().tween_property(FadeOut, "modulate:a", 1.0, 0.5);
	tween.finished.connect(func():
		var text_tween = create_tween().set_parallel(true)
		text_tween.tween_property(ScoreLabel, "modulate:a", 1.0, 0.5);
		text_tween.tween_property(Score, "modulate:a", 1.0, 0.5);
		text_tween.tween_property(FinishLabel, "modulate:a", 1.0, 0.5); 
		text_tween.tween_property(Thanks, "modulate:a", 1.0, 0.5);     
		text_tween.tween_property(Logo, "modulate:a", 1.0, 0.5);
	)
