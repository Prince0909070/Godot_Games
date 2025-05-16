# BattleScene.gd (更新後的腳本)
extends Node

signal player_won_rps
signal boss_won_rps
signal attack_selected(skill_index)

@onready var player_node = $Player
@onready var boss_node = $Boss
@onready var attack_select_ui = $SkillSelectUI  # 更正變數名稱
@onready var rps_ui = $RPSUI  #猜拳

var current_player_character # 當前上場的角色
var boss_character # Boss 角色
var player_choice = -1
var boss_choice = -1
var is_player_turn = true

func _ready(): #獲取玩家boss節點
	current_player_character = player_node.get_current_character()
	boss_character = boss_node.get_boss_character()
	attack_select_ui.hide()

	if is_instance_valid(rps_ui):  #對應每個猜拳按鈕，
		for i in 3:
			var button = rps_ui.get_node(get_rps_button_name(i))
			if is_instance_valid(button):
				button.connect("pressed", _on_rps_button_pressed.bind(i))

	player_node.connect("character_defeated", _on_player_character_defeated)

func _on_player_character_defeated(character_node):
	var next_char = player_node.get_next_available_character()
	if next_char:
		current_player_character = next_char
		print("當前上場角色變為：" + current_player_character.name)
	else:
		print("所有玩家角色都已陣亡！遊戲結束 (Boss 勝利)。")
		# 這裡可以加入 Boss 勝利的遊戲結束邏輯

func start_rps_round():
	is_player_turn = true
	player_choice = -1
	boss_choice = -1
	rps_ui.show()
	attack_select_ui.hide()

func _on_rps_button_pressed(choice: int):
	if not is_player_turn:
		return

	player_choice = choice
	boss_choice = randi_range(0, 2)
	rps_ui.hide()
	determine_rps_winner()

func determine_rps_winner():
	if player_choice == boss_choice:
		print("平手！重新猜拳。")
		start_rps_round()
	elif (player_choice == 0 and boss_choice == 2) or \
		 (player_choice == 1 and boss_choice == 0) or \
		 (player_choice == 2 and boss_choice == 1):
		print("玩家猜拳獲勝！")
		emit_signal("player_won_rps")
		show_attack_selection()
	else:
		print("Boss 猜拳獲勝！")
		emit_signal("boss_won_rps")
		boss_attack()

func show_attack_selection():
	is_player_turn = true
	attack_select_ui.show()

	for i in 3:
		var button = attack_select_ui.get_node(get_skill_button_name(i))
		if is_instance_valid(button):
			button.disconnect("pressed", _on_skill_button_pressed)
			button.connect("pressed", _on_skill_button_pressed.bind(i))

func get_rps_button_name(choice_index: int) -> String:
	match choice_index:
		0: return "ScissorsButton"
		1: return "RockButton"
		2: return "PaperButton"
		_: return ""

func get_skill_button_name(skill_index: int) -> String:
	return "Skill" + str(skill_index + 1) + "Button"

func _on_skill_button_pressed(skill_index: int):
	if not is_player_turn:
		return

	emit_signal("attack_selected", skill_index)
	attack_select_ui.hide()
	player_attack(skill_index)

func player_attack(skill_index: int):
	if is_instance_valid(current_player_character):
		current_player_character.get_node("AnimationPlayer").play("attack")
		await current_player_character.get_node("AnimationPlayer").animation_finished

		var damage = 0
		match skill_index:
			0:
				damage = current_player_character.get_attack_power() # 使用當前角色的攻擊力
				print(current_player_character.name + " 使用技能 1 攻擊 Boss！造成 " + str(damage) + " 點傷害。")
			1:
				damage = current_player_character.get_attack_power() # 假設所有技能攻擊力相同
				print(current_player_character.name + " 使用技能 2 攻擊 Boss！造成 " + str(damage) + " 點傷害。")
			2:
				damage = current_player_character.get_attack_power()
				print(current_player_character.name + " 使用技能 3 攻擊 Boss！造成 " + str(damage) + " 點傷害。")

		boss_node.take_damage(damage)

		current_player_character.get_node("AnimationPlayer").play("idle")
		check_battle_end()
		if !boss_node.is_defeated() and !player_node.is_all_defeated():
			start_rps_round()

func boss_attack():
	if is_instance_valid(boss_character):
		boss_character.get_node("AnimationPlayer").play("attack")
		await boss_character.get_node("AnimationPlayer").animation_finished

		if is_instance_valid(current_player_character):
			var damage = boss_node.get_attack_power() # 使用 Boss 的攻擊力
			current_player_character.get_node("HealthBar").value -= damage
			print("Boss 攻擊 " + current_player_character.name + "！造成 " + str(damage) + " 點傷害。")

		boss_character.get_node("AnimationPlayer").play("idle")
		check_battle_end()
		if !boss_node.is_defeated() and !player_node.is_all_defeated():
			start_rps_round()

func check_battle_end():
	if boss_node.is_defeated():
		print("玩家勝利！")
		# 這裡加入玩家勝利的遊戲結束邏輯
	elif player_node.is_all_defeated():
		print("Boss 勝利！")
		# 這裡加入 Boss 勝利的遊戲結束邏輯
