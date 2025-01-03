extends TileMapLayer

@export var maze_size: int = 30

const NORTH: Vector2i = Vector2i(0, -1)
const EAST: Vector2i = Vector2i(1, 0)
const SOUTH: Vector2i = Vector2i(0, 1)
const WEST: Vector2i = Vector2i(-1, 0)

## In NESW order
const DIRECTIONS: Array = [
    NORTH,
    EAST,
    SOUTH,
    WEST
]

## "Normal" rotation for everything is "North", "Up", "Top of screen", Negative-Y axis
## Think "Rotate to face KEY"
const TILE_TRANSFORMS: Dictionary = {
    NORTH: 0, # No rotation, default orientation
    EAST: TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H, # 90 degrees clockwise
    SOUTH: TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V,   # 180 degrees clockwise
    WEST: TileSetAtlasSource.TRANSFORM_FLIP_V | TileSetAtlasSource.TRANSFORM_TRANSPOSE  # 270 degrees clockwise
}

## Lookup table: maps wall locations (NESW) to (atlas_id, # of clockwise rotations) for appropriate piece
##   Keys are PackedByteArrays, representing [NESW]. 1 == wall. 0 == empty.
var TILE_LOOKUP = {
    hash(PackedByteArray([0, 0, 0, 0])): { "atlas_id": Vector2i(0, 0), "rotation": NORTH },  # Isolated wall (Island)
    hash(PackedByteArray([1, 0, 0, 0])): { "atlas_id": Vector2i(4, 0), "rotation": NORTH },  # Endcap (North)
    hash(PackedByteArray([0, 1, 0, 0])): { "atlas_id": Vector2i(4, 0), "rotation": EAST },   # Endcap (East)
    hash(PackedByteArray([0, 0, 1, 0])): { "atlas_id": Vector2i(4, 0), "rotation": SOUTH },  # Endcap (South)
    hash(PackedByteArray([0, 0, 0, 1])): { "atlas_id": Vector2i(4, 0), "rotation": WEST },   # Endcap (West)
    hash(PackedByteArray([0, 1, 0, 1])): { "atlas_id": Vector2i(1, 0), "rotation": NORTH },  # Horizontal wall (East-West)
    hash(PackedByteArray([1, 0, 1, 0])): { "atlas_id": Vector2i(1, 0), "rotation": EAST },   # Vertical wall (North-South)
    hash(PackedByteArray([1, 1, 0, 0])): { "atlas_id": Vector2i(2, 0), "rotation": NORTH },  # Corner (North and East)
    hash(PackedByteArray([0, 1, 1, 0])): { "atlas_id": Vector2i(2, 0), "rotation": EAST },   # Corner (East and South)
    hash(PackedByteArray([0, 0, 1, 1])): { "atlas_id": Vector2i(2, 0), "rotation": SOUTH },  # Corner (South and West)
    hash(PackedByteArray([1, 0, 0, 1])): { "atlas_id": Vector2i(2, 0), "rotation": WEST },   # Corner (West and North)
    hash(PackedByteArray([1, 1, 0, 1])): { "atlas_id": Vector2i(5, 0), "rotation": NORTH },  # Tee (no South)
    hash(PackedByteArray([1, 1, 1, 0])): { "atlas_id": Vector2i(5, 0), "rotation": EAST },   # Tee (no East)
    hash(PackedByteArray([0, 1, 1, 1])): { "atlas_id": Vector2i(5, 0), "rotation": SOUTH },  # Tee (no North)
    hash(PackedByteArray([1, 0, 1, 1])): { "atlas_id": Vector2i(5, 0), "rotation": WEST },   # Tee (no West)
    hash(PackedByteArray([1, 1, 1, 1])): { "atlas_id": Vector2i(3, 0), "rotation": NORTH }   # Cross intersection
}

var piece_size: int = 3

var pieces: Dictionary = {
    "J": [
        [1, 1, 1],
        [0, 0, 1],
        [1, 0, 0]
    ],
    "L": [
        [1, 0, 0],
        [0, 0, 1],
        [1, 1, 1]
    ],
    "T": [
        [0, 1, 0],
        [1, 1, 1],
        [0, 0, 0]
    ],
    "W": [
        [0, 0, 0],
        [0, 1, 0],
        [1, 1, 1]
    ],
    "I": [
        [0, 0, 0],
        [1, 1, 1],
        [0, 0, 0]
    ],
    "S": [
        [0, 1, 1],
        [1, 1, 0],
        [0, 0, 0]
    ],
    "Z": [
        [0, 0, 0],
        [1, 1, 0],
        [0, 1, 1]
    ],
     "C": [
        [1, 1, 1],
        [1, 0, 0],
        [1, 0, 1]
    ],
    "U": [  # U-shaped path
        [1, 0, 1],
        [1, 1, 1],
        [0, 1, 0]
    ],
    "X": [  # Cross intersection
        [0, 1, 0],
        [1, 1, 1],
        [0, 1, 0]
    ]
}

# Print maze section (or entire maze) to console for debugging
func pretty_print_maze_section(maze: Array, start_x: int = 0, start_y: int = 0, width: int = 0, height: int = 0) -> void:
    # Loop through the specified section of the maze, or the entire maze.
    if not width:
        width = maze.size()
    if not height:
        height = maze[0].size()

    for y in range(start_y, start_y + height):
        var row = ""
        for x in range(start_x, start_x + width):
            row += "#" if maze[x][y] == 1 else " "
        print(row)

func _ready() -> void:
    pass

