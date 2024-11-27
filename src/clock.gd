extends Node2D
class_name Clock
const Character = preload("res://src/character.gd")
const Action = preload("res://src/action.gd")

var radius: float
var points: int
var steps: Array
var center: Vector2
var turns: int = 0

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

func plan_step(ch: Character, action: Action) -> bool:
    var pos = next_available_step(ch) + action.time
    if pos >= points:
        return false
    add_step(pos, ch, action)
    return true

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
    area.connect("input_event", Callable(self, "_on_clock_clicked"))

func _on_clock_clicked(viewport, event, shape_idx):
    if event is InputEventMouseButton and event.pressed:
        turns += 1
        emit_signal("clock_event")

func next_available_step(ch: Character) -> int:
    var highest = 0

    for i in range(steps.size()):
        for step in steps[i]:
            if step[0] == ch:
                highest = i 
    return highest


func _draw():
    draw_circle(self.center, self.radius, Color.DIM_GRAY)
    draw_line(center, get_pos(0), Color.BLACK, 20)

    

    for child in get_children():
        if child is Label:  # Only remove Label nodes
            child.queue_free()

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
    var angle = 2.0 * PI * pos / self.points + calculate_start_angle()
    return Vector2(
        self.center.x - 10 + (offset + self.radius) * cos(angle),
        self.center.y - 10 + (offset + self.radius) * sin(angle)
    )

func calculate_start_angle() -> float:
    var clock_number :int = self.turns % self.points

    return 2.0 * PI * clock_number / self.points