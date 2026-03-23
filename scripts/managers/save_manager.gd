extends Node
class_name SaveManager

const SAVE_PATH: String = "user://idle_battler_save.json"

# Persists gameplay data and calculates offline gains.
func save_game(payload: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Unable to save game to %s" % SAVE_PATH)
		return
	payload["last_saved_unix"] = Time.get_unix_time_from_system()
	file.store_string(JSON.stringify(payload))


func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}


func calculate_offline_reward(state: Dictionary) -> Dictionary:
	var now: int = Time.get_unix_time_from_system()
	var last_saved: int = int(state.get("last_saved_unix", now))
	var elapsed: int = maxi(0, now - last_saved)
	var reward_rate: float = float(state.get("coin_rate", 1.0))
	var reward: int = int(mini(elapsed, 3600) * reward_rate)
	return {
		"elapsed": elapsed,
		"coins": reward
	}
