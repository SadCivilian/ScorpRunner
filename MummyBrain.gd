# Can you tell I'm wholeheartedly against OOP in this shit language?
# Does NOT IGNORE cliffs when chasing player, will instead drop chase and go back to "wander".
# The signal for when the hitbox of the enemy is entered will check if the enemy is punching, which will increase the knockback scalar and do TWO damage.
extends CharacterBody2D

signal onStateChanged(state);
enum state {WANDER, CHARGING, DEAD, CHASE};
const WanderSpeed : int = 20;
const ChaseSpeed : int = 50;
const PunchVelocity = 100;
var isonfloor = true;
var isdying = false;
var RNG : RandomNumberGenerator = RandomNumberGenerator.new();
@export var IgnorePlayer : bool = false;
@export var DrawRaycasts : bool = false;
@export var CurrentSpeed : int = 20;
@export var gravityprone : bool = true; 
@export var gravity : int = 300;
@export var CurrentState : state = state.WANDER;
@export var direction : int = 1; 
@export var punchCD : int = 20; # SECONDS, obviously  
@export var onpunchCD : bool = false; 
@export var punching : bool = false;

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player");
@onready var SightRay : RayCast2D = $SightRay; 
@onready var GroundRay : RayCast2D = $GroundRay;
@onready var Model : Sprite2D = $Model;
@onready var Animator : AnimationPlayer = $Animator;
@onready var BackArea : Area2D = $BackArea;
@onready var HitboxArea : Area2D = $HitboxArea;
@onready var snakeHiss : AudioStreamWAV = preload("res://assets/sounds/snake-hiss.wav");
@onready var Mouth : AudioStreamPlayer2D = $Mouth;
@onready var CD : Timer = $CD;

# target_position (x,y)/position (x,y) 
# BELOW ARE HEAVY PLACEHOLDERS AS THE MODEL IS NOT DONE YET!!!!!!!!
const GROUND_RIGHT_FLIP_VEC_POS = [30.0, 22.0, 67.0, 0.0];
const GROUND_LEFT_FLIP_VEC_POS = [-30.0, 22.0, 0.0, 0.0];
const SIGHT_LEFT_FLIP_VEC_POS = [-60.0, 0.0, 0.0, 0.0];
const SIGHT_RIGHT_FLIP_VEC_POS = [60.0, 0.0, 67.0, 0.0];
const KNOCKBACK_VECTOR = Vector2(1.0, 1.0); # Base vector for knockback which is muled by a scalar.

func _ready() -> void:
	DrawRaycasts = true;
	SightRay.collision_mask = 1;
	CurrentSpeed = 20; # Var keeps nulling for some reason.
	BackArea.area_entered.connect(onBackStabbedorEntered);
	HitboxArea.body_entered.connect(onHitboxEntered);
	Animator.animation_finished.connect(func(anim_name):
		if anim_name == &"Dying":
			Global.FelledEnemies.append(self.name);
			print("dying finished");
			onStateChanged.emit(state.DEAD)
		elif anim_name == &"Punching":
			punching = false;
			# After punching the mummy goes into wander? I probably will want to change this later.
			changeState(state.WANDER);
	)
	onStateChanged.connect(func(newstate : state):
		onstateChanged(newstate);
	)
	CD.timeout.connect(func():
		onpunchCD = false;	
	)
	
# Returns previous state as usual.
func onstateChanged(newstate : state) -> void:
	match newstate:
		state.CHASE:
			Mouth.play();
			CurrentSpeed = ChaseSpeed;
		state.WANDER:
			CurrentSpeed = WanderSpeed;
		state.CHARGING:
			punching = true;
			onpunchCD = true;
			CD.start(punchCD);
		state.DEAD:
			print("freeing object")
			queue_free();
			
# Changes the state to some state "newstate", returns the old state.
func changeState(newstate : state) -> state:
	var oldstate = self.CurrentState
	self.CurrentState = newstate
	onStateChanged.emit(newstate);
	return oldstate
				
func lookforPlayer() -> bool:
	var collider = SightRay.get_collider();
	if collider and collider.name == "Player":
		return true
	else:
		return false

func lookforCliff() -> bool:
	var collider = GroundRay.get_collider();
	if not collider:
		return true
	else:
		return false

func onBackStabbedorEntered(area : Area2D) -> void:
	if area.name == &"Stinger":
		if Animator.is_playing():
			Animator.stop();
			Animator.play(&"Dying");
			
