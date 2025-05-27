extends ParallaxBackground
class_name GameOver


func _on_replay_pressed() -> void:
	get_tree().paused = false
	Global.reset()
	get_tree().change_scene_to_file("res://scenes/levels/game_scene.tscn")

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/management/menu.tscn")
