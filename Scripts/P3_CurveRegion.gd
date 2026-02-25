class_name P3_CurveRegion

extends TextureRect 

@export var masterHeader: Control
@export var granularity: int = 10
@export var pointColor: Color = Color.RED
@export var pointRadius: float = 5
@export var splineColor: Color = Color.BLACK
@export var splineWidth: float = 5

@onready var camera: Camera2D = get_viewport().get_camera_2d()

var points: Array[Vector2]
var newtonPoints: Array[Vector2]
var splinePoints: Array[Vector2]
var gCache: Array[Vector2]
var isDragging: bool = false
var dragPointRef: int
var msDegree: int = 3

func ClearP3() -> void:
	points.clear()
	newtonPoints.clear()
	splinePoints.clear()
	queue_redraw()

func GetNearestPointRef( point: Vector2 ) -> int:
	var distance: float = 1.79769e308
	var chosenPointRef: int = 0;

	for i: int in points.size():
		var currentLength: float = ( points[i] - point ).length()
		
		if currentLength < distance:
			chosenPointRef = i 
			distance = currentLength

	return chosenPointRef

func BracketGRecursive( pointArray: Array[Vector2] ) -> float:
	if pointArray.size() > 2:
		var newArray1: Array[Vector2]
		newArray1.append_array(pointArray);
		newArray1.pop_front();

		var newArray2: Array[Vector2]
		newArray2.append_array(pointArray);
		newArray2.pop_back();

		return ( BracketGRecursive(newArray1) - BracketGRecursive(newArray2) ) / ( pointArray.back().x - pointArray.front().x )

	elif pointArray.size() == 2:
		return ( pointArray.back().y - pointArray.front().y ) / ( pointArray.back().x -pointArray.front().x ) 
	
	return 0

func BracketG( pointArray: Array[Vector2] ) -> Vector2:
	var xs: Array[Vector2]
	var ys: Array[Vector2]
	for i: int in pointArray.size():
		xs.push_back( Vector2( i, pointArray[i].x ) )
		ys.push_back( Vector2( i, pointArray[i].y ) )

	var y: float = BracketGRecursive(ys)
	var x: float = BracketGRecursive(xs)
	return Vector2( x, y )

func ResetGCache() -> void:
	gCache.clear()
	for i in newtonPoints.size() - 1:
		var tempArray: Array[Vector2]
		tempArray.append_array(newtonPoints)
		tempArray.resize( newtonPoints.size() - i )
		gCache.push_back( BracketG(tempArray) )
	gCache.push_back( newtonPoints.front() )


func NewtonInterpolation() -> void:
	if ( points.size() < 2 ):
		return

	splinePoints.push_back( points.front() )
	var step: float = 1 / float(granularity)
	for t: int in range( 1, granularity * ( points.size() - 1 ) ):
			var pointBuffer: Vector2 = Vector2.ZERO

			for j: int in gCache.size():
				var pointBuffer2: Vector2 = gCache[ gCache.size() - 1 - j ]
				for k: int in range( 0, j ):
					pointBuffer2 *= ( t * step - k )

				pointBuffer += pointBuffer2

			splinePoints.push_back(pointBuffer)

	splinePoints.push_back( points.back() )


func _ready() -> void:
	masterHeader.connect( "ClearScreen", ClearP3 )

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left click"):
		points.append( event.position )
		newtonPoints.clear()
		newtonPoints.append_array(points)
		ResetGCache()
		queue_redraw()

	if event.is_action_pressed("right click") && !points.is_empty():
		dragPointRef =  GetNearestPointRef(event.position)
		if !isDragging:
			var temp: Vector2 = newtonPoints[dragPointRef]
			newtonPoints.remove_at(dragPointRef)
			newtonPoints.push_back(temp)
			ResetGCache()

		isDragging = true

	if event.is_action_released("right click"):
		isDragging = false

	if event.is_action_pressed("middle click") && !points.is_empty():
		points.remove_at( GetNearestPointRef( event.position ) )
		newtonPoints.clear()
		newtonPoints.append_array(points)
		splinePoints.clear()
		ResetGCache()
		queue_redraw()
		
func _process( _delta: float ) -> void:
	if isDragging:
		points[dragPointRef] = get_local_mouse_position()
		gCache[ gCache.size() - 1 ] = BracketG(newtonPoints)
		queue_redraw()

func _draw() -> void:
	splinePoints.clear()
	NewtonInterpolation()

	for i: int in splinePoints.size() - 1:
		draw_line( splinePoints[i], splinePoints[ i + 1 ], splineColor, splineWidth )

	for point: Vector2 in points:
		draw_circle( point, pointRadius, pointColor )
