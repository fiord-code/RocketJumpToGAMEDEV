class_name SkillSelectionWindow
extends Control


export var skills_to_show: int
export var times_to_show: int

var max_times_to_show: int = 3
var max_player_turrets_amount: int = 3

var player: WeakRef
var player_turret := preload("res://scenes/weapons/turrets/PlayerTurretA.tscn")
var skills := {
  'attack': 'upgrade_attack',
  'defence': 'upgrade_defence',
  'speed': 'upgrade_speed',
  'steering': 'upgrade_steering',
  'health': 'upgrade_health',
  'times_to_show': 'upgrade_times_to_show',
  'turret': 'add_turret'
 }
var skills_names := [
  {'button_text': 'Атака', 'skill_name': 'attack'},
  {'button_text': 'Защита', 'skill_name': 'defence'},
  {'button_text': 'Скорость', 'skill_name': 'speed'},
  {'button_text': 'Маневренность', 'skill_name': 'steering'},
  {'button_text': 'Прочность', 'skill_name': 'health'},
  {'button_text': 'Количество улучшений', 'skill_name': 'times_to_show'},
  {'button_text': 'Турель', 'skill_name': 'turret'},
]
onready var buttons_container := $MarginContainer/Panel/VBoxContainer/ScrollContainer/VBoxContainer
onready var audio_stream := $AudioStreamPlayer


func _ready() -> void:
  pass


## Устаналивает персонажа, к которому будут применяться улучшения.
func set_player(player: BasicPlayer) -> SkillSelectionWindow:
  self.player = weakref(player)
  return self
  

## Устанавливает количество способностей, которое нужно показать.
func set_skills_to_show(skills_to_show: int) -> SkillSelectionWindow:
  self.skills_to_show = skills_to_show
  return self


## Устанавливает, скольк раз игрок сможет выбрать способность.
func set_times_to_show(times_to_show: int) -> SkillSelectionWindow:
  self.times_to_show = times_to_show
  return self


## Применяет выбранное игроком улучшение.
func apply_upgrade(skill_name: String) -> void:
  if not skills.has(skill_name):
    return
  if (player == null) or not player.get_ref():
    return  
  audio_stream.play()
  var upgrade_function_name: String = skills[skill_name]
  call_deferred(upgrade_function_name)


func show_skills() -> void:
  if times_to_show <= 0:
    hide()
    return
  times_to_show -= 1
  create_skills()
  show()


func create_skills() -> void:
  for child in buttons_container.get_children():
    child.queue_free()
  # Ограничивает число улучшений на волну.
  var deprecated_skills: Array = []
  if owner.times_to_show >= max_times_to_show:
    deprecated_skills.append('times_to_show')
  # Ограничивает число турелей.
  if owner.player_turrets_amount >= max_player_turrets_amount:
    deprecated_skills.append('turret')
  # Добавляет кнопки со способностями.
  skills_names.shuffle()
  var skill_index: int = -1
  var skills_added: int = 0
  while skills_added < skills_to_show:
    # Проверяет, можно ли добавить скилл.
    skill_index += 1
    var skill: Dictionary = skills_names[skill_index]
    if skill.skill_name in deprecated_skills:
      continue
    # Добавляет скилл.
    var skill_button := Button.new()    
    skill_button.text = skill.button_text
    skill_button.connect("pressed", self, 'on_upgrade_button_pressed', [skill.skill_name])
    buttons_container.add_child(skill_button)
    skills_added += 1
    

func on_upgrade_button_pressed(skill_name: String) -> void:
  apply_upgrade(skill_name)
  show_skills()
  

func upgrade_attack() -> void:
  player.get_ref().attack_modifier += 0.30
  Event.emit_signal("attack_modified")
  
func upgrade_defence() -> void:
  player.get_ref().defence_modifier += 6
  
func upgrade_speed() -> void:
  player.get_ref().max_speed += 20
  
func upgrade_steering() -> void:
  player.get_ref().steering_factor = clamp(
    player.get_ref().steering_factor + 0.075,
    0,
    0.4
   )
  
func upgrade_health() -> void:
  player.get_ref().max_health += 25
  player.get_ref().take_heal(player.get_ref().max_health)
  player.get_ref().setup_healthbar()
  
func upgrade_times_to_show() -> void:
  owner.times_to_show += 1
  

func add_turret() -> void:
  var new_turret := player_turret.instance()
  player.get_ref().call_deferred('add_child', new_turret)
  owner.player_turrets_amount += 1
