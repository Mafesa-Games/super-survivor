extends Resource
class_name weapon_global_class

@export var name: String
@export var description: String

@export var level: int
@export var max_level:int

@export var damage: float
@export var charger_capacity: int

@export var attack_rate: float
@export var critical_chance: float
@export var critical_damage: float

@export var projectile_speed: float
@export var projectile_lifetime: float
@export var projectile_range: float
@export var projectile_spread: float
@export var projectile_number: float


@export var makes_piercing: bool
@export var piercing_times: int

@export var makes_bounce: bool
@export var bounce_times: int

@export var makes_explosion: bool
@export var explosion_damage: float
@export var explosion_times: int
@export var explosion_area: float

#@export var makes_fire: bool 
#@export var fire_damage: float
#@export var fire_duration: float
#
#@export var makes_freeze: bool
#@export var freeze_damage: float
#@export var freeze_duration: float

@export var icon: Texture2D
