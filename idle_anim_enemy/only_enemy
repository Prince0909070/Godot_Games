extends Node2D
class_name IdleAnimation 

@export var anim_name: String = "idle" # 動畫名稱，預設為 "idle"
@export var anim_speed: float = 7.0 
@export var anim_loop: bool = true 
@export var sprite_scale: Vector2 = Vector2(2.0, 2.0) 
@export var sprite_position: Vector2 = Vector2(1350, 340) 
# -----------------------------------------------------

var animated_sprite: AnimatedSprite2D


func _ready():
	randomize()

	animated_sprite = AnimatedSprite2D.new()
	add_child(animated_sprite) 

	# 隨機Boss，15挑1
	var random_boss_id = randi_range(1, 15) 

	animated_sprite.position = sprite_position
	animated_sprite.scale = sprite_scale
	animated_sprite.z_index = 1 # 顯示在適當的層級

	setup_animation_for_boss(random_boss_id)


func setup_animation_for_boss(boss_id: int):
	# 
	var path_to_load = "res://assets/Actor_anim/enemy_idle/boss" + str(boss_id) + "/"
	
	if path_to_load.is_empty():
		push_warning("動畫幀路徑為空！無法載入動畫。")
		# 清除現有動畫以避免顯示錯誤
		animated_sprite.sprite_frames = null
		return

	var frames = SpriteFrames.new()
	animated_sprite.sprite_frames = frames 

	load_animation_frames(frames, anim_name, path_to_load) 

	# 確保播放動畫
	if frames.has_animation(anim_name):
		# 檢查是否已在播放，避免重複啟動
		if animated_sprite.animation != anim_name or not animated_sprite.is_playing():
			animated_sprite.play(anim_name)
		print("成功載入並播放 Boss%d 的 '%s' 動畫。" % [boss_id, anim_name])
	else:
		push_warning("動畫名稱 '" + anim_name + "' 不存在於 SpriteFrames 中。")
		# 如果動畫不存在，也清除避免顯示錯誤
		animated_sprite.sprite_frames = null


func load_animation_frames(sprite_frames_res: SpriteFrames, anim_name_to_add: String, path: String):
	sprite_frames_res.add_animation(anim_name_to_add)
	var dir = DirAccess.open(path)
	if dir == null:
		push_error("無法打開動畫資料夾: " + path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	var file_names_to_load = []
	while file_name != "":
		if !dir.current_is_dir() and (file_name.ends_with(".png") || file_name.ends_with(".webp")):
			file_names_to_load.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	file_names_to_load.sort() # 檔名排序，確保動畫順序正確

	var loaded_frames_count = 0
	for f_name in file_names_to_load:
		var texture_path = path + "/" + f_name
		var tex = load(texture_path)
		if tex:
			sprite_frames_res.add_frame(anim_name_to_add, tex)
			loaded_frames_count += 1
	
	if loaded_frames_count == 0:
		push_warning("資料夾 '" + path + "' 中沒有找到任何圖片幀。")
		return

	# 統一設定動畫的速度和循環
	sprite_frames_res.set_animation_speed(anim_name_to_add, anim_speed)
	sprite_frames_res.set_animation_loop(anim_name_to_add, anim_loop)

	print("成功載入動畫 '" + anim_name_to_add + "'，共 " + str(loaded_frames_count) + " 幀。")
