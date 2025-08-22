class_name QuadrantRow

var row : Array[Quadrant] = []

func push_back(item : Quadrant) -> void:
	row.push_back(item)
	
func size() -> int:
	return row.size()
	
func back() -> Quadrant:
	return row.back()
