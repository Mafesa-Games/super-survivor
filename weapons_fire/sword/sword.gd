extends Area2D
@export var weapon_resorce: weapon_melee_type
@onready var timer: Timer = $Timer
@onready var sprite_2d: Sprite2D = $Sprite2D

const BULLET = preload("res://weapons_fire/sword/sword_bullet.tscn")

@export var icon: Texture2D
var damage_done := 0.0

var ticks:= 0
var target_enemy: CharacterBody2D
var enemies: CharacterBody2D
var charger: int
var shoot_direction:= Vector2.RIGHT
var reloading:= false
var player: CharacterBody2D

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
		update_sprite_orientation()
		

func shoot() -> void:
	var projectile_instance = BULLET.instantiate()
	var root = get_tree().current_scene
	shoot_direction = global_position.direction_to(target_enemy.global_position)
	
	var attack = Attack.new()
	attack.damage = player.damage * weapon_resorce.damage / 100
	attack.critical_chance = player.critical_chance
	attack.critical_multiplier = player.critical_multiplier
	attack.shake = 8
	attack.weapon = self

	charger -= 1
	projectile_instance.speed = weapon_resorce.bullet_speed
	projectile_instance.global_position = get_parent().global_position
	projectile_instance.set_direction(shoot_direction)
	projectile_instance.set_max_distance(weapon_resorce.bullet_max_distance)
	projectile_instance.attack = attack
	projectile_instance.piercing = weapon_resorce.piercing

	root.call_deferred("add_child", projectile_instance)
	
	if charger == 0:
		timer.wait_time = weapon_resorce.reload_speed
		Events.emit_signal("reload_weapon", weapon_resorce.reload_speed)
		reloading = true
	
	return shoot_direction.normalized()

func update_sprite_orientation():
	sprite_2d.flip_h = shoot_direction.normalized().x < 0

func _on_shoot_timer_timeout() -> void:    
	if reloading:
		timer.wait_time = weapon_resorce.atack_rate
		charger = weapon_resorce.bullet_capacity
		reloading = false
	elif target_enemy && !reloading:
		shoot()

func stop_weapon():
	timer.stop()
