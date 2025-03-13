extends Area2D
@export var weapon_resorce: weapon_orb_type

const ORB = preload("res://weapon_throwable/rebound_orb/orb.tscn")

@export var damage: float = 10
@export var attack_rate: float = 1
@export var speed: float = 200
@export var range: float = 500
@export var max_time: int = 4
@export var rebound_times: int = 2
@export var critical_chance: float = 5

@export var icon: Texture2D
var player: CharacterBody2D

var damage_done := 0.0

@export var projectile_spread: float = 3.0
@onready var timer: Timer = $Timer

var target_enemy: CharacterBody2D = null
var ticks := 0

func _ready() -> void:
	timer.wait_time = attack_rate
	icon = weapon_resorce.icon
	timer.start()
	player = get_parent().get_parent()

func _process(_delta: float) -> void:
	const MIN_DISTANCE := 75.0
	var enemies_in_range = get_overlapping_bodies()
	target_enemy = null

	if enemies_in_range.is_empty():
		return

	ticks += 1
	if ticks >= 15 || !target_enemy:
		var valid_enemies = []
		for enemy in enemies_in_range:
			var distance_to_enemy = global_position.distance_to(enemy.global_position)
			if distance_to_enemy <= range && distance_to_enemy > MIN_DISTANCE:
				valid_enemies.append(enemy)

		if !valid_enemies.is_empty():
			target_enemy = valid_enemies[randi() % valid_enemies.size()]
		ticks = 0

func shoot() -> void:

	var attack = Attack.new()
	attack.damage = player.damage * weapon_resorce.damage / 100
	attack.critical_chance = player.critical_chance
	attack.critical_multiplier = player.critical_multiplier
	attack.shake = 8
	attack.weapon = self
	
	damage = weapon_resorce.damage 
	attack_rate = weapon_resorce.attack_rate
	max_time = weapon_resorce.max_time
	speed = weapon_resorce.speed
	range = weapon_resorce.range
	critical_chance = weapon_resorce.critical_chance

	timer.wait_time = attack_rate

	if !target_enemy:
		return
	var shoot_direction = global_position.direction_to(target_enemy.global_position)
	var distance_to_target = global_position.distance_to(target_enemy.global_position)


	var laser_instance = ORB.instantiate()

	laser_instance.direction = shoot_direction
	laser_instance.global_position = global_position

	laser_instance.activate(laser_instance.direction, laser_instance.global_position,speed, attack, max_time)
	
	get_tree().current_scene.call_deferred("add_child", laser_instance)

func _on_timer_timeout() -> void:
	if target_enemy:
		shoot()
		
func stop_weapon():
	timer.stop()
