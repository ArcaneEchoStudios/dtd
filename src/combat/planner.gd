extends Node2D
class_name Planner

const Action = preload("res://src/combat/action.gd")
const Character = preload("res://src/combat/character.gd")

var ch: Character
var plan: Callable

# Constructor
func _init(character: Character, on_action: Callable) -> void:
    self.ch = character
    self.plan = on_action
    

    
func _draw() -> void:
    for child in get_children():
        if child is Label:  # Only remove Label nodes
            child.queue_free()

    for i in range(self.ch.actions.size()):
        var action : Action = self.ch.actions[i]

        var label = Label.new()
        label.text = action.name
        label.add_theme_color_override("font_color", self.ch.color)
        label.add_theme_font_size_override("font_size", 18)
        label.position = Vector2(40, i*70)
        add_child(label)
        
        var helper = Label.new()
        helper.text = "Cost: %s\n%s" % [str(action.time), action.effect]
        helper.position = Vector2(40, i*70 + 20)
        helper.add_theme_color_override("font_color", Color.BLACK)
        helper.add_theme_font_size_override("font_size", 10)
        add_child(helper)

        var button = Button.new()
        button.text = "Plan"
        button.add_theme_font_size_override("font_size", 12)
        button.position = Vector2(0, i * 70 + 5)
        button.connect("pressed", self.plan.bind(ch, action.name))
        add_child(button)


