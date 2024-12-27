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

    var target

    for dir in dirs_copy:
        if dir.is_colliding():
            var collision_point = dir.get_collision_point()

            # Prefer the runner as target
            if dir.get_collider() is RunnerClass:
                target = dir
            elif not target:
                target = dir

    return target

func get_input() -> Vector2:
    match ai_state:
        AIState.WANDERING:
            if ai_direction.y == 0 and touching_ladder and randf() < .001:
                # If not already climbing a ladder, and touching one:
                # Medium chance to try to climb in one direction or the other
                print("Wander => Climbing ladder")
                ai_direction = Vector2(0, [-1, 1].pick_random())
            #elif ai_direction.y != 0 and touching_ladder and randf() < .00001:
                ## Very low chance of switching climb direction
                #print("Wander => Switching climb dir")
                #ai_direction += Vector2(0, -ai_direction.y)
            elif ai_direction.x != 0 and randf() < .0002:
                # very low chance of turning around mid-shamble
                print("Wander => Switching shamble dir")
                ai_direction = Vector2(-ai_direction.x, 0)
            elif ai_direction.x == 0.0 and randf():
                print("Wander => Shambling")
                ai_direction = Vector2([-1, 1].pick_random(), 0)
            elif randf() < 0.05:
                # Low chance to look around
                var target = look_around()
                if target and target.get_collider() is RunnerClass:
                    print("Wander => CHASING PLAYER")
                    change_ai_state(AIState.CHASING, target)

        AIState.CHASING:
            # Low chance of checking for target every frame
            if randf() < 0.001:
                var target = look_around()
                if target and target.get_collider() is RunnerClass:
                    print("CHASING => still see player!")
                    # Still see them, maybe update position
                    change_ai_state(AIState.CHASING, target)
                else:
                    print("CHASING => lost target")
                    change_ai_state(AIState.WANDERING)

    ai_direction = ai_direction.normalized()

    return ai_direction

func change_ai_state(new_ai_state: AIState, target: RayCast2D = null) -> void:
    var old_state: AIState = ai_state

    match new_ai_state:
        AIState.WANDERING:
            ai_direction = Vector2.ZERO

        AIState.CHASING:
            ai_direction = (target.get_collision_point() - global_position).normalized()

    ai_state = new_ai_state

    return

func change_state(new_state: CharacterState) -> void:
    var old_state: CharacterState = state

    if new_state == old_state:
        return super(new_state)

    if new_state == CharacterState.STANDING:
        change_ai_state(AIState.WANDERING)
    if new_state == CharacterState.CLIMBING:
        # When the zombi starts climbing, stop trying to move horizontally
        ai_direction.x = 0
    if new_state == CharacterState.FALLING:
        change_ai_state(AIState.WANDERING)

    return super(new_state)
