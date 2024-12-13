extends TileMapLayer

@export var maze_width: int = 90
@export var maze_height: int = 90

const DIRECTIONS: Array = [
	Vector2i(0, -1), # North
	Vector2i(1, 0),  # East
	Vector2i(0, 1),  # South
	Vector2i(-1, 0)  # West
]

# Lookup table: maps hashed PackedByteArray (NESW) to (atlas_id, # of clockwise rotations)
var TILE_LOOKUP = {
	hash(PackedByteArray([0, 0, 0, 0])): { "id": Vector2i(0, 0), "rotation": Vector2i(0, -1) },  # Isolated wall (Island)
	hash(PackedByteArray([0, 1, 0, 1])): { "id": Vector2i(1, 0), "rotation": Vector2i(0, -1) },  # Horizontal wall (East-West)
	hash(PackedByteArray([1, 0, 1, 0])): { "id": Vector2i(1, 0), "rotation": Vector2i(1, 0) },  # Vertical wall (North-South)
	hash(PackedByteArray([1, 1, 0, 0])): { "id": Vector2i(2, 0), "rotation": Vector2i(0, -1) },  # Outer corner (North and East)
	hash(PackedByteArray([0, 1, 1, 0])): { "id": Vector2i(2, 0), "rotation": Vector2i(1, 0) },  # Outer corner (East and South)
	hash(PackedByteArray([0, 0, 1, 1])): { "id": Vector2i(2, 0), "rotation": Vector2i(0, 1) },  # Outer corner (South and West)
	hash(PackedByteArray([1, 0, 0, 1])): { "id": Vector2i(2, 0), "rotation": Vector2i(-1, 0) },  # Outer corner (West and North)
	hash(PackedByteArray([1, 1, 1, 1])): { "id": Vector2i(3, 0), "rotation": Vector2i(0, -1) },  # Cross intersection
	hash(PackedByteArray([1, 0, 0, 0])): { "id": Vector2i(4, 0), "rotation": Vector2i(0, -1) },  # Endcap (North)
	hash(PackedByteArray([0, 1, 0, 0])): { "id": Vector2i(4, 0), "rotation": Vector2i(1, 0) },  # Endcap (East)
	hash(PackedByteArray([0, 0, 1, 0])): { "id": Vector2i(4, 0), "rotation": Vector2i(0, 1) },  # Endcap (South)
	hash(PackedByteArray([0, 0, 0, 1])): { "id": Vector2i(4, 0), "rotation": Vector2i(-1, 0) },  # Endcap (West)
	hash(PackedByteArray([1, 1, 0, 1])): { "id": Vector2i(5, 0), "rotation": Vector2i(0, -1) },  # T-junction (no South)
	hash(PackedByteArray([1, 1, 1, 0])): { "id": Vector2i(5, 0), "rotation": Vector2i(1, 0) },  # T-junction (no East)
	hash(PackedByteArray([0, 1, 1, 1])): { "id": Vector2i(5, 0), "rotation": Vector2i(0, 1) },  # T-junction (no North)
	hash(PackedByteArray([1, 0, 1, 1])): { "id": Vector2i(5, 0), "rotation": Vector2i(-1, 0) }   # T-junction (no West)
}

var tile_transforms: Dictionary = {
	Vector2i(0, -1): 0, # No rotation, default orientation
	Vector2i(1, 0): TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H, # 90 degrees clockwise
	Vector2i(0, 1): TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V, # 180 degrees clockwise
	Vector2i(-1, 0): TileSetAtlasSource.TRANSFORM_FLIP_V | TileSetAtlasSource.TRANSFORM_TRANSPOSE # 270 degrees clockwise
}

var piece_size: int = 3

