extends CharacterBody2D

enum CharacterState {
    STANDING,
    RUNNING,
    CLIMBING,
    FALLING
}

@export var gravity_enabled: bool = false
@export var touching_ladder: bool = false
@export var state: CharacterState = CharacterState.STANDING

const ACCEL = 8.0
const RUN_SPEED = 150.0
const CLIMB_SPEED = 100.0

const FALL_SPEED = 450.0

@onready var sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var ladder_checker: Area2D = get_node("LadderChecker")

func _ready() -> void:
    start_standing()

## Handle state transitions in the process loop
func _process(_delta: float) -> void:
    var input_vector: Vector2 = get_input()

    match state:
        CharacterState.FALLING:
            if touching_ladder and input_vector.y:
                start_climbing(input_vector)
            elif is_on_floor():
                start_standing(input_vector)

        CharacterState.STANDING:
            if touching_ladder and input_vector.y:
                start_climbing(input_vector)
            elif not is_on_floor() and gravity_enabled:
                start_falling(input_vector)
            elif input_vector.x:
                start_running(input_vector)

        CharacterState.RUNNING:
            if touching_ladder and input_vector.y:
                start_climbing(input_vector)
            elif not is_on_floor() and gravity_enabled:
                start_falling(input_vector)
            elif input_vector.x != 0:
                if sign(input_vector.x) != sign(velocity.x):
                    # We turned around
                    start_running(input_vector)
            else:
                start_standing(input_vector)

        CharacterState.CLIMBING:
            if not touching_ladder:
                start_falling(input_vector)
            elif is_on_floor() and input_vector.y == 0:
                start_standing(input_vector)
            elif sign(input_vector.y) != sign(velocity.y):
                    # We turned around
                    start_climbing(input_vector)

## Handle actual movement in physics process loop
func _physics_process(delta: float) -> void:
    var input_vector: Vector2 = get_input()

    match state:
        CharacterState.STANDING:
            velocity = velocity.move_toward(Vector2.ZERO, ACCEL * FALL_SPEED * delta)

        CharacterState.RUNNING:
            velocity = velocity.move_toward(input_vector * RUN_SPEED, ACCEL * RUN_SPEED * delta)

        CharacterState.CLIMBING:
            velocity = velocity.move_toward(input_vector * CLIMB_SPEED, ACCEL * CLIMB_SPEED * delta)

            if input_vector.y > 0 and is_on_floor(): # drop through the floor when climbing down a ladder
                position.y += CLIMB_SPEED * delta

        CharacterState.FALLING:
            velocity = velocity.move_toward(Vector2(0, FALL_SPEED), ACCEL * FALL_SPEED * delta)

    move_and_slide()

func _on_ladder_checker_body_entered(_body: Node2D) -> void:
    touching_ladder = true

func _on_ladder_checker_body_exited(_body: Node2D) -> void:
    touching_ladder = false

func get_input() -> Vector2:
    var input_vector = Vector2(Input.get_axis("player_left_a", "player_right_a"),
            Input.get_axis("player_up_a", "player_down_a"))

    return input_vector.normalized()

func start_standing(_input_vector: Vector2 = Vector2.ZERO) -> void:
    state = CharacterState.STANDING
    velocity = Vector2.ZERO

    sprite.play("standing")

func start_running(input_vector: Vector2) -> void:
    state = CharacterState.RUNNING

    sprite.play("running")

    if input_vector.x < 0.0:
        sprite.flip_h = true
    else:
        sprite.flip_h = false

func start_climbing(input_vector: Vector2) -> void:
    state = CharacterState.CLIMBING

    if input_vector.y < 0.0:
        sprite.play_backwards("climbing")
    else:
        sprite.play("climbing")

func start_falling(_input_vector: Vector2) -> void:
    state = CharacterState.FALLING
    sprite.play("falling")
