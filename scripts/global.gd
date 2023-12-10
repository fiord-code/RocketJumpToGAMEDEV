extends Node


const path_to_save_file := "user://progress.save"
const path_to_default_scene_settings_file := "res://res/settings/default_scene_settings.csv"
const path_to_enemies_settings_file := "res://res/settings/enemies_settings.csv"

# Счётчик побед над вражескими кораблями.
var player_progress := {
  'kills': 0,
  'health_level': 1,
  'speed_level': 1,
  'steering_level': 1,
  'attack_level': 1,
  'defence_level': 1,
  'gems': 0,
  'waves_finished': 0
}

# Настройки стандартной арены.
var default_scene_settings: Dictionary
# Характеристики врагов.
var enemies_settings: Dictionary

# Словарь со значениями характеристик на разных уровнях.
# Ключ - название характеристики. Значение - массив. 
# Индекс - уровень (0 - 1 lvl), значение - модификатор характеристики.
var player_levels := {
  'health_level':   [1.0, 1.15, 1.3, 1.45, 1.6, 1.75, 1.9, 2.05, 2.2, 2.35],
  'speed_level':    [1.0, 1.01, 1.02, 1.03, 1.04, 1.05, 1.06, 1.07, 1.08, 1.09],
  'steering_level': [1.0, 1.05, 1.1, 1.15, 1.2, 1.25, 1.3, 1.35, 1.4, 1.45],
  'attack_level':   [1.0, 1.07, 1.14, 1.21, 1.28, 1.35, 1.42, 1.49, 1.55, 1.60],
  'defence_level':  [0.0, 3, 6, 9, 12, 15, 18, 21, 24, 27]
}

var player_levels_cost := {
  'health_level':   [0, 10, 20, 30, 40, 50, 60, 70, 80, 90],
  'speed_level':    [0, 10, 20, 30, 40, 50, 60, 70, 80, 90],
  'steering_level': [0, 10, 20, 30, 40, 50, 60, 70, 80, 90],
  'attack_level':   [0, 10, 20, 30, 40, 50, 60, 70, 80, 90],
  'defence_level':  [0, 10, 20, 30, 40, 50, 60, 70, 80, 90],
 }

var state_names := {
  'health_level': 'Прочность',
  'speed_level': 'Скорость',
  'steering_level': 'Маневренность',
  'attack_level': 'Атака',
  'defence_level': 'Защита'
 }

# Возвращает значение характеристики.
func get_state_value(state_name: String) -> float:
  # Проверяет, есть ли характеристика в уровнях.
  if not player_levels.has(state_name):
    print('player_levels does not have key "%s"' % [state_name])
    return 1.0
  # Проверят, есть ли уровни у характеристики.
  if not player_progress.has(state_name):
    print('player_progress does not have key "%s"' % [state_name])
    return 1.0
  
  # Проверяет значение уровня характеристики.
  var state_level: int = player_progress[state_name]
  if state_level < 0:
    print('State level less than zero. State: %s' % [state_name])
    return 1.0
  
  # Проверяет, есть ли значения в уровнях характеристики.
  var max_state_level: int = len(player_levels[state_name])
  if max_state_level == 0:
    print('No level states. State: %s' % [state_name])
    return 1.0
  
  # Проверяет, не превосходит ли уровень характеристики максимальный.
  if (max_state_level < state_level):
    print('State: %s. Level: %d. Level exceeds max state level.' % [state_name, state_level])
    return player_levels[state_name][max_state_level - 1]
  
  # Возвращает значение характеристики на текущем уровне.
  return player_levels[state_name][state_level - 1]


func _ready() -> void:
  if not OS.is_userfs_persistent():
    print('User file system is not persistent. Game progress may not be saved.')
    
  load_save()
  default_scene_settings = load_csv_from_file(path_to_default_scene_settings_file)
  enemies_settings = load_csv_from_file(path_to_enemies_settings_file)


