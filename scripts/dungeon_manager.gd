#dungeon_manager.gd
# this script is responsible for the procedural generation of the dungeon as well as determining 
# the spawn points of the player and enemies

# this script will be autoloaded
extends Node

# grid array is needed for dungeon generation, stores 1's for walls and 0's for floors
# rooms array is needed for spawning behavior, creates a list of rooms
var grid = []
var rooms = []

# dungeon settings
var grid_width = 30
var grid_height = 30
var padding = 1
var min_room_size = 5
var min_partition_size = 10

#Binary Space Partitioning Node class
class BSPNode:
	var x1: int
	var y1: int
	var x2: int
	var y2: int
	var left: BSPNode
	var right: BSPNode
	var room: Rect2i

# creates BSP tree from the root node
func split_node(node: BSPNode):
	var room_width = node.x2 - node.x1
	var room_height = node.y2 - node.y1
	
	# this check to see if the partition is small enough to create the room. (leaf node)
	if room_width <= min_partition_size or room_height <= min_partition_size: #create the room
		# this creates a room
		var max_w = node.x2 - node.x1 - (padding * 2)
		var max_h = node.y2 - node.y1 - (padding * 2)
		var room_w = randi_range(min_room_size, max(min_room_size, max_w))
		var room_h = randi_range(min_room_size, max(min_room_size, max_h))
		var room_x = randi_range(node.x1 + padding, max(node.x1 + padding, node.x2 - padding - room_w))
		var room_y = randi_range(node.y1 + padding, max(node.y1 + padding, node.y2 - padding - room_h))
		node.room = Rect2i(room_x, room_y, room_w, room_h)
		
		room_w = min(room_w, grid_width - 1 - room_x)
		room_h = min(room_h, grid_height - 1 - room_y)
		
		#This carves out the dimensions set for the room
		for y in range(room_y, room_y + room_h):
			for x in range(room_x, room_x + room_w):
				grid[y][x] = 0
		
		#add room to list of rooms for spawning behavior
		rooms.append(node.room)
	else: #if the partition can still be made smaller, continue to split the node
		
		#create two child nodes
		var left_node = BSPNode.new()
		var right_node = BSPNode.new()
		
		if room_width > room_height: #split along x axis since the 
			var split = randi_range(node.x1 + min_partition_size, node.x2 - min_partition_size)
			left_node.x1 = node.x1
			left_node.y1 = node.y1
			left_node.x2 = split
			left_node.y2 = node.y2
			right_node.x1 = split
			right_node.y1 = node.y1
			right_node.x2 = node.x2
			right_node.y2 = node.y2
		else: #split along y axis
			var split = randi_range(node.y1 + min_partition_size, node.y2 - min_partition_size)
			left_node.x1 = node.x1
			left_node.y1 = node.y1
			left_node.x2 = node.x2
			left_node.y2 = split
			right_node.x1 = node.x1
			right_node.y1 = split
			right_node.x2 = node.x2
			right_node.y2 = node.y2
			
		node.left = left_node
		node.right = right_node
		
		#recursive steps
		split_node(left_node)
		split_node(right_node)

		var room_a = get_room(left_node)
		var room_b = get_room(right_node)
		var center_a = Vector2i(room_a.position.x + room_a.size.x / 2, room_a.position.y + room_a.size.y / 2)
		var center_b = Vector2i(room_b.position.x + room_b.size.x / 2, room_b.position.y + room_b.size.y / 2)
		carve_corridor(center_a, center_b)
			
func get_room(node: BSPNode) -> Rect2i:
	if node.room.size != Vector2i.ZERO:
		return node.room
	return get_room(node.left) # just need any room from subtree, left or right doesnt matter

func carve_corridor(a: Vector2i, b: Vector2i):
	# horizontal
	var x_start = min(a.x, b.x)
	var x_end = max(a.x, b.x)
	for x in range(x_start, x_end + 1):
		if a.y > 0 and a.y < grid_height - 1 and x > 0 and x < grid_width - 1:
			grid[a.y][x] = 0
	
	# vertical
	var y_start = min(a.y, b.y)
	var y_end = max(a.y, b.y)
	for y in range(y_start, y_end + 1):
		if y > 0 and y < grid_height - 1 and b.x > 0 and b.x < grid_width - 1:
			grid[y][b.x] = 0

func generate_dungeon():
	#grid creation
	grid = []
	for r in range(grid_height):
		var row = []
		for c in range(grid_width):
			row.append(1)
		grid.append(row)
				
	#create root node
	var root = BSPNode.new()
	root.x1 = 0
	root.y1 = 0
	root.x2 = grid_width - 1
	root.y2 = grid_height - 1
	split_node(root)
	
func get_spawn_point() -> Vector2i:
	var room = rooms[randi() % rooms.size()]
	var x = randi() % room.size.x + room.position.x
	var y = randi() % room.size.y + room.position.y
	var spawn_point = Vector2i(x, y)
	
	#check to make sure nobody is spawning in ontop of eachother
	while not is_valid_spawn(spawn_point):
		room = rooms[randi() % rooms.size()]
		x = randi() % room.size.x + room.position.x
		y = randi() % room.size.y + room.position.y
		spawn_point = Vector2i(x, y)
		
	return spawn_point

#helper function
func is_valid_spawn(point: Vector2i) -> bool:
		if point.x <= 0 or point.x >= grid_width - 1:
			return false
		if point.y <= 0 or point.y >= grid_height - 1:
			return false
		if grid[point.y][point.x] != 0:
			return false
		if TurnManager.is_tile_occupied(point):
			return false
		return true
