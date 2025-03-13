extends PanelContainer
@onready var texture_rect: TextureRect = $TextureRect
var item_data: item_class
@export var allowed_type: item_class.Type = item_class.Type.helmet

func _get_drag_data(at_position: Vector2) -> Variant:
	set_drag_preview(get_preview())
	return self

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data is PanelContainer and data.has_method("get_item_data"):
		var incoming_item = data.get_item_data()
		if incoming_item != null and incoming_item.type == allowed_type:
			return true
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var temp_texture = texture_rect.texture
	var temp_item = item_data
	
	if temp_item != null:
		temp_item.unequip_item()
	
	texture_rect.texture = data.texture_rect.texture
	item_data = data.get_item_data()
	data.texture_rect.texture = temp_texture
	data.set_item_data(temp_item)
	

	if item_data != null:
		item_data.equip_item()

func get_preview() -> Control:
	var preview_texture = TextureRect.new()
	preview_texture.texture = texture_rect.texture
	preview_texture.expand_mode = 1
	preview_texture.size = Vector2(50, 50)
	var preview = Control.new()
	preview.add_child(preview_texture)
	return preview

func get_item_data() -> item_class:
	return item_data

func set_item_data(new_data: item_class) -> void:
	if item_data != null:
		item_data.unequip_item()
	
	item_data = new_data
	
	if item_data != null:
		item_data.equip_item()
