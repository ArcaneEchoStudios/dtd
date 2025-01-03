extends Node2D

@onready var ball: Ball = get_node("Ball")
@onready var level: Node2D = get_node("Level")
@onready var paddle_left: Paddle = get_node("PlayerLeft")
@onready var paddle_right: Paddle = get_node("PlayerRight")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    paddle_left.configure("player_up_a", "player_down_a")
    paddle_right.configure("player_up_b", "player_down_b")

    var window_size = get_viewport().get_visible_rect().size
    #print(window_size)
    ball.start(window_size / 3, Vector2(-1, -1))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
