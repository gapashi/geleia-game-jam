extends Area2D
class_name Laser

signal laser_finished
signal laser_attack_done

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

@export var active_time: float = 8.0

var laser_done := false

func _ready() -> void:
	collision.disabled = true
	
func activate_damage():
	collision.disabled = false
	start_laser_time()
	
func start_laser_time():
	await get_tree().create_timer(active_time).timeout
	animated_sprite.play("laser_fading")

func _on_laser_animation_finished() -> void:
	if animated_sprite.animation == "laser_fading":
		emit_signal("laser_attack_done")
		emit_signal("laser_finished")
		laser_done = true
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("update_health"):
			body.update_health(50)

func wait_for_completion():
	while not laser_done:
		await get_tree().process_frame
