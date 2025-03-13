extends Node2D

var direction: Vector2
var speed: float = 500

var gravity_force: float = -0.8
var life_timer: float = 0.0
var life_time_after_bounce: float = 0.6

var impact_color: Color = Color("ff0000")  # Rojo inicial
var transition_color: Color = Color("ff8400")  # Naranja intermedio
var first_impact: Color = Color.YELLOW
var final_color: Color = Color.DIM_GRAY  # Gris final
var initial_speed: float = speed

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var bullet_ray: Sprite2D = $BulletRay

@onready var impact_light_1: Sprite2D = $impact_light_4
@onready var impact_light_2: Sprite2D = $impact_light_5
@onready var impact_light_3: Sprite2D = $impact_light_6

var x: float = 0.233
var y: float = 0.023 

func _ready() -> void:
	# Ocultar luces de impacto al inicio
	impact_light_1.visible = false
	impact_light_2.visible = false
	impact_light_3.visible = false

	bullet_ray.visible = false

func activate(direction: Vector2, speed: float, position: Vector2, rotation: float, attack: Attack, body: Node = null) -> void:
	self.position = position
	self.direction = direction
	self.speed = speed + randf_range(0, 200)
	self.initial_speed = self.speed  # Guardar velocidad inicial para la interpolación de color
	self.rotation = rotation
	randomize_direction()
	change_color()

	# Hacer visible el bullet_ray y establecer posición relativa inicial
	bullet_ray.visible = true
	bullet_ray.position = Vector2(0, 0)  # Centrado respecto a la bala, ajusta si necesitas desplazarlo

	# Hacer visibles las luces de impacto y reproducir animación
	impact_light_1.visible = true
	impact_light_2.visible = true
	impact_light_3.visible = true

	animation_player = $AnimationPlayer
	var animations = ["impact_light_1", "impact_light_2", "impact_light_3"]
	var selected_animation = animations[randi() % animations.size()]
	animation_player.play(selected_animation)

	# Aplicar daño si hay un cuerpo válido
	if body and body.has_method("apply_damage"):
		body.apply_damage(attack)

func randomize_direction() -> void:
	var angle = randf_range(-PI / 3.6, PI / 3.6)
	direction = direction.rotated(angle)
	rotation = direction.angle()

func change_color() -> void:
	sprite_2d = $Sprite2D
	bullet_ray = $BulletRay
	impact_light_1 = $impact_light_4
	impact_light_2 = $impact_light_5
	impact_light_3 = $impact_light_6
	
	sprite_2d.modulate = impact_color
	#bullet_ray.modulate = impact_color

	impact_light_1.modulate = first_impact
	impact_light_2.modulate = first_impact
	impact_light_3.modulate = first_impact

func _physics_process(delta: float) -> void:
	sprite_2d = $Sprite2D
	bullet_ray = $BulletRay

	# Movimiento de la bala (arrastrará a bullet_ray automáticamente)
	var movement = direction * speed * delta
	position += movement

	# Aplicar gravedad aleatoria
	gravity_force = randf_range(-0.8, -4.8)
	if direction.y < 0:
		direction.y += gravity_force * delta
	else:
		direction.y -= gravity_force * delta

	# Reducir velocidad gradualmente
	speed *= randf_range(0.75, 0.95)
	life_timer += delta

	# Interpolación de color basada en la velocidad
	var t: float = speed / initial_speed
	var color: Color
	if t > 0.4:
		color = impact_color.lerp(transition_color, (1 - (t - 0.4) * 1))
	else:
		color = transition_color.lerp(final_color, (1 - t * 33))

	# Aplicar el color interpolado a todos los elementos
	sprite_2d.modulate = color
	bullet_ray.modulate = color
	impact_light_1.modulate = color
	impact_light_2.modulate = color
	impact_light_3.modulate = color

	# Ajustar escala del bullet_ray para efecto visual
	#bullet_ray.scale = Vector2(x, y)
	#x += 0.024  
	#y = 0.023  

	# Eliminar la bala cuando se acabe su tiempo de vida
	if life_timer >= life_time_after_bounce:
		queue_free()
