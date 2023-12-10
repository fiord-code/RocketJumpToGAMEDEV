class_name BasicEnemy
extends BasicCharacter

export var stop_radius: float
export var loot_gems_amount: int
export var loot_gems_drop_probability: float

export(PackedScene) var loot_gem

var target: WeakRef
export var spawn_position: Vector2 = Vector2.ZERO

onready var hitbox_shape: CollisionShape2D = $HitBox/CollisionShape2D
onready var stop_area := $StopArea/CollisionShape2D
onready var rays := $Rays

func get_direction() -> Vector2:
  if (target == null) or not target.get_ref():
    return Vector2.ZERO
  var target_object: BasicPlayer = target.get_ref()
  rays.rotation = target_object.position.angle_to_point(self.position)
  for ray in rays.get_children():
    if not ray.is_colliding():
      continue
    var colliding_object: Node2D = ray.get_collider()
    var avoid_direction: Vector2 = colliding_object.position.direction_to(self.position).rotated(PI / 2)
    return avoid_direction
  return self.position.direction_to(target_object.position)
  
  
func set_target(new_target: Node2D) -> void:
  target = weakref(new_target)
  
func set_spawn_position(spawn_position: Vector2) -> void:
  self.spawn_position = spawn_position

func _ready() -> void:
  self.position = spawn_position
  if Global.enemies_settings.has(ship_name):
    load_settings()
  stop_area.shape.radius = stop_radius
  change_state(states.MOVE)
  ._ready()
  
  
func load_settings() -> void:
  self.max_speed = Global.enemies_settings[ship_name].max_speed
  self.max_health = Global.enemies_settings[ship_name].max_health
  self.steering_factor = Global.enemies_settings[ship_name].steering_factor
  self.attack_modifier = Global.enemies_settings[ship_name].attack_modifier
  self.defence_modifier = Global.enemies_settings[ship_name].defence_modifier
  self.stop_radius = Global.enemies_settings[ship_name].stop_radius
  self.loot_gems_amount = Global.enemies_settings[ship_name].loot_gems_amount
  self.loot_gems_drop_probability = Global.enemies_settings[ship_name].loot_gems_drop_probability
  
  
  
func act_attack() -> void:
  # Проверяет, есть ли цель.
  if (target == null) or not target.get_ref():
    return
  # Послепенно останавливает корабль.
  direction = self.position.direction_to(target.get_ref().position) 
  # Аккуратно поворачивается на цель.
  desired_velocity = direction * speed
  steering_vector = desired_velocity - velocity
  desired_velocity = velocity + steering_vector * steering_factor
  
  velocity = velocity.rotated(velocity.angle_to(desired_velocity)) 
  steering_vector = direction - velocity
  velocity += steering_vector * steering_factor
  
  
  pivot.rotation = velocity.angle()
  
  
func deactivate_attack() -> void:
  if velocity.length() < 1:
    velocity = Vector2.RIGHT
  velocity = Vector2.RIGHT.rotated(pivot.rotation) * velocity.length()


func _on_StopArea_area_entered(area: Area2D) -> void:
  change_state(states.ATTACK)


func _on_StopArea_area_exited(area: Area2D) -> void:
  change_state(states.MOVE)


## Спавнит кристаллики
func spawn_gem() -> void:
  var new_gem = loot_gem.instance()
  var hitbox_radius: int = hitbox_shape.shape.radius
  var gem_spawn_postition := self.global_position + Vector2(randf() - 0.5, randf() - 0.5) * 2 * hitbox_radius
  new_gem.set_spawn_position(gem_spawn_postition)
  get_tree().get_root().call_deferred('add_child', new_gem)


func die() -> void:
  # Оставляет кристаллики после поражения.
  for i in range(loot_gems_amount):
    if randf() <= loot_gems_drop_probability:
      spawn_gem()
  .die()


func on_round_ended() -> void:
  die()
  
  
func on_boost() -> void:
  pass
