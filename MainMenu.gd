class_name MainMenu
extends Control


var button_captions: Array = [
  'В битву!',
  'Начать полёт',
  'Начать',
  'К звёздам!',
  'Поехали!',
  'Полетели!',
  'Бесконечность'
]

onready var score_label := $MarginContainer/HBoxContainer/VBoxContainer/HFlowContainer/ScoreLabel
onready var kills_label := $MarginContainer/HBoxContainer/VBoxContainer/HFlowContainer2/KillsLabel
onready var waves_label := $MarginContainer/HBoxContainer/VBoxContainer/WavesLabel
onready var buttons_container := $MarginContainer/HBoxContainer/ScrollContainer/VBoxContainer2
onready var audio_stream := $AudioStreamPlayer


func _ready() -> void:
  Yasdk.js_show_ad()
  randomize()
  $MarginContainer/HBoxContainer/VBoxContainer/Button.text = button_captions[rand_range(0, button_captions.size() - 1)]
  
  for level_up_button in buttons_container.get_children():
    level_up_button.connect('level_raised', self, 'update_gems_and_buttons')
    
  update_gems_and_buttons()


## Обновляет метку с количеством гемов, а так же кнопки получения уровней.
func update_gems_and_buttons() -> void:
  # Отображает количество кристаллов.
  if Global.player_progress.has('gems'):
    score_label.text = str(Global.player_progress['gems'])
  else:
    printerr('Can not find key gems in player_progress.')
  # Отображает количеств побед.
  if Global.player_progress.has('kills'):
    kills_label.text = str(Global.player_progress.kills)
  # Отображает количество пройденных волн.
  if Global.player_progress.has('waves_finished'):
    var waves_finished: int = Global.player_progress.waves_finished
    var waves_total_amount: int = Global.default_scene_settings.size()
    waves_label.text = 'Волн пройдено: %d/%d' % [waves_finished, waves_total_amount]
    if waves_finished >= waves_total_amount:
      waves_label.text = waves_label.text + ' Спасибо за игру! Следите за обновлениями!'
  
  for level_up_button in buttons_container.get_children():
    level_up_button.update_button()
  Global.save_game()


func _on_Button_pressed() -> void:
  audio_stream.stop()
  yield(get_tree().create_timer(0.25), "timeout")
  get_tree().change_scene("res://DefaultScene.tscn")
