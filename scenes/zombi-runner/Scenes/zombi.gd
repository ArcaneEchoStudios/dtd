extends CharacterBase

class_name Zombi

@onready var look: RayCast2D = get_node("Look")
@onready var ai_timer: Timer = get_node("AITimer")

const LOOK_DISTANCE = 250 # 250 pixel vision range

enum AIState {
    WANDERING,
    CHASING,
    FEEDING
}

@export var ai_state: AIState = AIState.WANDERING
var ai_direction: Vector2 = Vector2.ZERO
var runner: Runner = null

func _ready() -> void:
    runner = get_parent().get_node("Runner")
    assert(runner is Runner, "Could not find Runner!")

func look_for_runner() -> void:
    var dir: Vector2 = runner.global_position - global_position
    dir = dir.normalized()
    look.target_position = dir * LOOK_DISTANCE

    if look.is_colliding():
        if look.get_collider() is Runner:
            chase(runner)
        else:
            print("Vision blocked")
    else:
        print("Out of range")

    wander(runner)

    return

func chase(target) -> void:
    return change_ai_state(AIState.CHASING, target)

func wander(target: Node2D) -> void:
    return change_ai_state(AIState.WANDERING, target)

func decide_what_to_do() -> void:
    # FIXME: This should only be triggered by timer timeout?

    look_for_runner() # Chase runner if visible, wander toward them if not

    match ai_state:
        AIState.WANDERING:
            # FIXME: Some sort of navigation logic goes here
            if is_on_wall() and get_wall_normal().x == ai_direction.x * -1:
                print("Wander => Stuck on a wall, turning around.")
                ai_direction.x *= -1
                # FIXME: Set a long timer for this?

        AIState.CHASING:
            pass
            #FIXME: Some sort of navigation logic goes here

        AIState.FEEDING:
            # Go back to wandering when done with meal
            change_ai_state(AIState.WANDERING)

func get_input() -> Vector2:
    return ai_direction.normalized() # Really I just want this to always be normalized, FIXME: better way?

func change_ai_state(new_ai_state: AIState, target: Node2D = null) -> void:
    var old_state: AIState = ai_state

    match new_ai_state:
        AIState.WANDERING:
            if target:
                ai_direction = (target.global_position - global_position).normalized()
            else:
                ai_direction = Vector2.ZERO
            change_state(CharacterState.WALKING)

        AIState.CHASING:
            if target:
                ai_direction = (target.global_position - global_position).normalized()
            else:
                ai_direction = Vector2.ZERO

            change_state(CharacterState.RUNNING)

        AIState.FEEDING:
            ai_direction = Vector2.ZERO
            change_state(CharacterState.FEEDING)

    ai_state = new_ai_state

    return

func change_state(new_state: CharacterState) -> void:
    var old_state: CharacterState = state

    if new_state == old_state:
        return super(new_state)

    if old_state == CharacterState.FEEDING:
        # Only let the AI timer return from feeding, so the sequence plays out
        return

    match new_state:
        CharacterState.STANDING:
            change_ai_state(AIState.WANDERING)
        CharacterState.CLIMBING:
            pass
            # FIXME: Not sure if correct: When the zombi starts climbing, stop trying to move horizontally
            #ai_direction.x = 0
        CharacterState.RUNNING:
            if ai_state != AIState.CHASING:
                #FIXME: Better to prevent this?
                print("Zombi attempting to run when not chasing")
                # Zombi only run when chasing
                return super(old_state)
        CharacterState.FALLING:
            # If we start falling, lose track of player
            # FIXME: Also not sure if correct
            change_ai_state(AIState.WANDERING)

    return super(new_state)

func feed() -> void:
    change_ai_state(AIState.FEEDING)

#FIXME: Use masks!
func _on_character_checker_area_entered(area: Area2D) -> void:
    if area.get_parent() is Runner:
        print("FEED!")
        feed()

func _on_ai_timer_timeout() -> void:
    ai_timer.start(2.0)
    decide_what_to_do()
