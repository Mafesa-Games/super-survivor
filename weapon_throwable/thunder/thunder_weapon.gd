extends Area2D

const RAY = preload("res://weapon_throwable/thunder/ray.tscn")

@export var weapon_resorce: thunder_class

@export var level: int 
@export var max_level: int 
@export var damage: float = 250
@export var attack_rate: float = 3
@export var critical_chance: float
@export var critical_damage: float
@export var attack_range: float = 260

@onready var timer: Timer = $Timer
var target_enemy: CharacterBody2D = null
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
var player: CharacterBody2D

@export var icon: Texture2D
var damage_done := 0.0

func _ready() -> void:
	update_weapon_stats()
	collision_shape_2d.shape.radius = attack_range
	timer.wait_time = attack_rate
	timer.start()
	player = get_parent().get_parent()

func _process(_delta: float) -> void:
	var enemies_in_range = get_overlapping_bodies()
	target_enemy = null

	if !enemies_in_range.is_empty():
		target_enemy = enemies_in_range[randi() % enemies_in_range.size()]

func update_weapon_stats() -> void:
	if weapon_resorce:
		self.level = weapon_resorce.level
		self.max_level = weapon_resorce.max_level
		self.damage = weapon_resorce.damage
		self.attack_rate = weapon_resorce.attack_rate
		self.critical_chance = weapon_resorce.critical_chance
		self.critical_damage = weapon_resorce.critical_damage
		self.attack_range = weapon_resorce.attack_range
		self.icon = weapon_resorce.icon

func strike() -> void:
	if !target_enemy:
		return
	
	var attack = Attack.new()
	attack.damage = player.damage # * weapon_lightning_resource.damage / 100
	attack.critical_chance = player.critical_chance
	attack.critical_multiplier = player.critical_multiplier
	attack.shake = 7
	attack.weapon = self
	
	var lightning_instance = RAY.instantiate()
	lightning_instance.activate(
		target_enemy.global_position,  # La posición donde caerá el rayo
		attack
	)
	get_tree().current_scene.add_child(lightning_instance)

func _on_timer_timeout() -> void:
	if target_enemy:
		strike()

func stop_weapon():
	timer.stop()
