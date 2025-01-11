extends Button

const ButtonIcons: Texture2D = preload("res://scenes/fleeting-frames/Assets/Fruit.png")
const SPRITE_DIM: int = 64

var fruit_name: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass

func configure(loc: Vector2i, fruit: String) -> void:
    var region_texture: AtlasTexture = AtlasTexture.new()
    region_texture.atlas = ButtonIcons
    region_texture.region = Rect2(loc * SPRITE_DIM, Vector2(SPRITE_DIM, SPRITE_DIM))

    icon = region_texture
    fruit_name = fruit
