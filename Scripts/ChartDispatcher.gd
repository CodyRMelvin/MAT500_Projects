extends VBoxContainer

@onready var spinBox: SpinBox = $ColorRect/FooterContainer_HBox/SpinBox

func OnSpinBoxUpdate( value: float ) -> void:
	print(value)

func _ready() -> void:
	spinBox.SpinBoxUpdate.connect(OnSpinBoxUpdate)
