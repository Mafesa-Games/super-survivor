extends Area2D

var last_position: Vector2
var direction: Vector2

var max_bounces: int = 3
var bounces: int = 1
var hit_enemies: Array = []
var bounce_range: float = 2000.0

var attack: Attack
var attack_rate: float = 1
var speed: float = 200
var range: float = 500

var critical_chance: float = 5


const ORB = preload("res://weapon_throwable/rebound_orb/orb.tscn")
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer

var impact_colors: Array = [
	Color("04ffff"),
	Color("04ffff"),
	Color("04ffff") 
]
var current_color_index: int = 0
var last_hit_body: Node2D = null

var color_transition_speed: float = 2.3
var current_color: Color = Color("00ff04")


func _ready() -> void:
	last_position = global_position
	timer = %Timer

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	var camera = get_viewport().get_camera_2d()
	if camera:
		var cam_center = camera.get_screen_center_position()
		var cam_size = camera.get_viewport_rect().size

		cam_size.x /= camera.zoom.x
		cam_size.y /= camera.zoom.y
		
		var min_x = cam_center.x - cam_size.x / 2
		var max_x = cam_center.x + cam_size.x / 2
		var min_y = cam_center.y - cam_size.y / 2
		var max_y = cam_center.y + cam_size.y / 2
		
		if global_position.x <= min_x or global_position.x >= max_x:
			direction.x *= -1  
		
		if global_position.y <= min_y or global_position.y >= max_y:
			direction.y *= -1  

	rotation = direction.angle()


func _on_body_entered(body: Node2D) -> void:
	if body == last_hit_body:
		return
	
	if body and body.has_method("apply_damage") and body not in hit_enemies:
		body.apply_damage(attack)
		hit_enemies.append(body)


	var random_angle = randf_range(-PI / 4, PI / 4)  # -45° and 45°
	direction = direction.rotated(random_angle).normalized()

func _on_timer_timeout() -> void:
	queue_free()

func activate(direction: Vector2, position: Vector2, speed: float, attack: Attack, max_time:int) -> void:
	self.global_position = position
	self.direction = direction
	self.speed = speed
	self.attack = attack
	%Timer.start(max_time)
