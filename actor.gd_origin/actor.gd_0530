# Actor.gd
extends Node2D
class_name Actor

# 宣告屬性
var id: int
var _name: String
var element: String
var health: int
var max_health: int
var attack_point: int
var magic_point: int
var attack_defence: int
var magic_defence: int
var level: int
var cooldown: float = 0.0
var attack_timer: float = 0.0 #不同actor的攻擊冷卻計時器


var db := SQLite.new()
var equipment: Equipment
var equipment_list:Array[Equipment] = []
var skill: Skill
var rings: Array[Ring] = []

# 動畫處理
#var hero_texture = preload("res://assets/2D_Pixel_Dungeon_Asset_Pack/hero_picture/hero.png")
#var enemy_texture = preload("res://assets/2D_Pixel_Dungeon_Asset_Pack/monster_picture/monster.png")
#var sprite_textures = []

# 移除舊的 Sprite2D 實例，現在由 IdleAnimation 負責
#var sprite = Sprite2D.new()
#var sprite2 = Sprite2D.new()

#動畫節點變數
var character_animation_node: IdleAnimation


var player_damage_numbers_origin = Node2D.new()
var enemy_damege_numbers_origin = Node2D.new()

# 初始化方法
func _init(data: Dictionary) -> void:
	randomize()
	id = data.get("id", 0)
	_name = data.get("name", "")
	element = data.get("element", "")
	health = data.get("health", 0)
	max_health = data.get("health", 0)
	attack_point = data.get("attack_point",0 )
	magic_point = data.get("magic_point", 0)
	attack_defence = data.get("attack_defence", 0)
	magic_defence = data.get("magic_defence", 0)
	level = int(data.get("level", 0))


	# 實例化通用的 IdleAnimation 節點
	character_animation_node = IdleAnimation.new()
	add_child(character_animation_node) # 將動畫節點加入到 Actor 實例中

	# 根據 level 設定動畫節點的屬性
	if level != 0:
		# 這是敵人 (level 不為 0)
		character_animation_node.name = "EnemyAnimation" 
		character_animation_node.animation_base_path = "res://assets/Actor_anim/enemy_idle/"
		character_animation_node.subfolder_prefix = "boss"
		character_animation_node.subfolder_id_min = 1
		character_animation_node.subfolder_id_max = 15
		character_animation_node.anim_speed = 7.0
		character_animation_node.sprite_scale = Vector2(2.0, 2.0)
		character_animation_node.sprite_position = Vector2(1350, 340) # 敵人位置
		character_animation_node.sprite_z_index = 1
		character_animation_node.flip_horizontally = false 
		print("已為敵人 '%s' 載入通用動畫。" % _name)
	else:
		# 這是玩家 (level 為 0)
		character_animation_node.name = "PlayerAnimation" 
		character_animation_node.animation_base_path = "res://assets/Actor_anim/player_idle/"
		character_animation_node.subfolder_prefix = "hero"
		character_animation_node.subfolder_id_min = 1
		character_animation_node.subfolder_id_max = 5
		character_animation_node.anim_speed = 6.0 
		character_animation_node.sprite_scale = Vector2(3.5, 3.5) 
		character_animation_node.sprite_position = Vector2(630, 480) 
		character_animation_node.sprite_z_index = 0 
		character_animation_node.flip_horizontally = true # 左右翻轉
		print("已為玩家 '%s' 載入通用動畫。" % _name)


	print("成功建立：%s，Level: %d" % [_name, level])

	open_data()

	if !skill:
		var level_skill:Array = db.select_rows("skill", "level = " + str(self.level), ["id"])
		var number_level_skill:int = level_skill.size()
		var rand_skill_id:int = randi() % number_level_skill
		skill_change(level_skill[rand_skill_id]["id"])

func open_data():
	db.path = "res://data/game.db"
	if not db.open_db():
		push_error("無法開啟資料庫")
		return


func add_equipment_to_list(equipment_id: int):#將裝備加入擁有清單中
	var query = "SELECT id, name, attack_defence, magic_defence, level FROM equipment WHERE id = ?"
	db.query_with_bindings(query, [equipment_id])

	if db.query_result.size() == 0:
		print("找不到指定 ID 的裝備")
		return

	var row = db.query_result[0]
	var new_equipment = Equipment.new(row)

	for eq in equipment_list:
		if eq.id == new_equipment.id:
			print("裝備已存在")
			return

	equipment_list.append(new_equipment)

func equipment_change(equipment_id: int) -> void:#更換身上裝備
	var query = "SELECT id, name, attack_defence, magic_defence, level FROM equipment WHERE id = ?"
	db.query_with_bindings(query, [equipment_id])

	if db.query_result.size() == 0:
		print("找不到指定 ID 的裝備")
		return

	var row = db.query_result[0]
	var new_equipment = Equipment.new(row)

	for eq in equipment_list:
		if eq.id == new_equipment.id:
			print("確實有這件裝備!")
			break

	equipment = new_equipment

	print("%s 裝備了 %s" % [_name, new_equipment.name])


