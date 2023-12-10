class_name BasicPlayer
extends BasicCharacter


onready var attack_area := $Areas/AttackArea


func _ready() -> void:
  # Загружает характеристики корабля.
  load_progress()
  # Устанавливает режим перемещения.
  change_state(states.MOVE)
  
  # Вызывает метод родителя.
  ._ready()


# Загружает уровни прокачки игровка.
func load_progress() -> void:
  self.max_health *= Global.get_state_value('health_level')
  self.health = max_health
  
  self.max_speed *= Global.get_state_value('speed_level')
  self.speed = max_speed
  
  self.steering_factor = clamp(
    steering_factor * Global.get_state_value('steering_level'),
    0.01,
    0.99
  )
  
  self.attack_modifier = Global.get_state_value('attack_level')
  
  self.defence_modifier = Global.get_state_value('defence_level')


func get_direction() -> Vector2:
  var new_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
  return new_direction
  

func _process(delta: float) -> void:
  # Если игроком не управляют, то он переходит в режим атаки.
  if (get_direction().length() == 0.0 and state != states.ATTACK):
    change_state(states.ATTACK)
  elif (get_direction().length() > 0.0 and state != states.MOVE):
    change_state(states.MOVE)
    
    
func act_attack():
  # Игрок продолжает движение (замедляется и останавливается)
  act_move()
  # Игрок поворачивается на врага.
  var target_enemy := get_target_enemy()
  if not target_enemy:
    return
  
  pivot.rotation = self.global_position.direction_to(target_enemy.global_position).angle()
  
  
func get_target_enemy() -> Node2D:
  # Получает узел, представляющий врага.
  var overlapping_areas: Array = attack_area.get_overlapping_areas()
  if not overlapping_areas:
    return null
  
  return overlapping_areas.front()


func on_round_ended() -> void:
  take_heal(self.max_health)
