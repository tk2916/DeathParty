extends Node

enum SCENES {
	Everywhere,
	Nowhere,
	Entrance,
	PartyRoom,
	Library,
	Bathroom,
	Basement,
	Bedroom,
	StorageRoom,
	Exterior,
	Kitchen,
	HourhandHallway,
	ControlRoom,
	GhostHallway,
}

const SCENES_STR : Dictionary[String, SCENES] = {
	"Everywhere" = SCENES.Everywhere,
	"Nowhere" = SCENES.Nowhere,
	"Entrance" = SCENES.Entrance,
	"PartyRoom" = SCENES.PartyRoom,
	"Library" = SCENES.Library,
	"Bathroom" = SCENES.Bathroom,
	"Basement" = SCENES.Basement,
	"Bedroom" = SCENES.Bedroom,
	"Storageroom" = SCENES.StorageRoom,
	"Exterior" = SCENES.Exterior,
	"Kitchen" = SCENES.Kitchen,
	"Hourhand hallway" = SCENES.HourhandHallway,
	"Control room" = SCENES.ControlRoom,
	"Ghost hallway" = SCENES.GhostHallway,
}
##

func get_scene_name(scene_enum : Globals.SCENES) -> String:
	for sc_name : String in Globals.SCENES_STR:
		if Globals.SCENES_STR[sc_name] == scene_enum:
			return sc_name
	return ""

enum SPAWN_OPTIONS {
	ONE,
	TWO,
	THREE,
	FOUR,
}

var player : Player