func skill_change(skill_id: int) -> void:
	var query = "SELECT * FROM skill WHERE id = ?"
	db.query_with_bindings(query, [skill_id])

	if db.query_result.size() == 0:
		print("找不到指定 ID 的技能")
		return

	var row = db.query_result[0]

	var new_skill = Skill.new(row)

	skill = new_skill

	cooldown = float(row.get("cooldown", 0.0)) #

	print("%s 學會了 %s" % [_name, new_skill.name])

#取名重複，原本函式跟內部變數重複取名
func build_new_ring(ring_id: int):#增加新的狀態
	var query = "SELECT * FROM ring WHERE id = ?"
	db.query_with_bindings(query, [ring_id])

	if db.query_result.size() == 0:
		push_error("找不到指定 ID 的狀態")
		return

	var row = db.query_result[0] # 是一個 Array 對應欄位順序

	var new_ring = Ring.new(row)

	rings.append(new_ring)
	print("已新增狀態：", new_ring.name) 
	health = _get_max_health()



func get_element_multiplier_from_db(attacker_element: String, target_element: String) -> float:#屬性判定
	var query = "SELECT advantage FROM element WHERE name = ?"
	db.query_with_bindings(query, [attacker_element])

	if db.query_result.size() == 0:
		return 1.0

	var row = db.query_result[0] # 取得第一筆資料（應該是 Dictionary 或 Array，取決於你的資料庫插件）

	var advantage = row["advantage"] # ✅ 使用欄位名稱存取

	if target_element == advantage:
		return 1.5
	else:
		return 1.0

func get_combined_ring_state() -> Dictionary: # 當前狀態加成
	var result = {
		"attack_power": 0.0,
		"magic_power": 0.0,
		"attack_defence": 0.0,
		"magic_defence": 0.0,
		"health": 0.0
	}

	for r in rings:
		result["attack_power"] = max(0.0, result["attack_power"] + r.attack_power)
		result["magic_power"] = max(0.0, result["magic_power"] + r.magic_power)
		result["attack_defence"] = max(0.0, result["attack_defence"] + r.attack_defence)
		result["magic_defence"] = max(0.0, result["magic_defence"] + r.magic_defence)
		result["health"] = max(0.0, result["health"] + r.health)

	return result

func _get_attack_damage():#物理傷害
	var ring_state = get_combined_ring_state()
	var attack_damege = attack_point * (1 + ring_state["attack_power"])
	return attack_damege

func _get_magic_damage():#魔法傷害
	var ring_state = get_combined_ring_state()
	var magic_damege = self.magic_point * (1 + ring_state["magic_power"])
	return magic_damege

func _get_attack_defence():#物理減傷
	var ring_state = get_combined_ring_state()
	var defence_number = (self.attack_defence) * (1 + ring_state["attack_defence"])

	if equipment != null:
		defence_number = (equipment.attack_defence + self.attack_defence) * (1 + ring_state["attack_defence"])

	var defence = defence_number / (100 + defence_number)
	return defence

func _get_magic_defence():#魔法減傷
	var ring_state = get_combined_ring_state()

	var magic_defence_number = (self.magic_defence) * (1 + ring_state["magic_defence"])
	if equipment != null:
		magic_defence_number = (equipment.magic_defence + self.magic_defence) * (1 + ring_state["magic_defence"])
	var magic_defence_result = magic_defence_number / (100 + magic_defence_number)
	return magic_defence_result

func _get_max_health():#最大血量
	var ring_state = get_combined_ring_state()
	var health_now = self.max_health*(1 + ring_state["health"])
	return health_now

func damage_calculate(target:Actor, is_magic: bool = false, is_player: bool = false) -> String:#傷害計算包含血量變更
	var attacker_damage: float
	var target_defence: float
	var skill_power = skill.power
	var attacker_element = skill.element
	var target_element = target.element
	var element_percent = get_element_multiplier_from_db(attacker_element, target_element)
	var is_critical = false
	var damage_numbers_origin = player_damage_numbers_origin

	player_damage_numbers_origin.position = Vector2(595,830)
	enemy_damege_numbers_origin.position = Vector2(1330,830)

	if is_player:
		damage_numbers_origin = enemy_damege_numbers_origin

	if is_magic:
		attacker_damage =_get_magic_damage()
		target_defence = target._get_magic_defence()
	else:
		attacker_damage = _get_attack_damage()
		target_defence = target._get_attack_defence()

	var final_damage = attacker_damage * element_percent * skill_power
	var real_damage = max (1,final_damage * (1 - target_defence))

	target.health = max(0, target.health - real_damage)

	if target.health <= 0:
		is_critical = true
		DamageNumber.display_number(real_damage, damage_numbers_origin.global_position, is_critical)
		return "%s has been defeated." %target._name
	else:
		DamageNumber.display_number(real_damage, damage_numbers_origin.global_position, is_critical)
		return "%s took %d damage." %[target._name, int(real_damage)]
