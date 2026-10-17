extends Node

enum Powerup {FASTER_MOVEMENT, BETTER_OIL, STUDY_WATERS, STUDY_SHIPS}

## Current level number
var level_num: int = 1
## Active powerups. Stored as a dictionary, since Godot doesn't have sets.
var powerups: Dictionary[Powerup, bool] = {}

## Lighthouse node
var lighthouse: Lighthouse
