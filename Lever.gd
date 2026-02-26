# This class will ALWAYS start on IDLE. It can never switch BACK to IDLE unless explicitly RESET via reset(), it will only be on ACTIVATED or DEACTIVATED on all other interactions.
class_name Lever
extends Node2D

enum LeverState {ACTIVATED, DEACTIVATED, IDLE};

signal activated(); # For one time use levers.
signal deactivated(); # For one time use levers.
signal stateChanged(newState); # For levers that can be switched on and off.

# exports
@export var is_activated : bool = false;
@export var activatable : bool = true; 
@export var one_time_use : bool = false; 
@export var used : bool = false; # For one time use levers.
@export var cd : float = 0.5;
@export var CurrentState : LeverState = LeverState.IDLE; 

# onreadies
@onready var Model : Sprite2D = $Pivot/Model;
@onready var ActivationArea : Area2D = $Pivot/ActivationArea;
@onready var CD : Timer = $CD;
@onready var Pivot : Node2D = $Pivot;



# regular vars
var onActivatedArray : Array[Callable] = [];
var onDeactivatedArray : Array[Callable] = [];

func _ready() -> void:
	CD.timeout.connect(onCooldownEnded);
	ActivationArea.area_entered.connect(selfEntered);
	self.deactivated.connect(run.bind("deactivated"));
	self.activated.connect(run.bind("activated"));

func selfEntered(area : Area2D) -> void:
	if area.name == &"Stinger": # This is the player "attack" area, which is also used for interactions 
		match self.CurrentState:
			LeverState.IDLE:
				activate();
			LeverState.ACTIVATED:
				deactivate();
			LeverState.DEACTIVATED:
				activate();
				
func onCooldownEnded() -> void:
	activatable = true;
				
func attachOnActivated(clbk : Callable) -> void:
	onActivatedArray.append(clbk);

func attachOnDeactivated(clbk : Callable) -> void:
	onDeactivatedArray.append(clbk);

func clearAll() -> void:
	onActivatedArray.clear();
	onDeactivatedArray.clear();
	
func clearActivated() -> void:
	onActivatedArray.clear();

func clearDeactivated() -> void:
	onDeactivatedArray.clear();

# The order is somehow not guaranteed, blame godot.
func popActivated() -> void:
	onActivatedArray.pop_front();
	
# The order is somehow not guaranteed, blame godot.
func popDeactivated() -> void:
	onDeactivatedArray.pop_front();
	
func updateRot(state : LeverState) -> void:
	var targetRot : int;
	match state:
		LeverState.ACTIVATED:
			targetRot = 45;
		LeverState.DEACTIVATED:
			targetRot = -45;
		LeverState.IDLE:
			targetRot = 0;
	var _HitboxTween = get_tree().create_tween().tween_property(Pivot, "rotation_degrees", targetRot, 0.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE);
			
# runs all callbacks attached to the lever depending on the type.
func run(type : String) -> void:
	match type:
		"activated":
			for clbk in onActivatedArray:
				if clbk.is_null() == false and clbk.is_valid():
					clbk.call();
		"deactivated":
			for clbk in onDeactivatedArray:
				if clbk.is_null() == false and clbk.is_valid():
					clbk.call();
			
func changeState(newState : LeverState) -> LeverState:
	var oldstate = self.CurrentState;
	self.CurrentState = newState;
	return oldstate

func getState(asString : bool = true) -> Variant:
	if asString == true:
		match self.CurrentState:
			LeverState.ACTIVATED:
				return "Deactivated";
			LeverState.IDLE:
				return "Idle";
			LeverState.DEACTIVATED:
				return "Deactivated";
	else:
		return self.CurrentState;	
	return "Unreachable"

# Activates the lever.
func activate() -> void:
	if one_time_use == true and used != true and activatable == true:
		used = true;
		activated.emit();
		changeState(LeverState.ACTIVATED);
		updateRot(self.CurrentState);
		CD.start(cd);
		activatable = false;
		return
	elif activatable == true:
		activated.emit();
		changeState(LeverState.ACTIVATED);
		updateRot(self.CurrentState);
		CD.start(cd);
		activatable = false;
		return

# Deactivates the lever.
func deactivate() -> void:
	if activatable == true:
		deactivated.emit();
		changeState(LeverState.DEACTIVATED);
		updateRot(self.CurrentState);
		CD.start(cd);
		activatable = false;
		return
		
func reset() -> void:
	changeState(LeverState.IDLE);
	updateRot(self.CurrentState);
	
	
	
