extends CharacterBody2D
class_name Player

const PROJECTILE: PackedScene = preload("res://scenes/management/shooting.tscn")

@onready var spawn_point: Marker2D = get_node("SpawnPoint")
@onready var sprite: AnimatedSprite2D = get_node("Sprite1")
@onready var health_bar = get_tree().root.get_node("GameScene/UI/PlayerHealth")

var can_attack: bool = true
var is_dead = false

@export var speed: int
@export var health: int
@export var available_animations: Array[String] = [
	"sprite1", "sprite2", "sprite3", "sprite4",
	"sprite5", "sprite6", "sprite7", "sprite8", "sprite9",
	"sprite10", "sprite11", "sprite12", "sprite13", "sprite14",
	"sprite15", "sprite16"
]

func _ready():
	if available_animations.is_empty():
		push_error("available_sprites array está vazio!")
		return
	
	if Global.selected_character_index < 0 or Global.selected_character_index >= available_animations.size():
		push_error("selected_character_index fora do range!")
		return
	
	var selected_anim = available_animations[Global.selected_character_index]
	if not sprite.sprite_frames.has_animation(selected_anim):
		push_error("Animação '%s' não existe no SpriteFrames do sprite!" % selected_anim)
		return
	
	sprite.play(selected_anim)

func _physics_process(_delta):
	move()
	move_and_slide()
	attack()
	if is_dead:
		return
	
func move():
	velocity = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		velocity.y = -speed
	elif Input.is_action_pressed("ui_down"):
		velocity.y = speed
		
	if Input.is_action_pressed("ui_left"):
		velocity.x = -speed
	elif Input.is_action_pressed("ui_right"):
		velocity.x = speed
	
	velocity.y = clamp(velocity.y, -speed, speed)

func attack():
	if Input.is_action_just_pressed("ui_attack") and can_attack:
		spawn_projectile()
		can_attack = false
		
		await get_tree().create_timer(0.1).timeout
		can_attack = true

func spawn_projectile():
	var projectile = PROJECTILE.instantiate()
	projectile.global_position = spawn_point.global_position
	get_tree().root.call_deferred("add_child", projectile)
	#rojectile.direction = sign(spawn_point.position.x)
	
func update_health(value: int):
	health -= value
	
	if health_bar:
		health_bar.max_value = 500
		health_bar.value = clamp(health, 0, 500)
	
	flash_red()
	
	if health <= 0 and not is_dead:
		is_dead = true
		speed = 0
		$"../GameSceneAudio".stop()
		
		await get_tree().create_timer(2.0).timeout
		
		var fade_res = preload("res://scenes/endings/fade_animation.tscn")
		var fade_scene = fade_res.instantiate()
		fade_scene.z_index = 999
		
		var anim_player = fade_scene.get_node("FadePlayer")
		anim_player.play("fade_in")
		
		get_tree().current_scene.add_child(fade_scene)
		
		await get_tree().create_timer(3.0).timeout
		get_tree().change_scene_to_file("res://scenes/endings/game_over.tscn")
	
func flash_red():
	sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.5).timeout
	sprite.modulate = Color (1, 1, 1)
