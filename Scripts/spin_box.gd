extends SpinBox

@export var defaultValue: int

signal SpinBoxUpdate( value: float )

func _ready() -> void:
	value = defaultValue
	SpinBoxUpdate.emit(value)

func _on_value_changed(value: float) -> void:
	SpinBoxUpdate.emit(value)
