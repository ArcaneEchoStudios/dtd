extends Node2D

func _ready() -> void:
    randomize()

    ## DEBUG
    #NavigationServer3D.set_debug_enabled(true)

    var maze: TileMapLayer = get_node("MazeNavigaton/Maze")
    var player: CharacterBody2D = get_node("Player")

    var section = maze.new_maze_section()
    var center: Vector2i = Vector2i(section.size() / 2, section[0].size() / 2)

    maze.populate_maze_section(section)
    maze.remove_cul_de_sacs(section)

    maze.place_ghost_start_box(section, center - Vector2i(4, 3))

    ## DEBUG
    #maze.pretty_print_maze_section(section)

    maze.render_maze(section)

    maze.generate_navigation_polygon(on_navigation_ready)

    var tile_size: Vector2i = maze.tile_set.tile_size
    var tilemap_scale: Vector2 = maze.transform.get_scale()

    ## DEBUG
    #print("Positioning player at ({0}, {1})".format([center[0], center[1]]))

    position_player_at(
        player,
        center[0] * tile_size[0] * tilemap_scale[0] - 32,
        center[1] * tile_size[1] * tilemap_scale[1] - 32)

## Drop the player at the specified position
func position_player_at(player, x, y):
    var player_position = Vector2(x, y)

    var camera = player.get_node("Camera2D")

    player.global_position = player_position

    camera.reset_smoothing()

## When navigation is ready, have the waka target the player and drop it in the maze
func on_navigation_ready():
    var waka: CharacterBody2D = get_node("WAKA")
    waka.ghost = get_node("Player")

    waka.global_position = Vector2(128, 128)
