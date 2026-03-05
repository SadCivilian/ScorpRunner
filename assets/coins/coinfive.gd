#Duplicated version of coin.gd , changed for x5 money
extends Area2D
@export var value : int = 5;

signal collected(value : int);
#onreadiess
@onready var BaseSprite : Sprite2D = $Model;
@onready var Area : Area2D = $".";
@onready var Animator : AnimationPlayer = $Animator;
@onready var SoundPlayer : AudioStreamPlayer2D = $SoundPlayer;
@onready var ParticleEmitter : GPUParticles2D = $ParticleEmitter;
@onready var Player : CharacterBody2D = get_tree().get_first_node_in_group("Player");
var collecting = false;

func _ready() -> void:
	SoundPlayer.finished.connect(func():
		if ParticleEmitter.emitting == false:
			queue_free();	
	)
	Animator.play(&"Spin");
	Area.area_entered.connect(func(who):
		collect(who);
	);
#getting the coinns
func collect(who : Area2D) -> void:
	if collecting == false and Global.isPlayerArea(who):
		collecting = true;
		BaseSprite.visible = false;
		SoundPlayer.play();
		collected.emit(self.value);
		Player.addCoins(self.value);
		ParticleEmitter.emitting = true;
		Global.TempCollectedCoins.append(self.name);


	
	
