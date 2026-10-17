class_name Ship extends Area2D

## Distance ahead to look for always dodge obstacles.
const OBSTACLE_SEARCH_DISTANCE: int = 400
## Distance ahead that rocks are counted as being seen.
const ROCK_VIEW_DISTANCE: int = 200
## Speed of the ship in pixels per second.
const SPEED: float = 720.0 / 60.0
## Rotation speed in radians.
const ROTATION_SPEED: float = PI / 32

## Velocity of the ship.
var velocity: Vector2 = Vector2.UP
var crashed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.crashed:
		return
	# Far ahead prediction of collision with objects
	$AlwaysDodgeRay.target_position = self.velocity.normalized() * OBSTACLE_SEARCH_DISTANCE
	$RockRay.target_position = self.velocity.normalized() * ROCK_VIEW_DISTANCE
	var collide_target: CollisionObject2D = get_collide_target()
	if collide_target != null:
		# Rotate both directions, "move forward", and see which is farther from the obstacle center.
		var collision: Vector2 = collide_target.position
		var new_velocity_a: Vector2 = velocity.rotated(ROTATION_SPEED * delta)
		var new_velocity_b: Vector2 = velocity.rotated(ROTATION_SPEED * delta)
		
		var new_pos_a: Vector2 = self.position + new_velocity_a
		var new_pos_b: Vector2 = self.position + new_velocity_b
		if new_pos_a.distance_squared_to(collision) < new_pos_b.distance_squared_to(collision):
			self.velocity = new_velocity_a
		else:
			self.velocity = new_velocity_b
	
	# Move based on velocity
	self.position += self.velocity * delta
	
	# Check if our position (rather than our entire collision area to be nice and to make ray code easier) is in the obstacle
	for area: Area2D in self.get_overlapping_areas():
		var collision: CollisionShape2D = self.get_collision_of_area(area)
		if collision.shape.get_rect().has_point(self.position):
			self.crashed = true

## Get the nearest target that the ship can collide with.
func get_collide_target() -> CollisionObject2D:
	var always_dodge_target = $AlwaysDodgeRay.get_collider()
	var rock_target = $RockRay.get_collider()
	if rock_target != null:
		var rock: Rock = rock_target as Rock
		if not rock.in_light:
			rock_target = null
	if always_dodge_target != null and rock_target != null:
		if self.position.distance_squared_to($AlwaysDodgeRay.get_collision_point()) < self.position.distance_squared_to($RockRay.get_collision_point()):
			return always_dodge_target as CollisionObject2D
		else:
			return rock_target as CollisionObject2D
	elif always_dodge_target != null:
		return always_dodge_target as CollisionObject2D
	elif rock_target != null:
		return rock_target as Rock
	else:
		return null

## Get collision for an area. Area must use exactly one CollisionShape2D
func get_collision_of_area(area: Area2D) -> CollisionShape2D:
	for child in area.get_children():
		if child is CollisionShape2D:
			return child
	return null  # Unreachable if all areas uphold the doc mentioned above


func get_speed() -> float:
	return SPEED
