extends Node2D
class_name Clock
const Character = preload("res://src/character.gd")
const Action = preload("res://src/action.gd")

var radius: float
var points: int
var steps: Array
var center: Vector2

signal clock_event  # Define the signal

func _init(x, y, size: float, clock_points: int) -> void:
    self.center = Vector2(x, y)
    self.radius = size
    self.points = clock_points
    # Create an empty list for all of the clock points
    for i in range(self.points):
        steps.append([])


func add_step(pos: int, character: Character, action: Action):
    # TODO: Tuples aren't really supported in gds so this is kinda dumb
    steps[pos].append([character, action])

func _ready():
    # Add an Area2D for click detection
    var area = Area2D.new()
    var collision_shape = CollisionShape2D.new()
    var circle_shape = CircleShape2D.new()
    circle_shape.radius = radius
    collision_shape.shape = circle_shape
    area.add_child(collision_shape)
    add_child(area)

    # Center the Area2D on the clock
    area.position = center

    # Connect the input_event signal to detect clicks
    area.connect("input_event", Callable(self, "_on_clock_ticked"))

func _on_clock_ticked(viewport, event, shape_idx):
    if event is InputEventMouseButton and event.pressed:
        print("Clock clicked!")

func _draw():
    draw_circle(self.center, self.radius, Color.DIM_GRAY)
    
    for i in range(points):
        var n = Label.new()
        n.text = str(i)
        n.position = get_pos(i)
        add_child(n)

        for s in range(steps[i].size()):
            var character = steps[i][s][0]
            var action = steps[i][s][1]

            var step = Label.new()
            step.text = action.name
            step.add_theme_color_override("font_color", character.color)
            step.position = get_pos(i, (s + 1)*50)
            add_child(step)

func get_pos(pos, offset: int = 0) -> Vector2:
    var angle = 2.0 * PI * pos / self.points - PI / 2
    return Vector2(
        self.center.x - 10 + (offset + self.radius) * cos(angle),
        self.center.y - 10 + (offset + self.radius) * sin(angle)
    )