# This is where the match case for when the enemy is punching is initiated.
func onHitboxEntered(body : PhysicsBody2D) -> void:
	if body.name == "Player":
		match punching:
			true:
				player.takeDamage(2, true, 2.0);
				player.applyKnockback(KNOCKBACK_VECTOR, 800.0);
			false:
				player.takeDamage(1, true, 1.0);
				player.applyKnockback(KNOCKBACK_VECTOR, 300.0);

func loseChase() -> void:
	print("well it seems the player got away somehow");
	flip();
	changeState(state.WANDER);

func drawRays() -> void:
	Global.visualizeRays(self, SightRay, GroundRay);

func flipRays(lr : int) -> void:
	match lr:
		1:
			var comp1 = SIGHT_LEFT_FLIP_VEC_POS[0]; 
			var comp2 = SIGHT_LEFT_FLIP_VEC_POS[1]; 
			var comp3 = SIGHT_LEFT_FLIP_VEC_POS[2]; 
			var comp4 = SIGHT_LEFT_FLIP_VEC_POS[3]; 
			var comp5 = GROUND_LEFT_FLIP_VEC_POS[0];
			var comp6 = GROUND_LEFT_FLIP_VEC_POS[1];
			var comp7 = GROUND_LEFT_FLIP_VEC_POS[2];
			var comp8 = GROUND_LEFT_FLIP_VEC_POS[3];
			SightRay.target_position = Vector2(comp1, comp2);
			SightRay.position = Vector2(comp3, comp4);
			GroundRay.target_position = Vector2(comp5, comp6);
			GroundRay.position = Vector2(comp7, comp8);
		-1:
			var comp1 = SIGHT_RIGHT_FLIP_VEC_POS[0]; 
			var comp2 = SIGHT_RIGHT_FLIP_VEC_POS[1]; 
			var comp3 = SIGHT_RIGHT_FLIP_VEC_POS[2]; 
			var comp4 = SIGHT_RIGHT_FLIP_VEC_POS[3]; 
			var comp5 = GROUND_RIGHT_FLIP_VEC_POS[0];
			var comp6 = GROUND_RIGHT_FLIP_VEC_POS[1];
			var comp7 = GROUND_RIGHT_FLIP_VEC_POS[2];
			var comp8 = GROUND_RIGHT_FLIP_VEC_POS[3];
			SightRay.target_position = Vector2(comp1, comp2);
			SightRay.position = Vector2(comp3, comp4);
			GroundRay.target_position = Vector2(comp5, comp6);
			GroundRay.position = Vector2(comp7, comp8);

func flip() -> void:
	if isonfloor != false:
		Model.flip_h = not Model.flip_h;
		match direction:
			1:
				flipRays(-1);
				direction = -1;
			-1:
				flipRays(1);
				direction = 1;
			
# Fuck em up good would ya
func punch() -> void:
	# Stop all velocity first
	velocity = Vector2(0.0, 0.0);
	changeState(state.CHARGING);
	if Animator.is_playing():
		Animator.stop();
		Animator.play(&"Punching"); 
		get_tree().physics_frame.connect(func():
			velocity = Vector2(PunchVelocity * direction, 0)
		)
		# TODO: ANIMATION event
	
	
func chase() -> void:
	# Every frame while chasing, decide to do punch by rolling a 10% chance.
	if RNG.randi_range(1,10) == 1 and onpunchCD == false:
		punch();
	var SeesCliff = lookforCliff();
	# Drop the chase if we see a cliff.
	if SeesCliff:
		loseChase();
	velocity.x = direction * CurrentSpeed;

 # Use StringName for performance reasonsa
func wander() -> void:
	if Animator.current_animation != &"Walking" and isdying == false:
		Animator.play(&"Walking");
	elif isdying == true:
		Animator.play(&"Dying");
	var SeesPlayer = lookforPlayer(); 
	var SeesCliffOnWander = lookforCliff();
	# Ignore player, the cliff is lowkey more important anyway
	if SeesPlayer == true and SeesCliffOnWander == true:
		flip();
	elif SeesPlayer == true and SeesCliffOnWander == false:
		if CurrentState != state.CHASE and IgnorePlayer == false: 
			changeState(state.CHASE);
	elif SeesPlayer == false and SeesCliffOnWander == true:
		flip();
	else:
		pass
	velocity.x = CurrentSpeed * -direction;

func _physics_process(delta: float) -> void:
	if DrawRaycasts == true and is_instance_valid(self):
		drawRays();
	isonfloor = self.is_on_floor();
	if self.CurrentState == state.WANDER:
		wander();
	elif self.CurrentState == state.CHASE:
		chase();
	
	if not is_on_floor():
		velocity.y += gravity * delta;
	move_and_slide();
