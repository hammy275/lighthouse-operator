class_name Lighthouse extends Node2D

## Maximum number of stages the light can grow across all gameplay conditions.
var MAX_STAGES: int = 5
## The radius increase per stage. Stage 1 is this radius.
var RADIUS_PER_STAGE: int = 10
## Minimum distance the light can be away from the lighthouse.
var MIN_TRAVEL_RADIUS: int = 100
## Maximum distance the light can be away from the lighthouse.
@onready
var MAX_TRAVEL_RADIUS: int = get_viewport().size.y / 2 - (MAX_STAGES * RADIUS_PER_STAGE)
## Start rotation for the light
var START_ROTATION: float = PI / 2.0
## Time in seconds to go down by a stage (1.0 in radius).
var STAGE_DECREASE_TIME: int = 30

## Turn speed in radians per second.
var turn_speed: float = PI / 8.0
## In/out movement speed in pixels per second.
var inout_speed: float = 0.5

## Current radius the light is at.
var current_radius: float = 4.0
## Current rotation of the light.
var current_rotation: float = START_ROTATION
## Current distance of the light from the lighthouse.
var current_distance: float = MIN_TRAVEL_RADIUS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var circle_shape: CircleShape2D = $Light/LightCircleShape.shape
	circle_shape.radius = RADIUS_PER_STAGE
	self.reset_for_level()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Input handling
	var input_rotate: float = Input.get_axis("move_left", "move_right") * delta * turn_speed
	if input_rotate != 0:
		current_rotation += input_rotate
		self.calc_and_set_pos()
	else:
		var input_inout = Input.get_axis("move_down", "move_up")
		if input_inout != 0:
			current_distance += input_inout * inout_speed
			current_distance = min(max(MIN_TRAVEL_RADIUS, current_distance), MAX_TRAVEL_RADIUS)
			self.calc_and_set_pos()
	
	# Light radius
	current_radius -= delta / STAGE_DECREASE_TIME
	$Light.scale = Vector2(current_radius, current_radius)


## Resets the light for entering a new level
func reset_for_level() -> void:
	if Global.Powerup.BETTER_OIL in Global.powerups:
		self.current_radius = 5.0
	else:
		self.current_radius = 4.0
	self.calc_and_set_pos()

## Calculates and sets the light's position based on its current rotation and distance.
func calc_and_set_pos() -> void:
	var angle: Vector2 = Vector2.RIGHT.rotated(self.current_rotation)
	$Light.position = angle * self.current_distance
	
