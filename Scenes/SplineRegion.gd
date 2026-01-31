class_name SplineRegion

extends TextureRect 

@export var masterHeader: Control

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

func Clear() -> void:
	points.clear()
	queue_redraw()

func _ready() -> void:
	masterHeader.connect( "ClearScreen", Clear )

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left click"):
		points.append( event.position )
		queue_redraw()

	if event.is_action_pressed("right click"):
		isDragging = true
		var distance: float = 1.79769e308
		var mousePos: Vector2 = event.position
		print("test")

		for i: int in points.size():
			var currentLength: float = ( points[i] - mousePos ).length()
			
			if currentLength < distance:
				dragPointRef = i 
				distance = currentLength

	if event.is_action_released("right click"):
		isDragging = false
		
func _process( _delta: float ) -> void:
	if isDragging:
		points[dragPointRef] = get_local_mouse_position()
		queue_redraw()

func _draw() -> void:
	for point: Vector2 in points:
		draw_circle( point, 5, Color.RED )

	if style == DrawStyle.NLI:
		for i: int in points.size() - 1:
			draw_line( points[i], points[ i + 1 ], Color( 0, 0, 1, .25 ), 2 )
			pass
