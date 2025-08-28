class_name CellPlane

var plane : Array[CellRow] = []

func push_back(cell_row : CellRow) -> void:
	plane.push_back(cell_row)
	
func size() -> int:
	return plane.size()
	
func back() -> CellRow:
	return plane.back()
