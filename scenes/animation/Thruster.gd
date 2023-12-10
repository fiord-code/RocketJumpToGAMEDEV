class_name Thruster
extends Position2D


export(Texture) var texture

onready var sprite := $Sprite

func _ready() -> void:
  sprite.texture = self.texture


func _process(delta: float) -> void:
  var deviation := randf() * 0.4
  var speed_scale: float = owner.velocity.length() / owner.max_speed * (0.6 + deviation)
  
  sprite.scale = Vector2.ONE * speed_scale
