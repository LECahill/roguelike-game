extends Node

var grid = []
var rooms = []

# dungeon settings
var grid_width = 40
var grid_height = 40
var padding = 1
var min_room_size = 5
var min_partition_size = 10

#Binsary Space Partitioning Node class
class BSPNode:
	var x1: int
	var y1: int
	var x2: int
	var y2: int
	var left: BSPNode
	var right: BSPNode
	var room: Rect2i

func split_node(node: BSPNode):
	var room_width = node.x2 - node.x1
	var room_height = node.y2 - node.y1
	if room_width <= min_partition_size or room_height <= min_partition_size: #this carves out a room
		var max_w = node.x2 - node.x1 - (padding * 2)
		var max_h = node.y2 - node.y1 - (padding * 2)
		var room_w = randi_range(min_room_size, max(min_room_size, max_w))
		var room_h = randi_range(min_room_size, max(min_room_size, max_h))
		var room_x = randi_range(node.x1 + padding, max(node.x1 + padding, node.x2 - padding - room_w))
		var room_y = randi_range(node.y1 + padding, max(node.y1 + padding, node.y2 - padding - room_h))
		node.room = Rect2i(room_x, room_y, room_w, room_h)
		
		room_w = min(room_w, grid_width - 1 - room_x)
		room_h = min(room_h, grid_height - 1 - room_y)
		
		for y in range(room_y, room_y + room_h):
			for x in range(room_x, room_x + room_w):
				grid[y][x] = 0
		
		#add room to list of rooms for spawning behavior
		rooms.append(node.room)
	else:
		if room_width > room_height: #split along x axis
			var split = randi_range(node.x1 + min_partition_size, node.x2 - min_partition_size)
			var left_node = BSPNode.new()
			var right_node = BSPNode.new()
			
			left_node.x1 = node.x1
			left_node.y1 = node.y1
			left_node.x2 = split
			left_node.y2 = node.y2
			right_node.x1 = split
			right_node.y1 = node.y1
			right_node.x2 = node.x2
			right_node.y2 = node.y2
			
			node.left = left_node
			node.right = right_node
			
			split_node(left_node)
			split_node(right_node)
			
		else: #split along y axis
			var split = randi_range(node.y1 + min_partition_size, node.y2 - min_partition_size)
			var left_node = BSPNode.new()
			var right_node = BSPNode.new()
			
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
			
			split_node(left_node)
			split_node(right_node)

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
	root.x1 = padding
	root.y1 = padding
	root.x2 = grid_width - padding
	root.y2 = grid_height - padding
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
