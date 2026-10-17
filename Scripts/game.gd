extends Node2D

## Minimum distance squared between two rocks.
const MIN_ROCK_DISTANCE_SQUARED: int = 100 * 100
## Minimum distance the NESW rocks should be out from center.
const MIN_HARDCODE_OUT: int = 150
## Maximum distance the NESW rocks should be out from center.
const MAX_HARDCODE_OUT: int = 300
## Minimum distance the random rocks should be out from center.
const MIN_RANDOM_OUT: int = 125
## Maximum distance the random rocks should be out from center.
const MAX_RANDOM_OUT: int = 330
## Maximum number of attempts to place a rock
const MAX_PLACEMENT_ATTEMPTS: int = 20
## The width and height of each "tile" in the A* search used for building ship paths. Must divide into the viewport height.
const SEARCH_SIZE: int = 8


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.build_game.call_deferred()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


## Build the game state for playing. Only needs to be called once to play.
func build_game():
	self.place_rocks()


## Places rocks in the water.
func place_rocks() -> void:
	var viewport_center: Vector2 = Vector2(get_viewport().size.x / 2, get_viewport().size.y / 2)
	for rock: Rock in self.get_rocks():
		if rock.placement == rock.Placement.RANDOM:
			for i in range(MAX_PLACEMENT_ATTEMPTS):
				var vec = Vector2.RIGHT.rotated(randf_range(0, PI * 2.0)) * randi_range(MIN_RANDOM_OUT, MAX_RANDOM_OUT)
				rock.position = viewport_center + vec
				if not is_nearby_other_rocks(rock):
					break
				if i == MAX_PLACEMENT_ATTEMPTS - 1:
					# Failed to place the rock, just get rid of it.
					rock.queue_free()
		else:
			var mid: float
			match rock.placement:
				rock.Placement.NORTH:
					mid = PI / 2.0
				rock.Placement.SOUTH:
					mid = 3 * PI / 2.0
				rock.Placement.EAST:
					mid = 0
				rock.Placement.WEST:
					mid = PI
			var min_rad: float = mid - PI / 4.0
			var max_rad: float = mid + PI / 4.0
			# 20 total attempts to try to place the rock not nearby another
			for _ignored in range(MAX_PLACEMENT_ATTEMPTS):
				var vec = Vector2.RIGHT.rotated(randf_range(min_rad, max_rad)) * randi_range(MIN_HARDCODE_OUT, MAX_HARDCODE_OUT)
				rock.position = viewport_center + vec
				if not is_nearby_other_rocks(rock):
					break


func is_nearby_other_rocks(rock: Rock):
	for other: Rock in self.get_rocks():
		if rock != other and rock.position.distance_squared_to(other.position) < MIN_ROCK_DISTANCE_SQUARED:
			return true
	return false

func point_in_obstacle(point: Vector2):
	if 320 < point.x and point.x < 400 and 320 < point.y and point.y < 400:
		return true
	for rock in self.get_rocks():
		if rock.get_collision_rect().has_point(point):
			return true
	return false


func get_rocks() -> Array[Rock]:
	var rocks: Array[Rock]
	rocks.assign($Rocks.get_children())
	return rocks


func _on_refuel_button_pressed() -> void:
	$Lighthouse.do_relight()
	$RefuelButton.disabled = true


func _on_lighthouse_relight_done() -> void:
	$RefuelButton.disabled = false
