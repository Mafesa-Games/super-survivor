extends Area2D


@export var explosion_duration: float = 0.5

@export var explosion_damage = 0
@export var explosion_times = 0
@export var explosion_area = 0
var attack: Attack

var enemys : Array = []

func _ready() -> void:
	$GPUParticles2D.emitting = false
	var shape = $CollisionShape2D.shape
	if shape is CircleShape2D:
		shape.radius = explosion_area

	await get_tree().create_timer(explosion_duration).timeout
	queue_free()
	#
func _on_body_entered(body: Node) -> void:
	if body and body.has_method("apply_damage"):
		$GPUParticles2D.emitting = true
		body.apply_damage(attack)

func activate(attack, explosion_times_value, explosion_area_value):
	self.attack = attack
	explosion_times = explosion_times_value
	explosion_area = explosion_area_value
