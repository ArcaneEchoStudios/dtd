extends Node2D

@onready var runner: CharacterBody2D = get_node("Runner")
@onready var terrain: TileMapLayer = get_node("Level/Foreground")

const ZombiScene = preload("res://scenes/zombi-runner/Scenes/zombi.tscn")

var zombis: Array = []
var zombi_portals: Array = []

func _ready() -> void:
    zombi_portals = find_portal_tiles()
    spawn_zombie()

func _process(_delta: float) -> void:
    pass

func find_portal_tiles() -> Array:
    var portal_tiles = []

    for cell in terrain.get_used_cells():
        var tile_data: TileData = terrain.get_cell_tile_data(cell)
        if tile_data:
            if tile_data.get_custom_data("SpecialZone") == "portal":
                #print(str(cell) + ": " + str(tile_data.get_custom_data("SpecialZone")))
                portal_tiles.append(cell)

    return portal_tiles

func spawn_zombie() -> void:
    var portal = zombi_portals.pick_random()
    var zombi = ZombiScene.instantiate()

    add_child(zombi)
    zombi.position = terrain.map_to_local(portal)

    zombis.append(zombi)

func _on_zombi_spawn_timer_timeout() -> void:
    pass
    #spawn_zombie()