func generate_navigation_polygon(callback) -> void:
    var region = get_parent()

    var poly = NavigationPolygon.new()
    var height: int = int(maze_size * tile_set.tile_size.x * transform.get_scale().x)
    var width: int = int(maze_size * tile_set.tile_size.y * transform.get_scale().x)

    var bounding_outline = PackedVector2Array([
        Vector2(0, 0),
        Vector2(0, width),
        Vector2(height, width),
        Vector2(height, 0)])

    poly.add_outline(bounding_outline)

    region.navigation_polygon = poly
    region.bake_navigation_polygon()
    region.bake_finished.connect(callback)

## Create and return a new empty "section" of the maze of the given size
#    This array is ready to pass to other functions
func new_maze_section(size: int = maze_size) -> Array:
    var section = []
    section.resize(size)

    for x in range(size):
        section[x] = []
        section[x].resize(size)
        section[x].fill(null)

    return section

## Generate a section of the maze into the provided array
func populate_maze_section(section: Array) -> void:
    var num_chunks = section.size() / piece_size

    var piece_tiles = pieces.values()

    for chunk_x in range(num_chunks):
        for chunk_y in range(num_chunks):
            var random_piece = rotated_piece(piece_tiles.pick_random())
            for piece_x in range(piece_size):
                for piece_y in range(piece_size):
                    var final_x = chunk_x * piece_size + piece_x
                    var final_y = chunk_y * piece_size + piece_y
                    section[final_y][final_x] = random_piece[piece_x][piece_y]

## Scan for and remove cul_de_sacs
func remove_cul_de_sacs(maze: Array) -> void:
    var size_x = maze.size()
    var size_y = maze[0].size()
    var changes = true

    while changes:
        changes = false
        for y in range(size_y):
            for x in range(size_x):
                if maze[x][y] == 0: # Check only floor cells
                    var open_neighbors = count_open_neighbors(maze, x, y)
                    if open_neighbors == 1: # Dead end
                        remove_random_adjacent_wall(maze, x, y)
                        changes = true

## Remove a wall adjacent to (x, y) at random
func remove_random_adjacent_wall(maze: Array, x: int, y: int) -> void:
    var directions = DIRECTIONS.duplicate()
    directions.shuffle()

    var loc: Vector2i = Vector2i(x, y)

    for dir in directions:
        if in_bounds(maze, loc + dir):
            if maze[x + dir[0]][y + dir[1]] == 1:
                maze[x + dir[0]][y + dir[1]] = 0

                return

## Is the target location within maze bounds?
func in_bounds(maze: Array, looking: Vector2i) -> bool:
    return looking.x >= 0 and looking.y >= 0 and looking.x < maze.size() and looking.y < maze[0].size()

## Return neighbors to target location in NESW array
func get_neighbors(maze: Array, x: int, y: int) -> Array:
    var neighbors: Array = [] # NESW
    var location: Vector2i = Vector2i(x, y)

    for dir in DIRECTIONS:
        var looking = location + dir
        if in_bounds(maze, looking):
            neighbors.append(maze[looking.x][looking.y])
        else:
            neighbors.append(0) # outside of maze is empty for now

    return neighbors

## Return sum of arguments
##   => Just used for reduce call below
func sum(accum: int, number: int) -> int:
    return accum + number

## Return mumber of "empty" neighbor tiles (NESW)
func count_open_neighbors(maze: Array, x: int, y: int) -> int:
    var neighbors = get_neighbors(maze, x, y)

    return 4 - neighbors.reduce(sum, 0)

## Return a copy of a piece tile, randomly rotated.
##   Note: A copy just to avoid modifying the original piece
func rotated_piece(piece: Array) -> Array:
    var rotations = randi() % 4 # 0 .. 3

    # Clone the array to avoid modifying the original
    piece = piece.duplicate(true)

    # Rotate by 90 degrees for the appropriate number of times
    for i in range(rotations):
        rotate_90_in_place(piece)

    return piece

## rotate a piece 90 degrees clockwise, in place
func rotate_90_in_place(piece: Array) -> void:
    var size = piece.size()

    # Step 1: Transpose the matrix (swap rows and columns)
    for y in range(size):
        for x in range(y + 1, size):
            var temp = piece[y][x]
            piece[y][x] = piece[x][y]
            piece[x][y] = temp

    # Step 2: Reverse each row
    for y in range(size):
        piece[y].reverse()

## Draw the maze to the TileMapLayer
func render_maze(maze):
    for x in range(maze.size()):
        for y in range(maze[0].size()):

            if maze[x][y] == 1: # Wall
                var neighbors: Array = get_neighbors(maze, x, y)
                # Cast into a PackedByteArray so that hashes are guaranteed to be consistent.
                # I'm not sure if this matters in practice,
                # but ChatGPT was being super uppity about it.
                var tile: Dictionary = TILE_LOOKUP[hash(PackedByteArray(neighbors))]
                var transform_flags = TILE_TRANSFORMS[tile["rotation"]]

                set_cell(Vector2i(x, y), 0, tile["atlas_id"], transform_flags)
            else: # Empty
                set_cell(Vector2i(x, y), 0, Vector2i(1, 1))

const ghost_start_box: Array = [
    [0, 0, 0, 0, 0, 0, 0],
    [0, 1, 1, 0, 1, 1, 0],
    [0, 1, 0, 0, 0, 1, 0],
    [0, 1, 1, 1, 1, 1, 0],
    [0, 0, 0, 0, 0, 0, 0]
]

## Place a ghost start box at the specified location
# FIXME: Make this generic to place any special pieces
func place_ghost_start_box(maze: Array, loc: Vector2i):
    for piece_x in range(ghost_start_box.size()):
        for piece_y in range(ghost_start_box[0].size()):
            var current: Vector2i = Vector2i(piece_y, piece_x) + loc
            maze[current[0]][current[1]] = ghost_start_box[piece_x][piece_y]
