extends Node2D
class_name Character

const Action = preload("res://src/action.gd")

# Properties
var ch_name: String
var color: Color
var is_pc: bool

var actions: Array

func _init(character_name: String, player_color: Color, is_player_character: bool) -> void:
    self.ch_name = character_name
    self.color = player_color
    self.is_pc = is_player_character
    self.actions = [
        Action.new("Attack", 2, "Make attack roll")
    ]

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
