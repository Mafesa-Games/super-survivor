extends Area2D

@export var damage: float
@export var critical_chance: float
@export var critical_damage: float
var attack: Attack

const THUNDER_1 = preload("res://weapon_throwable/thunder/thunder_1.png")
const THUNDER_2 = preload("res://weapon_throwable/thunder/thunder_2.png")
const THUNDER_3 = preload("res://weapon_throwable/thunder/thunder_3.png")

func _ready() -> void:
	var textures = [THUNDER_1, THUNDER_2, THUNDER_3]
	$Line2D.texture = textures[randi() % textures.size()]
	await get_tree().create_timer(0.1).timeout
	$Line2D.visible = false

func activate(target_position: Vector2, attack: Attack) -> void:
	global_position = target_position
	self.attack = attack

func _on_body_entered(body) -> void:
	body.apply_damage(attack)
	$Line2D.visible = false
	queue_free()
