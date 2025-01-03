extends RigidBody2D

class_name Ball

const INITIAL_SPEED: float = 12000.0
const BEYONCE: float = 500.0

func _ready() -> void:
    # FIXME: I think there's a way to do this with signals that may be more efficient?
    contact_monitor = true
    max_contacts_reported = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func _physics_process(delta: float) -> void:
    # Works because contact_monitor and max_contacts_reported set in _ready()
    var c: Array = get_colliding_bodies()

    if c.size() and c[0] is Paddle:
        var paddle: Paddle = c[0]
        var dir: Vector2 = Vector2(global_position - paddle.global_position).normalized()
        print("Bouncing off of " + str(paddle))
        print("  Initial dir: " + str(dir))

        # If we're headed "too far" up or down, clamp until we're under 45 degrees
        # FIXME: I think the right way to do this is with cosines and stuff?
        while abs(dir.y) > .5:
            dir.y /= 2
            dir = dir.normalized()

        print("  Final dir: " + str(dir))

        # This is "above and beyond" the normal physics interaction, I think?
        apply_central_impulse(dir * BEYONCE)

func start(loc: Vector2, dir: Vector2) -> void:
    transform.origin = loc
    apply_central_force(dir * INITIAL_SPEED)
