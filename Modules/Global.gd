extends Node

# Some stuff for global setup.
@onready var anubisScript = preload("res://Anubis.gd");

# Cache.
var LineCache : Array[Line2D] = [];

# Save Data
var CollectedCoins = []; # Coins which were collected.
var FelledEnemies = []; # Killed enemies which will not respawn. 
var OpenedChests = [] # Opened chests which will spawn open.

var SceneTransitions = {
	&"shn1" : &"shn2",
	&"shn2" : &"shn3",
	&"shn3" : &"shn4"
}

# Works on a NAME basis.
var SaveData = {
	&"HasDoubleJump" : false,
	&"Checkpoint" : &"Checkpoint",
	&"Hearts" : 3,
	&"Coins" : 0,
	&"Score" : 0,
}

var CurrentLevel = &"shn1"

var __TEMP_FADE_IN = false;

signal PlayerCoinsChanged(newCoins);
signal PlayerHealthChanged(newHealth);

static func concatPrint(... args : Array):
	var message: String = ", ".join(args.map(str));
	print(message);

func delay(seconds : float, function : Callable) -> Variant:
	await get_tree().create_timer(seconds).timeout;
	var ret = function.call();
	return ret;
	
func wait(time : float) -> void:
	await get_tree().create_timer(time).timeout
	return
	
func BlurImage(spr2d : Sprite2D) -> Sprite2D:
	var newimgblurred : Image = Image.new();
	var img = spr2d.texture.get_image();
	newimgblurred.copy_from(img);
	newimgblurred.resize(64,36, Image.INTERPOLATE_TRILINEAR);
	var text = ImageTexture.create_from_image(newimgblurred);
	var newsprite = Sprite2D.new();
	newsprite.texture = text;
	return newsprite
	
func visualizeRays(caller : Node, ... rays: Array) -> void:
	for line in LineCache:
		if is_instance_valid(line):
			line.queue_free();
	LineCache.clear();
	for ray in rays:
		if ray.get_class() == "RayCast2D":
			var newline = Line2D.new();
			# print("ray position " + str(ray.position));
			# aprint("ray target pos " + str(ray.target_position));
			newline.add_point(ray.position);
			newline.add_point(ray.target_position); 
			newline.width = 2;
			newline.default_color = Color(0.0, 0.0, 255.0); 
			caller.add_child(newline);
			LineCache.append(newline);
		else: 
			push_error("Arguments given were not raycasts.");
			
# Returns the type of the variable "variable" as a human readable string. 
func TypeString(variable : Variant) -> Variant:
	var string = type_string(typeof(variable));
	if string != null:
		return string
	else:
		return null

# TODO
func MakeHitbox(x : float, y : float, pos : Vector2 = Vector2(0,0)) -> Area2D:
	var newBox = Area2D.new();
	var newCollisionShape = CollisionShape2D.new();
	var rect = RectangleShape2D.new();
	rect.size = Vector2(x, y);
	newBox.add_child(newCollisionShape);
	newCollisionShape.shape = rect;
	if pos:
		newBox.global_position = pos;
	return newBox

## This function will only work if the given Area2D has a CollisionShape2D child that posseses a .get_rect() method.
func visualizeArea(Area : Area2D, color : Color = Color(1.0,0.0,0.3)) -> ColorRect:
	var visualizer = ColorRect.new();
	if not Area.get_child(0):
		print("what the hell we're missing box");
		return 
	var collision = Area.get_child(0) as CollisionShape2D;
	var ColRect = collision.shape.get_rect();
	
	visualizer.color = color; 
	visualizer.position = ColRect.position;
	visualizer.size = ColRect.size;
	Area.add_child(visualizer);
			
	return visualizer
	
func _GBOSSFIGHTVARS(boss : Node) -> void:
	boss.Health = 250;
	boss.IgnorePlayer = false;
	boss.CurrentSpeed = 20;
	boss.gravityprone = true;
	boss.gravity = 300;
	boss.CurrentState = anubisScript.state.FIGHT;
	boss.CurrentAttack = anubisScript.attacks.NIL;
	boss.LastUsedAttack = anubisScript.attacks.NIL;
	boss.direction = -1;
	
func GetCurrentScene() -> String:
	var scenename = get_tree().current_scene.scene_file_path.get_basename().substr(6);
	return scenename

func GetSceneFromString(string : String) -> PackedScene:
	var scene = load("res://" + string + ".tscn") as PackedScene; 
	return scene
