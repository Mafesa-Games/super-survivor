extends PanelContainer

@onready var texture_rect: TextureRect = $TextureRect
var item_data: item_class

func _get_drag_data(at_position: Vector2) -> Variant:
	set_drag_preview(get_preview())
	return self

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is PanelContainer and data.has_method("get_item_data")

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var temp_texture = texture_rect.texture
	var temp_item = item_data
	print("test: ", item_data)

	texture_rect.texture = data.texture_rect.texture
	item_data = data.get_item_data()

	data.texture_rect.texture = temp_texture
	data.set_item_data(temp_item)
	print("test2: ", item_data.attack_speed)
	
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
	item_data = new_data
