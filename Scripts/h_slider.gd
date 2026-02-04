extends HSlider

signal SliderUpdate( value: float )

func _on_value_changed( _value: float ) -> void:
	SliderUpdate.emit(_value)
	pass # Replace with function body.
