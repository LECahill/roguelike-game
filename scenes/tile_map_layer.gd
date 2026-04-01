extends TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DungeonManager.generate_dungeon()
	for r in range(DungeonManager.grid.size()):
		var row = DungeonManager.grid[r]
		for c in range(row.size()):
			if row[c] == 1:
				set_cell(Vector2i(c, r), 0, Vector2i(0,3))
			else:
				set_cell(Vector2i(c, r), 0, Vector2i(0,0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
