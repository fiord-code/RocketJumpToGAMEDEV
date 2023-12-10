extends Node2D


var round_number: int = 0
# Время раунда в секундах.
var round_time: float
# Оставшееся время раунда.
var time_left: float
# Процент, в который устанавливается время спавна, если игрок убивает волну быстрее, чем спавнится следующая.
var spawn_decrease_rate: float
# Количество врагов в волне.
var enemies_to_spawn: float
# Время между волнами.
var spawn_time: float
var skills_to_show: int = 4
var times_to_show: int = 1
var player_turrets_amount: int = 0

var waves_to_grow: int
var max_enemies_count: int = 15
var round_ended: bool = false
# Расстояние от игрока, на котором спавнятся враги.
export var spawn_radius := 1000.0
# Если игрок близко краю карты, то враги спавнятся по направлению от игрока к центру карты с отклонением spawn_deviation.
export var spawn_deviation := PI / 3
# Время до спавна первой волны.
export var first_spawn_time := 1.0
# Количество волн, которые должны пройти перед тем, как количество врагов в волне увеличится.


const enemy_scenes = {
  'EnemyShipA': preload("res://scenes/characters/EnemyShips/EnemyShipA.tscn"),
  'EnemyShipB': preload("res://scenes/characters/EnemyShips/EnemyShipB.tscn"),
  'EnemyShipB1': preload("res://scenes/characters/EnemyShips/EnemyShipB1.tscn"),
  'EnemyShipB2': preload("res://scenes/characters/EnemyShips/EnemyShipB2.tscn"),
  'EnemyShipC': preload("res://scenes/characters/EnemyShips/EnemyShipC.tscn"),
  'EnemyShipT1': preload("res://scenes/characters/EnemyShips/EnemyShipT1.tscn"),
  'EnemyShipT2': preload("res://scenes/characters/EnemyShips/EnemyShipT2.tscn"),
  'EnemyShipT3': preload("res://scenes/characters/EnemyShips/EnemyShipT3.tscn"),
 } 

onready var spawn_timer := $Spawner/SpawnTimer
onready var round_timer := $RoundTimer
onready var spawn_shape := $Spawner/SpawnArea/CollisionShape2D
onready var enemies_node := $Enemies
onready var player_ship := weakref($PlayerShipA)

onready var ui := $UI
onready var skill_window := $UI/SkillSelectionWindow 
onready var final_window := $UI/Final

onready var enemy_blast_stream := $AudioStreamEnemyBlast
onready var collect_gem_stream := $AudioStreamCollectGem

var enemies_count := 0
var waves_amount := 0
var enemies_kills := 0
var gems_collected := 0

onready var laser_streams := [
  $AudioStreamLaser1,
  $AudioStreamLaser2,
  $AudioStreamLaser3,
  $AudioStreamLaser4,
  $AudioStreamLaser5,
 ]


# Запускает таймер спавна волны.
func start_spawn_timer(wait_time: float) -> void:
  spawn_timer.wait_time = wait_time
  spawn_timer.start()
  

# Возвращает позицию спавна врага.
func get_spawn_position() -> Vector2:
  var spawn_position_offset := Vector2.RIGHT.rotated(randf() * 2 * PI) * spawn_radius
  var player_position: Vector2 = player_ship.get_ref().position
  var spawn_position: Vector2 = player_position + spawn_position_offset
  if spawn_position.length() > spawn_shape.shape.radius:
    spawn_position_offset = player_position.direction_to(Vector2.ZERO).rotated(-spawn_deviation / 2 + randf() * spawn_deviation) * spawn_radius
    spawn_position = player_position + spawn_position_offset
  return spawn_position


func _process(delta: float) -> void:
  ui.set_enemies_value(enemies_count)
  

# Спавнит врага.
func spawn_enemy(enemy_ship_name: String) -> void:
  if (player_ship == null) or not player_ship.get_ref():
    return
  
  spawn_enemy_on_position(get_spawn_position(), enemy_ship_name)


# Спавнит врага по переданным координатам.
func spawn_enemy_on_position(spawn_position: Vector2, enemy_ship_name: String) -> void:
  # Создаёт объект вражеского корабля.
  var enemy_instance: BasicEnemy = enemy_scenes[enemy_ship_name].instance()
  # Задаёт цель для врага.
  enemy_instance.set_target(player_ship.get_ref())
  # Устаналивает начальное положение.
  enemy_instance.set_spawn_position(spawn_position)
  # Безопасно добавляет врага на сцену.
  enemies_node.call_deferred("add_child", enemy_instance)
  # Устанавливает callback на смерть врага.
  track_character(enemy_instance)
  

func _ready() -> void:
  randomize()
  # Выходит из сцены после смерти игрока.
  $PlayerShipA.connect("died", self, 'lose_game')
  Event.connect("item_collected", self, '_on_item_collected')
  Event.connect("item_collected", self, 'play_collect_sound')
  Event.connect("enemy_shoot", self, 'play_random_shoot')
  Event.connect("player_shoot", self, 'play_random_shoot')
  Event.connect("enemy_died", self, 'play_sfx', [enemy_blast_stream])
  start_next_round()


# Устанавливает отслеживание переданного персонажа.
func track_character(character: BasicCharacter) -> void:
  enemies_count += 1
  if not character.is_connected("died", self, 'decrease_enemy_count'):
    character.connect("died", self, 'decrease_enemy_count')


