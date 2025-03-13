extends Control

@onready var player_inventory = $MarginContainer/VBoxContainer/menu_general/general_inventory/MarginContainer/player_inventory
var slot_scene = preload("res://menu/inventory/slot.tscn")


func _ready() -> void:
	var inventory_slots = global_status.inventory_slots_availables
	for i in range(inventory_slots):
		var slot_instance = slot_scene.instantiate()
		if i < global_status.inventory.size():
			var resource = load(global_status.inventory[i])
			slot_instance.get_node("TextureRect").texture = resource.icon
			slot_instance.set_item_data(resource)
		else:
			slot_instance.get_node("TextureRect").texture = null
		player_inventory.add_child(slot_instance)
