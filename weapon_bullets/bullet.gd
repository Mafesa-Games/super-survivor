extends Area2D

var speed: float = 700.0
var direction: Vector2
var attack: Attack

@onready var sprite: Sprite2D = $Sprite2D
@export var rebounce_effect_scene: PackedScene = preload("res://weapon_bullets/rebounce_effect.tscn")
@export var piercing_effect_scene: PackedScene = preload("res://weapon_bullets/piercing_effect.tscn")
var piercing: bool = false

var distance_travelled: float = 0.0
@export var max_distance: float = 1000

# weapon total damage
var weapon: Area2D

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	var movement = direction * speed * delta
	position += movement
	distance_travelled += movement.length()
	if distance_travelled >= max_distance:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body and randi_range(1, 100) < body.enemy_stats.rebanuce_chance:
		var rebounce_effect = rebounce_effect_scene.instantiate()
		get_parent().call_deferred("add_child", rebounce_effect)
		rebounce_effect.activate(direction, speed, position, rotation, attack)
	elif body and body.has_method("apply_damage"):
		body.apply_damage(attack)
		
		# weapon total damage
		#weapon.damage_done += attack.damage
		
		if piercing and body and randi_range(1,100) > body.enemy_stats.penetration_resistence:
			# PIERCING
			var piercing_effect = piercing_effect_scene.instantiate()
			piercing_effect.weapon = weapon # weapon total damage
			get_parent().call_deferred("add_child", piercing_effect)
			piercing_effect.activate(direction, speed, position, rotation, attack, body)
	
	call_deferred("queue_free")
