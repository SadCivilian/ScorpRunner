extends CanvasLayer

@onready var Renderer : CanvasLayer = $".";
@onready var RetryLevel : Button = $RetryLevel;
@onready var QuitGame : Button = $QuitGame;
@onready var ContinueText : RichTextLabel = $ContinueText;
@onready var Player : CharacterBody2D = get_tree().get_first_node_in_group(&"Player");
@onready var mainMenuScene = Global.GetSceneFromString(&"MainMenu");

func getUILayer() -> CanvasLayer:
	return get_tree().get_first_node_in_group(&"GameOverUIRenderer");

func WireFunctionality() -> void:
	RetryLevel.pressed.connect(func():
		hide();
		get_tree().reload_current_scene();
	);
	QuitGame.pressed.connect(func():
		get_tree().change_scene_to_packed(mainMenuScene);
	);

func style(button : Button, color : Color) -> void:
	# this was painful
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

	button.add_theme_stylebox_override("normal", style)
	
	var hover_style = style.duplicate()
	hover_style.bg_color = color.lightened(0.2)
	button.add_theme_stylebox_override("hover", hover_style)
	
	var pressed_style = style.duplicate()
	pressed_style.bg_color = color.darkened(0.2)
	button.add_theme_stylebox_override("pressed", pressed_style)
	
	var disabled_style = style.duplicate()
	disabled_style.bg_color = Color.GRAY
	button.add_theme_stylebox_override("disabled", disabled_style)	

func _ready() -> void:
	add_to_group(&"GameOverUIRenderer");
	WireFunctionality();
	style(RetryLevel, Color("#00FF00"));
	style(QuitGame, Color("#FF0000"));
