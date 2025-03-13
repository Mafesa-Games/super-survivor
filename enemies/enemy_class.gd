extends Resource
class_name enemy_type


@export var name: String
@export var speed: int
@export var damage: int
@export var health: int
@export var type: types
@export var exp: float
@export var penetration_resistence: int
@export var rebanuce_chance: int


enum types {
	RED,
	GREEN,
	BLUE,
	GREY,
	DARK,
	BIG_GREEN,
	DUMMY,
	BOSS_00
}

func find_apparence():
	pass
