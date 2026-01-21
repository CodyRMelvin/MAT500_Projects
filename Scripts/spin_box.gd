extends SpinBox

signal SpinBoxUpdate( value: float )

func _on_value_changed( value: float ) -> void:
	SpinBoxUpdate.emit(value)
