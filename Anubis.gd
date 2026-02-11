# Boss enemy.
extends CharacterBody2D

# SCENE IMPORTS
var mummyScene = preload("res://Mummy.tscn");
var mummyScript = preload("res://MummyBrain.gd");
var ShockwaveScene = preload("res://Shockwave.tscn");
var BlastScene = preload("res://Blast.tscn");
@onready var scene = get_tree().current_scene;

# OTHER SHIT
signal onStateChanged(state);
enum state {FIGHT, DEAD, HIT};
enum attacks {SUMMON, PROJECTILE, STOMP, OVERHEAD, NIL};
const TimeBetweenAttacks : int = 5;
var caninitiate = true;
var isonfloor = true;
var isdying = false;
var closeEnoughtoOverhead = false;
@export var Health = 500;
@export var IgnorePlayer = false;
@export var CurrentSpeed = 20;
@export var gravityprone : bool = true; 
@export var gravity : int = 300;
@export var CurrentState : state = state.FIGHT;
@export var CurrentAttack : attacks = attacks.NIL;
@export var LastUsedAttack : attacks = attacks.NIL;
@export var direction : int = 1;
@onready var Player: CharacterBody2D = get_tree().get_first_node_in_group("Player");
@onready var Model : Sprite2D = $Model;
@onready var Animator : AnimationPlayer = $Animator;
@onready var Mouth : AudioStreamPlayer2D = $Mouth;
@onready var CD : Timer = $CD;
@onready var HPBar : ProgressBar = $Model/ProgressBar;
@onready var Hitbox : Area2D = $Anubis_HitboxArea;
@onready var GameWinUI : CanvasLayer = get_tree().get_first_node_in_group(&"Camera").get_child(3);

func _ready() -> void:
	Hitbox.area_entered.connect(onSelfEntered);
	CD.timeout.connect(func():
		caninitiate = true;	
	)
	Animator.animation_finished.connect(func(anim_name):
		match anim_name:
			&"Summoning":
				CurrentAttack = attacks.NIL;
				LastUsedAttack = attacks.SUMMON;
			&"Overhead":
				CurrentAttack = attacks.NIL;
				LastUsedAttack = attacks.OVERHEAD;
			&"Staff":
				CurrentAttack = attacks.NIL;
				LastUsedAttack = attacks.PROJECTILE;
			&"Stomp":
				CurrentAttack = attacks.NIL;
				LastUsedAttack = attacks.STOMP;
	);
	add_to_group(&"AnubisBoss");
	
# Need to figure out turning logic? Or always face player?
func _physics_process(dt : float) -> void:
	Model.flip_h = not Global.IntToBool(direction); # Normalize model I guess
	if not IgnorePlayer:
		var playerPos = Player.global_position;
		var selfPos = self.global_position;
		var yDiff = abs(selfPos.y - playerPos.y);
		var xDiff = abs(selfPos.x - playerPos.x);
		var can : bool = yDiff < 3.0 and LastUsedAttack != attacks.OVERHEAD and sign(direction) == sign(xDiff) and xDiff < sign(direction) * 20
		# First, figure out if we can do the overhead if we're close enough, off cooldown, and facing the right dir
		if can:
			closeEnoughtoOverhead = true;
		else:
			closeEnoughtoOverhead = false;
		
	
# Instantiates a scene.
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
			queue_free();
			
func onSelfEntered(area : Area2D) -> void:
	if area.name == &"Stinger":
		takeDamage(Player.attackDMG);
	elif area.get_parent().get_parent().is_in_group(&"Player"):
		Player.takeDamage(1, 1.0, true);	
	elif area.get_parent().is_in_group(&"Player"):
		Player.takeDamage(1, 1.0, true);

func updateHealthBar(hp : int) -> void:
	create_tween().tween_property(HPBar, "value", hp, 0.2).set_ease(Tween.EASE_IN);

func takeDamage(amount : int) -> void:
	var new = Health - amount;
	Health = new;
	updateHealthBar(new);
	if new <= 0:
		Die();
	
func DecideNextAttack() -> StringName:
	while true:
		var random = randi_range(1,4);
		if random == LastUsedAttack:
			continue
		else:
			return attacks.find_key(random);
	return &"";
	
# Summoning attack. Enemy is buffed.
#TODO: fade it in
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
	newMummy.CurrentState = mummyScript.state.CHASE;
	newMummy.direction = direction;
	newMummy.punchCD = 5;
	newMummy.onpunchCD = false;
	newMummy.punching = false;
	newMummy.global_position = self.global_position; # hack, fix later
	scene.add_child(newMummy);
	return newMummy;
	
# Stomping attack.
func Stomp() -> void:
	CurrentAttack = attacks.STOMP;
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
		scene.add_child(one);
		scene.add_child(two);
		print(one.global_position, two.global_position);
		await Global.wait(1.5); # hack fix, add animation event


func Overhead() -> void:
	var pos = self.global_position + Vector2(10 * direction, 0);
	CurrentAttack = attacks.OVERHEAD;
	Animator.play(&"Overhead");
	await Global.wait(1.0);
	var IntersectArray = [];
	var newBox = Global.MakeHitbox(1, 20.0, 30.0);
	Global.visualizeArea(newBox);
	
# Ranged attack.
func Staff() -> void:
	CurrentAttack = attacks.PROJECTILE;
	Animator.play(&"Staff");
	var newBlast = Create(BlastScene);
	newBlast.moving = true;
	newBlast.direct = direction;
	newBlast.speed = 200;
	newBlast.global_position = self.global_position;
	scene.add_child(newBlast);
	

# For when HP hits 0.
func Die() -> void:
	HPBar.visible = false;
	await Global.wait(0.3);
	var curr = Model.modulate;
	var tweener = create_tween().tween_property(Model, "modulate", Color(curr.r, curr.g, curr.b, 0), 0.2).set_ease(Tween.EASE_IN);
	tweener.finished.connect(func():
		queue_free();	
	)
	

	
	
			
					
	
	
