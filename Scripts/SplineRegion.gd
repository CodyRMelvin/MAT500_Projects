class_name SplineRegion

extends TextureRect 

@export var masterHeader: Control
@export var menuButton: MenuButton
@export var slider: HSlider
@export var spinBox: SpinBox
@export var granularity: int = 100
@export var pointColor: Color = Color.RED
@export var pointRadius: float = 5
@export var splineColor: Color = Color.BLACK
@export var splineWidth: float = 5
@export var shellColor: Color = Color( 0, 0, 1, .25 )
@export var shellWidth: float = 2

@onready var camera: Camera2D = get_viewport().get_camera_2d()

enum DrawStyle
{
	NLI,
	BBForm,
	MidpointSubdivision,
}

var style: DrawStyle = DrawStyle.NLI
var points: Array[Vector2]
var splinePoints: Array[Vector2]
var isDragging: bool = false
var dragPointRef: int
var t: float = 0.5
var msDegree: int = 3

func Clear() -> void:
	points.clear()
	splinePoints.clear()
	queue_redraw()

func UpdateT( value: float ) -> void:
	t = value
	queue_redraw()

func UpdateDrawMode( id: int ) -> void:
	style = id as DrawStyle
	splinePoints.clear()
	queue_redraw()

func UpdateMSDegree( value: int ) -> void:
	msDegree = value
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

func DrawNLI() -> void:
	if points.size() < 2:
		return

	# drawing shells
	var shellPoints = [ points ]
	var shellPointBuffer: Array[Vector2]
	var i: int = 0
	
	while i > -1:
		for j: int in shellPoints[i].size() - 1:
			shellPointBuffer.append( lerp( shellPoints[i][j], shellPoints[i][ j + 1 ], t ))

		shellPoints.append( shellPointBuffer.duplicate() )
		if shellPointBuffer.size() == 1:
			i = -1
		else:
			i += 1
			shellPointBuffer.clear()

	for j: int in shellPoints.size():
		for k: int in shellPoints[j].size() - 1:
			draw_line( shellPoints[j][k], shellPoints[j][ k + 1 ], shellColor, shellWidth )	
	
	draw_circle( shellPoints.back()[0], pointRadius, pointColor )

	splinePoints.append( points[0] )
	var step: float = 1 / float(granularity)
	var ti: float = step

	while ti < 1.0:
		var pointsBuff1: Array[Vector2]
		pointsBuff1.append_array(points)

		while( pointsBuff1.size() > 1 ):
			var pointsBuff2: Array[Vector2]
			
			for j: int in pointsBuff1.size() - 1:
				pointsBuff2.append( lerp( pointsBuff1[j], pointsBuff1[ j + 1 ], ti ) )

			pointsBuff1.clear()
			pointsBuff1.append_array(pointsBuff2)
		
		splinePoints.append( pointsBuff1[0] )
		ti += step

	splinePoints.append( points.back() )

func Factorial( i: float ) -> float:
	if i < 2:
		return 1
	return i * Factorial( i - 1 );
	
func Choose( d: float, i: float ) -> float:
	if d == 0 || i == 0 || d == i:
		return 1
	return Factorial(d) / ( Factorial(i) * Factorial( d - i ) ) 

func Bernstein( d: float, i: float, t: float ) -> float:
	var choose = Choose( d, i )
	return choose * pow( t, i ) * pow( 1 - t, d - i )

func DrawBBForm() -> void:
	if points.size() < 2:
		return

	splinePoints.append( points[0] )
	var step: float = 1 / float(granularity)

	for ti: int in range( 1, granularity ):
		var pointBuffer: Vector2 = Vector2.ZERO

		for i: float in points.size():
			pointBuffer += points[i] * Bernstein( points.size() - 1, i, ti * step )

		splinePoints.append(pointBuffer)		
	
	splinePoints.append( points.back() )

func InterpolatePoint( pointArray: Array[Vector2], d: int, i: int, t: float ) -> Vector2:
	if pointArray.size() < 1:
		return Vector2.ZERO

	if d < 0 || i < 0:
		return Vector2.ZERO

	if pointArray.size() < d + i:
		return Vector2.ZERO

	if d == 0:
		return pointArray[i]

	var pointBuffer1: Array[Vector2]
	pointBuffer1.append_array(pointArray)

	for j: int in d:
		if pointBuffer1.size() < 2:
			break

		var pointBuffer2: Array[Vector2]

		for k: int in pointBuffer1.size() - 1:
			pointBuffer2.append( lerp( pointBuffer1[k], pointBuffer1[ k + 1 ], t ) )

		pointBuffer1.clear()
		pointBuffer1.append_array(pointBuffer2)

	return pointBuffer1[i]
	
func MSRecursive( pointArray: Array[Vector2], depth: int ) -> Array[Vector2]:
	if depth == 0:
		return pointArray

	var returnArray: Array[Vector2]
	var buffer1: Array[Vector2]
	var buffer2: Array[Vector2]
	
	for i: int in pointArray.size():
		buffer1.append( InterpolatePoint( pointArray, i, 0, .5 ) )

	buffer1 = MSRecursive( buffer1, depth - 1 )

	for i: int in range( 0, pointArray.size() ):
		buffer2.append( InterpolatePoint( pointArray, pointArray.size() - i - 1, i, .5 ) )
	
	buffer2 = MSRecursive( buffer2, depth - 1 )

	returnArray.append_array(buffer1)
	returnArray.pop_back()
	returnArray.append_array(buffer2)

	return returnArray
	
func DrawMS() -> void:
	if points.size() < 2:
		return

	if msDegree < 1:
		return

	if msDegree == 1:
		splinePoints.append_array(points)
		return

	splinePoints.append_array( MSRecursive( points, msDegree - 1 ) )
	pass
		

func _ready() -> void:
	masterHeader.connect( "ClearScreen", Clear )
	slider.SliderUpdate.connect(UpdateT)
	menuButton.StyleChange.connect(UpdateDrawMode)
	spinBox.SpinBoxUpdate.connect(UpdateMSDegree)
	msDegree = int(spinBox.value)

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
	splinePoints.clear()

	match style:
		DrawStyle.NLI:
			DrawNLI()
		
		DrawStyle.BBForm:
			DrawBBForm()

		DrawStyle.MidpointSubdivision:
			DrawMS()

	for i: int in splinePoints.size() - 1:
		draw_line( splinePoints[i], splinePoints[ i + 1 ], splineColor, splineWidth )

	for point: Vector2 in points:
		draw_circle( point, pointRadius, pointColor )
