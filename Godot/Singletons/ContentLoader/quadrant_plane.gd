class_name QuadrantPlane

var plane : Array[QuadrantRow] = []

func push_back(quad_row : QuadrantRow) -> void:
	plane.push_back(quad_row)
	
func size() -> int:
	return plane.size()
	
func back() -> QuadrantRow:
	return plane.back()
