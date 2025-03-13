extends Node

# economy
var coins: int = 123
var diamonds: int = 12

# inventory
var inventory_slots_availables = 15
var inventory: Array= ["res://items/armors/armor-b-00.tres","res://items/boots/boots-a-00.tres","res://items/armors/armor-b-03.tres","res://items/gloves/gloves-a-00.tres","res://items/helmets/helmet-a-01.tres"] 

var helmet: item_class
var armor: item_class
var gloves: item_class
var boots: item_class

# player
var exp: float = 0
var lvl: int = 1

var base_hp:int = 100
var hp: int = 100

var base_speed: float = 120
var speed: float = 120

var base_defense:float = 5
var defense: float = 5

# combat
var damage:float = 100

var base_life_steal:float = 0
var life_steal:float = 0

var base_attack_speed:float = 1
var attack_speed:float = 0

var base_critical_chance:float = 1
var critical_chance:float = 20

var base_critical_damage:float = 1
var critical_multiplier:float = 1.5

var base_dodge_chance:float = 1
var dodge_chance:float = 0

var base_hp_regeneration:float = 1
var hp_regeneration:float = 0

var base_explosion_damage:float = 1
var explosion_damage:float = 0

var base_explosion_size:float = 1
var explosion_size:float = 0

var base_pickup_range:float = 1
var pickup_range:float = 40

# elemantal
var base_elemental_damage: float = 1
var elemental_fire_damage:float = 0
var elemental_thunder_damage:float = 0
var elemental_water_damage:float = 0
var elemental_rock_damage:float = 0

var base_elemental_defense: float = 1
var elemental_fire_defense:float = 0
var elemental_thunder_defense:float = 0
var elemental_water_defense:float = 0
var elemental_rock_defense:float = 0

# jewelery
#var ring_1 = 0 # ring object
#var ring_2 = 0 # ring object
#var earing_1 = 0 # earing object
#var earing_2 = 0 # earing object
#var amulet = 0 # amulet object





func update_status():
	
	print("before stats hp: ", self.hp)
	print("before stats def: ", self.defense)
	print("before stats speed: ", self.speed)
	print("before stats critical_chance: ", self.critical_chance)
	
	#var items = [self.helmet , self.armor , self.gloves , self.boots]
	var items = []
	if self.helmet:
		items.append(self.helmet)
	if self.armor:
		items.append(self.armor)
	if self.gloves:
		items.append(self.gloves)
	if self.boots:
		items.append(self.boots)
	
	#for i in items:
		#print(i.hp)
	
	var items_hp: int = 0
	var items_speed: float = 0
	var items_defense: float = 0 
	var items_life_steal:float = 0
	var items_attack_speed:float = 0
	var items_critical_chance:float = 0
	var items_critical_damage:float = 0
	var items_dodge_chance:float = 0
	var items_hp_regeneration:float = 0
	var items_explosion_damage:float = 0
	var items_explosion_size:float = 0
	var items_pickup_range:float = 0
	var items_elemental_fire_damage:float = 0
	var items_elemental_thunder_damage:float = 0
	var items_elemental_water_damage:float = 0
	var items_elemental_rock_damage:float = 0
	var items_elemental_fire_defense:float = 0
	var items_elemental_thunder_defense:float = 0
	var items_elemental_water_defense:float = 0
	var items_elemental_rock_defense:float = 0
	
	
	for i in items:
		items_hp += i.hp if i.get("hp") else 0
		items_speed += i.speed if i.get("speed") else 0
		items_defense += i.defense if i.get("defense") else 0
		items_life_steal += i.life_steal if i.get("life_steal") else 0
		items_attack_speed += i.attack_speed if i.get("attack_speed") else 0
		items_critical_chance += i.critical_chance if i.get("critical_chance") else 0
		items_critical_damage += i.critical_damage if i.get("critical_damage") else 0
		items_dodge_chance += i.dodge_chance if i.get("dodge_chance") else 0
		items_hp_regeneration += i.hp_regeneration if i.get("hp_regeneration") else 0
		items_explosion_damage += i.explosion_damage if i.get("explosion_damage") else 0
		items_explosion_size += i.explosion_size if i.get("explosion_size") else 0
		items_pickup_range += i.pickup_range if i.get("pickup_range") else 0
		items_elemental_fire_damage += i.elemental_fire_damage if i.get("elemental_fire_damage") else 0
		items_elemental_thunder_damage += i.elemental_thunder_damage if i.get("elemental_thunder_damage") else 0
		items_elemental_water_damage += i.elemental_water_damage if i.get("elemental_water_damage") else 0
		items_elemental_rock_damage += i.elemental_rock_damage if i.get("elemental_rock_damage") else 0
		items_elemental_fire_defense += i.elemental_fire_defense if i.get("elemental_fire_defense") else 0
		items_elemental_thunder_defense += i.elemental_thunder_defense if i.get("elemental_thunder_defense") else 0
		items_elemental_water_defense += i.elemental_water_defense if i.get("elemental_water_defense") else 0
		items_elemental_rock_defense += i.elemental_rock_defense if i.get("elemental_rock_defense") else 0


	self.hp = items_hp + base_hp
	self.speed = items_speed + base_speed
	self.defense = items_defense + base_defense
	self.life_steal = items_life_steal + base_life_steal
	self.attack_speed = items_attack_speed + base_attack_speed
	self.critical_chance = items_critical_chance + base_critical_chance
	#self.critical_damage = items_critical_damage + base_critical_damage
	self.dodge_chance = items_dodge_chance + base_dodge_chance
	self.hp_regeneration = items_hp_regeneration + base_hp_regeneration
	self.explosion_damage = items_explosion_damage + base_explosion_damage
	self.explosion_size = items_explosion_size + base_explosion_size
	self.pickup_range = items_pickup_range + base_pickup_range
	self.elemental_fire_damage = items_elemental_fire_damage + base_elemental_damage
	self.elemental_thunder_damage = items_elemental_thunder_damage + base_elemental_damage
	self.elemental_water_damage = items_elemental_water_damage + base_elemental_damage
	self.elemental_rock_damage = items_elemental_rock_damage + base_elemental_damage
	self.elemental_fire_defense = items_elemental_fire_defense + base_elemental_defense
	self.elemental_thunder_defense = items_elemental_thunder_defense + base_elemental_defense
	self.elemental_water_defense = items_elemental_water_defense + base_elemental_defense
	self.elemental_rock_defense = items_elemental_rock_defense + base_elemental_defense

	print("after stats hp: ", self.hp)
	print("after stats def: ", self.defense)
	print("after stats speed: ", self.speed)
	print("after stats critical_chance: ", self.critical_chance)
