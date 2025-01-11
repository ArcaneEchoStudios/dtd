extends Node2D

#@onready var ball: Ball = get_node("Ball")
const BallScene: PackedScene = preload("res://scenes/poing/Scenes/ball.tscn")
var ball: Ball = null

@onready var level: Node2D = get_node("Level")
@onready var paddle_left: Paddle = get_node("PlayerLeft")
@onready var paddle_right: Paddle = get_node("PlayerRight")
@onready var round_timer: PanelContainer = get_node("HUD/RoundStartTimer")
var round_timer_countdown: int = 11

var window_size: Vector2 = Vector2.ZERO
var score: Array = [0, 0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    paddle_left.configure("player_up_a", "player_down_a")
    paddle_right.configure("player_up_b", "player_down_b")
    window_size = get_viewport().get_visible_rect().size

    start_round_timer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if ball and ball.global_position.x < 0:
        score_point(paddle_right)
    elif ball and ball.global_position.x > window_size.x:
        score_point(paddle_left)

func score_point(paddle: Paddle) -> void:
    if paddle == paddle_left:
        score[0] += 1
    elif paddle == paddle_right:
        score[1] += 1

    ball.queue_free()
    ball = null

    # Play a sound?

    start_round_timer()

func start_round_timer() -> void:
    round_timer_countdown = 11
    round_timer.get_node("Label").text = ""

    var timer: Timer = round_timer.get_node("Timer")
    timer.paused = false

    round_timer.visible = true

func start_round() -> void:
    var timer: Timer = round_timer.get_node("Timer")
    timer.paused = true

    round_timer.visible = false

    ball = BallScene.instantiate()
    add_child(ball)
    ball.start(window_size / 2, Vector2(-2, 0))

func _on_timer_timeout() -> void:
    var num: String = str(round_timer_countdown / 3)
    var dots: int = int(2 + round_timer_countdown % 3)
    num = num.rpad(dots, ".")

    round_timer.get_node("Label").text = num

    round_timer_countdown -= 1

    if round_timer_countdown < 0:
        start_round()
