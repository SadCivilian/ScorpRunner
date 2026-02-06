class_name Coin
extends Area2D

@export var value : int = 1;

signal collected(value : int);

@onready var BaseSprite : Sprite2D = $Sprite;
@onready var Area : Area2D = $".";
@onready var Animator : AnimationPlayer = $Animator;
@onready var SoundPlayer : AudioStreamPlayer2D = $SoundPlayer;
@onready var Player : CharacterBody2D = get_tree().get_first_node_in_group("Player");

func _ready() -> void:
	Animator.play(&"Spin");
	Area.area_entered.connect(func(who):
		collect(who);
	);
	
func collect(who : Area2D) -> void:
	if who.name == "Hitbox" and who.parent.is_in_group(&"Player"):
		SoundPlayer.play();
		collected.emit(self.value);
		Player.addCoins(self.value);
		queue_free();


	
	
