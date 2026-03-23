extends Node
class_name UnitManager

signal units_changed(units: Array)

# Defines the roster shown in the bottom barracks area.
var units: Array[Dictionary] = [
	{"name": "Knight", "level": 1, "base_cost": 30, "dps": 4.0, "accent": Color("#5ec8ff"), "role": "Frontline"},
	{"name": "Mage", "level": 1, "base_cost": 55, "dps": 6.5, "accent": Color("#ad6cff"), "role": "AoE"},
	{"name": "Archer", "level": 1, "base_cost": 45, "dps": 5.0, "accent": Color("#60e38e"), "role": "Rapid"},
	{"name": "Guardian", "level": 0, "base_cost": 110, "dps": 12.0, "accent": Color("#ffc14d"), "role": "Tank"},
	{"name": "Priest", "level": 0, "base_cost": 150, "dps": 15.5, "accent": Color("#ff7ab6"), "role": "Support"}
]

func import_state(saved_units: Array) -> void:
	if saved_units.size() == units.size():
		for i: int in units.size():
			units[i]["level"] = int(saved_units[i].get("level", units[i]["level"]))
	emit_signal("units_changed", units)


func export_state() -> Array:
	var data: Array[Dictionary] = []
	for unit: Dictionary in units:
		data.append({"name": unit["name"], "level": unit["level"]})
	return data


func get_total_dps() -> float:
	var total: float = 0.0
	for unit: Dictionary in units:
		total += float(unit["level"]) * float(unit["dps"])
	return total


func get_upgrade_cost(index: int) -> int:
	var unit: Dictionary = units[index]
	return int(float(unit["base_cost"]) * pow(1.35, int(unit["level"])))


func get_unit_power_text(index: int) -> String:
	var unit: Dictionary = units[index]
	return "%s • DPS %0.1f" % [str(unit["role"]), float(unit["dps"]) * max(1, int(unit["level"]))]


func upgrade_unit(index: int, available_coins: int) -> Dictionary:
	var cost: int = get_upgrade_cost(index)
	if available_coins < cost:
		return {"success": false, "reason": "Not enough coins."}
	units[index]["level"] = int(units[index]["level"]) + 1
	emit_signal("units_changed", units)
	return {"success": true, "cost": cost, "unit": units[index]}
