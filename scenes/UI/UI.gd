extends CanvasLayer

const WAVE_LABEL_TEMPLATE := 'Волна: %d'
const ENEMY_LABEL_TEMPLATE := 'Врагов: %d'

onready var timer_label := $HUD/VBoxContainer/TimerLabel
onready var score_label := $HUD/VBoxContainer/HBoxContainer/ScoreLabel
onready var wave_label := $HUD/VBoxContainer/HBoxContainer2/WaveLabel
onready var enemy_label :=  $HUD/VBoxContainer/HBoxContainer2/EnemiesLabel

func set_timer_text(text: String) -> void:
  timer_label.text = text


func set_score_value(value: int) -> void:
  score_label.text = str(value)
  
  
func set_enemies_value(value: int) -> void:
  enemy_label.text = ENEMY_LABEL_TEMPLATE % [value]


func set_wave_number(number: int) -> void:
  wave_label.text = WAVE_LABEL_TEMPLATE % [number]
