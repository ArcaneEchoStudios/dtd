extends TileMapLayer

@export var maze_width: int = 90
@export var maze_height: int = 90

#FIXME: Make rotation and direction names nicer/clearer.
const DIRECTIONS: Array = [
    Vector2i(0, -1), # North
    Vector2i(1, 0),  # East
    Vector2i(0, 1),  # South
    Vector2i(-1, 0)  # West
]

const TILE_TRANSFORMS: Dictionary = {
    Vector2i(0, -1): 0, # No rotation, default orientation
    Vector2i(1, 0): TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H, # 90 degrees clockwise
    Vector2i(0, 1): TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V,    # 180 degrees clockwise
    Vector2i(-1, 0): TileSetAtlasSource.TRANSFORM_FLIP_V | TileSetAtlasSource.TRANSFORM_TRANSPOSE # 270 degrees clockwise
}

# Lookup table: maps hashed PackedByteArray (NESW) to (atlas_id, # of clockwise rotations)
## Using and naming this like a const, but the `hash` function forces it to be a var
var TILE_LOOKUP = {
    hash(PackedByteArray([0, 0, 0, 0])): { "atlas_id": Vector2i(0, 0), "rotation": Vector2i(0, -1) },  # Isolated wall (Island)
    hash(PackedByteArray([1, 0, 0, 0])): { "atlas_id": Vector2i(4, 0), "rotation": Vector2i(0, -1) },  # Endcap (North)
    hash(PackedByteArray([0, 1, 0, 0])): { "atlas_id": Vector2i(4, 0), "rotation": Vector2i(1, 0) },   # Endcap (East)
    hash(PackedByteArray([0, 0, 1, 0])): { "atlas_id": Vector2i(4, 0), "rotation": Vector2i(0, 1) },   # Endcap (South)
    hash(PackedByteArray([0, 0, 0, 1])): { "atlas_id": Vector2i(4, 0), "rotation": Vector2i(-1, 0) },  # Endcap (West)
    hash(PackedByteArray([0, 1, 0, 1])): { "atlas_id": Vector2i(1, 0), "rotation": Vector2i(0, -1) },  # Horizontal wall (East-West)
    hash(PackedByteArray([1, 0, 1, 0])): { "atlas_id": Vector2i(1, 0), "rotation": Vector2i(1, 0) },   # Vertical wall (North-South)
    hash(PackedByteArray([1, 1, 0, 0])): { "atlas_id": Vector2i(2, 0), "rotation": Vector2i(0, -1) },  # Corner (North and East)
    hash(PackedByteArray([0, 1, 1, 0])): { "atlas_id": Vector2i(2, 0), "rotation": Vector2i(1, 0) },   # Corner (East and South)
    hash(PackedByteArray([0, 0, 1, 1])): { "atlas_id": Vector2i(2, 0), "rotation": Vector2i(0, 1) },   # Corner (South and West)
    hash(PackedByteArray([1, 0, 0, 1])): { "atlas_id": Vector2i(2, 0), "rotation": Vector2i(-1, 0) },  # Corner (West and North)
    hash(PackedByteArray([1, 1, 0, 1])): { "atlas_id": Vector2i(5, 0), "rotation": Vector2i(0, -1) },  # Tee (no South)
    hash(PackedByteArray([1, 1, 1, 0])): { "atlas_id": Vector2i(5, 0), "rotation": Vector2i(1, 0) },   # Tee (no East)
    hash(PackedByteArray([0, 1, 1, 1])): { "atlas_id": Vector2i(5, 0), "rotation": Vector2i(0, 1) },   # Tee (no North)
    hash(PackedByteArray([1, 0, 1, 1])): { "atlas_id": Vector2i(5, 0), "rotation": Vector2i(-1, 0) },   # Tee (no West)
    hash(PackedByteArray([1, 1, 1, 1])): { "atlas_id": Vector2i(3, 0), "rotation": Vector2i(0, -1) }  # Cross intersection
}

var piece_size: int = 3

