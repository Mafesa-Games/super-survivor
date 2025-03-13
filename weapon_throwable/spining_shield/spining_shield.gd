extends Area2D

var attack: Attack

func _on_body_entered(body: Node2D) -> void:
	if body and body.has_method("apply_damage"):
		#$GPUParticles2D.emitting = true
		body.apply_damage(attack)


func activate(attack: Attack):
	self.attack = attack
