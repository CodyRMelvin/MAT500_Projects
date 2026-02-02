class_name SplineRegion

extends TextureRect 

@export var masterHeader: Control
@export var granularity: int = 100
@export var pointColor: Color = Color.RED
@export var pointRadius: float = 5
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
var isDragging: bool = false
var dragPointRef: int
var t: float = 0.5

func Clear() -> void:
	points.clear()
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


	

func DrawBBForm() -> void:
	pass
	
func DrawMS() -> void:
	pass

func _ready() -> void:
	masterHeader.connect( "ClearScreen", Clear )

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
		queue_redraw()
		
func _process( _delta: float ) -> void:
	if isDragging:
		points[dragPointRef] = get_local_mouse_position()
		queue_redraw()

func _draw() -> void:
	for point: Vector2 in points:
		draw_circle( point, pointRadius, pointColor )

	match style:
		DrawStyle.NLI:
			DrawNLI()
		
		DrawStyle.BBForm:
			DrawBBForm()

		DrawStyle.MidpointSubdivision:
			DrawMS()