func save_game() -> void:
  # Сохраняет игровые данные.
  # Получает словарь с игровыми данными.
  var game_data := get_game_data()
  # Открывает файл с сохранением.
  var save_file := File.new()
  var err_code := save_file.open(path_to_save_file, File.WRITE)
  # Проверяет, удалось ли открыть файл.
  if err_code != OK:
    print("Can't open save file to save a game. Error code: %d" % [err_code])
    if save_file.is_open():
      save_file.close()
    return
  # Сохраняет данные.
  save_file.store_string(to_json(game_data))
  save_file.close()


func load_save() -> void:  
  # Загружает игровые данные.
  var save_file := File.new()
  # Выходит, если файла с сохранением не существует.
  if not save_file.file_exists(path_to_save_file):
    print("Can't load save: save file doesn't exist.")
    return
  # Открывает файл с сохранением.
  var err_code := save_file.open(path_to_save_file, File.READ)
  # Если не удалось открыть файл с сохранением, то выходит.
  if err_code != OK:
    print("Can't open save file. Error code: %d." % [err_code])
    if save_file.is_open():
      save_file.close()
    return
  # Читает весь файл.
  var game_data := save_file.get_as_text()
  # Закрывает файл с сохранением.
  save_file.close()
  # Парсит полученные из файла с сохранением данные и получает данные.
  if not game_data:
    print('Savefile is empty. Can not load data.')
    return
  set_game_data(parse_json(game_data))
  


func get_game_data() -> Dictionary:
  # Возвращает игровые данные в виде словаря.
  return player_progress


func set_game_data(game_data: Dictionary) -> void:
  for key in player_progress:
    if game_data.has(key):
      player_progress[key] = game_data[key]


func load_csv_from_file(path_to_file: String, delim=';') -> Dictionary:
  # Открывает файл.
  var loaded_dictionary = {}
  var csv_file = File.new()
  
  if not csv_file.file_exists(path_to_file):
    print('File %s does not exist.' % [path_to_file])
  
  var err_code: int = csv_file.open(path_to_file, File.READ)
  
  if err_code != OK:
    print('Can not open the %s file.' % [path_to_file])
    if csv_file.is_open():
      csv_file.close()
    return {}
    
  # Загружает из файла данные.
  var fields_names: Dictionary = {}
  
  # Загружает названия столбцов.
  var fields_names_str: PoolStringArray = csv_file.get_csv_line(delim)
  for i in fields_names_str.size():
    fields_names[i] = fields_names_str[i]
  
  # Загружает записи.
  while csv_file.get_position() < csv_file.get_len():
    # Строка с полями одной записи.
    var csv_line: PoolStringArray = csv_file.get_csv_line(delim)
    # Словарь с полями записи, который будет заполняться.
    var csv_record: Dictionary = {}
    # Цикл по полям записи.
    for i in range(1, csv_line.size()):
      # Получает имя поля.
      var field_name: String = fields_names[i]
      # Значение поля в записи, в котором возможные разделители целой и дробной
      # части чисел с плавающей запятй заменены на '.'.
      var csv_value: String = csv_line[i].replace(',', '.').strip_edges()
      # Преобразует значение поля в подходящий тип данных.
      if csv_value.is_valid_integer():
        csv_record[field_name] = int(csv_value)
      elif csv_value.is_valid_float():
        csv_record[field_name] = float(csv_value)
      else:
        csv_record[field_name] = csv_line[i]
        
    # Сохраняет загруженную запись. 
    # Первичный ключ записи.
    var primary_key_value: String = csv_line[0]
    # Если получится преобразовать первичный ключ в целое число, то преобразует.
    # Иначе записывает ПК как строку.
    if primary_key_value.is_valid_integer():
      loaded_dictionary[int(primary_key_value)] = csv_record
    else:
      loaded_dictionary[primary_key_value] = csv_record
  
  csv_file.close()
  
  return loaded_dictionary
  
