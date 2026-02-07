# Boss enemy.
extends CharacterBody2D

signal onStateChanged(state);
enum state {IDLE, DEAD, HIT};
const WanderSpeed : int = 20;
const ChaseSpeed : int = 50;
var isonfloor = true;
var isdying = false;
var RNG : RandomNumberGenerator = RandomNumberGenerator.new();
@export var Health = 250;
@export var IgnorePlayer = false;
@export var DrawRaycasts : bool = false;
@export var CurrentSpeed = 20;
@export var gravityprone : bool = true; 
@export var gravity : int = 300;
@export var CurrentState : state = state.IDLE;
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player");
@onready var SightRay : RayCast2D = $SightRay; 
@onready var GroundRay : RayCast2D = $GroundRay;
@onready var Model : Sprite2D = $Model;
@onready var Animator : AnimationPlayer = $Animator;
@onready var BackArea : Area2D = $BackArea;
@onready var HitboxArea : Area2D = $HitboxArea;
@onready var Mouth : AudioStreamPlayer2D = $Mouth;
@onready var CD : Timer = $CD;
@onready var ParticleEmitter : CPUParticles2D = $ParticleEmitter;


# Changes the state to some state "newstate", returns the old state.
func changeState(newstate : state) -> state:
	var oldstate = self.CurrentState
	self.CurrentState = newstate
	onStateChanged.emit(newstate);

	return oldstate

# Returns previous state as usual.
func onstateChanged(newstate : state) -> void:
	match newstate:
		state.DEAD:
			print("freeing object")
			queue_free();

func activate() -> void:
	self.Model.visible = true;
	


func _ready() -> void:
	add_to_group(&"AnubisBoss");
	
