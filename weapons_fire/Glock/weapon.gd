extends Area2D
@export var weapon_resorce: weapon_type
@onready var timer: Timer = $Timer
@onready var sprite_2d: Sprite2D = $Sprite2D


const BULLET = preload("res://weapon_bullets/bullet.tscn")
const BULLET_SHELL = preload("res://weapons_fire/Glock/bullet_shell.tscn")
const WEAPON_FIRE_FLASH = preload("res://weapons_fire/Glock/weapon_fire_flash.tscn")

@export var icon: Texture2D
var damage_done := 0.0

var ticks:= 0
var target_enemy: CharacterBody2D
var enemies: CharacterBody2D
var charger :int
var shoot_direction = Vector2.RIGHT
var reloading :bool = false
var player: CharacterBody2D
const MAX_SPREAD_ANGLE := 3.0 

func _ready() -> void:
	timer.wait_time = weapon_resorce.atack_rate
	icon = weapon_resorce.icon
	charger = weapon_resorce.bullet_capacity
	player = get_parent().get_parent()


func _process(_delta: float) -> void:
	var enemies_in_range = get_overlapping_bodies()
	target_enemy = null
	
	if enemies_in_range.is_empty():
		return
	
	ticks +=1
	if ticks >= 15 || !target_enemy:
		target_enemy = enemies_in_range[0]
		for enemy in enemies_in_range:
			if global_position.distance_to(target_enemy.global_position) > global_position.distance_to(enemy.global_position):
				target_enemy = enemy
		ticks= 0


func get_spread_direction(base_direction: Vector2) -> Vector2:
	var random_angle = randf_range(-MAX_SPREAD_ANGLE, MAX_SPREAD_ANGLE)
	var angle_rad = deg_to_rad(random_angle)
	return base_direction.rotated(angle_rad)

func shoot() -> void:
	var projectile_instance = BULLET.instantiate()
	var bullet_shell = BULLET_SHELL.instantiate()
	var fire_flash = WEAPON_FIRE_FLASH.instantiate()
	
	bullet_shell.global_position = global_position
	shoot_direction = global_position.direction_to(target_enemy.global_position)

	var is_facing_right = shoot_direction.x > 0 
	var shell_velocity_x = randf_range(50, 150) * (-1 if is_facing_right else 1)
	bullet_shell.initial_velocity = Vector2(shell_velocity_x, randf_range(-300, -200))  
	
	var root = get_tree().current_scene
	root.call_deferred("add_child", bullet_shell)
	
	var attack = Attack.new()
	attack.damage = player.damage * weapon_resorce.damage / 100
	attack.critical_chance = player.critical_chance
	attack.critical_multiplier = player.critical_multiplier
	attack.shake = 8
	attack.weapon = self
	
	charger -= 1
	projectile_instance.speed = weapon_resorce.bullet_speed
	projectile_instance.global_position = get_parent().global_position
	
	var spread_direction := get_spread_direction(shoot_direction)
	projectile_instance.set_direction(spread_direction)
	projectile_instance.attack = attack
	projectile_instance.piercing = weapon_resorce.piercing
	root.call_deferred("add_child", projectile_instance)
	
	fire_flash.global_position = global_position
	fire_flash.rotation = spread_direction.angle()
	root.call_deferred("add_child", fire_flash)
	
	if charger == 0:
		timer.wait_time = weapon_resorce.reload_speed
		Events.emit_signal("reload_weapon", weapon_resorce.reload_speed)
		reloading = true

func _on_shoot_timer_timeout() -> void:
	if reloading:
		timer.wait_time = weapon_resorce.atack_rate
		charger = weapon_resorce.bullet_capacity
		reloading = false
	elif target_enemy && !reloading:
		shoot()

func stop_weapon():
	timer.stop()