var pieces: Dictionary = {
    "J": [
        [1, 1, 1],
        [0, 0, 1],
        [0, 0, 0]
    ],
    "L": [
        [0, 0, 0],
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
    "O": [
        [1, 1, 0],
        [1, 1, 0],
        [0, 0, 0]
    ]
}

# Print maze section (or entire maze) to console for debugging
func pretty_print_maze_section(maze: Array, start_x: int = 0, start_y: int = 0, width: int = 0, height: int = 0) -> void:
    # Loop through the specified section of the, or the entire, maze
    if not width:
        width = maze.size()

    if not height:
        height = maze[0].size()

    for y in range(start_y, start_y + height):
        var row = ""
        for x in range(start_x, start_x + width):
            row += "#" if maze[x][y] == 1 else " "
        print(row)

# Godot lifecycle: Maze is generated and rendered to TileMapLayer
func _ready() -> void:
    randomize()
    var maze: Array = []

    var coarse_grid: Array = generate_coarse_grid()
    expand_into_maze(coarse_grid, maze)
    remove_cul_de_sacs(maze)

    # DEBUG
    pretty_print_maze_section(maze)

    render_maze(maze)

# Create a "coarse" grid of the maze from 3x3 "tetris" pieces
func generate_coarse_grid() -> Array:
    ## To disable subsequent warning:
    # Project => Project Settings -> [Filter: Integer Division] => Ignore
    var coarse_grid_width = maze_width / piece_size
    var coarse_grid_height = maze_height / piece_size

    var coarse_grid: Array = []
    coarse_grid.resize(coarse_grid_width)

    var row_template: Array = [null]
    row_template.resize(coarse_grid_height)
    row_template.fill(null)

    for x in range(coarse_grid_width):
        var row = row_template.duplicate()
        coarse_grid[x] = row

    var piece_keys = pieces.keys()
    for x in range(coarse_grid_width):
        for y in range(coarse_grid_height):
            var random_piece = piece_keys.pick_random()
            coarse_grid[x][y] = random_piece

    return coarse_grid

#  Expand the "coarse" grid into final maze
func expand_into_maze(coarse_grid, maze) -> void:
    for x in range(maze_width):
        maze.append([])
        for y in range(maze_height):
            maze[x].append(0)

    # Render each piece from the coarse grid onto the final maze
    # Rotate randomly
    for grid_x in range(coarse_grid.size()):
        for grid_y in range(coarse_grid[0].size()):
            var piece = pieces[coarse_grid[grid_x][grid_y]].duplicate(true)
            piece = rotate_piece(piece)

            for piece_x in range(piece.size()):
                for piece_y in range(piece[0].size()):
                    var final_x = grid_x * piece_size + piece_x
                    var final_y = grid_y * piece_size + piece_y
                    maze[final_x][final_y] = piece[piece_x][piece_y]

# Scan for and remove cul_de_sacs
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

# Remove a wall adjacent to (x, y) at random
func remove_random_adjacent_wall(maze: Array, x: int, y: int) -> void:
    var directions = DIRECTIONS.duplicate()
    directions.shuffle()

    var loc: Vector2i = Vector2i(x, y)

    for dir in directions:
        if in_bounds(maze, loc + dir):
            if maze[x + dir[0]][y + dir[1]] == 1:
                maze[x + dir[0]][y + dir[1]] = 0

                return

# Is the target location within maze bounds?
func in_bounds(maze: Array, looking: Vector2i) -> bool:
    return looking.x >= 0 and looking.y >= 0 and looking.x < maze.size() and looking.y < maze[0].size()

# Return neighbors to target location in NESW array
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

# Return sum of arguments => used for reduce call
func sum(accum: int, number: int) -> int:
    return accum + number

# Return Number of "empty" neighbor tiles (NESW)
func count_open_neighbors(maze: Array, x: int, y: int) -> int:
    var neighbors = get_neighbors(maze, x, y)

    return 4 - neighbors.reduce(sum, 0)

# Rotate a piece, return a copy
func rotate_piece(piece: Array) -> Array:
    var rotations = randi() % 4 # 0 .. 3

    # Clone the array to avoid modifying the original
    var rotated_piece: Array = piece.duplicate(true)

    # Rotate by 90 degrees for the appropriate number of times
    for i in range(rotations):
        rotate_90_in_place(rotated_piece)

    return rotated_piece

# Rotate 90 degrees clockwise, in place
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

# Draw the maze to the TileMapLayer
func render_maze(maze):
    for x in range(maze.size()):
        for y in range(maze[0].size()):

            if maze[x][y] == 1: # Wall
                var neighbors: Array = get_neighbors(maze, x, y)
                # Cast into a PackedByteArray so that hashes are guaranteed to be consistent.
                # I'm not sure if this matters, but ChatGPT was being super uppity about it.
                var tile: Dictionary = TILE_LOOKUP[hash(PackedByteArray(neighbors))]
                var transform_flags = TILE_TRANSFORMS[tile["rotation"]]

                set_cell(Vector2i(x, y), 0, tile["atlas_id"], transform_flags)
            else: # Empty
                set_cell(Vector2i(x, y), 0, Vector2i(1, 1))
