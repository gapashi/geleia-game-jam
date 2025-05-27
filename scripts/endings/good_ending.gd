extends ParallaxBackground
class_name GoodEnding



func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/management/menu.tscn")
