extends Area2D
@export var weapon_resorce : spining_shield_class

@export var level: int
@export var max_level:int

@export var damage: float = 15
@export var num_orbs: int = 0
@export var rotation_speed: float = 3
@export var orbit_radius: float = 100
var player: CharacterBody2D
@export var critical_chance: float
@export var critical_damage: float

var defender_orbs: Array = []
var defender_scene = preload("res://weapon_throwable/spining_shield/spining_shield.tscn")  

@export var icon: Texture2D
var damage_done := 0.0

func _ready():
	player = get_parent().get_parent()
	icon = weapon_resorce.icon
	update_weapon_stats()
	spawn_defender_orbs()


func spawn_defender_orbs():
	for orb in defender_orbs:
		orb.queue_free()
	defender_orbs.clear()
	var attack = Attack.new()
	attack.damage = player.damage * weapon_resorce.damage / 100
	attack.critical_chance = player.critical_chance
	attack.critical_multiplier = player.critical_multiplier
	attack.shake = 8
	attack.weapon = self
	
	for i in range(num_orbs):
		var orb = defender_scene.instantiate()
		orb.activate(attack) # ORB DAGAME
		add_child(orb)
		defender_orbs.append(orb)

		var angle = (2 * PI * i) / num_orbs
		orb.position = Vector2(
			cos(angle) * orbit_radius,
			sin(angle) * orbit_radius
		)

func _process(delta):
	for i in range(defender_orbs.size()):
		var orb = defender_orbs[i]
		var current_pos = orb.position
		var angle = current_pos.angle()
		var new_angle = angle + rotation_speed * delta
		orb.position = Vector2(
			cos(new_angle) * orbit_radius,
			sin(new_angle) * orbit_radius
		)

func update_weapon_stats() -> void:
	if weapon_resorce:
		#self.name = weapon_resorce.name
		#self.description = weapon_resorce.description
		
		self.level = weapon_resorce.level
		self.max_level = weapon_resorce.max_level

		self.damage = weapon_resorce.damage
		self.num_orbs = weapon_resorce.num_orbs

		self.rotation_speed = weapon_resorce.rotation_speed
		self.orbit_radius = weapon_resorce.orbit_radius

		self.critical_chance = weapon_resorce.critical_chance
		self.critical_damage = weapon_resorce.critical_damage
		spawn_defender_orbs()

func stop_weapon():
	for orb in defender_orbs:
		orb.queue_free()
		defender_orbs.clear()
