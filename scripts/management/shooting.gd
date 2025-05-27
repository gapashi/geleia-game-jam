extends Area2D
class_name Shooting

@onready var sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")

var direction: float = 1.0
@export var speed: int = 60
@export var damage: int = 35


func _physics_process(delta):
	translate(Vector2(delta * direction * speed, 0))
	

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("apply_damage"):
			body.apply_damage(damage)
		queue_free()

func _on_notifier_2d_screen_exited():
	queue_free()
