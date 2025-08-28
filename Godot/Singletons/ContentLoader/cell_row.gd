class_name CellRow

var row : Array[Cell] = []

func push_back(item : Cell) -> void:
	row.push_back(item)
	
func size() -> int:
	return row.size()
	
func back() -> Cell:
	return row.back()
