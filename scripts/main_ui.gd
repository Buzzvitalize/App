extends Control

@onready var game_manager: GameManager = $GameManager
@onready var enemy_bar: ProgressBar = %EnemyHealthBar
@onready var enemy_name_label: Label = %EnemyNameLabel
@onready var stage_label: Label = %StageLabel
@onready var wave_label: Label = %WaveLabel
@onready var progress_bar: ProgressBar = %StageProgressBar
@onready var coin_label: Label = %CoinLabel
@onready var gem_label: Label = %GemLabel
@onready var dps_label: Label = %DpsLabel
@onready var auto_button: Button = %AutoButton
@onready var battle_button: Button = %BattleTapButton
@onready var status_label: Label = %StatusLabel
@onready var floating_text: Label = %FloatingDamageLabel
@onready var unit_grid: GridContainer = %UnitGrid
@onready var offline_popup: PanelContainer = %OfflinePopup
@onready var offline_label: Label = %OfflineLabel
@onready var player_one: ColorRect = %PlayerOne
@onready var player_two: ColorRect = %PlayerTwo
@onready var enemy_actor: ColorRect = %EnemyActor

var _unit_cards: Array[Dictionary] = []
var _float_tween: Tween

func _ready() -> void:
	_apply_mock_theme()
	_build_unit_cards()
	_start_actor_bobs()
	game_manager.state_changed.connect(_refresh_ui)
	game_manager.offline_reward_ready.connect(_show_offline_reward)
	battle_button.pressed.connect(_on_battle_tap_button_pressed)
	auto_button.pressed.connect(_on_auto_button_pressed)
	_refresh_ui(game_manager.get_state())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("tap_attack"):
		game_manager.tap_attack()
		_play_damage_feedback()


func _build_unit_cards() -> void:
	for child in unit_grid.get_children():
		child.queue_free()
	_unit_cards.clear()
	for i in game_manager.unit_manager.units.size():
		var unit: Dictionary = game_manager.unit_manager.units[i]
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(0, 168)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var style := StyleBoxFlat.new()
		style.bg_color = Color("#203a68")
		style.border_color = unit["accent"]
		style.border_width_left = 4
		style.border_width_top = 4
		style.border_width_right = 4
		style.border_width_bottom = 4
		style.corner_radius_top_left = 24
		style.corner_radius_top_right = 24
		style.corner_radius_bottom_right = 24
		style.corner_radius_bottom_left = 24
		card.add_theme_stylebox_override("panel", style)

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 14)
		margin.add_theme_constant_override("margin_right", 14)
		margin.add_theme_constant_override("margin_top", 12)
		margin.add_theme_constant_override("margin_bottom", 12)
		card.add_child(margin)

		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 6)
		margin.add_child(vbox)

		var header := HBoxContainer.new()
		vbox.add_child(header)

		var portrait := ColorRect.new()
		portrait.custom_minimum_size = Vector2(54, 54)
		portrait.color = unit["accent"]
		header.add_child(portrait)

		var title_box := VBoxContainer.new()
		title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		header.add_child(title_box)

		var name_label := Label.new()
		name_label.text = unit["name"]
		name_label.add_theme_font_size_override("font_size", 22)
		title_box.add_child(name_label)

		var level_label := Label.new()
		level_label.text = "Lv. %d" % unit["level"]
		title_box.add_child(level_label)

		var stats_label := Label.new()
		stats_label.text = "DPS %0.1f" % (unit["dps"] * max(1, unit["level"]))
		vbox.add_child(stats_label)

		var upgrade_button := Button.new()
		upgrade_button.text = "Upgrade"
		upgrade_button.custom_minimum_size = Vector2(0, 44)
		upgrade_button.pressed.connect(_on_upgrade_pressed.bind(i))
		vbox.add_child(upgrade_button)

		var cost_label := Label.new()
		cost_label.text = "Cost %d" % game_manager.unit_manager.get_upgrade_cost(i)
		vbox.add_child(cost_label)

		unit_grid.add_child(card)
		_unit_cards.append({
			"level": level_label,
			"stats": stats_label,
			"cost": cost_label,
			"button": upgrade_button
		})


func _refresh_ui(state: Dictionary) -> void:
	var enemy := state["enemy"]
	enemy_bar.max_value = enemy["max_health"]
	enemy_bar.value = enemy["current_health"]
	enemy_name_label.text = enemy["name"]
	stage_label.text = "STAGE %02d" % enemy["stage"]
	wave_label.text = "Wave %d/%d" % [enemy["wave"], game_manager.enemy_manager.max_wave]
	progress_bar.value = enemy["progress"] * 100.0
	coin_label.text = str(state["coins"])
	gem_label.text = str(state["gems"])
	dps_label.text = "TEAM DPS %0.1f" % state["dps"]
	auto_button.text = "AUTO %s" % ("ON" if state["auto_mode"] else "OFF")
	status_label.text = "Tap battlefield for bonus damage • Coin rate %0.1f/s" % state["coin_rate"]
	var units: Array = state["units"]
	for i in min(units.size(), _unit_cards.size()):
		var unit: Dictionary = units[i]
		_unit_cards[i]["level"].text = "Lv. %d" % unit["level"]
		_unit_cards[i]["stats"].text = "DPS %0.1f" % (unit["dps"] * max(1, unit["level"]))
		_unit_cards[i]["cost"].text = "Cost %d" % game_manager.unit_manager.get_upgrade_cost(i)


