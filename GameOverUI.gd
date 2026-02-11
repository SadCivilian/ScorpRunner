extends CanvasLayer

@onready var Renderer : CanvasLayer = $".";
@onready var RetryLevel : Button = $RetryLevel;
@onready var QuitGame : Button = $QuitGame;
@onready var ContinueText : RichTextLabel = $ContinueText;
@onready var GameOver : RichTextLabel = $GameOver;
@onready var Player : CharacterBody2D = get_tree().get_first_node_in_group(&"Player");

		
func getUILayer() -> CanvasLayer:
	return get_tree().get_first_node_in_group(&"GameOverUIRenderer");

func WireFunctionality() -> void:
	RetryLevel.pressed.connect(func():
		FadeTransition.transition(FadeTransition.TransitionType.OTHER)
		hide();
		var PlayerData : Dictionary[StringName, Variant] = Player.getUserData();
		get_tree().reload_current_scene();
		Player.Health = PlayerData[&"Health"];
		Player.Coins = PlayerData[&"Coins"];
		Player.Score = PlayerData[&"Score"];
	);
	QuitGame.pressed.connect(func():
		get_tree().quit(0);
	);

func style(button : Button, color : Color) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = color.darkened(0.3)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	
	# Set for all states
	button.add_theme_stylebox_override("normal", style)
	
	# Hover state (lighter)
	var hover_style = style.duplicate()
	hover_style.bg_color = color.lightened(0.2)
	button.add_theme_stylebox_override("hover", hover_style)
	
	# Pressed state (darker)
	var pressed_style = style.duplicate()
	pressed_style.bg_color = color.darkened(0.2)
	button.add_theme_stylebox_override("pressed", pressed_style)
	
	# Disabled state (gray)
	var disabled_style = style.duplicate()
	disabled_style.bg_color = Color.GRAY
	button.add_theme_stylebox_override("disabled", disabled_style)	

func _ready() -> void:
	add_to_group(&"GameOverUIRenderer");
	WireFunctionality();
	style(RetryLevel, Color("#00FF00"));
	style(QuitGame, Color("#FF0000"));
