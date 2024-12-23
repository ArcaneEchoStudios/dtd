extends CharacterBody2D

## Movement parameters
@export var max_speed: float = 200.0 # Maximum speed the character can reach
@export var acceleration: float = 500.0 # How quickly the character speeds up
@export var deceleration: float = 300.0 # How quickly the character slows down

@onready var sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var navigation_agent: NavigationAgent2D = get_node("Navigation/NavigationAgent2D")

var ghost: Node2D

func _ready() -> void:
    velocity = Vector2.ZERO
    motion_mode = MOTION_MODE_FLOATING

    sprite.play("default")

    # These values need to be adjusted for the actor's speed
    # and the navigation layout.
    navigation_agent.path_desired_distance = 16.0
    navigation_agent.target_desired_distance = 8.0

    ## DEBUG
    #navigation_agent.debug_enabled = true

    # Make sure to not await during _ready.
    agent_setup.call_deferred()

## Wait for the first physics frame so the NavigationServer can sync.
func agent_setup():
    await get_tree().physics_frame

## Chase the target node
func chase(target: Node2D) -> void:

    navigation_agent.target_position = target.global_position

func _physics_process(delta: float) -> void:
    #FIXME: Figure out the 'catching' mechanic
    #if navigation_agent.is_navigation_finished():
        #if ghost:
            #chase(ghost)
        #return

    var target_vector: Vector2 = Vector2.ZERO

    target_vector = navigation_agent.get_next_path_position() - global_position
    target_vector = target_vector.normalized()

    if target_vector != Vector2.ZERO:
        velocity = velocity.move_toward(target_vector * max_speed, acceleration * delta)

        if not sprite.is_playing() or sprite.animation == "idle":
            sprite.play("default")

        sprite.flip_h = bool(velocity.x < 0.0)

    else:
        velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
        sprite.play("default")

    move_and_slide()

func _on_nav_timer_timeout() -> void:
    if ghost:
        chase(ghost)
