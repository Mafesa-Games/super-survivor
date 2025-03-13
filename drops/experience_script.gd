extends Node2D
@export var exp_resource : experience
var exp: float
@onready var sprite_2d: Sprite2D = $Sprite2D
@export var type = "experience"


func _ready() -> void:
	sprite_2d.texture = exp_resource.sprit
