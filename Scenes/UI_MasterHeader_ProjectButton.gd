extends MenuButton

var project2Scene = preload("res://Scenes/Project_2.tscn").instantiate()
var project3Scene = preload("res://Scenes/Project_3.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_popup().id_pressed.connect(_on_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_pressed( id: int ) -> void:
	match id:
		2:
			get_tree().change_scene_to_node(project2Scene)
		3:
			get_tree().change_scene_to_node(project3Scene)
