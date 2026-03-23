extends Node
class_name GameManager

signal state_changed(game_state: Dictionary)
signal offline_reward_ready(reward: Dictionary)

@export var auto_attack_interval := 0.45
@export var tap_damage := 18.0

var coins := 0
var gems := 25
var auto_mode := true
var coin_rate := 1.0

@onready var save_manager: SaveManager = $SaveManager
@onready var unit_manager: UnitManager = $UnitManager
@onready var enemy_manager: EnemyManager = $EnemyManager

var _auto_timer := 0.0

func _ready() -> void:
	unit_manager.units_changed.connect(_on_units_changed)
	enemy_manager.enemy_changed.connect(_emit_state)
	enemy_manager.enemy_defeated.connect(_on_enemy_defeated)
	load_game()
	if enemy_manager.current_health <= 0.0:
		enemy_manager.spawn_enemy()
	_emit_state()


func _process(delta: float) -> void:
	_auto_timer += delta
	if auto_mode and _auto_timer >= auto_attack_interval:
		_auto_timer = 0.0
		enemy_manager.apply_damage(max(1.0, unit_manager.get_total_dps() * auto_attack_interval))


func tap_attack() -> void:
	enemy_manager.apply_damage(tap_damage)


func toggle_auto() -> void:
	auto_mode = not auto_mode
	_emit_state()


func upgrade_unit(index: int) -> Dictionary:
	var result := unit_manager.upgrade_unit(index, coins)
	if result.get("success", false):
		coins -= int(result["cost"])
		coin_rate = max(1.0, unit_manager.get_total_dps() * 0.25)
		save_game()
		_emit_state()
	return result


func get_state() -> Dictionary:
	return {
		"coins": coins,
		"gems": gems,
		"auto_mode": auto_mode,
		"coin_rate": coin_rate,
		"dps": unit_manager.get_total_dps(),
		"enemy": enemy_manager.get_enemy_state(),
		"units": unit_manager.units
	}


func save_game() -> void:
	var payload := {
		"coins": coins,
		"gems": gems,
		"auto_mode": auto_mode,
		"coin_rate": coin_rate,
		"enemy": enemy_manager.export_state(),
		"units": unit_manager.export_state()
	}
	save_manager.save_game(payload)


func load_game() -> void:
	var data := save_manager.load_game()
	if data.is_empty():
		enemy_manager.spawn_enemy()
		return
	coins = int(data.get("coins", coins))
	gems = int(data.get("gems", gems))
	auto_mode = bool(data.get("auto_mode", auto_mode))
	coin_rate = float(data.get("coin_rate", coin_rate))
	unit_manager.import_state(data.get("units", []))
	enemy_manager.import_state(data.get("enemy", {}))
	var reward := save_manager.calculate_offline_reward(data)
	coins += int(reward.get("coins", 0))
	emit_signal("offline_reward_ready", reward)


func _on_enemy_defeated(reward: int) -> void:
	coins += reward
	gems += int(reward / 40)
	coin_rate = max(1.0, unit_manager.get_total_dps() * 0.25)
	save_game()
	_emit_state()


func _on_units_changed(_units: Array) -> void:
	_emit_state()


func _emit_state() -> void:
	emit_signal("state_changed", get_state())
