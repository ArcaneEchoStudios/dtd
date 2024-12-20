extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    randomize()

    var maze: TileMapLayer = get_node("Maze")
    var player: CharacterBody2D = get_node("Player")

    var section = maze.new_maze_section()
    var center: Vector2i = Vector2i(section.size() / 2, section[0].size() / 2)

    maze.populate_maze_section(section)
    maze.remove_cul_de_sacs(section)

    maze.place_ghost_start_box(section, center - Vector2i(4, 3))

    # DEBUG
    maze.pretty_print_maze_section(section)

    maze.render_maze(section)

    var tile_size: Vector2i = maze.tile_set.tile_size
    var tilemap_scale: Vector2 = maze.transform.get_scale()

    print("Positioning player at ({0}, {1})".format([center[0], center[1]]))
    position_player_at(
        player,
        center[0] * tile_size[0] * tilemap_scale[0] - 32,
        center[1] * tile_size[1] * tilemap_scale[1] - 32)

func position_player_at(player, x, y):
    var player_position = Vector2(x, y)

    var camera = player.get_node("Camera2D")

    # Move the player
    player.global_position = player_position

    # Don't smoothly slide camera to new location
    camera.reset_smoothing()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
