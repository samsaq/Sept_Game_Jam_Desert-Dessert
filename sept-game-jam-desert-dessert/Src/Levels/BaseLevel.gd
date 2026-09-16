@abstract
class_name BaseLevel
extends Node2D
## Abstract class for levels, used by the Game_Root.gd to define the form of concrete levels
## Mostly for stuff like player spawn location, etc, so that the player and levels can be kept seperate from the GameRoot

# defines where the player should start the level
@abstract func getDefaultPlayerSpawn() -> Vector2
