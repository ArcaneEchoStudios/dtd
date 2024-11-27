extends Node2D
class_name Character  # Makes it globally accessible

const Action = preload("res://src/action.gd")
# Properties
var ch_name: String
var color: Color
var zone: String
var slot: int
var is_pc: bool

var actions: Array

# Constructor
func _init(name: String, color: Color, zone: String, slot: int, is_pc: bool) -> void:
    self.ch_name = name
    self.color = color
    self.zone = zone
    self.slot = slot
    self.is_pc = is_pc
    self.actions = [
        Action.new("Move", 1, "Moves one zone"),
        Action.new("Attack", 2, "Attack successful!")
    ]

# Example method
func describe() -> String:
    return "Character: %s, Color: %s, Zone: %s, Slot: %d" % [name, color.to_html(), zone, slot]

func add_action(action: Action) -> void:
    self.actions.append(action)

func get_action(action_name: String) -> Action:
    if action_name == '__random__': 
        return actions[randi() % actions.size()]
    else: 
        for a in actions:
            if a.name == action_name:
                return a
    return null
    
    
func _draw() -> void:
    var label = Label.new()
    label.text = self.ch_name
    label.add_theme_color_override("font_color", self.color)  # Set to red
    label.add_theme_font_size_override("font_size", 18)
    add_child(label)

