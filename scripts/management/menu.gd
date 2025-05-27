extends Control
class_name Menu


func _on_play_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/lounge/lounge.tscn")

func _on_controls_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/management/controls.tscn")

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/management/credits.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
