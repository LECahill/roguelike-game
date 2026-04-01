extends Node

var grid = []

func generate_dungeon():
	grid = []
	for r in range(10):
		var row = []
		for c in range(10):
			if r == 0 or r == 9 or c == 0 or c == 9:
				row.append(1)
			else:
				row.append(0)
		grid.append(row)
				
