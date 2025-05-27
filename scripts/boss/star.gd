extends Area2D
class_name Stars

@export var fall_speed = 200.0

func _physics_process(delta):
	position.y += fall_speed * delta
	
	if position.y > get_viewport_rect().size.y + 100:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("update_health"):
			body.update_health(25)
		queue_free()
