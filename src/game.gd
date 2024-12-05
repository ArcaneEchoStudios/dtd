extends Node2D

var current_scene: Node = null  # Stores the current subscene instance

var scenes = {
    "combat": preload("res://scenes/combat.tscn"),
    "menu": preload("res://scenes/menu.tscn"),
}

func _ready() -> void:
    change_scene("menu")

    
func change_scene(scene_name: String):
    if not scenes.has(scene_name):
        print("Trying to switch to an invalid scene")
        return

    if current_scene:
        current_scene.queue_free()

    var scene = scenes[scene_name].instantiate()

    # If the scene wants to channge, we listen for this event on each one
    # Note: The signal needs to come from the root node of the scene
    if scene.has_signal("scene_change"):
        scene.connect("scene_change", Callable(self, "change_scene"))
    add_child(scene)
    current_scene = scene
