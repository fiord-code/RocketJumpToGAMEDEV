class_name BasicGun
extends BasicWeapon


export(PackedScene) var bullet


func shoot():
  var new_bullet: BasicBullet = bullet.instance()
  
  var bullet_position: Vector2 = self.global_position
  var bullet_rotation: float = self.global_rotation
  
  new_bullet.prepare_bullet(damage, bullet_speed, bullet_life_time, bullet_rotation, bullet_position)
  
  Event.emit_signal("player_shoot")
  get_tree().get_root().call_deferred('add_child', new_bullet)
  
