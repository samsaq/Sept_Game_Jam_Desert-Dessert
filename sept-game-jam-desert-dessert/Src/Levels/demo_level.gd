class_name DemoLevel
extends BaseLevel


@onready var player_spawn_marker : PlayerSpawn = $Entities/PlayerSpawn

func getDefaultPlayerSpawn() -> Vector2:
	# returns a reference to the player camera, in case it needs to get pulled to look at something level-specific
	# should return the camera to the player before finishing
	# maybe move this into a seperate manager if we start needing more of the player camera:_player_spawn() -> Vector2:
	return player_spawn_marker.global_position
