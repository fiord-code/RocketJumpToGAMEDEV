extends Control

signal level_raised

export var state_name: String

onready var state_name_label := $VBoxContainer/IconButton
onready var level_label := $VBoxContainer/Label
onready var level_up_button := $VBoxContainer/Button
onready var audio_stream := $AudioStreamPlayer


# Обновляет информацию кнопки.
func update_button() -> void:
  # Получает имя характеристики.
  if Global.state_names.has(state_name):
    state_name_label.text = Global.state_names[state_name]
  else:
    return
  
  # Получает уровень характеристики.
  if Global.player_progress.has(state_name):
    level_label.text = 'Уровень %s' % [Global.player_progress[state_name]]
  else:
    return
    
  # Получает стоимость улучшения характеристики.
  if Global.player_levels_cost.has(state_name):
    var levels_costs: Array = Global.player_levels_cost[state_name]
    
    var player_level: int = Global.player_progress[state_name]
    if levels_costs.size() <= player_level:
      level_up_button.text = 'MAX'
      return
    
    level_up_button.text = str(levels_costs[player_level])
    
    if levels_costs[player_level] > Global.player_progress['gems']:
      level_up_button.disabled = true
  else:
    return


# Улучшение характеристики.
func _on_Button_pressed() -> void:
  # Проверяет, можно ли улучшить уровень.
  if not Global.player_progress.has(state_name):
    return
  var player_level: int = Global.player_progress[state_name]
  
  if not Global.player_levels_cost.has(state_name):
    return
  var levels_costs: Array = Global.player_levels_cost[state_name]
  
  if not Global.player_progress.has('gems'):
    return
  var player_gems: int = Global.player_progress['gems']
  
  if levels_costs.size() <= player_level:
    return
  var state_cost: int = levels_costs[player_level]
  
  if state_cost > player_gems:
    return
    
  # Улучшает уровень.
  Global.player_progress['gems'] -= state_cost
  Global.player_progress[state_name] += 1
  audio_stream.play()
  emit_signal("level_raised")
  
