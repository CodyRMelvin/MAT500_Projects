class_name SplineRegion

extends TextureRect 

@onready var camera: Camera2D = get_viewport().get_camera_2d()

var points: Array[Vector2]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left click"):
		points.append( event.position )
		print( event.position )
		queue_redraw()

func _draw() -> void:
	for point: Vector2 in points:
		draw_circle( point, 5, Color.RED )

	pass
