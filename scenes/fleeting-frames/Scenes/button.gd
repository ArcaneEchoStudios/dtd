extends Button

@export var ButtonIcons: Texture2D = preload("res://scenes/fleeting-frames/Assets/Fruit.png")
@export var sprite_dim: int = 64

var button_name: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass

func configure(loc: Vector2i, new_name: String) -> void:
    var region_texture: AtlasTexture = AtlasTexture.new()

    region_texture.atlas = ButtonIcons
    region_texture.region = Rect2(loc * sprite_dim, Vector2(sprite_dim, sprite_dim))

    icon = region_texture
    button_name = new_name
