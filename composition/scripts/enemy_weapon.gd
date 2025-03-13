extends Node2D
@export var weapon_resorce: weapon_type
@onready var shoot_timer: Timer = $ShootTimer
#@onready var sprite_2d: Sprite2D = $Sprite2D

const BULLET = preload("res://composition/scenes/bullet.tscn")
const RANGE_ATACK_GREEN = preload("res://enemies/range_enemy/range_atack_green.tres")
const RANGE_ATACK_RED = preload("res://enemies/range_enemy/range_atack_red.tres")
const RANGE_ATACK_BLUE = preload("res://enemies/range_enemy/range_atack_blue.tres")
const RANGE_ATACK_YELLOW = preload("res://enemies/range_enemy/range_atack_yellow.tres")

var type: String
var enemys = {}
var charger :int
var shoot_direction = Vector2(1000,1000)
var reloading :bool = false
# Añadimos una constante para el ángulo máximo de desviación (en grados)
const MAX_SPREAD_ANGLE = 0

func _ready() -> void:
	if type == "Green Range Zombie":
		weapon_resorce = RANGE_ATACK_GREEN
	elif type == "Red Range Zombie":
		weapon_resorce = RANGE_ATACK_RED
	elif type == "Blue Range Zombie":
		weapon_resorce = RANGE_ATACK_BLUE
	else:
		weapon_resorce = RANGE_ATACK_YELLOW
		
	shoot_timer.wait_time = weapon_resorce.atack_rate
	charger = weapon_resorce.bullet_capacity

func _process(_delta: float) -> void:
	var closest_enemy_position = null
	var closest_distance_squared = INF
	for enemy in enemys:
		var enemy_position = enemys[enemy].position
		var distance_squared = enemy_position.distance_squared_to(global_position)
		if distance_squared < closest_distance_squared:
			closest_enemy_position = enemy_position
			closest_distance_squared = distance_squared
	if closest_enemy_position:
		shoot_direction = (closest_enemy_position - global_position)


func get_spread_direction(base_direction: Vector2) -> Vector2:
	# Genera un ángulo aleatorio entre -MAX_SPREAD_ANGLE y +MAX_SPREAD_ANGLE
	var random_angle = randf_range(-MAX_SPREAD_ANGLE, MAX_SPREAD_ANGLE)
	# Convierte el ángulo a radianes
	var angle_rad = deg_to_rad(random_angle)
	return base_direction.rotated(angle_rad)

func shoot() -> void:
	var projectile_instance = BULLET.instantiate()
	var root = get_tree().current_scene
	projectile_instance.speed = weapon_resorce.bullet_speed
	projectile_instance.global_position = get_parent().global_position
	
	# Aplicamos la desviación a la dirección del disparo
	var spread_direction = get_spread_direction(shoot_direction.normalized())
	projectile_instance.set_direction(spread_direction)
	
	
	
	
	if get_parent().has_method("damage"):  # Verifica si el nodo padre tiene la propiedad 'damage'
		projectile_instance.damage = weapon_resorce.damage + get_parent().damage
	else:
		projectile_instance.damage = weapon_resorce.damage  # Usa solo el daño del arma si el padre no tiene 'damage'
	# Añadir el proyectil a la escena
	root.call_deferred("add_child", projectile_instance)



func _on_shoot_timer_timeout() -> void:
	if !enemys.is_empty():
		shoot()


func _on_search_enemy_body_entered(body: Node2D) -> void:	
	enemys[body.name] = body

func _on_search_enemy_body_exited(body: Node2D) -> void:
	enemys.erase(body.name)
