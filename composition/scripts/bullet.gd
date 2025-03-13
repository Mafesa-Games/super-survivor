extends Area2D

var speed: float = 700.0
var direction: Vector2
var damage: int = 0

@onready var sprite: Sprite2D = $Sprite2D

var distance_travelled: float = 0.0
@export var max_distance: float = 1000 # max bullet distance

func _ready() -> void:
	sprite.modulate = Color("041f0e")

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
	if body and body.name == "Player":
		Events.emit_signal("do_damage", damage)
	call_deferred("queue_free")
