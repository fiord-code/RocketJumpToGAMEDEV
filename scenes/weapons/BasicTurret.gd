class_name BasicTurret
extends Node2D


var attack_modifier: float setget , get_attack_modifier
export var detection_radius: int

onready var detection_shape := $DetectionArea/CollisionShape2D
onready var detection_area := $DetectionArea

var target: WeakRef


func _ready() -> void:
  detection_shape.shape.radius = detection_radius


func _physics_process(delta: float) -> void:
  # Враги в зоне обнаружения.
  var overlapping_areas: Array = detection_area.get_overlapping_areas()
  # Если нет врагов, то выходит.
  if not overlapping_areas:
      return
  # Если нет цели, то ищет новую
  if (target == null) or not target.get_ref() or not (target.get_ref() in overlapping_areas):
    var random_index: int = randi() % overlapping_areas.size()
    target = weakref(overlapping_areas[random_index])
    
  var target_position: Vector2 = target.get_ref().global_position
  self.global_rotation = target_position.angle_to_point(global_position)


func get_attack_modifier() -> float:
  if owner:
    return owner.attack_modifier
  return 1.0
