extends CharacterBody2D

enum CharacterState {
    STANDING,
    WALKING,
    RUNNING,
    CLIMBING,
    FALLING
}

@export var touching_ladder: bool = false
@export var state: CharacterState = CharacterState.STANDING

@export var accel: float = 2000.0

@export var walk_speed: float = 150.0
@export var run_speed: float = 300.0
@export var climb_speed: float = 100.0
@export var fall_speed: float = 986.0

@onready var sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var ladder_checker: Area2D = get_node("LadderChecker")

func _ready() -> void:
    change_state(CharacterState.STANDING)

func _process(_delta: float) -> void:
    pass

## Handle actual movement in physics process loop
func _physics_process(delta: float) -> void:
    var input_vector: Vector2 = get_input()

    if state == CharacterState.CLIMBING:
        ## Only way off a ladder is to fall off or step off
        if not touching_ladder:
            change_state(CharacterState.FALLING)
        elif is_on_floor() and input_vector.y == 0:
            change_state(CharacterState.STANDING)
    elif touching_ladder and input_vector.y:
        ## If we're not climbing, on a ladder, and trying to climb, start climbing
        ## FIXME: At the bottom, we keep trying to climb as long as down is pressed.
        ## I don't *think* we can use is_touching_floor here because the ladders are implemented with one-way floors so we can stand on them.
        change_state(CharacterState.CLIMBING)
    elif not is_on_floor():
        ## We're not climbing, and we're not on the floor, and we're not already falling so time to start falling.
        if state != CharacterState.FALLING:
            change_state(CharacterState.FALLING)
        else:
            ## We're still falling until we hit the floor
            pass
    elif state == CharacterState.WALKING and input_vector.x:
        if walk_speed - abs(velocity.x) <= accel * delta:
            ## If we're walking at top speed, start running
            change_state(CharacterState.RUNNING)
        else:
            ## Still walking
            pass
    elif input_vector.x:
        if abs(velocity.x) < walk_speed:
            ## Slowing to a walk or starting from standing
            change_state(CharacterState.WALKING)
        else:
            ## Still running
            pass
    elif state != CharacterState.STANDING:
        ## We're on the floor, we're not walking or running, so we're standing.
        change_state(CharacterState.STANDING)

    match state:
        CharacterState.STANDING:
            velocity = velocity.move_toward(Vector2(0, fall_speed), accel * delta * 10)

        CharacterState.WALKING:
            velocity = velocity.move_toward(Vector2(input_vector.x * walk_speed, fall_speed), accel * delta)

        CharacterState.RUNNING:
            velocity = velocity.move_toward(Vector2(input_vector.x * run_speed, fall_speed), accel * delta)

        CharacterState.CLIMBING:
            velocity = velocity.move_toward(Vector2(input_vector.x * walk_speed, input_vector.y * climb_speed), accel * delta)

            if is_equal_approx(velocity.y, 0.0):
                sprite.pause()
            if velocity.y > 0.0 and sprite.get_playing_speed() >= 0:
                sprite.play("", -1, true)
            elif velocity.y < 0.0 and sprite.get_playing_speed() <= 0:
                sprite.play("", 1)

            if input_vector.y > 0 and is_on_floor(): # drop through the floor when climbing down a ladder
                position.y += climb_speed * delta
        CharacterState.FALLING:
            velocity = velocity.move_toward(Vector2(0, fall_speed), accel * delta)

    if velocity.x < 0.0:
        sprite.flip_h = true
    else:
        sprite.flip_h = false


    move_and_slide()

func change_state(new_state: CharacterState) -> void:
    var old_state: CharacterState = state

    if new_state == old_state:
        return

    match new_state:
        CharacterState.STANDING:
            sprite.play("standing")

        CharacterState.WALKING:
            sprite.play("running") # just one animation right now, play it a bit slower...
            sprite.speed_scale = 0.75

        CharacterState.RUNNING:
            sprite.play("running")
            sprite.speed_scale = 1.0

        CharacterState.CLIMBING:
            sprite.play("climbing")

        CharacterState.FALLING:
            sprite.play("falling")

    state = new_state

    return

func _on_ladder_checker_body_entered(_body: Node2D) -> void:
    touching_ladder = true

func _on_ladder_checker_body_exited(_body: Node2D) -> void:
    touching_ladder = false

func get_input() -> Vector2:
    var input_vector = Vector2(Input.get_axis("player_left_a", "player_right_a"),
            Input.get_axis("player_up_a", "player_down_a"))

    return input_vector.normalized()