# Обновляет глобальные переменные.
func update_global() -> void:
  Global.player_progress.kills += enemies_kills
  Global.player_progress.gems += gems_collected
  var max_waves_finished: int = Global.player_progress.waves_finished
  Global.player_progress.waves_finished = max(max_waves_finished, round_number - 1)


func lose_game() -> void:
  round_timer.stop()
  spawn_timer.stop()
  ui.set_timer_text('')
  round_ended = true
  Event.emit_signal("round_ended")
  enemies_count = 0
  final_window.set_gems_amount(gems_collected).set_kills_amount(enemies_kills).show_lose()
  yield(final_window, 'hide')
  $AudioStreamPlayer.stop()
  yield(get_tree().create_timer(0.2), "timeout")
  end_round()


# Заканчивает раунд.
func end_round() -> void:
  $AudioStreamPlayer.stop()
  update_global()
  Global.save_game()
  get_tree().call_group('collectibles', 'queue_free')
  load_menu()


# Загружает меню.
func load_menu() -> void:
  get_tree().change_scene("res://MainMenu.tscn")


# Уменьшает счётчик количества врагов и производит связанные с этим вычисления.
func decrease_enemy_count() -> void:
  if round_ended:
    return
  # Обновляет счётчики.
  enemies_count -= 1
  enemies_kills += 1
  
  # Если врагов на сцене не осталось, то немедленно спавнит новую волну.
  if enemies_count > 0:
    return
  # Если следующая волна скоро появится, то ничего делать не нужно.
  if spawn_timer.time_left <= first_spawn_time and not spawn_timer.is_stopped():
    return
  # Инициирует спавн следующей волны.
  if not spawn_timer.is_stopped():
    spawn_timer.stop()
  start_spawn_timer(first_spawn_time)
  # Уменьшает время до спавна следующей волны.
  spawn_time *= spawn_decrease_rate


# Обновляет счётчик до конца раунда.
func _on_RoundTimer_timeout() -> void:
  time_left -= 1
  ui.set_timer_text(str(time_left))
  
  if time_left <= 0:
    $RoundTimer.stop()
    start_next_round()


func choose_random_enemy() -> String:
  # Построение пороговых значений.
  var round_settings: Dictionary = Global.default_scene_settings[round_number]
  var bias_values: Array = []
  var accumulative_value: int = 0
  for ship_name in enemy_scenes:
    if not round_settings.has(ship_name):
      continue
    accumulative_value += round_settings[ship_name]
    bias_values.append({
      'name': ship_name,
      'value': accumulative_value 
    });
  # Выбор случайного элемента.
  var random_value: float = randf() * accumulative_value
  for pair in bias_values:
    if random_value <= pair.value:
      return pair.name
  
  return bias_values.back().name


# Спавнит волну врагов.
func _on_SpawnTimer_timeout() -> void:
  if round_ended:
    return
  if enemies_count >= max_enemies_count:
    get_tree().call_group('enemies', 'on_boost')
    start_spawn_timer(spawn_time)
    return
  for i in range(enemies_to_spawn):
    var enemy_ship_name := choose_random_enemy()
    spawn_enemy(enemy_ship_name)
    
  waves_amount += 1
  
  if waves_amount % waves_to_grow == 0:
    enemies_to_spawn += 1
  
  start_spawn_timer(spawn_time)


func _on_item_collected(item_cost: int) -> void:
  gems_collected += item_cost
  ui.set_score_value(gems_collected)
  final_window.set_gems_amount(gems_collected)


func setup_round(round_number: int) -> void:
  # Настраивает раунд.
  round_time = Global.default_scene_settings[round_number].round_time
  time_left = round_time
  spawn_decrease_rate = Global.default_scene_settings[round_number].spawn_decrease_rate
  enemies_to_spawn = Global.default_scene_settings[round_number].enemies_to_spawn
  spawn_time = Global.default_scene_settings[round_number].spawn_time
  waves_to_grow = Global.default_scene_settings[round_number].waves_to_grow
  # Начальное значение таймера.
  ui.set_timer_text(str(time_left))
  # Показывает окно выбора способностей.
  spawn_timer.stop()
  skill_window.set_skills_to_show(skills_to_show).set_times_to_show(times_to_show).set_player(player_ship.get_ref())
  skill_window.show_skills()
  yield(skill_window, 'hide')
  start_spawn_timer(first_spawn_time)
  round_timer.start()
  enemies_count = 0
  round_ended = false
  
  
func start_next_round() -> void:
  # Увеличивает номер раунда.
  round_number += 1
  round_ended = true
  Event.emit_signal("round_ended")
  enemies_count = 0
  # Если был последний раунд, то выходит.
  if not Global.default_scene_settings.has(round_number):
    ui.set_timer_text('')
    final_window.set_gems_amount(gems_collected).set_kills_amount(enemies_kills).show_win()
    yield(final_window, 'hide')
    end_round()
    return
  # Настраивает раунд.
  setup_round(round_number)
  # Отображает номер волны.
  ui.set_wave_number(round_number)


func play_sfx(sfx_stream: AudioStreamPlayer):
  var pitch_scale := 0.5 + randf()
  sfx_stream.pitch_scale = pitch_scale
  sfx_stream.play()

func play_collect_sound(item_cost: float):
  var pitch_scale := 0.5 + randf()
  collect_gem_stream.pitch_scale = pitch_scale
  collect_gem_stream.play()
  
  
func play_random_shoot():
  var random_stream: AudioStreamPlayer = laser_streams[randi() % laser_streams.size()]
  var pitch_scale := 0.5 + randf()
  random_stream.pitch_scale = pitch_scale
  random_stream.play()
