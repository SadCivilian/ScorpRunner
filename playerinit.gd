extends CharacterBody2D

const attackCD : int = 2;
@export var canAttack : bool = true;
@export var isAttacking : bool = false;
@export var speed : int = 85;
@export var gravity : int = 300;
@export var jumpforce : int = 200;
@export var hasDoubleJump : bool = false;
@export var Health : int = 3;
@export var Coins : int = 0;
@export var gravityprone = true; # controls gravity
@export var iframes = false; # controls if char has iframes
@onready var sprite = $Model;
@onready var HurtBox = $Model/HurtArea/Hurtbox;
@onready var HurtArea = $Model/HurtArea;
@onready var Cam : Camera2D = $"../Camera2D";
@onready var DeathZone : Area2D = $"../DeathZone";
@onready var Animator : AnimationPlayer = $Animator;
@onready var tilemap : TileMapLayer = $"../MainLayer";
@onready var CD : Timer = $CD;
var TimesJumped : int = 0;
var onfloor : bool;
var jumpedfromvalid : bool = false; # if the player jumped from a surface (aka they can bypass the check to see if they're on a surface to double jump)
var beingKnockedBack : bool = false;
var currentKnockbackForce : Vector2 = Vector2.ZERO;


func connectListeners() -> void:
	DeathZone.area_entered.connect(area_entered_clbk);
	Animator.animation_finished.connect(func(anim_name):
		if anim_name == &"Stinger":
			onAttackFinished();
	)
	CD.timeout.connect(onAttackCooldownFinished);
	
func GameOver() -> void:
	print("Game Over");	
	get_tree().reload_current_scene();
	
func area_entered_clbk(area : Area2D) -> void:
	if area.name == "HurtArea":
		GameOver();
		
func onAttackFinished() -> void:
	isAttacking = false;
		
func onAttackCooldownFinished() -> void:
	canAttack = true;
	
func _ready() -> void:
	add_to_group("Player");
	connectListeners();	
	print("Connected signals");
	# FadeTransition.transition(FadeTransition.TransitionType.OTHER);
	
	# Cam.setSteppedclbk(func(): print("this is from the clbk"));
	# await get_tree().create_timer(2.0).timeout;
	# Cam.clearSteppedclbk();
	# print("cleared clbk now!");

# Gives character iframes.
func enableIFrames(timeout : float = 2.0) -> void:
	self.iframes = true;
	if is_inside_tree():
		get_tree().create_timer(timeout).timeout.connect(func(): self.iframes = false);

# Used for attacking enemies and also "interacting". Returns whatever Area2D's intersect the created Area2D.
func attack() -> Array[Area2D]:
	var IntersectArray : Array[Area2D] = [];
	var currentPos : Vector2 = sprite.position;
	var areaPos : Vector2 = Vector2(currentPos.x + 40.0, currentPos.y);
	print("ran");
	Animator.stop();
	# Animator.play(&"Stinger");
	isAttacking = true;
	CD.start(attackCD);
	var hitArea = Area2D.new();
	var hitShape = CollisionShape2D.new();
	hitShape.shape = RectangleShape2D.new();
	hitShape.debug_color = Color(255,255,255, 1);
	hitArea.add_child(hitShape);
	hitArea.name = "Stinger";
	hitArea.position = areaPos;
	self.get_tree().current_scene.add_child(hitArea);
	IntersectArray = hitArea.get_overlapping_areas();
		
		# We have to triangulate the position here and spawn an Area2D.
	return IntersectArray

func _input(keyevent : InputEvent) -> void:
	if Input.is_action_just_pressed(&"Attack"):
		attack();
	# This is for debugging purposes, delete it later
	if keyevent.as_text() == "P":
		get_tree().reload_current_scene();
	elif keyevent.as_text() == "V":
		attack();
		
	
func takeDamage(amount : int, triggeriframes : bool = true, iframetime : float = 1.0) -> void:
	if iframes == false:
		self.Health -= amount;
		Global.emit_signal(&"PlayerHealthChanged");	
		if self.Health <= 0:
			GameOver();
		if triggeriframes == true and (self.Health - 1) != 0:
			enableIFrames(iframetime);

func addCoins(amount : int) -> void:
	if self.Coins >= 999:
		return 
	self.Coins += amount;
	Global.emit_signal(&"PlayerCoinsChanged");		
	
func applyKnockback(direction : Vector2, strength : float) -> void:
	beingKnockedBack = true; 
	currentKnockbackForce = direction * strength;
	print("Applying knockback to character");
	
# Handles all jump states
func processJump() -> void:
	if Input.is_action_just_pressed("jump"):
		if onfloor == false:
			if hasDoubleJump == true and TimesJumped == 0:
				velocity.y = -jumpforce;
				TimesJumped += 1;
			elif jumpedfromvalid == true:
				velocity.y = -jumpforce;
				TimesJumped += 1;
				jumpedfromvalid = false;
		else:
			if hasDoubleJump == false and TimesJumped == 0:
				velocity.y = -jumpforce;
				TimesJumped += 1;
			elif hasDoubleJump == true and TimesJumped < 2:
				velocity.y = -jumpforce
				TimesJumped += 1;
				jumpedfromvalid = true;
				
# This shit probably doesn't work. Doesn't bother me though I think I'm fucked either way.
func checktransitionTile() -> void:
	var tile_pos = tilemap.local_to_map(global_position)
	var tile_data = tilemap.get_cell_tile_data(tile_pos) as TileData; 
	if tile_data:
		var transition_target = tile_data.get_custom_data("transition_target") as String;
		var tile_id = tilemap.get_cell_source_id(tile_pos)
		if tile_id != -1 and tile_id == 1 and transition_target:
			var CurrentScene = Global.GetCurrentScene();
			var NextScene = Global.SceneTransitions[CurrentScene] as StringName;
			var Scene = Global.GetSceneFromString(NextScene);
			print("standing on transition tile and transitioning");	
			FadeTransition.transition(FadeTransition.TransitionType.ROOM_TRANSITION, Scene);
		
# Use StringName for performance reasons
func _physics_process(delta: float) -> void: 
	if velocity != Vector2(0.0,0.0) and Animator.current_animation != &"Walk":
		Animator.play(&"Walk");	
	elif (velocity == Vector2(0.0,0.0) and Animator.current_animation == &"Walk") or is_on_floor() == false:
		Animator.stop();	
	if self.gravityprone == true:
		if not is_on_floor():
			onfloor = false;
			velocity += Vector2(0.0, gravity * delta); 
		else:
			onfloor = true;
			TimesJumped = 0;
	else:
		velocity.y = 0;
	
	# Handle jump.
	processJump();
	
	if beingKnockedBack:
		velocity += currentKnockbackForce * delta;
		currentKnockbackForce = currentKnockbackForce.lerp(Vector2.ZERO, 5.0 * delta);
		
		# Stop knockback when weak enough, the vector will decay over time
		if currentKnockbackForce.length() < 10.0:
			beingKnockedBack = false;
			currentKnockbackForce = Vector2.ZERO;
	else:	
		var direction := Input.get_axis("move_left", "move_right");
		if direction:
			match direction:
				-1.0:
					sprite.flip_h = false;
				1.0:
					sprite.flip_h = true;
					
			velocity.x = direction * speed;
		else:
			velocity.x = move_toward(velocity.x, 0, speed);
			
	move_and_slide();
	checktransitionTile();
	
