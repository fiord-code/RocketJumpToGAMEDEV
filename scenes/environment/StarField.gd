extends Particles2D


func _ready() -> void:
  var screen_size: Vector2 = get_viewport().size
  self.process_material.emission_box_extents.x = screen_size.x
  self.process_material.emission_box_extents.y = screen_size.y
