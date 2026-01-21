extends Control

@onready var chart: Chart = $Chart 

var bCoefficients: Array[float] = [ 1.0, 1.0 ]

var chartFunction: Function = Function.new(

	[ 0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0 ],
	[ -3.0, -2.5, -2.0, -1.5, -1.0, -0.5, 0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0 ],
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

func GenerateXValues( dim: int ) -> Array[float]:
	var xVals: Array[float] 
	
	for i: float in range( 0, dim + 1 ):
		xVals.append( lerp( 0, 1, i / dim ) )

	return xVals

func _ready() -> void:
	chart.plot( [ chartFunction, chartFunction2 ] )
