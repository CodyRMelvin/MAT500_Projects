extends MenuButton

var project2Scene = "res://Scenes/Project_2.tscn"
var project3Scene = "res://Scenes/Project_3.tscn"
var project4Scene = "res://Scenes/Project_4.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_popup().id_pressed.connect(_on_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_pressed( id: int ) -> void:
	match id:
		2:
			get_tree().change_scene_to_file(project2Scene)
		3:
			get_tree().change_scene_to_file(project3Scene)
		4:
			get_tree().change_scene_to_file(project4Scene)
