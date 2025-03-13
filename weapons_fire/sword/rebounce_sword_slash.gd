extends Node2D

var direction: Vector2
var speed: float = 500

var gravity_force: float = -0.8
var life_timer: float = 0.0
var life_time_after_bounce: float = 0.6

var impact_color: Color = Color("ff0000")
var transition_color: Color = Color("ff8400")
var final_color: Color = Color.DIM_GRAY
var initial_speed: float = speed

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sprite_2d_2: Sprite2D = $Sprite2D2

var x = 0.233
var y = 0.023
var pos_x = -5.531

func activate(direction: Vector2, speed: float, position: Vector2, rotation: float, attack: Attack, body: Node = null) -> void:
	self.position = position
	self.direction = direction
	self.speed = speed + randf_range(0, 200)
	self.rotation = rotation
	randomize_direction()
	change_color()

	if body and body.has_method("apply_damage"):
		body.apply_damage(attack)

func randomize_direction() -> void:
	var angle = randf_range(-PI / 3.6, PI / 3.6)
	direction = direction.rotated(angle)
	rotation = direction.angle()

func change_color() -> void:
	sprite_2d = $Sprite2D
	sprite_2d_2 = $Sprite2D2
	#sprite_2d_2.transform.scaled(Vector2(0.1 , 0.1))
	
	sprite_2d.modulate = impact_color
	sprite_2d_2.modulate = impact_color  # Usamos modulate en lugar de color

func _physics_process(delta: float) -> void:
	sprite_2d = $Sprite2D
	sprite_2d_2 = $Sprite2D2

	var movement = direction * speed * delta
	position += movement

	gravity_force = randf_range(-0.8, -4.8)
	if direction.y < 0:
		direction.y += gravity_force * delta
	else:
		direction.y -= gravity_force * delta

	speed *= randf_range(0.75, 0.95)
	life_timer += delta

	var t: float = speed / initial_speed
	var color: Color
	if t > 0.4:
		color = impact_color.lerp(transition_color, (1 - (t - 0.4) * 1))
	else:
		color = transition_color.lerp(final_color, (1 - t * 33))

	sprite_2d.modulate = color
	sprite_2d_2.modulate = color  # Aplicamos el mismo color

	sprite_2d_2.scale = Vector2(x, y) 
	x += 0.024
	sprite_2d_2.position = Vector2(pos_x, 0.023)
	pos_x -= 0.745
	
	# Simulamos la disminución de energía con opacidad
	sprite_2d_2.modulate.a = max(0, sprite_2d_2.modulate.a - delta * 2)

	if life_timer >= life_time_after_bounce:
		queue_free()
