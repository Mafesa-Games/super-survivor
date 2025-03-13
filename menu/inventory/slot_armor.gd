extends PanelContainer
@onready var texture_rect: TextureRect = $TextureRect
var item_data: item_class
@export var allowed_type: item_class.Type = item_class.Type.armor

var at_position: Vector2
var data

func _ready() -> void:
	%HTTPRequest.request_completed.connect(_on_request_completed)


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
	self.at_position = at_position
	self.data = data
	var json = JSON.new().stringify({"itemId": "r"})
	var jwt = "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwbGF5ZXJJZCI6ImFfMTM5MjM5NDU2NjE1MzUwMjg3IiwiZXhwIjoxNzQxNTMwMjg3fQ.klBHmne_v7FrlIPRJ3rMye_z6eUIzODMjSjgHJki_j4"
	var headers = ["Content-Type: application/json", jwt]
	%HTTPRequest.request("https://super-survival-server-production.up.railway.app/api/auth/gear/equip-on",headers, HTTPClient.METHOD_POST, json)


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

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	
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

	
