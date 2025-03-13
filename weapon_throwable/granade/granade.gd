extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var atack_area: CollisionShape2D = $CollisionShape2D

@onready var explosion_1: Sprite2D = $explosion_1
@onready var explosion_2: Sprite2D = $explosion_2
@onready var explosion_3: Sprite2D = $explosion_3


var speed: float = 100
var direction: Vector2
var attack: Attack
var distance: float = 600
var last_position: Vector2
var exploto: bool = false
var start_timer: bool = true
var rotation_speed: float = 5.0 
var rotation_active: bool = true
var dmg_area: int = 50


func _ready() -> void:
	explosion_1.visible = false
	explosion_2.visible = false
	explosion_3.visible = false
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
				timer.start(0.5)
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
		body.apply_damage(attack)

func _on_timer_timeout() -> void:
	animation_player = $AnimationPlayer
	animation_player.play("explosion_light_1")
	if exploto: 
		call_deferred("queue_free")

	else:
		collision_mask = 65280
		exploto = true
		sprite_2d.queue_free()
		timer.start(0.50)
		

func damage_area(new_area: int) -> void:
		dmg_area= new_area

func stop_weapon():
	timer.stop()
