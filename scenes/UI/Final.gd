class_name Final
extends Control

onready var result_label := $MarginContainer/VBoxContainer/ResultLabel
onready var gems_label := $MarginContainer/VBoxContainer/HBoxContainerGems/GemLabel
onready var kills_label := $MarginContainer/VBoxContainer/HBoxContainerKills/KillsLabel


func _ready() -> void:
  hide()
  
  
func set_gems_amount(gems_amount: int) -> Final:
  gems_label.text = str(gems_amount)
  return self
  
  
func set_kills_amount(kills_amount: int) -> Final:
  kills_label.text = str(kills_amount)
  return self
  
  
func set_header(text: String) -> Final:
  result_label.text = text
  return self


func show_win() -> void:
  set_header('Победа').show()


func show_lose() -> void:
  set_header('Поражение').show()


func _on_Button_pressed() -> void:
  hide()
