extends Node2D

@export var gravity: float = 1000.0 
@export var initial_velocity: Vector2 = Vector2(50, -100) 
@export var lifetime: float = 0.5 
@export var rest_time: float = 2.0
@export var bounce_factor: float = 0.3
@export var min_bounce_velocity: float = 15.0
@export var bounce_interval: float = 0.2

@export var min_turns: int = 1 
@export var max_turns: int = 4  

var velocity: Vector2
var time_passed: float = 0.0
var bounce_timer: float = 0.0
var rotation_speed: float = 0.0
var is_resting: bool = false

func _ready() -> void:
	velocity = initial_velocity
	bounce_timer = bounce_interval

	var flight_time: float = -initial_velocity.y / gravity
	var turns: float = randf_range(min_turns, max_turns)
	rotation_speed = (turns * 360.0) / flight_time


func _process(delta: float) -> void:
	if is_resting:
		time_passed += delta
		if time_passed >= rest_time:
			queue_free()
		return
	
	velocity.y += gravity * delta
	position += velocity * delta
	rotation_degrees += rotation_speed * delta

	bounce_timer -= delta
	if bounce_timer <= 0:
		_bounce()

	time_passed += delta
	if time_passed >= lifetime and not is_resting and abs(velocity.y) <= min_bounce_velocity:
		_start_resting()

func _bounce() -> void:
	if abs(velocity.y) > min_bounce_velocity:
		velocity.y = -velocity.y * bounce_factor
	else:
		velocity.y = 0
		rotation_speed = 0

	rotation_speed *= 0.9
	bounce_timer = bounce_interval

func _start_resting() -> void:
	velocity = Vector2.ZERO
	rotation_speed = 0.0
	is_resting = true
	time_passed = 0.0
