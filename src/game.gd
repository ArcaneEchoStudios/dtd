extends Node2D

var current_scene: Node = null  # Stores the current subscene instance
var fade: ColorRect = null

# This is called when the scene starts
func _ready() -> void:   

    var viewport_size = get_viewport().size
    fade = ColorRect.new()
    fade.color = Color(0,0,0,1)
    fade.set_script(load("res://src/ui/fade.gd"))
    fade.size = viewport_size
    fade.z_index = 100
    add_child(fade) 

    await get_tree().create_timer(1.0).timeout

    load_subscene("res://scenes/combat.tscn")
    fade.fade_out()  
    # load_subscene_with_transition("res://scenes/combat.tscn")


func load_subscene_with_transition(scene_path: String):
    fade.fade_in()  
    load_subscene(scene_path)  # Load the new scene
    fade.fade_out()  

    
func load_subscene(scene_path: String):
    if current_scene:
        current_scene.queue_free()
    var scene = load(scene_path).instantiate()
    add_child(scene)
    current_scene = scene
