class_name ChartManager
extends Control

@onready var chart: Chart = $Chart 

var bCoefficients: Array[float] = [ 1.0, 1.0 ]

func GenerateXValues( dim: int ) -> Array[float]:
	var xVals: Array[float] 
	
	for i: float in range( 0, dim + 1 ):
		xVals.append( lerp( 0, 1, i / dim ) )

	return xVals

func RegenBernsteinCoefficients( dim: int ) -> void:
	bCoefficients.resize( dim + 1 )	
	bCoefficients.fill(1.0)
	DrawGraph()

func ResetBernsteinCoefficients() -> void:
	bCoefficients.fill(1.0)
	DrawGraph()

func _ready() -> void:
	DrawGraph()

func DrawGraph() -> void:

	var chartFunction: Function = Function.new(

		[ 0.0, .25, .5, .75, 1.0 ],
		[ -3.0, -1.5, 0.0, 1.5, 3.0 ],
		"Placeholder",
		{
			type = Function.Type.LINE,
			marker = Function.Marker.SQUARE,
			color = Color("#36a2eb")
		}
	)

	var chartFunction2: Function = Function.new(

		GenerateXValues( bCoefficients.size() - 1 ),
		bCoefficients,
		"Placeholder 2",
		{
			type = Function.Type.SCATTER,
			marker = Function.Marker.CIRCLE,
			color = Color( 1, 0, 0 )
		}
	)

	chart.queue_redraw()
	chart.plot( [ chartFunction, chartFunction2 ] )
