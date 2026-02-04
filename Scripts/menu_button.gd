extends MenuButton

signal StyleChange( id: int )

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = "NLI"
	get_popup().id_pressed.connect(_on_pressed)

func _on_pressed( id: int ) -> void:
	text = get_popup().get_item_text(id)
	StyleChange.emit(id)
