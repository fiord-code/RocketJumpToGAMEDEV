extends Gem

export var heal_amount: float = 10.0


func _on_HitBox_area_entered(area: Area2D) -> void:
  if area.owner:
    area.owner.take_heal(heal_amount)
  ._on_HitBox_area_entered(area)