func _on_upgrade_pressed(index: int) -> void:
	var result := game_manager.upgrade_unit(index)
	if result.get("success", false):
		status_label.text = "%s upgraded!" % result["unit"]["name"]
	else:
		status_label.text = str(result.get("reason", "Upgrade failed"))


func _on_auto_button_pressed() -> void:
	game_manager.toggle_auto()


func _on_battle_tap_button_pressed() -> void:
	game_manager.tap_attack()
	_play_damage_feedback()


func _play_damage_feedback() -> void:
	floating_text.visible = true
	floating_text.modulate = Color(1, 1, 1, 1)
	floating_text.position = Vector2(300, 120)
	if _float_tween:
		_float_tween.kill()
	_float_tween = create_tween()
	_float_tween.tween_property(floating_text, "position", Vector2(300, 40), 0.45)
	_float_tween.parallel().tween_property(floating_text, "modulate", Color(1, 1, 1, 0), 0.45)


func _show_offline_reward(reward: Dictionary) -> void:
	if int(reward.get("elapsed", 0)) <= 5:
		return
	offline_label.text = "Away for %ds\nCollected %d bonus coins" % [reward["elapsed"], reward["coins"]]
	offline_popup.visible = true


func _on_close_offline_pressed() -> void:
	offline_popup.visible = false


func _apply_mock_theme() -> void:
	for path in [
		"TopHUD", "EnemyPanel", "SkillPanel", "BottomPanel", "OfflinePopup",
		"TopHUD/TopHUDMargin/HUDVBox/CurrencyRow/CoinPanel",
		"TopHUD/TopHUDMargin/HUDVBox/CurrencyRow/GemPanel",
		"EnemyPanel/EnemyMargin/EnemyVBox/BattleArena",
		"BottomPanel/BottomMargin/BottomVBox/FooterRow/QuestPanel",
		"BottomPanel/BottomMargin/BottomVBox/FooterRow/ForgePanel"
	]:
		var panel := get_node(path) as PanelContainer
		if panel:
			var style := StyleBoxFlat.new()
			style.bg_color = Color("#1d2f59")
			style.border_width_left = 3
			style.border_width_top = 3
			style.border_width_right = 3
			style.border_width_bottom = 3
			style.border_color = Color("#6fd3ff")
			style.corner_radius_top_left = 24
			style.corner_radius_top_right = 24
			style.corner_radius_bottom_left = 24
			style.corner_radius_bottom_right = 24
			panel.add_theme_stylebox_override("panel", style)

	for button_path in ["SkillPanel/SkillMargin/SkillVBox/SkillsRow/Skill1", "SkillPanel/SkillMargin/SkillVBox/SkillsRow/Skill2", "SkillPanel/SkillMargin/SkillVBox/SkillsRow/Skill3", "SkillPanel/SkillMargin/SkillVBox/SkillsRow/AutoButton", "SkillPanel/SkillMargin/SkillVBox/Skill4", "BottomPanel/BottomMargin/BottomVBox/BottomHeader/ChestButton", "OfflinePopup/OfflineMargin/OfflineVBox/CloseOfflineButton"]:
		var button := get_node(button_path) as Button
		if button:
			button.add_theme_color_override("font_color", Color.WHITE)
			button.add_theme_color_override("font_hover_color", Color.WHITE)
			button.add_theme_stylebox_override("normal", _make_button_style(Color("#355bb7"), Color("#8de7ff")))
			button.add_theme_stylebox_override("hover", _make_button_style(Color("#4874d8"), Color("#ffe47a")))

	enemy_bar.add_theme_stylebox_override("fill", _make_bar_fill(Color("#ff6177")))
	progress_bar.add_theme_stylebox_override("fill", _make_bar_fill(Color("#ffd04f")))


func _make_button_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	return style


func _make_bar_fill(fill: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14
	return style


func _start_actor_bobs() -> void:
	for node_data in [[player_one, 10.0, 0.55], [player_two, 12.0, 0.65], [enemy_actor, 14.0, 0.8]]:
		var actor: CanvasItem = node_data[0]
		var start_pos := actor.position
		var tween := create_tween().set_loops()
		tween.tween_property(actor, "position:y", start_pos.y - node_data[1], node_data[2])
		tween.tween_property(actor, "position:y", start_pos.y, node_data[2])
