extends CanvasLayer

enum imageExtension {png, jpeg, jpg};
@onready var Heart1 = $Heart1;
@onready var Heart2 = $Heart2;
@onready var Heart3 = $Heart3;
@onready var CoinImage = $CoinImage;
@onready var Counter = $Counter;
var Player : CharacterBody2D;

func _ready() -> void:
	self.add_to_group("UIRenderer");
	Player = get_tree().get_first_node_in_group("Player");
	Global.PlayerCoinsChanged.connect(Update);
	Global.PlayerHealthChanged.connect(Update);
	
func stringifyEnum(extension : imageExtension) -> String:
	match extension:
		imageExtension.png:
			return ".png"
		imageExtension.jpeg:
			return ".jpeg"
		imageExtension.jpg:
			return ".jpg"
		_:
			return "unknown"
			
# Looks in the res://assets/images to load an image as a CompressedTexture2D and return it.
func getTexture(imagename : String, extension : imageExtension) -> CompressedTexture2D:
	var texture = load("res://assets/images/" + imagename + stringifyEnum(extension))
	return texture

# Calls a UI update which updates all the labels used in the player HUD.
func Update() -> void:
	var hp = Player.get("Health");
	var coins = Player.get("Coins");
	match hp:
		0:
			for i in range(3):
				var heart = get_child(i) as TextureRect;
				heart.texture = getTexture("emptyHeart", imageExtension.png);
		1:
			for i in range(3):
				var heart = get_child(i) as TextureRect;
				if i > 0:
					heart.texture = getTexture("emptyHeart", imageExtension.png);
				else:
					heart.texture = getTexture("fullHeartFinal", imageExtension.png);
		2:
			for i in range(3):
				var heart = get_child(i) as TextureRect;
				if i > 1:	
					heart.texture = getTexture("emptyHeart", imageExtension.png);
				else:
					heart.texture = getTexture("fullHeartFinal", imageExtension.png);
		3:
			for i in range(3):
				var heart = get_child(i) as TextureRect;
				heart.texture = getTexture("fullHeartFinal", imageExtension.png);
				
	Counter.text = str(coins);
		
# Gets the CanvasLayer object used to render objects.
func getRenderer() -> CanvasLayer:
	return get_tree().get_first_node_in_group("UIRenderer")
