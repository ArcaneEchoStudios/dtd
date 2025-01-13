extends Control

class_name FleetingFrames

@onready var ui_control: Control = get_node("UI")

@onready var button_container: GridContainer = get_node("UI/Game/ButtonContainer")
@onready var fruit_name_label: Label = get_node("UI/Prompt/FruitName")
@onready var submit_button: Button = get_node("UI/Game/Control/Submit")
@onready var score_label: Label = get_node("UI/Game/Control/RewardCoin/Score")
@onready var round_timer_label: Label = get_node("UI/Game/Control/RoundTimer")
@onready var cover_panel: PanelContainer = get_node("CoverPanel")
@onready var game_ui: VBoxContainer = get_node("UI/Game")

@onready var sfx_correct: AudioStreamPlayer2D = get_node("SFX/correct")
@onready var sfx_incorrect: AudioStreamPlayer2D = get_node("SFX/incorrect")

@onready var sfx_pass: AudioStreamPlayer2D = get_node("SFX/pass")
@onready var sfx_fail: AudioStreamPlayer2D = get_node("SFX/fail")

@onready var sfx_select_all: AudioStreamPlayer2D = get_node("SFX/select_all")

@onready var sfx_fruit_names: Dictionary = {}

# Animations for checkmark, X, et. al.
@export var sprite_animation: SpriteFrames

const ButtonScene: PackedScene = preload("res://scenes/fleeting-frames/Scenes/button.tscn")
const main_theme: Theme = preload("res://scenes/fleeting-frames/Themes/Main.tres")

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

var SUBMIT_MESSAGES: Array =  [
    "SUBMIT",
    "APPLY",
    "SEND",
    "CONFIRM",
    "COMPLETE",
    "EXECUTE",
    "UPLOAD",
    "ENTER",
    "ACCEPT",
    "PROCEED",
    "VALIDATE",
    "FINALIZE",
    "FORWARD",
    "POST",
    "DELIVER",
    "APPROVE"
]

# fruits is FRUITS in a random order per-game
var fruits: Array = FRUITS.duplicate()
var target_fruit: String

# How far into the list of fruits do we delve for the current round?
# eg, start with just four choices, expand as the player "learns".
var fruits_extent: int = 4

var game_score: int = 0
var round_score: int = 0

# Fudge factor for timers, varies every round
var timer_factor: float = 1.0

var round_timer_running: bool = false
var round_timer: float = 0.0

var start_timer_running: bool = false
var start_timer: float = 0.0

func _ready() -> void:
    for fruit in FRUITS:
        sfx_fruit_names[fruit] = get_node("SFX/%s" % fruit)

    randomize()

    fruits.shuffle()

    setup_round()

func _process(delta: float) -> void:
    if start_timer_running:
        start_timer -= delta * timer_factor
        cover_panel.get_node("Label").text = "%d" % [int(start_timer)]

        if start_timer < 1:
            start_round()

    elif round_timer_running:
        round_timer -= delta * timer_factor
        round_timer_label.text = "%1.2f" % [round_timer]

        if round_timer < 0:
            sfx_fail.play()

            setup_round()
    else:
        start_timer_running = true
        start_timer = 4

        cover_panel.global_position = game_ui.global_position
        cover_panel.set_size(game_ui.size)
        cover_panel.visible = true

func _on_fruit_button_pressed(button: Button) -> void:
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

func setup_round() -> void:
    # Each round, only give #fruits_extent options to choose from.
    var current_round_fruits = fruits.slice(0, fruits_extent)

    # Target fruit for this round.
    target_fruit = current_round_fruits.pick_random()

    round_score = 0

    # Clear previous round buttons.
    for button in button_container.get_children():
        button_container.remove_child(button)
        button.queue_free()

    # Populate current round buttons.
    for i in range(16):
        var button = ButtonScene.instantiate()

        var loc: Vector2i
        var fruit: String

        while fruit not in current_round_fruits:
            # Calculate location on sprite sheet to select fruit from,
            # then pick the name of the fruit in a way that's "stable" per game.
            loc = Vector2i(randi() % 4, randi() % 4)
            fruit = FRUITS[loc[0] * 4 | loc[1]]

            # Now, if we picked a fruit that isn't in the current round, the while loop repeats.
            #
            # Throwing them out rather than picking from the current_round_fruits in the first place
            # feels a bit jank, but this way I get a random picture/name relationship that's stable
            # for each game, while only starting with a subset and expanding.

        button.configure(loc, fruit)
        button.connect("pressed", Callable(self, "_on_fruit_button_pressed").bind(button))
        button_container.add_child(button)

    fruit_name_label.text = target_fruit

    # Configure SUBMIT button.
    # 95% chance of first option ("SUBMIT"), otherwise a synonym.
    if randf() < 0.95:
        submit_button.text = SUBMIT_MESSAGES[0]
    else:
        submit_button.text = SUBMIT_MESSAGES.slice(1).pick_random()

    score_label.text = str(game_score)

    round_timer_running = false

    sfx_select_all.play()

func start_round() -> void:
    cover_panel.visible = false

    start_timer_running = false
    round_timer_running = true
    round_timer = 5.0

    # Each round, the timer runs up to 15% slower or faster. <3
    timer_factor = 0.85 + randf() * (0.3)

func update_score(success: bool) -> void:
    # play sound

    if success:
        sfx_correct.play()
        round_score += 1
    else:
        sfx_incorrect.play()
        round_score = -1000 # One wrong move...

func _on_submit_pressed() -> void:
    var target_count: int = 0
    for button in button_container.get_children():
        if button.fruit_name == target_fruit:
            target_count += 1

    if target_count == round_score:
        sfx_pass.play()

        game_score += 1

        if fruits_extent < fruits.size():
            fruits_extent += 1
    else:
        sfx_fail.play()

    setup_round()

func _on_select_all_finished() -> void:
    sfx_fruit_names[target_fruit].play()
