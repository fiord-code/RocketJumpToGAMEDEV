class_name BasicBullet
extends Area2D


var damage: float
var speed: float
var life_time: float
var direction_angle: float
var start_position: Vector2

onready var pivot := $Pivot
onready var life_timer := $LifeTimer
onready var collision_shape := $CollisionShape2D
onready var animated_sprite := $AnimatedSprite

var velocity := Vector2.ZERO


func _ready() -> void:
  shoot_in_direction()

func prepare_bullet(damage: float, speed: float, life_time: float, direction_angle: float, start_position: Vector2) -> void:
  self.damage = damage
  self.speed = speed
  self.life_time = life_time
  self.direction_angle = direction_angle
  self.start_position = start_position


func shoot_in_direction() -> void:
  pivot.global_rotation = direction_angle
  self.global_position = start_position
  life_timer.wait_time = life_time
  
  velocity = Vector2.RIGHT.rotated(direction_angle) * speed
  
  life_timer.start()
  
  
func _physics_process(delta: float) -> void:
  self.position += velocity * delta


func _on_LifeTimer_timeout() -> void:
  queue_free()


func _on_BasicBullet_area_entered(area: Area2D) -> void:
  area.owner.take_damage(damage)
  collision_shape.set_deferred("disabled", true)
  self.velocity = Vector2.ZERO
  pivot.hide()
  animated_sprite.show()
  animated_sprite.play('burst')


func _on_AnimatedSprite_animation_finished() -> void:
  queue_free()
