# Can you tell I'm wholeheartedly against OOP in this shit language?
# Does NOT IGNORE cliffs when chasing player, will instead drop chase and go back to "wander".
# The signal for when the hitbox of the enemy is entered will check if the enemy is punching, which will increase the knockback scalar and do TWO damage.
extends CharacterBody2D

const AnimEvents : Array[StringName] = [&"Punching"];
signal MarkerReached(anim_name : StringName);

func onMarkerReached(anim_name : StringName) -> void:
	if AnimEvents.has(anim_name):
		MarkerReached.emit(anim_name);  

signal onStateChanged(state);
signal killed();

enum state {WANDER, CHARGING, DEAD, CHASE};
const WanderSpeed : int = 20;
const ChaseSpeed : int = 30;
const PunchVelocity = 200;
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
@export var punchCD : int = 10; # SECONDS, obviously  
@export var onpunchCD : bool = false; 
@export var punching : bool = false;
@export var Health : int = 80;
@export var Spawned : bool = false; # Controls if the enemy is spawned, so it won't be added to the felled list
@onready var HPBar : ProgressBar = $Model/ProgressBar;
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player");
@onready var SightRay : RayCast2D = $SightRay; 
@onready var GroundRay : RayCast2D = $GroundRay;
@onready var Model : Sprite2D = $Model;
@onready var Animator : AnimationPlayer = $Animator;
@onready var HitboxArea : Area2D = $HitboxArea;
@onready var snakeHiss : AudioStreamWAV = preload("res://assets/sounds/snake-hiss.wav");
@onready var CD : Timer = $CD;

# target_position (x,y)/position (x,y)
const GROUND_RIGHT_FLIP_VEC_POS = [30.0, 22.0, 0.0, 0.0];
const GROUND_LEFT_FLIP_VEC_POS = [-30.0, 22.0, -5.0, 0.0];
const SIGHT_LEFT_FLIP_VEC_POS = [-60.0, 0.0, -5.0, 0.0];
const SIGHT_RIGHT_FLIP_VEC_POS = [60.0, 0.0, 0.0, 0.0];

func _ready() -> void:
	SightRay.collision_mask = 1;
	HitboxArea.area_entered.connect(onHitboxEntered);
	Animator.animation_finished.connect(func(anim_name):
		if anim_name == &"Dying" and Spawned == false:
			Global.FelledEnemies.append(self.name);
			changeState(state.DEAD);
		elif anim_name == &"Punching":
			await Global.wait(0.2);
			punching = false;
	)
	onStateChanged.connect(func(newstate : state):
		onstateChanged(newstate);
	)
	CD.timeout.connect(func():
		print("off cd");
		onpunchCD = false;	
	)
	
# Returns previous state as usual.
func onstateChanged(newstate : state) -> void:
	match newstate:
		state.CHASE:
			CurrentSpeed = ChaseSpeed;
		state.WANDER:
			CurrentSpeed = WanderSpeed;
		state.CHARGING:
			punching = true;
			onpunchCD = true;
			CD.start(punchCD);
		state.DEAD:
			killed.emit();
			player.addScore(25);
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
		
func isClosetoWall() -> bool:
	var collider = SightRay.get_collider();
	if collider:
		var pos = SightRay.get_collision_point();
		if abs(self.global_position.x - pos.x) < 20 and (collider.is_class(&"TileMapLayer") or (collider.is_class(&"CharacterBody2D") and collider != player) or collider.is_class(&"StaticBody2D")):
			return true
		return false
	else:
		return false

func lookforCliff() -> bool:
	var collider = GroundRay.get_collider();
	if not collider:
		return true
	else:
		return false
		
func isPlayerBehind() -> bool:
	return player.facing == direction;
			
# This is where the match case for when the enemy is punching is initiated.
func onHitboxEntered(area : Area2D) -> void:
	if Global.isPlayerArea(area):
		match punching:
			true:
				player.takeDamage(2, true, 2.0);
				player.applyKnockback((player.global_position - global_position).normalized() + Vector2(0, -1.5), 800.0);
			false:
				player.takeDamage(1, true, 1.0);
				player.applyKnockback((player.global_position - global_position).normalized() + Vector2(0, -1.5), 400.0);
	elif area.name == &"Stinger":
		if isPlayerBehind() == true:
			flip();
		takeDamage(player.attackDMG);
				
func updateHealthBar(hp : int) -> void:
	create_tween().tween_property(HPBar, "value", hp, 0.2).set_ease(Tween.EASE_IN);
	
func takeDamage(amount : int) -> void:
	var new = Health - amount;
	Health = new;
	updateHealthBar(new);
	if new <= 0:
		changeState(state.DEAD);

func loseChase() -> void:
	print("well it seems the player got away somehow");
	flip();
	changeState(state.WANDER);

func drawRays() -> void:
	Global.visualizeRays(self, SightRay, GroundRay);

func flipRays(lr : int) -> void:
	match lr:
		1:
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
		-1:
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

func flip() -> void:
	if isonfloor != false:
		Model.flip_h = not Model.flip_h;
		match direction:
			1:
				HPBar.global_position.x = HPBar.global_position.x - 5
				flipRays(-1);
				direction = -1;
			-1:
				HPBar.global_position.x = HPBar.global_position.x + 5
				flipRays(1);
				direction = 1;
				
func punchLambda() -> void:
	velocity = Vector2(PunchVelocity * direction, 0);

func punch() -> void:
	if punching: return;
	
	# Stop all velocity first
	velocity = Vector2(0.0, 0.0);
	changeState(state.CHARGING);
	
	if Animator.is_playing():
		Animator.stop();
		Animator.play(&"Punching"); 
		MarkerReached.connect(func(anim_name):
			if anim_name == &"Punching":
				get_tree().physics_frame.connect(punchLambda);
				await Global.wait(1);
				get_tree().physics_frame.disconnect(punchLambda);	
				var sees = lookforPlayer();
				if sees:
					changeState(state.CHASE);
				else:
					changeState(state.WANDER);
		)
		
func chase() -> void:
	# Every frame while chasing, decide to do punch by rolling a 1% chance.
	# Keep in mind the punch can still ricochet the guy off the cliff.
	var rand = RNG.randi_range(1,100);
	if rand == 1 and onpunchCD == false and lookforPlayer() != null: # the last check is to make sure we're atleast in raycast range to avoid incidens where we punch air.
		punch();
	var SeesCliff = lookforCliff();
	var CloseToWall = isClosetoWall();
	# Drop the chase if we see a cliff.
	if SeesCliff:
		loseChase();
	elif CloseToWall:
		loseChase();
	velocity.x = direction * CurrentSpeed;

 # Use StringName for performance reasons
func wander() -> void:
	if Animator.current_animation != &"Walking" and isdying == false:
		Animator.play(&"Walking");
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
	elif CloseToWall == true:
		flip();
	else:
		pass
	velocity.x = CurrentSpeed * direction;

func validateDirection() -> void:
	match direction:
		-1:
			flipRays(-1)
		1:
			flipRays(1)

func _physics_process(delta: float) -> void:
	validateDirection();
	if DrawRaycasts == true and is_instance_valid(self):
		drawRays();
	isonfloor = self.is_on_floor();
	if punching: return;
	if self.CurrentState == state.WANDER:
		wander();
	elif self.CurrentState == state.CHASE:
		chase();
	
	if not isonfloor:
		velocity.y += gravity * delta;
		
	move_and_slide();
