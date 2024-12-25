extends "res://scenes/zombi-runner/Scenes/character.gd"

const RunnerClass = preload("res://scenes/zombi-runner/Scenes/runner.gd")

@onready var look_right: RayCast2D = get_node("LookRight")
@onready var look_left: RayCast2D = get_node("LookLeft")
@onready var look_up: RayCast2D = get_node("LookUp")
@onready var look_down: RayCast2D = get_node("LookDown")

@onready var look_dirs: Array = [look_right, look_left, look_up, look_down]

enum AIState {
    WANDERING,
    CHASING
}

@export var ai_state: AIState = AIState.WANDERING

var ai_direction: Vector2 = Vector2.ZERO

func look_around():
    var dirs_copy = look_dirs.duplicate();
    dirs_copy.shuffle()
    for dir in dirs_copy:
        if dir.is_colliding():
            var collision_point = dir.get_collision_point()

            if dir.get_collider() is RunnerClass:
                print("  CHASING PLAYER")
                ai_state = AIState.CHASING
                ai_direction = (collision_point - global_position).normalized()
                print("    " + str(ai_direction))

                return dir.get_collider()

func get_input() -> Vector2:

    match ai_state:

        AIState.WANDERING:
            if ai_direction.y == 0 and touching_ladder and randf() < .001:
                # If not already climbing a ladder, and touching one:
                # Medium chance to try to climb in one direction or the other
                print("Wander => Climbing ladder")
                ai_direction = Vector2(0, [-1, 1].pick_random())
            elif ai_direction.y != 0 and touching_ladder and randf() < .00001:
                # Very low chance of switching climb direction
                print("Wander => Switching climb dir")
                ai_direction += Vector2(0, -ai_direction.y)
            elif ai_direction.x != 0 and randf() < .0002:
                # very low chance of turning around mid-shamble
                print("Wander => Switching shamble dir")
                ai_direction = Vector2(-ai_direction.x, 0)
            elif ai_direction == Vector2.ZERO and randf() < .01:
                print("Wander => Shambling")
                ai_direction = Vector2([-1, 1].pick_random(), 0)
            elif randf() < 0.05:
                # Low chance to look around
                print("Wander => Looking around")
                look_around()
            elif randf() < .00001:
                # Very low chance to just start hanging out
                print("Wander => Hanging out")
                ai_direction = Vector2.ZERO

        AIState.CHASING:
            # High chance of checking for escape via ladder
            if touching_ladder and randf() < 0.50:
                print("CHASING => Checking ladder")
                look_around()

            # Low chance of checking for target
            if randf() < 0.01:
                print("CHASING => Checking for target...")
                ai_state = AIState.WANDERING
                ai_direction = Vector2.ZERO
                look_around()

    ai_direction = ai_direction.normalized()

    return ai_direction

# Whenever the zombi is standing around, they should start wandering
func start_standing(input_vector: Vector2 = Vector2.ZERO) -> void:
    ai_state = AIState.WANDERING
    ai_direction = input_vector

    super(input_vector)

# When the zombi starts climbing, stop trying to move horizontally
func start_climbing(input_vector) -> void:
    ai_direction.x = 0

    super(input_vector)
