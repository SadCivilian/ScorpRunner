#player code
extends CharacterBody2D
#setup (33 lines lol)
@export var attackCD : float = 1;
@export var attackDMG : int = 20;
@export var canAttack : bool = true;
@export var isAttacking : bool = false;
@export var speed : int = 95; 
@export var gravity : int = 300;
@export var jumpforce : int = 200;
@export var hasDoubleJump : bool = false; 
@export var Health : int = 3;
@export var Coins : int = 0;
@export var Score : int = 0;
@export var gravityprone = true; # controls gravity
@export var iframes = false; # controls if char has iframes
@export var dead = false;
@export var facing : int = 1 # An alternative to direction which is statically changed instead of being reliant on inputs.
@onready var sprite : Sprite2D = $Model;
@onready var HurtBox = $Model/HurtArea/Hurtbox;
@onready var HurtArea = $Model/HurtArea;
@onready var PlayerStomp = $Model/PlayerStomp;
@onready var PlayerCamera = $"../PlayerCamera";
@onready var DeathZone : Area2D = $"../DeathZone";
@onready var Animator : AnimationPlayer = $Animator;
@onready var DamagedAnimator : AnimationPlayer = $DamagedAnimator;
@onready var AttackAnimator : AnimationPlayer = $AttackAnimator;
@onready var tilemap : TileMapLayer = $"../MainLayer";
@onready var CD : Timer = $CD;
@onready var GameOverUIRenderer : CanvasLayer = PlayerCamera.get_child(2);
@onready var Flasher = $Model/Flash;

var TimesJumped : int = 0;
var onfloor : bool;
var jumpedfromvalid : bool = false; # if the player jumped from a surface (aka they can bypass the check to see if they're on a surface to double jump)
var beingKnockedBack : bool = false;
var currentKnockbackForce : Vector2 = Vector2.ZERO;

func connectListeners() -> void:
	DeathZone.area_entered.connect(area_entered_clbk);
	DamagedAnimator.animation_finished.connect(func(anim_name):
		Flasher.visible = false;	
	)
	Animator.animation_finished.connect(func(anim_name):
		if anim_name == &"Stinger":
			onAttackFinished();
	)
	CD.timeout.connect(onAttackCooldownFinished);
	
	
func GameOver() -> void:
	var current_color = sprite.modulate
	create_tween().tween_property(sprite, "modulate:a", 0, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT);
	dead = true;
	GameOverUIRenderer.show();
	
func area_entered_clbk(area : Area2D) -> void:
	if area.name == "HurtArea":
		GameOver();
		
func onAttackFinished() -> void:
	isAttacking = false;
		
func onAttackCooldownFinished() -> void:
	canAttack = true;
	
func _ready() -> void:
	add_to_group(&"Player");
	connectListeners();	
	
	
# Gives character iframes.
func enableIFrames(timeout : float = 2.0) -> void:
	self.iframes = true;
	if is_inside_tree():
		get_tree().create_timer(timeout).timeout.connect(func(): self.iframes = false);
		
func bundleChecks(area : Area2D) -> Variant:
	var results = [];
	# Check 10 times if there is anything intersecting, and append to an array
	for i in range(10):
		await get_tree().physics_frame;
		# Triangulate position first:
		var currentPos = self.global_position;
		match facing:
			1:
				area.global_position = Vector2(currentPos.x + 30.0, currentPos.y + 2.5);	
			-1:
				area.global_position = Vector2(currentPos.x - 25.0, currentPos.y + 2.5);
		var areas = area.get_overlapping_areas();
		for v in areas:
			if v == area or area.is_ancestor_of(self):
				continue
			elif results.has(v):
				continue
			else:
				results.append(v)
					
	return results;

# Used for attacking enemies and also "interacting". Returns whatever Area2D's intersect the created Area2D.
func attack() -> Variant:
	if dead: return;
	if isAttacking == false and canAttack == true:
		var IntersectArray = [];
		var currentPos : Vector2 = self.global_position;
		var areaPos : Vector2 = Vector2.ZERO;
		match facing: 
			1:
				areaPos = Vector2(currentPos.x + 30.0, currentPos.y + 2.5);	
			-1:
				areaPos = Vector2(currentPos.x - 30.0, currentPos.y + 2.5);
		isAttacking = true;
		canAttack = false;
		CD.start(attackCD);
		
		var hitArea = Area2D.new();
		var hitShape = CollisionShape2D.new();
		var rect = RectangleShape2D.new();
		rect.size = Vector2(45, 20);
		
		hitArea.add_child(hitShape);
		hitArea.name = &"Stinger";
		hitArea.global_position = areaPos;
		hitArea.collision_layer = 1;
		hitArea.collision_mask = 1;
		hitArea.monitoring = true;
		hitArea.priority = 1e4;
		hitShape.shape = rect
		self.get_tree().current_scene.add_child(hitArea);
		await get_tree().physics_frame;
		IntersectArray = await bundleChecks(hitArea);
		hitArea.queue_free(); 
		onAttackFinished();
		
		return IntersectArray
	return []

func _input(keyevent : InputEvent) -> void:
	if Input.is_action_just_pressed(&"Attack"):
		attack();	
	
