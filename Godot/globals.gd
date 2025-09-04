extends Node

## CHARACTER LOCATIONS
enum CHARACTER_LOCATIONS_ENUM {
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

const CHARACTER_LOCATIONS = [
	"Everywhere",
	"Nowhere",
	"Entrance",
	"PartyRoom",
	"Library",
	"Bathroom",
	"Basement",
	"Bedroom",
	"Storageroom",
	"Exterior",
	"Kitchen",
	"Hourhand hallway",
	"Control room",
	"Ghost hallway",
]
##

##SCENES
enum SCENE_LOCATIONS_ENUM {
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

const SCENE_LOCATIONS = [
	"Entrance",
	"PartyRoom",
	"Library",
	"Bathroom",
	"Basement",
	"Bedroom",
	"Storageroom",
	"Exterior",
	"Kitchen",
	"Hourhand hallway",
	"Control room",
	"Ghost hallway",
]
##

enum SPAWN_OPTIONS {
	ONE,
	TWO,
	THREE,
	FOUR,
}

var player : Player

##FUNCTIONS
func get_scene_location(index : int) -> String:
	return SCENE_LOCATIONS[index]
	
func get_character_location(index : int) -> String:
	return CHARACTER_LOCATIONS[index]
