#snake code
extends CharacterBody2D

signal onStateChanged(state);
enum state {WANDER, CHASE, DEAD};
const WanderSpeed : int = 40;
const ChaseSpeed : int = 60;
var isonfloor = true;
var isdying = false;
@export var IgnorePlayer = false;
@export var DrawRaycasts : bool = false;
@export var CurrentSpeed = 40;
@export var gravityprone : bool = true;
@export var gravity : int = 300;
@export var CurrentState : state = state.WANDER;
@export var direction : int = 1; 

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player");
@onready var SightRay : RayCast2D = $SightRay; 
@onready var GroundRay : RayCast2D = $GroundRay;
@onready var Model : Sprite2D = $Model;
@onready var Animator : AnimationPlayer = $Animator;
@onready var HeadArea : Area2D = $HeadArea;
@onready var HitboxArea : Area2D = $HitboxArea;
@onready var snakeHiss : AudioStreamWAV = preload("res://assets/sounds/snake-hiss.wav");
@onready var Mouth : AudioStreamPlayer2D = $Mouth;
# target_position (x,y)/position (x,y) 
const GROUND_RIGHT_FLIP_VEC_POS = [50.0, 22.0, 67.0, 0.0];
const GROUND_LEFT_FLIP_VEC_POS = [-50.0, 22.0, 0.0, 0.0];
const SIGHT_LEFT_FLIP_VEC_POS = [-60.0, 0.0, 0.0, 0.0];
const SIGHT_RIGHT_FLIP_VEC_POS = [60.0, 0.0, 67.0, 0.0];
const KNOCKBACK_VECTOR = Vector2(1.0, 1.0); # Base vector for knockback which is muled by a scalar.


func onPlayerJumpedOn() -> void:
	# Stop the killer first
	CurrentSpeed = 0;
	isdying = true;
	Global.TempFelledEnemies.append(self.name);
	if Animator.is_playing():
		Animator.stop();
		Animator.play(&"Dying");
		
		
func onHeadEntered(area : Area2D) -> void:
	if area.name == &"PlayerStomp":
		onPlayerJumpedOn(); 
		
func onHitboxEntered(body : PhysicsBody2D) -> void:
	if body.name == &"Player":
		if isdying: return;
		if player.iframes == true: return;
		player.takeDamage(1, true, 1.0);
		match self.direction:
			1:
				player.applyKnockback((player.global_position - global_position).normalized() + Vector2(0, -1.5), 500.0);
			-1:
				player.applyKnockback((player.global_position - global_position).normalized() + Vector2(0, -1.5), -500.0);
				
# Signal clbk
func onstateChanged(newstate : state) -> void:
	match newstate:
		state.CHASE:
			Mouth.play()
			self.CurrentSpeed = ChaseSpeed;
		state.WANDER:
			self.CurrentSpeed = WanderSpeed;
		state.DEAD:
			player.addScore(10);
			self.queue_free();
			
# Changes the state of the snake and returns the old state.
func changeState(newstate) -> state:
	var oldState = CurrentState;
	self.CurrentState = newstate;
	onStateChanged.emit(newstate);
	return oldState;
	
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

func isClosetoWall() -> bool:
	var collider = SightRay.get_collider();
	if collider:
		var pos = SightRay.get_collision_point();
		var distance = abs(self.global_position.x - pos.x) - 40;
		if distance < 30 and collider.is_class(&"TileMapLayer") or collider.is_class(&"StaticBody2D") or (collider.is_class(&"CharacterBody2D") and collider != player):
			return true
		return false
	else:
		return false
			
func drawRays() -> void:
	Global.visualizeRays(self, SightRay, GroundRay);
	
func chase() -> void:
	if isClosetoWall():
		flip();
		changeState(state.WANDER);
	velocity.x = CurrentSpeed * -direction;

# Use StringName for performance reasonsa
func wander() -> void:
	if Animator.current_animation != &"Crawling" and isdying == false:
		Animator.play(&"Crawling");
	elif isdying == true:
		Animator.play(&"Dying");
	var CloseToWall = isClosetoWall();
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
	elif isClosetoWall():
		flip();
	else:
		pass
	velocity.x = CurrentSpeed * -direction;
	
# Flips the model and direction of the snake.
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

# Casts the ray to look for the player
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

func _ready() -> void:
	SightRay.collision_mask = 1;
	CurrentSpeed = 40; # Var keeps nulling for some reason.
	HeadArea.area_entered.connect(onHeadEntered);
	HitboxArea.body_entered.connect(onHitboxEntered);
	Animator.animation_finished.connect(func(anim_name):
		if anim_name == &"Dying":
			print("dying finished");
			onStateChanged.emit(state.DEAD)
	)
	# Wire signal for state machine
	onStateChanged.connect(func(newState): 
		onstateChanged(newState);
	)

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
