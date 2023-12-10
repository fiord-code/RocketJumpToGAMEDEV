class_name BasicCharacter
extends KinematicBody2D


signal died

# Машина состояний.
enum states {IDLE, MOVE, ATTACK}
var state = states.IDLE

# Словарь: состояние-действие-имя_функции
var states_actions := {
  states.IDLE: {
    "activation": "activate_idle",
    "action": "act_idle",
    "deactivation": "deactivate_idle"
   },
  states.MOVE: {
    "activation": "activate_move",
    "action": "act_move",
    "deactivation": "deactivate_move"
   },
  states.ATTACK: {
    "activation": "activate_attack",
    "action": "act_attack",
    "deactivation": "deactivate_attack"
   },
 }

# Скорость, прочность и маневренность.
export var max_speed: float
export var max_health: float
export var steering_factor: float

export var attack_modifier: float = 1.0
export var defence_modifier: float = 0.0

export var ship_name: String

# Текущая скорость и прочность.
onready var speed := max_speed
onready var health := max_health

# Узел с графикой персонажа.
onready var pivot := $Pivot
# ХП бар.
onready var health_bar := $HealthBar
onready var hitbox := $HitBox
onready var animated_sprite := $AnimatedSprite

# Вектора для плавного движения.
var velocity := Vector2.ZERO
var desired_velocity := Vector2.ZERO
var steering_vector := Vector2.ZERO
var direction := Vector2.ZERO


func _ready() -> void:
  setup_healthbar()
  if not Event.is_connected('round_ended', self, 'on_round_ended'):
    Event.connect('round_ended', self, 'on_round_ended')

  
func on_round_ended() -> void:
  pass


# Настраивает хп бар.
func setup_healthbar() -> void:
  health_bar.max_value = max_health
  health_bar.value = health
  

# Изменяет состояние.
func change_state(new_state) -> void:
  call(states_actions[state].deactivation)
  state = new_state
  call(states_actions[state].activation)


# Вызывает действие состояния.
func call_state_action() -> void:
  call(states_actions[state].action)

  
func _physics_process(delta: float) -> void:
  call_state_action()
  velocity = move_and_slide(velocity)
  
  
func get_direction() -> Vector2:
  return Vector2.ZERO
  
  
func take_damage(damage: float) -> void:
  if health <= 0.0:
    return
  
  health -= clamp(
    damage - defence_modifier,
    5,
    damage
  )
  health_bar.value = health
  
  if health <= 0.0:
    die()
  
  
func die() -> void:
  # Прячет отображение персонажа.
  Event.emit_signal("enemy_died")
  emit_signal('died')
  change_state(states.IDLE)
  self.set_deferred('disabled', true)
  hitbox.set_deferred('disabled', true)
  pivot.hide()
  health_bar.hide()
  # Показывает взрыв.
  # Устанавливает вращение для взрыва.
  animated_sprite.rotate(2 * PI * randf())
  animated_sprite.show()
  animated_sprite.play("explosion")
  yield(animated_sprite, "animation_finished")
  queue_free()
  
  
func act_idle() -> void:
  pass
  

func activate_idle() -> void:
  direction = Vector2.ZERO
  
  
func deactivate_idle() -> void:
  pass
  
  
func act_move() -> void:
  direction = get_direction()
  desired_velocity = direction * speed
  steering_vector = desired_velocity - velocity
  velocity += steering_vector * steering_factor
  
  if velocity.length() > 0:
    pivot.rotation = velocity.angle()
  

func activate_move() -> void:
  direction = Vector2.ZERO
  
  
func deactivate_move() -> void:
  direction = Vector2.ZERO
  
  
func act_attack() -> void:
  pass
  

func activate_attack() -> void:
  pass
  
  
func deactivate_attack() -> void:
  pass


func take_heal(heal: float) -> void:
  self.health = clamp(self.health + heal, self.health, self.max_health)
  
  health_bar.value = self.health
