extends Area2D

var show_bounding_box := false:
	set(b):
		show_bounding_box = b
		queue_redraw()

var rect := Rect2()

@onready var _sprite := $Sprite2D

func _ready() -> void:
	$Sprite2D.set_modulate(Color(randf(), randf(), randf(), 1.0))

func _draw() -> void:
	if show_bounding_box:
		var d_rect := _resize_rect(_sprite.get_rect(), get_parent()._inflate_bounding_box)
		draw_rect(d_rect, Color(1.0, 1.0, 1.0, 0.3), true)

func update_rect(inflate := 0.0) -> void:
	rect = _resize_rect(_sprite.get_rect(), inflate)
	rect.position = to_global(rect.position)
	queue_redraw()

func _resize_rect(_rect:Rect2, inflate:float) -> Rect2:
	_rect.position += Vector2(-inflate, -inflate)
	_rect.size += Vector2(inflate * 2, inflate * 2)
	
	var scaling:float = _sprite.scale.x
	_rect.position *= scaling
	_rect.size *= scaling
	return _rect
