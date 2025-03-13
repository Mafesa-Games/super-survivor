extends Area2D

@export var type = "potion"


func _on_area_entered(area: Area2D) -> void:
	if area.name == "PickArea": 
		var player = area.get_parent()
		var heal_amount: float = player.max_hp / 5
		player.hp += heal_amount
		queue_free()
