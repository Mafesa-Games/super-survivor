extends Area2D

var speed: float = 100.0
var direction: Vector2
var attack: Attack
@onready var sprite: Sprite2D = $sword_slash_1
@export var rebounce_effect_scene: PackedScene = preload("res://weapons_fire/sword/rebounce_sword_slash.tscn")

var piercing: bool = false
var distance_travelled: float = 0.0
@export var max_distance: float = 50.0


func set_max_distance(distance: float) -> void:
	max_distance = distance

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
