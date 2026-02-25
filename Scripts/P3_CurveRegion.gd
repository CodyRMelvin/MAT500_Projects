class_name P3_CurveRegion

extends TextureRect 

@export var masterHeader: Control
@export var granularity: int = 100
@export var pointColor: Color = Color.RED
@export var pointRadius: float = 5
@export var splineColor: Color = Color.BLACK
@export var splineWidth: float = 5

@onready var camera: Camera2D = get_viewport().get_camera_2d()

var points: Array[Vector2]
var splinePoints: Array[Vector2]
var isDragging: bool = false
var dragPointRef: int
var msDegree: int = 3

func ClearP3() -> void:
	points.clear()
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

func BracketG( pointArray: Array[Vector2] ) -> float:
	if pointArray.size() > 2:
		var newArray1: Array[Vector2]
		newArray1.append_array(pointArray);
		newArray1.pop_front();

		var newArray2: Array[Vector2]
		newArray2.append_array(pointArray);
		newArray2.pop_back();

		return ( BracketG(newArray1) - BracketG(newArray2) ) / ( pointArray.back().x - pointArray.front().x )

	elif pointArray.size() == 2:
		return ( pointArray.back().y - pointArray.front().y ) / ( pointArray.back().x -pointArray.front().x ) 
	
	return 0

func _ready() -> void:
	masterHeader.connect( "ClearScreen", ClearP3 )
	var test: Array[Vector2] = [ Vector2(0, 2), Vector2(2, 5), Vector2(3, 2), Vector2(4, 3) ]
	var ret: float = BracketG(test)
	print(ret)

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left click"):
		points.append( event.position )
		queue_redraw()

	if event.is_action_pressed("right click") && !points.is_empty():
		isDragging = true
		dragPointRef =  GetNearestPointRef(event.position)

	if event.is_action_released("right click"):
		isDragging = false

	if event.is_action_pressed("middle click") && !points.is_empty():
		points.remove_at( GetNearestPointRef( event.position ) )
		splinePoints.clear()
		queue_redraw()
		
func _process( _delta: float ) -> void:
	if isDragging:
		points[dragPointRef] = get_local_mouse_position()
		queue_redraw()

func _draw() -> void:
	for i: int in splinePoints.size() - 1:
		draw_line( splinePoints[i], splinePoints[ i + 1 ], splineColor, splineWidth )

	for point: Vector2 in points:
		draw_circle( point, pointRadius, pointColor )
