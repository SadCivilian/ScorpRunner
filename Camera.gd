extends Camera2D

signal CameraStepped;
signal CutsceneShifted;
@export var CurrentFocus : Node2D;
@export var debugMode : bool = false;
@onready var bg = $"../Background";
var currentClbk : Callable;
var null_voidClbk : Callable = Callable();
var cutsceneActive : bool = false;

func _ready() -> void:
	var blurred = Global.BlurImage(bg);
	# Display(blurred);
	print("Camera initialized"); 
	CurrentFocus = $"../Player";
	CameraStepped.connect(func(): if currentClbk.is_valid(): currentClbk.call());
	setSteppedclbk(func():
		bg.global_position = self.global_position;		
	)
	
	
# Changes the focus of the camera to a new Node2s.
#@NewObj --> Node2D
func changeFocus(NewObj : Node2D) -> void:
	CurrentFocus = NewObj;
	
# Serializes a Vector2 into 2 strings.
#@Vec2 --> Vector2	
func serializeVec2(Vec2 : Vector2) -> String:
	var xcom = Vec2.x;
	var ycom = Vec2.y;
	return str(xcom) + str(ycom);

func stepCam() -> void:
	var CurrentFocusPos = CurrentFocus.position;
	self.position = Vector2(CurrentFocusPos.x, CurrentFocusPos.y + 10)
	if debugMode == true:
		print("new pos: " + serializeVec2(self.position));
	
	
func setSteppedclbk(function : Callable) -> void:
	currentClbk = function;
	
func clearSteppedclbk() -> void:
	currentClbk = null_voidClbk;
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if debugMode == true:
		print("time since last render: " + str(delta));
	stepCam();
	if currentClbk != null_voidClbk || currentClbk == null:
		CameraStepped.emit();
		
func _input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.is_pressed() and cutsceneActive == true:
		CutsceneShifted.emit();
		
func autofarm(_img : Image) -> void:
	pass
	
# Displays an image directly on the camera. Fades in from black.
func Display(spr : Sprite2D) -> void:
	spr.rotation_degrees = 270;
	spr.scale = Vector2(2,2);
	add_child(spr);
	#var tween = create_tween().set_parallel(false)
	#tween.tween_property(newsprite, "modulate:a", 1.0, 1.0).from_current();

func createSpriteFromPath(path : String) -> Sprite2D:
	var img = load(path).get_image();
	var texture = ImageTexture.create_from_image(img);
	var sprite = Sprite2D.new()
	sprite.scale = Vector2(0.5,0.5);
	sprite.texture = texture;	
	return sprite;

# Gets the current sprite and fades it to black. Deletes the sprite after it is finished.
func FadeToBlack(sprite : Sprite2D) -> void:
	pass
	
# Spawns in the sprite in the camera already blacked out, then fades it in.
func FadeInFromBlack(sprite : Sprite2D) -> void:
	pass
	
# lerp opacity or some shit idk, dont overlay a pic though
func Transition(current : Sprite2D, next : Sprite2D, transitiontime : float) -> void:
	FadeToBlack(current);
	Global.wait(transitiontime);
	FadeInFromBlack(next);

# Initializes a cutscene with minimum wait time between images "mintime", and images "...". The mintime determines the amount of seconds inputs will be ignored for each picture. Each picture will fade in and out.
func InitCutscene(mintime : float, ... args : Array) -> void:
	cutsceneActive = true;
	var lambdavars = {"index" : -1, "currentImg" : args[0], "nextimg" : null, "transitionready" : true};
	#var index : int = 0;
	#var currentImg : Image = args[0];
	#var nextimg : Image = null;
	#var transitionready = true;
	
	var lambda : Callable = func(): 
		lambdavars["index"] += 1;
		lambdavars["currentImg"] = args[lambdavars["index"]];
		# terminate if out of bounds of array
		if lambdavars["index"] + 1 > len(args):
			cutsceneActive = false;
			return;
		lambdavars["nextimg"] = args[lambdavars["index"] + 1];
		Transition(lambdavars["currentImg"], lambdavars["nextimg"], 1.0);
		
	CutsceneShifted.connect(lambda);
	

	
