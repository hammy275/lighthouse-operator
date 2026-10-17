extends Node

enum Powerup {FASTER_MOVEMENT, BETTER_OIL, STUDY_SHIP_VIEW}
enum Direction {NORTH, EAST, SOUTH, WEST}

## Current level number
var level_num: int = 1
var current_hour: int = 1
## Number of ships that had safe passage.
var score: int = 0
## Active powerups. Stored as a dictionary, since Godot doesn't have sets.
var powerups: Dictionary[Powerup, bool] = {Powerup.FASTER_MOVEMENT: true}

## Lighthouse node
var lighthouse: Lighthouse