func takeDamage(amount : int, triggeriframes : bool = true, iframetime : float = 1.0) -> void:
	if iframes == false or amount < 0:
		self.Health -= amount;
		if triggeriframes == true:
			Flasher.visible = true
			DamagedAnimator.play(&"Damaged");
		Global.emit_signal(&"PlayerHealthChanged");	
		if self.Health <= 0:
			GameOver();
		if triggeriframes == true:
			enableIFrames(iframetime);

func addCoins(amount : int) -> void:
	if self.Coins >= 999:
		return 
	self.Coins += amount;
	self.Score += amount;
	Global.emit_signal(&"PlayerCoinsChanged");		
	
func addScore(amount : int) -> void:
	self.Score += amount;
	
# Uses an amount of counts and returns a boolean on whether it was successful.
func useCoins(amount : int) -> bool:
	if self.Coins - amount < 0:
		return false
	else:
		self.Coins = self.Coins - amount;
		Global.emit_signal(&"PlayerCoinsChanged");
		return true

func getUserData() -> Dictionary:
	return Global.SaveData;
	
func wipeUserData() -> void:
	Global.SaveData[&"Hearts"] = 3;
	Global.SaveData[&"Coins"] = 0;
	Global.SaveData[&"Score"] = 0;
	Global.SaveData[&"HasDoubleJump"] = false;
	
func Disperse() -> void:
	DisperseUsedCheckpoints();
	DisperseCollectedCoins();
	DisperseOpenedChests();
	DisperseKilledEnemies();
	DisperseCollectedHearts();

func DisperseKilledEnemies() -> void:
	var enemiesNode = get_tree().current_scene.find_child(&"Enemies", false);
	for enemyName in Global.FelledEnemies:
		var node = enemiesNode.find_child(enemyName);
		if node:
			node.queue_free();

func DisperseCollectedCoins() -> void:
	var coinsNode = get_tree().current_scene.find_child(&"Coins", false);
	for coinName in Global.CollectedCoins:
		var node = coinsNode.find_child(coinName);
		if node:
			node.queue_free();
		
func DisperseOpenedChests() -> void:
	var openTexture = load("res://assets/sprites/Chest/chestopen.jpeg");
	var chestsNode = get_tree().current_scene.find_child(&"Chests", false);
	for chestName in Global.OpenedChests:
		var node = chestsNode.find_child(chestName);
		if node:
			node.opened = true;
			node.get_child(2).texture = openTexture;

func DisperseCollectedHearts() -> void:
	var heartsNode = get_tree().current_scene.find_child(&"Hearts", false);
	for heartName in Global.TakenHearts:
		var node = heartsNode.find_child(heartName);
		if node:
			node.queue_free();
			
func DisperseUsedCheckpoints() -> void:
	var root = get_tree().current_scene;
	for checkName in Global.UsedCheckpoints:
		var node = root.find_child(checkName);
		if node:
			node.queue_free();
		
func loadPlayerState() -> void:
	var userData = getUserData();
	var SpawnPoint : Area2D = get_tree().current_scene.find_child(userData[&"Checkpoint"]);
	if userData[&"Checkpoint"] == &"Checkpoint" or SpawnPoint == null:
		self.Score = userData[&"Score"];
		self.Coins = userData[&"Coins"];
		self.Health = userData[&"Hearts"];
		self.hasDoubleJump = userData[&"HasDoubleJump"];
		Global.emit_signal(&"PlayerCoinsChanged");
		Global.emit_signal(&"PlayerHealthChanged");
	else:
		# First pos
		self.global_position = SpawnPoint.global_position;
		self.Score = userData[&"Score"];
		self.Coins = userData[&"Coins"];
		self.Health = userData[&"Hearts"];
		self.hasDoubleJump = userData[&"HasDoubleJump"];
		Global.emit_signal(&"PlayerCoinsChanged");
		Global.emit_signal(&"PlayerHealthChanged");
	
func applyKnockback(direction : Vector2, strength : float) -> void:
	if dead: return;
	beingKnockedBack = true; 
	currentKnockbackForce = direction * strength;
	
func update_animations() -> void:
	# Attack anim plays when clicking M1 and blocks ALL other anims until finished
	if isAttacking:
		if Animator.is_playing():
			Animator.stop();
		if AttackAnimator.current_animation != &"Stinger":
			AttackAnimator.play(&"Stinger");
		# Force stop main animator during attack
		return;

	# In air
	if not is_on_floor():
		if velocity.y != 0:
			Animator.play(&"Jump");
	else:
		if Animator.current_animation == &"Jump":
			Animator.play(&"RESET");
		var direction := Input.get_axis("move_left", "move_right");
		if direction != 0:
			Animator.play(&"Walk");  # Always play walk when moving (no check)
		else:
			# No anim -> while no movement on tile 
			if Animator.is_playing() and Animator.current_animation != &"RESET":
				Animator.stop();
	
# Handles all jump states
func processJump() -> void:
	if dead: return;
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
		
# Use StringName for performance reasons
func _physics_process(delta: float) -> void: 
	if dead: return;
	if self.gravityprone == true:
		if not is_on_floor():
			onfloor = false;
			velocity += Vector2(0.0, gravity * delta); 
		else:
			if Animator.current_animation == &"Jump":
				Animator.stop();
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
					facing = -1;
					sprite.flip_h = false;
				1.0:
					facing = 1;
					sprite.flip_h = true;
			velocity.x = direction * speed;
		else:
			velocity.x = move_toward(velocity.x, 0, speed);
			
	move_and_slide();
	update_animations();
	
