#well,it was better to not use this thing actually
extends CanvasLayer
#onreadies
var bus_id = AudioServer.get_bus_index(&"Master");
@onready var StartAdventure = $Control/StartAdventure;
@onready var QuitGame = $Control/QuitGame;
@onready var SettingsButton = $Control/SettingsButton;
@onready var FadeRect = $Control/FadeRect;
@onready var VolumeSlider = $Control/VolumeSlider;
@onready var Volume = $Control/VolumeSlider/Volume;
@onready var shn1 = Global.GetSceneFromString(&"shn1");
@onready var CreditsButton = $Control/CreditsButton;
@onready var ContinueButton = $Control/ContinueButton;


func _ready() -> void:
	StartAdventure.pressed.connect(func():
		var tweener = create_tween().tween_property(FadeRect, "modulate:a", 1, 0.5);
		tweener.finished.connect(func():
			get_tree().change_scene_to_packed(shn1);	
		)
	);
	QuitGame.pressed.connect(func():
		get_tree().quit(0);
	);
	SettingsButton.pressed.connect(func():
		pass
	);
	CreditsButton.pressed.connect(func():
		pass
	);
	ContinueButton.pressed.connect(func():
		# Since sava data is not wiped here, it should just be able to load
		var oldScene = Global.GetSceneFromString(Global.CurrentLevel);
		var tweener = create_tween().tween_property(FadeRect, "modulate:a", 1, 0.5);
		tweener.finished.connect(func():
			get_tree().change_scene_to_packed(oldScene);	
		)
	);
	VolumeSlider.value_changed.connect(func(value : float):
		var newValue = value as int;
		AudioServer.set_bus_volume_linear(bus_id, (value - 80.0));	
		Volume.text = str(newValue);
		print(newValue);	
	);
