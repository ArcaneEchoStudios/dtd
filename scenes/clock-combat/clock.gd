extends Node2D
class_name Clock
const Character = preload("res://scenes/clock-combat/character.gd")
const Action = preload("res://scenes/clock-combat/action.gd")
# Happy little change
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

# This adds a single step, or action to the end of the slot where it belongs
func add_step(pos: int, character: Character, action: Action):
    steps[pos].append({ "character": character, "action": action })

# Plan step will check to see if the step is valid and where it should go
# based on the next step the character already has planned
func plan_step(ch: Character, action: Action) -> bool:
    var pos = next_available_step(ch) + action.time
    if pos >= points:
        return false
    add_step(pos, ch, action)
    return true

func _ready():
    var button = Button.new()
    button.text = "Tick"
    button.add_theme_font_size_override("font_size", 12)
    button.position = self.center
    button.connect("pressed", Callable(self, "_on_clock_clicked"))
    add_child(button)

# Anytime something happens with the circle, we capture it. If it's a click
# event, we send it up the stack. Note: This could send as many events as
# they can click
func _on_clock_clicked():
    clock_event.emit()

# Loop through each step and find whichever the last action they have planned is
func next_available_step(ch: Character) -> int:
    var highest = 0

    for i in range(steps.size()):
        for step in steps[i]:
            if step['character'] == ch:
                highest = i
    return highest


func _draw():
    draw_circle(self.center, self.radius, Color.DIM_GRAY)
    draw_line(center, get_pos(0), Color.BLACK, 20)

    # Remove any previous labels and we'll redraw everything. Wasteful, I know.
    for child in get_children():
        if child is Label:  # Only remove Label nodes
            child.queue_free()

    # For each slot
    for i in range(points):

        # Create an 'O' label. This is just a marker for visual effects
        var n = Label.new()
        n.text = "O"
        n.position = get_pos(i)
        add_child(n)

        # Now for every planned action in this step, we're going to add it
        for s in range(steps[i].size()):
            var character = steps[i][s]['character']
            var action = steps[i][s]['action']

            # If the action is an enemy action, we hide the action
            var step = Label.new()
            if character.is_pc:
                step.text = action.name
            else:
                step.text = "????"
            step.add_theme_color_override("font_color", character.color)
            step.position = get_pos(i, (s + 1)*50)
            add_child(step)

# Beware, here lies math
func get_pos(pos, offset: int = 0) -> Vector2:

    var clock_number :int = self.turns % self.points

    var angle = 2.0 * PI * pos / self.points + (2.0 * PI * clock_number / self.points)
    return Vector2(
        self.center.x - 10 + (offset + self.radius) * cos(angle),
        self.center.y - 10 + (offset + self.radius) * sin(angle)
    )
