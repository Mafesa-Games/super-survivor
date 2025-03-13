extends Sprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sprite_2d_2: Sprite2D = $Sprite2D2
@onready var sprite_2d_3: Sprite2D = $Sprite2D3

func _ready() -> void:
	sprite_2d.visible = false
	sprite_2d_2.visible = false
	sprite_2d_3.visible = false

	animation_player = $AnimationPlayer
	var animations = ["fire_flash_1", "fire_flash_2", "fire_flash_3"]
	var selected_animation = animations[randi() % animations.size()]
	animation_player.play(selected_animation)
