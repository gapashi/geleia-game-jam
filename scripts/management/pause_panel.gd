extends Panel
class_name Pause


func _on_play_button_pressed() -> void:
	get_tree().paused = false
	self.visible = false

func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/management/menu.tscn")
