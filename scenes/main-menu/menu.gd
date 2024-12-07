extends Node2D

signal scene_change # Define the signal

# This is called when the scene starts
func _ready() -> void:
    $Combat.connect("pressed", Callable(self, "_on_start_combat"))
    $Exit.connect("pressed", Callable(self, "_on_exit"))

func _on_start_combat():
    scene_change.emit('clock-combat')

func _on_exit():
    get_tree().quit()
