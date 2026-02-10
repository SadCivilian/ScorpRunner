extends CanvasLayer

var faderect;
var fadeplayer;
var TransitionClbk : Callable;
var OtherClbk : Callable;
var transitionScene : PackedScene;
enum TransitionType {ROOM_TRANSITION, OTHER};
	
func supply(rect : ColorRect, player : AnimationPlayer) -> void:
	faderect = rect;
	fadeplayer = player;
	fadeplayer.animation_finished.connect(on_anim_finished);
	
func changeclbk(clbktype : TransitionType, clbk : Callable) -> void:
	match clbktype:
		TransitionType.ROOM_TRANSITION:
			TransitionClbk = clbk;
		TransitionType.OTHER:
			OtherClbk = clbk;

func on_anim_finished(anim_name) -> void:
	if anim_name == "fade_to_black":
		await Global.wait(0.5);
		if transitionScene: #queued
			get_tree().change_scene_to_packed(transitionScene);
			transitionScene = null;
		fadeplayer.play("fade_to_normal");
	elif anim_name == "fade_to_normal":
		faderect.visible = false;

# Fades the screen black. 
# The given TransitionType will decide which callback to run (seperate callbacks can be attached to changing scenes via transition or other misc. transitions)
func transition(type : TransitionType = TransitionType.ROOM_TRANSITION, Scene : PackedScene = null) -> void:
	if Scene:
		transitionScene = Scene;
	if fadeplayer and faderect:
		match type:
			TransitionType.ROOM_TRANSITION:
				fadeplayer.play("fade_to_black");
				if TransitionClbk.is_valid():
					TransitionClbk.call();
			TransitionType.OTHER:
				fadeplayer.play("fade_to_black");
				if OtherClbk.is_valid():
					print("call clbk");
					OtherClbk.call();
	else:
		await Global.wait(0.1)
		transition(type)
		

			
	
