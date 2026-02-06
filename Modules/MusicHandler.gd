extends Node

var currentBGTrack : AudioStreamMP3;
var CurrentTrackLength : float;
var InitTrack : AudioStreamMP3;
var FadeRan : bool = false;
const FADE_OUT_TIME = 0.5;
const FADE_IN_TIME = 0.5;
@onready var BGMusicPlayer : AudioStreamPlayer2D = $".";

func _ready() -> void:
	BGMusicPlayer.finished.connect(FadeOutTrack);
	CurrentTrackLength = BGMusicPlayer.stream.get_length();
	await get_tree().create_timer(1.0).timeout;
	# BGMusicPlayer.play();

func _process(delta: float) -> void:
	if BGMusicPlayer.get_playback_position() - CurrentTrackLength < FADE_OUT_TIME:
		FadeOutTrack();
		FadeRan = true;

# Fades out the current track right before replaying it.
func FadeOutTrack() -> void:
	var fadeouttween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO);	
	fadeouttween.tween_property(BGMusicPlayer, "volume_db", -80.0, FADE_OUT_TIME);
	
func FadeInTrack() -> void:
	var fadeintween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO);
	fadeintween.tween_property(BGMusicPlayer, "volume_db", 0.0, FADE_IN_TIME);

	
# Sets the background music 
func setBgMusic(Track : AudioStreamMP3, fade : bool) -> void:
	if fade == true:	
		print("Transitioning track with fade");
		var fadeouttween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO);
		var fadeintween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO);
		fadeouttween.tween_property(BGMusicPlayer, "volume_db", -80.0, FADE_OUT_TIME);
		BGMusicPlayer.stream = Track;
		currentBGTrack = Track;
		fadeintween.tween_property(BGMusicPlayer, "volume_db", 0, FADE_IN_TIME);
	else: 
		BGMusicPlayer.stream = Track;
		currentBGTrack = Track;
