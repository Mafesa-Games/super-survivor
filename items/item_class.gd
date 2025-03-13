extends Resource
class_name item_class

enum Quality { common, uncommon, rare, very_rare, epic, legendary }
enum Type { helmet, armor, boots, gloves }

@export var name: String
@export var quality: Quality
@export var type: Type

@export var hp: int = 0
@export var speed: float = 0
@export var defense: float = 0 

# combat
@export var life_steal: float = 0
@export var attack_speed: float = 0
@export var critical_chance: float = 0
@export var critical_damage: float = 0
@export var dodge_chance: float = 0
@export var hp_regeneration: float = 0
@export var explosion_damage: float = 0
@export var explosion_size: float = 0
@export var pickup_range: float = 0

# elemental
@export var elemental_fire_damage: float = 0
@export var elemental_thunder_damage: float = 0
@export var elemental_water_damage: float = 0
@export var elemental_rock_damage: float = 0

@export var elemental_fire_defense: float = 0
@export var elemental_thunder_defense: float = 0
@export var elemental_water_defense: float = 0
@export var elemental_rock_defense: float = 0

@export var icon: Texture2D

func equip_item():
	if self.type == Type.helmet:
		global_status.helmet = self
	elif self.type == Type.armor:
		global_status.armor = self
	elif self.type == Type.gloves:
		global_status.gloves = self
	elif self.type == Type.boots:
		global_status.boots = self
	
	global_status.update_status() # Global func

func unequip_item():
	if self.type == Type.helmet and global_status.helmet == self:
		global_status.helmet = null
	elif self.type == Type.armor and global_status.armor == self:
		global_status.armor = null
	elif self.type == Type.gloves and global_status.gloves == self:
		global_status.gloves = null
	elif self.type == Type.boots and global_status.boots == self:
		global_status.boots = null
	
	global_status.update_status() # Global func
