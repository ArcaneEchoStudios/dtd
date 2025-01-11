extends Node2D

@onready var button_container: GridContainer = get_node("UI/ButtonContainer")
@onready var fruit_name_label: Label = get_node("UI/Prompt/FruitName")

const ButtonScene: PackedScene = preload("res://scenes/fleeting-frames/Scenes/button.tscn")

const FRUITS: Array =  [
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

func _ready() -> void:
    fruits.shuffle()
    target_fruit = fruits.pick_random()

    start_round()

func _process(delta: float) -> void:
    pass

func _on_button_pressed(button) -> void:
    print(button.fruit_name)

func start_round() -> void:
    for node in button_container.get_children():
        button_container.remove_child(node)
        node.queue_free()

    for i in range(16):
        var button = ButtonScene.instantiate()
        var loc: Vector2i = Vector2i(randi() % 4, randi() % 4)
        var fruit: String = fruits[loc[0] * 4 | loc[1]]

        button.configure(loc, fruit)
        button.connect("pressed", Callable(self, "_on_button_pressed").bind(button))
        button_container.add_child(button)

    fruit_name_label.text = target_fruit
