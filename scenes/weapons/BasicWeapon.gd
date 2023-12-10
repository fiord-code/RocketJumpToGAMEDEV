class_name BasicWeapon
extends Node2D

enum states {READY, RELOAD}
var state = states.READY

export var cooldown: float
export var damage: float
export var bullet_speed: float
export var bullet_life_time: float

var basic_damage: float

onready var reload_timer := $ReloadTimer
onready var attack_area := $AttackArea


func _ready() -> void:
  basic_damage = damage
  owner.connect("ready", self, 'load_damage_modifier')
  Event.connect("attack_modified", self, 'load_damage_modifier')
  
  
func load_damage_modifier() -> void:
  self.damage = max(self.basic_damage * owner.attack_modifier, 0)


func shoot() -> void:
  pass
  
func shoot_and_reload() -> void:
  if state == states.RELOAD:
    return
  
  shoot()
  
  state = states.RELOAD
  
  reload_timer.wait_time = cooldown
  reload_timer.start()


func _on_AttackArea_area_entered(area: Area2D) -> void:
  shoot_and_reload()
  

func _on_ReloadTimer_timeout() -> void:
  state = states.READY
  if attack_area.get_overlapping_areas():
    shoot_and_reload()
