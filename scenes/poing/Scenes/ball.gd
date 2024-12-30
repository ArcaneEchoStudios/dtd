extends RigidBody2D

class_name Ball

const INITIAL_SPEED: float = 12000.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func start(loc: Vector2, dir: Vector2) -> void:
    transform.origin = loc
    apply_central_force(dir * INITIAL_SPEED)
