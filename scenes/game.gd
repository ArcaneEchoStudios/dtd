extends Node2D

var current_scene: Node = null

# This dict allows us to reference scenes by name. It does load all of them
# before we need them. If this becomes a performance concern, we'll need to
# figure out how to lazy load them.
var scenes = {
    "clock-combat": preload("res://scenes/clock-combat/combat.tscn"),
    "menu": preload("res://scenes/main-menu/menu.tscn"),
}

# By default, we load the menu scene
func _ready() -> void:
    change_scene("menu")

# This function changes the scene. But the other important thing it does it
# register a listener on the new scene for further scene changes.
func change_scene(scene_name: String):

    # Safety check to try to make sure we are loading a real scene
    if not scenes.has(scene_name):
        print("Trying to switch to an invalid scene")
        return

    # If there's a scene already, we should remove it
    if current_scene:
        current_scene.queue_free()
        
    # Create a new instance of the scene. If/when we get to passing information
    # between scenes, this is likely the place we hook it in.
    var scene = scenes[scene_name].instantiate()

    # If the scene wants to channge, we listen for this event on each one
    # Note: The signal needs to come from the root node of the scene
    if scene.has_signal("scene_change"):
        scene.connect("scene_change", Callable(self, "change_scene"))

    # Add the scene to the node. Fade in and transitions likely start here.
    add_child(scene)
    current_scene = scene
