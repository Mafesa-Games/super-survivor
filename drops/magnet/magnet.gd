extends Area2D

@export var type = "iman"


func _on_area_entered(area: Area2D) -> void:
	if area.name == "PickArea":
		var player = area.get_parent()
		player.magnet()
		queue_free()
