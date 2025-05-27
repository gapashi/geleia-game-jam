extends Area2D
class_name Finger

@export var speed: float = 100.0
var target: Node2D
var direction = Vector2.ZERO

func set_direction_to_player(player_position: Vector2):
	direction = (player_position - global_position).normalized()
	
func _process(delta):
	global_position += direction * speed * delta
	
	if not get_viewport_rect().has_point(global_position):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("update_health"):
			body.update_health(5)
		queue_free()
