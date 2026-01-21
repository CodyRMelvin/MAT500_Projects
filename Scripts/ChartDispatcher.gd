extends VBoxContainer

@onready var spinBox: SpinBox = $ColorRect/FooterContainer_HBox/SpinBox
@onready var chartManager: ChartManager = $ChartManager
@onready var masterHeader: Control = $UI_MasterHeader

func OnSpinBoxUpdate( value: float ) -> void:
	chartManager.RegenBernsteinCoefficients( int(value) )

func OnScreenReset() -> void:
	chartManager.ResetBernsteinCoefficients()

func _ready() -> void:
	spinBox.SpinBoxUpdate.connect(OnSpinBoxUpdate)
	masterHeader.ClearScreen.connect(OnScreenReset)
