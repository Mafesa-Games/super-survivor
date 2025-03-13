extends Node2D

@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D

const MAGNET = preload("res://drops/magnet/magnet.tscn")
const POTION = preload("res://drops/potion/potion.tscn")

func spawn_item() -> void:
	path_follow_2d.progress_ratio = randf_range(0.5415, 1)
	var x = path_follow_2d.global_position.x
	path_follow_2d.progress_ratio = randf_range(0, 0.525)
	var y = path_follow_2d.global_position.y
	var pos := Vector2(x,y)
	
	var items = [MAGNET,POTION]
	var item_index: int = randi_range(0,99)
	var chance: int = randf_range(0,99)
	if item_index > 30:
		item_index = 1
	else:
		item_index = 0
	
	if chance <= 3:
		var new_item = items[item_index].instantiate()
		new_item.global_position = pos
		get_tree().current_scene.add_child(new_item)
