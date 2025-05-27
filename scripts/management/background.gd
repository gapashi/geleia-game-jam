extends ParallaxBackground
class_name Background

@export var scroll_speed: Vector2 = Vector2(-50, 0)

func _process(delta):
	scroll_base_offset.x += scroll_speed.x * delta
