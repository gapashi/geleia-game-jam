extends Node2D
class_name Lounge

@export var characters: Array[NodePath]
var selected_index := 0

func _ready():
	update_carousel()

func _on_left_pressed() -> void:
	selected_index = (selected_index - 1 + characters.size()) % characters.size()
	update_carousel()


func _on_right_pressed() -> void:
	selected_index = (selected_index + 1) % characters.size()
	update_carousel()

func update_carousel():
	for i in characters.size():
		var sprite = get_node(characters[i])
		
		if i == selected_index:
			sprite.scale = Vector2(1.5, 1.5)
			sprite.z_index = 1
		else:
			sprite.scale = Vector2 (1, 1)
			sprite.z_index = 0
			

func _on_button_play_pressed() -> void:
	Global.selected_character_index = selected_index
	SceneLoader.load_scene("res://scenes/levels/game_scene.tscn")
