extends Resource
class_name weapon_orb_type

@export var name: String
@export var description: String = "Weapon description"

@export var damage: float = 10
@export var attack_rate: float = 2
@export var speed: float = 50
@export var range: float = 500

@export var max_time: int = 4
@export var critical_chance: float = 8.0

@export var icon: Texture2D