var tiles: Dictionary = {
	"L": [
		[1, 1, 1],
		[0, 0, 1],
		[0, 0, 0]
	],
	"J": [
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
	"Q": [
		[1, 1, 0],
		[1, 1, 0],
		[0, 0, 0]
	]
}

func pretty_print_maze_section(maze: Array, start_x: int = 0, start_y: int = 0, width: int = 0, height: int = 0) -> void:
	# Loop through the specified section of the maze
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
	randomize()
	var maze: Array = []

	var coarse_grid: Array = generate_coarse_grid()
	expand_into_maze(coarse_grid, maze)
	remove_cul_de_sacs(maze)

	# DEBUG
	pretty_print_maze_section(maze)

	render_maze(maze)

func generate_coarse_grid() -> Array:
	## To disable subsequent warning:
	# Project => Project Settings -> [Filter: Integer Division] => Ignore
	var coarse_grid_width = maze_width / piece_size
	var coarse_grid_height = maze_height / piece_size

	# Initialize coarse_grid with nulls
	var coarse_grid: Array = []
	coarse_grid.resize(coarse_grid_width)

	var row_template: Array = []
	row_template.resize(coarse_grid_height)
	row_template.fill(null)

	for x in range(coarse_grid_width):
		var row = row_template.duplicate()
		coarse_grid[x] = row

	var piece_keys = tiles.keys()
	for x in range(coarse_grid_width):
		for y in range(coarse_grid_height):
			var random_piece = piece_keys.pick_random()
			coarse_grid[x][y] = random_piece
	
	return coarse_grid

func is_within_bounds(grid: Array, pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < grid.size() and pos.y >= 0 and pos.y < grid[0].size()

# Maze should be an empty array at this point, will be modified in place
func expand_into_maze(coarse_grid, maze) -> void:
	for x in range(maze_width):
		maze.append([])
		for y in range(maze_height):
			maze[x].append(0)

	# Place each piece from the coarse grid onto the final grid
	for grid_x in range(coarse_grid.size()):
		for grid_y in range(coarse_grid[0].size()):
			var piece = tiles[coarse_grid[grid_x][grid_y]].duplicate(true)
			piece = rotate_piece(piece)

			pretty_print_maze_section(piece)

			for piece_x in range(piece.size()):
				for piece_y in range(piece[0].size()):
					var final_x = grid_x * piece_size + piece_x
					var final_y = grid_y * piece_size + piece_y
					maze[final_x][final_y] = piece[piece_x][piece_y]

# FIXME: Doesn't seem to, you know...work.
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

func remove_random_adjacent_wall(maze: Array, x: int, y: int) -> void:
	var directions = DIRECTIONS.duplicate()
	directions.shuffle()

	for dir in directions:
		var nx = x + dir[0]
		var ny = y + dir[1]
		
		if nx >= 0 and ny >= 0 and nx < maze.size() and ny < maze[0].size():
			if maze[nx][ny] == 1:
				maze[nx][ny] = 0

				return

func in_bounds(maze: Array, looking: Vector2i) -> bool:
	return looking.x >= 0 and looking.y >= 0 and looking.x < maze.size() and looking.y < maze[0].size()

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

func sum(accum: int, number: int) -> int:
	return accum + number

func count_open_neighbors(maze: Array, x: int, y: int) -> int:
	var neighbors = get_neighbors(maze, x, y)

	return 4 - neighbors.reduce(sum, 0)

func rotate_piece(piece: Array) -> Array:
	var rotations = randi() % 4 # 0 .. 3

	# Clone the array to avoid modifying the original
	var rotated_piece: Array = piece.duplicate(true)

	# Rotate by 90 degrees for the appropriate number of times
	for i in range(rotations):
		rotate_90_in_place(rotated_piece)

	return rotated_piece

func rotate_90_in_place(piece: Array) -> void:
	var size = piece.size()
	
	# Step 1: Transpose the matrix (swap rows and columns)
	for y in range(size):
		for x in range(y + 1, size):  # Only process upper triangle
			var temp = piece[y][x]
			piece[y][x] = piece[x][y]
			piece[x][y] = temp
	
	# Step 2: Reverse each row
	for y in range(size):
		piece[y].reverse()

func render_maze(maze):
	for x in range(maze.size()):
		for y in range(maze[0].size()):

			if maze[x][y] == 1:

				var neighbors: Array = get_neighbors(maze, x, y)
				# Cast into a PackedByteArray so that hashes are guaranteed to be consistent.
				# I'm not sure if this matters, but ChatGPT was being super uppity about it.
				var tile: Dictionary = TILE_LOOKUP[hash(PackedByteArray(neighbors))]
				var transform_flags = tile_transforms[tile["rotation"]]

				set_cell(Vector2i(x, y), 0, tile["id"], transform_flags)
			else:
				pass #
