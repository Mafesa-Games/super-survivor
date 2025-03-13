extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer
@onready var atack_area: CollisionShape2D = $CollisionShape2D

@onready var fire_12: Sprite2D = $fire_12
@onready var fire_13: Sprite2D = $fire_13
@onready var fire_14: Sprite2D = $fire_14
@onready var fire_15: Sprite2D = $fire_15
@onready var fire_16: Sprite2D = $fire_16
@onready var fire_17: Sprite2D = $fire_17
@onready var fire_18: Sprite2D = $fire_18
@onready var fire_19: Sprite2D = $fire_19

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var speed: float = 100
var direction: Vector2
var attack: Attack
var distance: float = 600
var last_position: Vector2
var exploto: bool = false
var start_timer: bool = true
var rotation_speed: float = 5.0
var rotation_active: bool = true
var dmg_area: int
var enemys : Array = []


func _ready() -> void:
	fire_12.visible = false
	fire_13.visible = false
	fire_14.visible = false
	fire_15.visible = false
	fire_16.visible = false
	fire_17.visible = false
	fire_18.visible = false
	fire_19.visible = false

	last_position = global_position 
	atack_area.shape.radius= dmg_area
	
func _physics_process(delta: float) -> void:
	if !exploto:
		var travel_distance = global_position.distance_to(last_position)
		last_position = global_position
		distance -= travel_distance
		if distance <= 0:
			speed = speed / 20
			if start_timer:
				timer.start(0.05)
				start_timer = false

	var movement = direction * speed * delta
	position += movement

	if speed < 1:
		rotation_active = false

	if rotation_active:
		var rotation_amount = rotation_speed * delta
		sprite_2d.rotation += rotation_amount

func _on_body_entered(body: Node2D) -> void:
	if body and body.has_method("apply_damage"):
		enemys.append(body)
		body.apply_damage(attack)

func _on_body_exited(body: Node2D) -> void:
	enemys.erase(body)
	
	
func _on_timer_timeout() -> void:
	if exploto: 
		call_deferred("queue_free")
	else:
		animation_player = $AnimationPlayer
		animation_player.play("fire_explosion")
		collision_mask = 65280
		exploto = true
		sprite_2d.queue_free()
		#point_light_2d.queue_free()
		timer.start(3.50)


func _on_damage_timer_timeout() -> void:
	for e in enemys:
		if e and e.has_method("apply_damage"):
			e.apply_damage(attack)
			
func damage_area(new_area: int) -> void:
		dmg_area= new_area
