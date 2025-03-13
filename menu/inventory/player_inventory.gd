extends GridContainer
#const SLOT = preload("res://menu/slot.tscn")

	#var item_resource = preload("res://items/helmets/helmet-a-01.tres") 
	#var item = preload("res://items/helmet_scene.tscn") 
	#var node_2d = item.instance() 
	#node_2d.helmet_item = item_resource 
	#add_child(node_2d)

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#var newitem = SLOT.instantiate()
	#add_child(newitem)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
