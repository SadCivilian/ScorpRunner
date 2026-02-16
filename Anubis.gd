# Boss enemy.
extends CharacterBody2D

# SCENE IMPORTS
var mummyScene = preload("res://Mummy.tscn");
var mummyScript = preload("res://MummyBrain.gd");
var ShockwaveScene = preload("res://Shockwave.tscn");
var BlastScene = preload("res://Blast.tscn");
@onready var scene = get_tree().current_scene;

# ANIMATION EVENT STUFF
const AnimEvents : Array[StringName] = [&"Overhead", &"Staff", &"Stomp", &"Summoning"];
signal MarkerReached(anim_name : StringName);

func onMarkerReached(anim_name : StringName) -> void:
	if AnimEvents.has(anim_name):
		MarkerReached.emit(anim_name);  

# OTHER SHIT
signal onStateChanged(state);
enum state {FIGHT, DEAD, HIT};
enum attacks {SUMMONING, STAFF, STOMP, OVERHEAD, NIL};
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
@onready var PlayerHitbox : Area2D = Player.find_child(&"HurtArea", true);
@onready var Model : Sprite2D = $Model;
@onready var Animator : AnimationPlayer = $Animator;
@onready var Mouth : AudioStreamPlayer2D = $Mouth;
@onready var CD : Timer = $CD;
@onready var HPBar : ProgressBar = $Model/ProgressBar;
@onready var Hitbox : Area2D = $Anubis_HitboxArea;

func _ready() -> void:
	Hitbox.area_entered.connect(onSelfEntered);
	CD.timeout.connect(func():
		print("we're off move cooldown now");
		caninitiate = true;	
		print(caninitiate);
	)
	Animator.animation_finished.connect(func(anim_name):
		match anim_name:
			&"Summoning":
				CurrentAttack = attacks.NIL;
				LastUsedAttack = attacks.SUMMONING;
			&"Overhead":
				CurrentAttack = attacks.NIL;
				LastUsedAttack = attacks.OVERHEAD;
			&"Staff":
				CurrentAttack = attacks.NIL;
				LastUsedAttack = attacks.STAFF;
			&"Stomp":
				MarkerReached.disconnect(stompLambda);
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
		var can : bool = yDiff < 3.0 and LastUsedAttack != attacks.OVERHEAD and sign(direction) == sign(xDiff) and xDiff < abs(direction * 50)
		# First, figure out if we can do the overhead if we're close enough, off cooldown, and facing the right dir
		if can:
			print("close");
			closeEnoughtoOverhead = true;
		else:
			closeEnoughtoOverhead = false;
		if caninitiate and CurrentAttack == attacks.NIL:
			var attack = DecideNextAttack();
			call(attack);
			
func walkLoop() -> void:
	if Animator.current_animation != &"Walk" and velocity != Vector2(0,0):
		Animator.play(&"Walk");
	velocity.x = CurrentSpeed * -direction;
		
func Halt() -> void:
	velocity.x = 0;

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
		var random = randi_range(0,3);
		if random == LastUsedAttack as int:
			print("SAME!");
			continue
		else:
			var attackName = attacks.find_key(random).capitalize();
			print("decided for " + attackName);
			return attackName;
	return &"";
	
func bundleChecks(area : Area2D) -> Variant:
	var results = [];
	# Check 3 times if there is anything intersecting, and append to an array
	for i in range(3):
		await get_tree().physics_frame;
		var areas = area.get_overlapping_areas();
		for v in areas:
			if v == area or area.is_ancestor_of(self):
				continue
			elif results.has(v):
				continue
			else:
				results.append(v)
	return results;
	
func checkIfPlayerHit(hitbox : Area2D) -> bool:
	var objects = await bundleChecks(hitbox);
	if objects.has(PlayerHitbox):
		return true
	return false

# Summoning attack. Enemy is buffed.
#TODO: fade it in
func Summoning() -> void:
	print("executing summon");
	CurrentAttack = attacks.SUMMONING;
	Animator.stop();
	Halt();
	caninitiate = false;
	CD.start(TimeBetweenAttacks);
	MarkerReached.connect(func(anim_name):
		if anim_name == &"SUMMONING":
			var newMummy = Global.Create(mummyScene);
			newMummy.CurrentSpeed = 20;
			newMummy.DrawRaycasts = false;
			newMummy.IgnorePlayer = false;
			newMummy.gravityprone = true;
			newMummy.gravity = 300;
			newMummy.CurrentState = mummyScript.state.WANDER;
			newMummy.direction = direction;
			newMummy.punchCD = 5;
			newMummy.onpunchCD = false;
			newMummy.punching = false;
			newMummy.global_position = self.global_position; # hack, fix later
			scene.add_child(newMummy);
	, CONNECT_ONE_SHOT)
	Animator.play(&"Summoning");
	
func stompLambda(anim_name : StringName) -> void:
	if anim_name == &"Stomp":
		for i in [-1, 1]:
			print(i);
			var vec;
			var new = Global.Create(ShockwaveScene);
			new.direct = i;
			new.moving = true;
			new.speed = 150;			
			match i:
				-1:
					vec = Vector2(-5, 0);
				1:
					vec = Vector2(5, 0);
			new.global_position = self.global_position + vec;
			scene.add_child(new);
			
# Stomping attack.
func Stomp() -> void:
	CurrentAttack = attacks.STOMP;
	MarkerReached.connect(stompLambda);
	Animator.stop();
	Halt();
	caninitiate = false;
	CD.start(TimeBetweenAttacks);
	Animator.play(&"Stomp");
	

func Overhead() -> void:
	var pos = self.global_position + Vector2(25 * direction, -3.5);
	CurrentAttack = attacks.OVERHEAD;
	MarkerReached.connect(func(anim_name):
		pass
	, CONNECT_ONE_SHOT)
	Animator.stop();
	Halt();
	caninitiate = false;
	CD.start(TimeBetweenAttacks);
	Animator.play(&"Overhead");
	await Global.wait(1.0);
	var newBox = Global.MakeHitbox(1, 40.0, 30.0, pos);
	scene.add_child(newBox);
	#var visualizer = Global.visualizeArea(newBox);
	#scene.add_child(visualizer);
	if await checkIfPlayerHit(newBox) == true:
		Player.takeDamage(2, 1.0, true);
		Player.applyKnockback(Vector2.ONE, 800.0 * direction);
	newBox.queue_free();
	
# Ranged attack.
func Staff() -> void:
	CurrentAttack = attacks.STAFF;
	MarkerReached.connect(func(anim_name):
		if anim_name == &"Staff":
			var newBlast = Global.Create(BlastScene);
			newBlast.moving = true;
			newBlast.direct = direction;
			newBlast.speed = 200;
			newBlast.global_position = self.global_position;
			scene.add_child(newBlast);
	, CONNECT_ONE_SHOT);
	Animator.stop();
	Halt();
	caninitiate = false;
	CD.start(TimeBetweenAttacks);
	Animator.play(&"Staff");
	

# For when HP hits 0.
func Die() -> void:
	HPBar.visible = false;
	await Global.wait(0.3);
	var curr = Model.modulate;
	var tweener = create_tween().tween_property(Model, "modulate", Color(curr.r, curr.g, curr.b, 0), 0.2).set_ease(Tween.EASE_IN);
	tweener.finished.connect(func():
		queue_free();	
	)
	

	
	
			
					
	
	
