extends Node2D

signal scene_change # Define the signal

# This is called when the scene starts
func _ready() -> void:
    $Combat.connect("pressed", Callable(self, "_on_start_combat"))
    $WakaWaka.connect("pressed", Callable(self, "_on_waka"))
    $ZombiRunner.connect("pressed", Callable(self, "_on_zombi_runner"))
    $Poing.connect("pressed", Callable(self, "_on_poing"))
    $Exit.connect("pressed", Callable(self, "_on_exit"))

func _on_start_combat():
    scene_change.emit('clock-combat')

func _on_waka():
    scene_change.emit('waka-waka')

func _on_zombi_runner():
    scene_change.emit('zombi-runner')

func _on_poing():
    scene_change.emit('poing')

func _on_exit():
    get_tree().quit()
