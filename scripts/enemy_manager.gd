extends Node
class_name EnemyManager

signal enemy_changed(enemy_data: Dictionary)
signal enemy_defeated(reward: int)

var stage := 1
var wave := 1
var max_wave := 10
var enemy_name := "Slime Boss"
var max_health := 70.0
var current_health := 70.0

func import_state(data: Dictionary) -> void:
	stage = int(data.get("stage", stage))
	wave = int(data.get("wave", wave))
	spawn_enemy()


func export_state() -> Dictionary:
	return {"stage": stage, "wave": wave}


func spawn_enemy() -> void:
	var titles := ["Slime Boss", "Horn Beetle", "Stone Golem", "Sky Bat", "Crystal Mimic"]
	enemy_name = titles[(stage - 1) % titles.size()]
	max_health = 60.0 + (stage - 1) * 22.0 + (wave - 1) * 12.0
	current_health = max_health
	emit_signal("enemy_changed", get_enemy_state())


func get_enemy_state() -> Dictionary:
	return {
		"name": enemy_name,
		"current_health": current_health,
		"max_health": max_health,
		"stage": stage,
		"wave": wave,
		"progress": float(wave - 1) / float(max_wave)
	}


func apply_damage(amount: float) -> void:
	current_health = max(current_health - amount, 0.0)
	if current_health <= 0.0:
		var reward := int(15 + stage * 6 + wave * 4)
		emit_signal("enemy_defeated", reward)
		wave += 1
		if wave > max_wave:
			wave = 1
			stage += 1
		spawn_enemy()
	else:
		emit_signal("enemy_changed", get_enemy_state())
