extends Control

func _process(delta: float) -> void:
	$VBoxContainer/HBoxContainer/diamonds_amount.text = str(global_status.diamonds)
	$VBoxContainer/HBoxContainer2/coins_amount.text = str(global_status.coins)

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://stage_1.tscn")
	
