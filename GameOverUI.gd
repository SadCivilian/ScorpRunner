extends CanvasLayer

@onready var Renderer : CanvasLayer = $".";
@onready var RetryLevel : Button = $RetryLevel;
@onready var QuitGame : Button = $QuitGame;
@onready var ContinueText : RichTextLabel = $ContinueText;
@onready var GameOver : RichTextLabel = $GameOver;
		
func getUILayer() -> CanvasLayer:
	return get_tree().get_first_node_in_group(&"GameOverUIRenderer");

func WireFunctionality() -> void:
	RetryLevel.pressed.connect(func():
		FadeTransition.transition(FadeTransition.TransitionType.OTHER)
		hide();
		get_tree().reload_current_scene();
	);
	QuitGame.pressed.connect(func():
		get_tree().quit(0);
	);
	

func _ready() -> void:
	add_to_group(&"GameOverUIRenderer");
	WireFunctionality();

	# Styling
	var retrystyle : StyleBox = RetryLevel.get_theme_stylebox(&"normal")
	retrystyle.bg_color = ""
	var quitstyle : StyleBox = QuitGame.get_theme_stylebox(&"normal")
	quitstyle.bg_color = ""
