extends CharacterBody2D
class_name Boss

enum BossState { IDLE, STAR_RAIN, FINGER_SHOTS, LASER_ATTACK }

@export var shooting_duration: float = 10.0
@export var time_between_shots: float = 0.5

@export var star_rain_duration: float = 12.0
@export var time_between_stars: float = 0.25
@export var hand_disappear_speed: float = 300.0

@onready var sprite = $AnimatedSprite2D

var boss_health = 1000
var original_hand_y: float
var LaserScene = preload("res://scenes/boss/laser.tscn")
var FingerScene = preload("res://scenes/boss/finger.tscn")
var StarScene = preload("res://scenes/boss/star.tscn")

var current_state = BossState.IDLE
var attack_in_progress = false
var health_bar
var waiting_for_laser: bool = false
var raining = true
var laser_finished = false
var shooting_timer: Timer = null

func _ready() -> void:
	original_hand_y = global_position.y
	health_bar = get_tree().root.get_node("GameScene/UI/BossHealthBar")
	health_bar.max_value = boss_health
	health_bar.value = boss_health
	perform_next_attack()
	
#----------- MACHINE CONTROLLER
	
func perform_next_attack():
	if boss_health <= 0:
		return
		
	attack_in_progress = true
	
	var next_attack = randi() % 3
	match next_attack:
		0:
			current_state = BossState.STAR_RAIN
			await spawn_star_rain()
		1:
			current_state = BossState.FINGER_SHOTS
			await start_shooting()
		2:
			current_state = BossState.LASER_ATTACK
			await start_laser_attack()
			
	attack_in_progress = false
	await get_tree().create_timer(2.0).timeout
	perform_next_attack()

#-------------- ATTACK 3

func start_laser_attack():
	$AnimatedSprite2D.play("open_laser")
	await $AnimatedSprite2D.animation_finished
	
	var laser_instance = spawn_laser()
	
	if laser_instance:
		laser_finished = false
		laser_instance.connect("laser_attack_done", Callable(self, "_on_laser_finished"))
		
		if laser_instance.has_method("activate_damage"):
			laser_instance.activate_damage()
			
		while not laser_finished:
			await get_tree().create_timer(0.01).timeout
			#await get_tree().process_frame
			
	$AnimatedSprite2D.play("idle")
	
func _on_laser_finished():
	laser_finished = true

func spawn_laser():
	var laser_instance = LaserScene.instantiate()
	
	var spawn_point = $HandMarker.global_position
	laser_instance.global_position = spawn_point
	
	get_parent().add_child(laser_instance)
	
	if laser_instance.has_method("start_firing"):
		laser_instance.start_firing()
	
	return laser_instance
	
#-------------- ATTACK 2

func start_shooting():
	$AnimatedSprite2D.play("shooting_going")
	await $AnimatedSprite2D.animation_finished
	
	if shooting_timer:
		shooting_timer.queue_free()
	
	shooting_timer = Timer.new()
	shooting_timer.name = "ShootingTimer"
	shooting_timer.wait_time = shooting_duration
	shooting_timer.one_shot = true
	add_child(shooting_timer)
	shooting_timer.start()
	
	spawn_shots()
	
	await shooting_timer.timeout
	$AnimatedSprite2D.play("shooting_going")
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.play("idle")

func spawn_shots():
	var shooting = true
	
	while shooting:
		if shooting_timer.time_left <= 0:
			shooting = false
			break
			
		var finger_instance = FingerScene.instantiate()
		var spawn_point = $FingerMark.global_position
		finger_instance.global_position = spawn_point
		
		if get_tree().get_nodes_in_group("player").size() > 0:
			var player = get_tree().get_nodes_in_group("player")[0]
			
			if finger_instance.has_method("set_direction_to_player"):
				finger_instance.set_direction_to_player(player.global_position) #add método no script do finger
			
		get_parent().add_child(finger_instance)
		
		await get_tree().create_timer(time_between_shots).timeout

#---------- ATTACK 1

func spawn_star_rain():
	$AnimatedSprite2D.play("going_up")
	await $AnimatedSprite2D.animation_finished
	
	var current_frame_texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	var target_y = -current_frame_texture.get_size().y
	
	while global_position.y > target_y:
		global_position.y -= hand_disappear_speed * get_process_delta_time()
		await get_tree().process_frame
	
	var elapsed_time = 0.0
	while elapsed_time < star_rain_duration:
		var star_instance = StarScene.instantiate()
		var spawn_x = randf_range(0, 256)
		star_instance.global_position = Vector2(spawn_x, -50)
		
		get_parent().add_child(star_instance)
		
		await get_tree().create_timer(time_between_stars).timeout
		elapsed_time += time_between_stars
	
	while global_position.y < original_hand_y:
		global_position.y += hand_disappear_speed * get_process_delta_time()
		await get_tree().process_frame
		
	$AnimatedSprite2D.play("idle")
	
func spawn_stars():
	raining = true
	
	while raining:
		var star_instance = StarScene.instantiate()
		var spawn_x = randf_range(0, get_viewport().size.x)
		star_instance.global_position = Vector2(spawn_x, -50)
		
		get_parent().add_child(star_instance)
		
		await get_tree().create_timer(time_between_stars).timeout


#--------------- DEATH & HEALTH

func flash_red():
	sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.3).timeout
	sprite.modulate = Color(1, 1, 1)

func apply_damage(value: int):
	boss_health -= value
	if health_bar:
		health_bar.value = boss_health

	flash_red()
	
	if boss_health <= 0:
		die()
		
func on_boss_defeated():
	get_tree().paused = false
	
	if Global.selected_character_index in [0, 4, 8, 12]:
		get_tree().change_scene_to_file("res://scenes/endings/bad_ending.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/endings/good_ending.tscn")
		
func die():
	queue_free()
	await get_tree().create_timer(2.0).timeout
	on_boss_defeated()
