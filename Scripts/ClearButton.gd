extends Button

@export var root: Control

func _on_pressed() -> void:
	root.ClearScreen.emit()
