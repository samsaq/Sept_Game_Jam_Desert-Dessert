class_name game_root
extends Node

## Main Game Entry Point
# Scoped for setting up world layers, and high level systems coordination
# eg: always-on systems, level loading, etc
# currently just loads test assets, FUTURE: main menu should be added in here at some point (as a sub-scene)

const Demo_Level : String = "uid://bxrlrwbfm120b"
const Player_Scene : String = "uid://bgfb2j7huog0m"

var player : Player = null
var current_level : BaseLevel = null

# game world root nodes
@onready var entity_root: Node2D = $World/EntityRoot
@onready var effect_root: Node2D = $World/EffectRoot
@onready var level_root: Node2D = $World/LevelRoot

# UI root nodes
@onready var hud_root: Control = $HudLayer/HudRoot
@onready var pause_root: Control = $PauseLayer/PauseRoot
@onready var transition_root: Control = $TransitionLayer/TransitionRoot
@onready var debug_root: Control = $DebugRoot/DebugRoot

# propogates quit notifications through the whole tree
func quit_game() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_player()

	load_level(Demo_Level)

func _input(event: InputEvent) -> void:
	# debug mode only
	if not OS.is_debug_build():
		return

	if event.is_action_pressed(&"debug_quit"):
		quit_game()

## Loads a level scene that must extend BaseLevel
func load_level(level_scene : String) -> void:
	# Make sure this is called during idle time
	_perform_level_load.call_deferred(level_scene)


func _perform_level_load(level_scene_uid : String) -> void:
	if is_instance_valid(current_level):
		current_level.queue_free()
		current_level = null
		# Wait to allow the queued deletion to process so it is out of the scene tree
		await get_tree().process_frame


	var new_level_packed : PackedScene = (
			ResourceLoader.load(level_scene_uid, "PackedScene") as PackedScene
	)

	if new_level_packed == null:
		push_error("Could not load level as a packed scene: " + level_scene_uid)
		return

	var new_level : Node = new_level_packed.instantiate()

	if not new_level:
		push_error("Could not instantiate new level " + level_scene_uid)
		return

	if new_level is not BaseLevel:
		new_level.free()  # Level must be freed to avoid unreferenced orphan nodes
		push_error("Loaded level is not of type BaseLevel " + level_scene_uid)
		return
	# FUTURE (main menu): Should have a fall back scene

	current_level = new_level as BaseLevel

	level_root.add_child(current_level)

	_place_player_at_level_spawn()


## Instantiates the player and adds it to the entity layer
func _init_player() -> void:
	var player_scene : PackedScene = ResourceLoader.load(Player_Scene) as PackedScene
	
	if player_scene == null:
		push_error("Could not load player scene: " + Player_Scene)
		return

	var player_instance : Node = player_scene.instantiate()
	if not player_instance:
		push_error("Could not instantiate player scene " + Player_Scene)
		return
		
	if player_instance is not Player:
		player_instance.free() # Node must be freed to avoid unreferenced orphan nodes
		push_error("Loaded player scene is not of type Player " + Player_Scene)
		return

	player = player_instance as Player

	entity_root.add_child(player)


## Finds the default spawn location in currently loaded level, and places
##  the Player at that position.
func _place_player_at_level_spawn() -> void:
	if player == null:
		push_error("Cannot place player in level because it is null")
		return
	if current_level == null:
		push_error("Cannot place player into level because level is null")
		return

	player.global_position = current_level.getDefaultPlayerSpawn()

func _init_systems() -> void:
	pass # FUTURE (systems): Will be called to set up high level systems
