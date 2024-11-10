@tool
class_name LevelEntrance
extends Node2D

enum Direction { Up, Down, Left, Right }

@export var direction: Direction = Direction.Up

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		update_arrow_direction()

func _ready():
	add_to_group("LevelEntrances")
	visible = Engine.is_editor_hint()
	update_arrow_direction()
	
func update_arrow_direction():
	var sprite = $Sprite2D as Sprite2D
	if direction == Direction.Up:
		sprite.rotation_degrees = 0
		
	if direction == Direction.Right:
		sprite.rotation_degrees = 90
		
	if direction == Direction.Down:
		sprite.rotation_degrees = 180
		
	if direction == Direction.Left:
		sprite.rotation_degrees = 270
