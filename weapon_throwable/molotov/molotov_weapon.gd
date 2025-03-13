extends Area2D
@export var weapon_resorce: weapon_molotov_type
@onready var timer: Timer = $Timer

var player: CharacterBody2D

const MOLOTOV = preload("res://weapon_throwable/molotov/molotov.tscn")

var cat_ady: float 
var type: int
var enemies: CharacterBody2D
var target_enemy: CharacterBody2D
var ticks:= 0

var charger :int
var shoot_direction:= Vector2.RIGHT
var reloading :bool = false
const MAX_SPREAD_ANGLE:= 3.0 

@export var icon: Texture2D
var damage_done := 0.0

func _ready() -> void:
	timer.wait_time = weapon_resorce.atack_rate
	icon = weapon_resorce.icon
	player = get_parent().get_parent()

func _process(_delta: float) -> void:
	const MIN_DISTANCE := 75
	var enemies_in_range = get_overlapping_bodies()
	target_enemy = null
	
	if enemies_in_range.is_empty():
		return
	
	ticks +=1
	#Find closest enemy every 15(0.25ms) ticks
	if ticks >= 15 || !target_enemy:
		if global_position.distance_to(enemies_in_range[0].global_position) > MIN_DISTANCE:
			target_enemy = enemies_in_range[0]
		for enemy in enemies_in_range:
			var distance_to_enemy := global_position.distance_to(enemy.global_position)
			if !target_enemy && distance_to_enemy > MIN_DISTANCE:
				target_enemy = enemy
			elif distance_to_enemy > MIN_DISTANCE && global_position.distance_to(target_enemy.global_position) > distance_to_enemy:
				target_enemy = enemy
		ticks= 0


func shoot() -> void:
	shoot_direction = global_position.direction_to(target_enemy.global_position)
	cat_ady = global_position.distance_to(target_enemy.global_position)
	if !target_enemy:
		return 
	
	var angulo = atan(weapon_resorce.atack_area * 1.9 / cat_ady)
	for i in weapon_resorce.throwable_capacity:
		var throwable_instance
		#if type == 0:
			#throwable_instance = GRANADE.instantiate()
		#else:
		throwable_instance = MOLOTOV.instantiate()
		
		var attack = Attack.new()
		attack.damage = player.damage * weapon_resorce.damage / 100
		attack.critical_chance = player.critical_chance
		attack.critical_multiplier = player.critical_multiplier
		attack.shake = 8
		attack.weapon = self
		
		
		throwable_instance.speed = weapon_resorce.throwable_speed
		throwable_instance.global_position = global_position
		throwable_instance.attack = attack
		throwable_instance.direction = shoot_direction.normalized().rotated(angulo * i)
		throwable_instance.damage_area(weapon_resorce.atack_area)

		
		throwable_instance.distance = global_position.distance_to(target_enemy.global_position) - target_enemy.enemy_stats.speed/5
		var root = get_tree().current_scene
		root.call_deferred("add_child", throwable_instance)


func _on_throw_timer_timeout() -> void:
	if target_enemy:
		shoot()

func stop_weapon():
	timer.stop()
