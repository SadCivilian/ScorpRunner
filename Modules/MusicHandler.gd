extends Node

var currentBGTrack : AudioStreamMP3;
var CurrentTrackLength : float;
var InitTrack : AudioStreamMP3;
var FadeRan : bool = false;
const FADE_OUT_TIME = 1.5;
const FADE_IN_TIME = 0.75;
@onready var BGMusicPlayer : AudioStreamPlayer = $".";
@onready var bossMusic = preload("res://assets/songs/bossFight.mp3");

func _ready() -> void:
	add_to_group(&"BGMusicPlayer");
	BGMusicPlayer.finished.connect(FadeOutTrack);
	CurrentTrackLength = BGMusicPlayer.stream.get_length();
	await get_tree().create_timer(1.0).timeout;
	BGMusicPlayer.play();
	
func _process(delta: float) -> void:
	if (CurrentTrackLength - BGMusicPlayer.get_playback_position()) < FADE_OUT_TIME and FadeRan == false:
		FadeOutTrack();
		FadeRan = true;

# Fades out the current track right before replaying it.
func FadeOutTrack() -> void:
	var fadeouttween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO);	
	var tweener = fadeouttween.tween_property(BGMusicPlayer, "volume_linear", 0.0, FADE_OUT_TIME);
	tweener.finished.connect(func():
		FadeInTrack();	
	);
	
func FadeOutTrackPerm() -> void:
	var fadeouttween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO);	
	fadeouttween.tween_property(BGMusicPlayer, "volume_linear", 0.0, FADE_OUT_TIME);
	
func FadeInTrack() -> void:
	BGMusicPlayer.volume_linear = 0;
	BGMusicPlayer.play();
	var fadeintween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO);
	var tweener = fadeintween.tween_property(BGMusicPlayer, "volume_linear", 1.0, FADE_IN_TIME);
	tweener.finished.connect(func():
		FadeRan = false;	
	);

	
# Sets the background music 
func setBgMusic(Track : AudioStreamMP3, fade : bool) -> void:
	if fade == true:	
		var fadeouttween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO);
		var tweener = fadeouttween.tween_property(BGMusicPlayer, "volume_linear", 0.0, FADE_OUT_TIME);
		tweener.finished.connect(func():
			BGMusicPlayer.stream = Track;
			currentBGTrack = Track;
			CurrentTrackLength = Track.get_length();
			BGMusicPlayer.play();
			var fadeintween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO);
			fadeintween.tween_property(BGMusicPlayer, "volume_linear", 1.0, FADE_IN_TIME);
		);
	else: 
		BGMusicPlayer.stream = Track;
		currentBGTrack = Track;
		CurrentTrackLength = Track.get_length();
		BGMusicPlayer.play();
