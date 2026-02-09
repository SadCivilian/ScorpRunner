# Boss enemy.
extends CharacterBody2D

# SCENE IMPORTS
var mummyScene = preload("res://Mummy.tscn");
var mummyScript = preload("res://MummyBrain.gd");
var ShockwaveScene = preload("res://Shockwave.tscn");

# OTHER SHIT
signal onStateChanged(state);
enum state {IDLE, DEAD, HIT};
enum attacks {SUMMON, PROJECTILE, STOMP, OVERHEAD, NIL};
const WanderSpeed : int = 20;
const ChaseSpeed : int = 50;
var isonfloor = true;
var isdying = false;
var RNG : RandomNumberGenerator = RandomNumberGenerator.new();
@export var Health = 250;
@export var IgnorePlayer = false;
@export var CurrentSpeed = 20;
@export var gravityprone : bool = true; 
@export var gravity : int = 300;
@export var CurrentState : state = state.IDLE;
@export var CurrentAttack : attacks = attacks.NIL;
@export var LastUsedAttack : attacks = attacks.NIL;
@export var direction : int = -1;
@onready var Player: CharacterBody2D = get_tree().get_first_node_in_group("Player");
@onready var SightRay : RayCast2D = $SightRay; 
@onready var GroundRay : RayCast2D = $GroundRay;
@onready var Model : Sprite2D = $Model;
@onready var Animator : AnimationPlayer = $Animator;
@onready var BackArea : Area2D = $BackArea;
@onready var HitboxArea : Area2D = $HitboxArea;
@onready var Mouth : AudioStreamPlayer2D = $Mouth;
@onready var CD : Timer = $CD;
@onready var ParticleEmitter : CPUParticles2D = $ParticleEmitter;
@onready var HPBar : ProgressBar = $Model/ProgressBar;

func _ready() -> void:
	Animator.animation_finished.connect(func(anim_name):
		if anim_name == &"Summoning":
			CurrentAttack = attacks.NIL;
			LastUsedAttack = attacks.SUMMON;
		elif anim_name == &"Overhead":
			CurrentAttack = attacks.NIL;
			LastUsedAttack = attacks.OVERHEAD;
		elif anim_name == &"Stomp":
			CurrentAttack = attacks.NIL;
			LastUsedAttack = attacks.STOMP;
	);
	add_to_group(&"AnubisBoss");

func Create(loaded : Resource) -> Node:
	return loaded.instantiate();

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

func updateHealthBar(hp : int) -> void:
	var final = Health - hp;
	create_tween().tween_property(HPBar, "value", final, 0.2).set_ease(Tween.EASE_IN);

func takeDamage(amount : int) -> void:
	Health -= amount;
	updateHealthBar(Health);
	
func Summon() -> Node:
	CurrentAttack = attacks.SUMMON;
	Animator.stop(); # Make sure he's LOCKED IN
	Animator.play(&"Summoning");
	var newMummy = Create(mummyScene);
	newMummy.CurrentSpeed = 20;
	newMummy.DrawRaycasts = false;
	newMummy.IgnorePlayer = false;
	newMummy.gravityprone = true;
	newMummy.gravity = 300;
	newMummy.CurrentState = mummyScript.state.IDLE;
	newMummy.direction = direction;
	newMummy.punchCD = 20;
	newMummy.onpunchCD = false;
	newMummy.punching = false;
	newMummy.global_position = self.global_position; # hack, fix later
	get_tree().current_scene.add_child(newMummy);
	return newMummy;
	
func Stomp() -> void:
	for i in range(2):
		var one = Create(ShockwaveScene);
		var two = Create(ShockwaveScene);
		one.direct = -1;
		two.direct = 1;
		one.moving = true;
		two.moving = true;
		one.speed = 200;
		two.speed = 200;
		one.global_position = self.global_position + Vector2(5, 0);
		two.global_position = self.global_position - Vector2(5, 0);
		await Global.wait(0.5); # hack fix, add animation event
		
func Overhand() -> void:
	Animator.play(&"Overhead");
	await Global.wait(1.0);
	var IntersectArray = [];
	var newBox = Global.MakeHitbox(20.0, 30.0);
	
	
	
	
	
			
					
	
	
