extends CanvasLayer
class_name PauseButton

@onready var pause_panel = get_parent().get_node("PauseCanvas/PanelPause")

func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	pause_panel.visible = true
