class_name Gem
extends BasicCharacter

export var item_cost: int      = 1
export var collect_radius: int = 400
export var life_time: float = 10.0

var target: WeakRef
var spawn_position := Vector2.ZERO

onready var life_timer := $LifeTimer

func set_spawn_position(spawn_position: Vector2) -> void:
  self.spawn_position = spawn_position


func _ready() -> void:
  $Areas/CollectArea/CollisionShape2D.shape.radius = collect_radius
  self.global_position = spawn_position
  life_timer.wait_time = life_time
  life_timer.start()
  


func _on_HitBox_area_entered(area: Area2D) -> void:
  Event.emit_signal("item_collected", item_cost)
  self.velocity = Vector2.ZERO
  die()


func _on_CollectArea_area_entered(area: Area2D) -> void:
  target = weakref(area)
  change_state(states.MOVE)
  
  
func get_direction() -> Vector2:
  if (target == null) or not target.get_ref():
    return Vector2.ZERO
  
  var direction_to_target: Vector2 = self.global_position.direction_to(target.get_ref().global_position)
  return direction_to_target


func _on_LifeTimer_timeout() -> void:
  if state == states.IDLE:
    queue_free()
