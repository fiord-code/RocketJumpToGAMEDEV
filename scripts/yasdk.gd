extends Node


var callback_rewarded_ad := JavaScript.create_callback(self, '_rewarded_ad')
var callback_ad := JavaScript.create_callback(self, '_ad')
var hide_callback := JavaScript.create_callback(self, '_mute_on_hide')
var show_callback := JavaScript.create_callback(self, '_unmute_on_show')
var is_showing_ad := false

onready var win = JavaScript.get_interface("window")


func _ready() -> void:
  if not win:
    return
  win.AddVisibilityChangeListener(hide_callback, show_callback)


func js_show_ad():
  if not win:
    return
  win.ShowAd(callback_ad)
  is_showing_ad = true
  # Здесь можно приостановить музыку / звуки
  AudioServer.set_bus_mute(0, true)
  
  
func js_show_rewarded_ad():
  if not win:
    return
  win.ShowAdRewardedVideo(callback_rewarded_ad)
  is_showing_ad = true
  # Здесь можно приостановить музыку / звуки
  AudioServer.set_bus_mute(0, true)
  
  
func _rewarded_ad(args):
  print(args[0])
  is_showing_ad = false
  # Здесь можно возобновить музыку / звуки
  AudioServer.set_bus_mute(0, false)
  
  
func _ad(args):
  print(args[0])
  is_showing_ad = false
  # Здесь можно возобновить музыку / звуки
  AudioServer.set_bus_mute(0, false)
  
  
func _mute_on_hide(args):
  AudioServer.set_bus_mute(0, true)
  
  
func _unmute_on_show(args):
  if is_showing_ad:
    return
  AudioServer.set_bus_mute(0, false)
  
