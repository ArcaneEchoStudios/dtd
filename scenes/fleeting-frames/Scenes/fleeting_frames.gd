extends Node2D

class_name FleetingFrames

@onready var button_container: GridContainer = get_node("UI/ButtonContainer")
@onready var fruit_name_label: Label = get_node("UI/Prompt/FruitName")

@export var sprite_animation: SpriteFrames

const ButtonScene: PackedScene = preload("res://scenes/fleeting-frames/Scenes/button.tscn")

var FRUITS: Array =  [
    "Zelqua",
    "Mirala",
    "Xynum",
    "Velkin",
    "Trivon",
    "Clorun",
    "Felyra",
    "Glintan",
    "Sorala",
    "Quenith",
    "Rylath",
    "Obris",
    "Kynor",
    "Tavix",
    "Orintha",
    "Lymar"
]

# FRUITS in random order per-game
var fruits: Array = Array(FRUITS)
var target_fruit: String

var round_score: int = 0

func _ready() -> void:
    fruits.shuffle()
    target_fruit = fruits.pick_random()

    start_round()

func _process(_delta: float) -> void:
    pass

func _on_button_pressed(button: Button) -> void:
    print(button.fruit_name)

    var success: bool = false
    if button.fruit_name == target_fruit:
        success = true

    var animated_sprite = AnimatedSprite2D.new()
    animated_sprite.frames = sprite_animation
    animated_sprite.animation = "check" if success else "X"
    animated_sprite.play()

    # Add the AnimatedSprite2D as a child of the button
    button.add_child(animated_sprite)

    # Center the AnimatedSprite2D on the button
    animated_sprite.position = button.get_size() / 2
    button.disabled = true

    update_score(success)

func start_round() -> void:
    for button in button_container.get_children():
        button_container.remove_child(button)
        button.queue_free()

    for i in range(16):
        var button = ButtonScene.instantiate()
        var loc: Vector2i = Vector2i(randi() % 4, randi() % 4)
        var fruit: String = fruits[loc[0] * 4 | loc[1]]

        button.configure(loc, fruit)
        button.connect("pressed", Callable(self, "_on_button_pressed").bind(button))
        button_container.add_child(button)

    fruit_name_label.text = target_fruit

func update_score(success: bool) -> void:
    # play sound

    if success:
        round_score += 1
    else:
        round_score = -1000 # One wrong move

func _on_submit_pressed() -> void:
    var target_count: int = 0
    for button in button_container.get_children():
        if button.fruit_name == target_fruit:
            target_count += 1

    if target_count == round_score:
        print("Win")
    else:
        print("Loss")
