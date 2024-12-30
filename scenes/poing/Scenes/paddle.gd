extends CharacterBody2D

class_name Paddle

const SPEED = 30000.0
const BEYONCE = 10.0

var pos_action: String = ""
var neg_action: String = ""

func configure(neg: String, pos: String) -> void:
    neg_action = neg
    pos_action = pos

func _physics_process(delta: float) -> void:
    var direction := Input.get_axis(neg_action, pos_action)

    if direction:
        velocity.y = direction * SPEED * delta
    else:
        velocity.y = move_toward(velocity.y, 0, SPEED * delta)

    move_and_slide()

    for i in get_slide_collision_count():
        var c = get_slide_collision(i)
        var collider = c.get_collider()
        if collider is RigidBody2D:
            print(collider)
            print(-c.get_normal())
            print(collider.linear_velocity.length())
            print(collider.mass)
            collider.apply_central_impulse(-c.get_normal() * collider.linear_velocity.length() * collider.mass * BEYONCE) # Use ball velocity?
