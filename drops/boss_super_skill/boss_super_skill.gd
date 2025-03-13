extends Area2D


func _on_area_entered(area: Area2D) -> void:
	if area.name == "PickArea":
		var stage = area.get_parent().get_parent()
		var rulete = stage.find_child("Rulete")
		var active_powers = rulete.get_active_power_resources()
		if active_powers.size() > 0:
			rulete.setup_roulette(active_powers)
			rulete.start_roulette()
		queue_free()
