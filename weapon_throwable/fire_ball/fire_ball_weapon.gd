extends Area2D

@export var weapon_resorce: weapon_global_class

const FIRE_BALL = preload("res://weapon_throwable/fire_ball/fire_ball.tscn")

@export var level: int # W 
@export var max_level: int # W 
@export var damage: float = 22
@export var charger_capacity: int # W 
@export var attack_rate: float = 1 # W
@export var critical_chance: float
@export var critical_damage: float
var player: CharacterBody2D
@export var projectile_speed: float = 150 
@export var projectile_lifetime: float = 3
@export var projectile_range: float = 500 # W 
@export var projectile_number: int = 6 # W  
@export var projectile_spread: float = 5 # W 

@export var makes_piercing: bool
@export var piercing_times: int

@export var makes_bounce: bool
@export var bounce_times: int

@export var makes_explosion: bool
@export var explosion_damage: float
@export var explosion_times: int
@export var explosion_area: float

@export var icon: Texture2D

@onready var timer: Timer = $Timer
var target_enemy: CharacterBody2D = null
var ticks := 0

var damage_done := 0.0

func _ready() -> void:
	timer.wait_time = attack_rate
	timer.start()
	update_weapon_stats()
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
			if distance_to_enemy <= projectile_range && distance_to_enemy > MIN_DISTANCE:
				valid_enemies.append(enemy)

		if !valid_enemies.is_empty():
			target_enemy = valid_enemies[randi() % valid_enemies.size()]
		ticks = 0
		

func update_weapon_stats() -> void:
	if weapon_resorce:
		self.level = weapon_resorce.level
		self.max_level = weapon_resorce.max_level
		self.damage = weapon_resorce.damage
		self.charger_capacity = weapon_resorce.charger_capacity
		self.attack_rate = weapon_resorce.attack_rate
		self.critical_chance = weapon_resorce.critical_chance
		self.critical_damage = weapon_resorce.critical_damage
		
		self.projectile_speed = weapon_resorce.projectile_speed
		self.projectile_lifetime = weapon_resorce.projectile_lifetime
		self.projectile_range = weapon_resorce.projectile_range

		self.projectile_number = weapon_resorce.projectile_number
		self.projectile_spread = weapon_resorce.projectile_spread
		
		self.makes_piercing = weapon_resorce.makes_piercing
		self.piercing_times = weapon_resorce.piercing_times
		
		self.makes_bounce = weapon_resorce.makes_bounce
		self.bounce_times = weapon_resorce.bounce_times
		
		self.makes_explosion = weapon_resorce.makes_explosion
		self.explosion_damage = weapon_resorce.explosion_damage
		self.explosion_times = weapon_resorce.explosion_times
		self.explosion_area = weapon_resorce.explosion_area
		self.icon = weapon_resorce.icon

func shoot() -> void:
	if !target_enemy:
		return

	update_weapon_stats()
	
	var directions: Array = []
	var base_direction = global_position.direction_to(target_enemy.global_position)
	
	var attack = Attack.new()
	attack.player_damage = player.damage
	attack.damage = player.damage * weapon_resorce.damage / 100
	attack.critical_chance = player.critical_chance
	attack.critical_multiplier = player.critical_multiplier
	attack.shake = 8
	attack.weapon = self
	
	for i in range(projectile_number):
		var angle_offset = deg_to_rad(randf_range(-projectile_spread, projectile_spread))
		directions.append(base_direction.rotated(angle_offset))
	
	for direction in directions:
		var fire_ball_instance = FIRE_BALL.instantiate()
		fire_ball_instance.activate(
			direction,              
			global_position,        
			attack,                 
			critical_chance,
			critical_damage,
			projectile_speed,       
			projectile_lifetime,    
			makes_piercing,         
			piercing_times,         
			makes_bounce,           
			bounce_times,           
			makes_explosion,        
			explosion_damage,       
			explosion_times,        
			explosion_area          
		)
		
		get_tree().current_scene.add_child(fire_ball_instance)
		if projectile_number > 1:
			await get_tree().create_timer(0.05).timeout


func _on_timer_timeout() -> void:
	if target_enemy:
		shoot()

func stop_weapon():
	timer.stop()
