extends Control

@export var masterHeader: Control

func OnClear() -> void:
	print("test")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	masterHeader.ClearScreen.connect(OnClear)
	pass # Replace with function body.
