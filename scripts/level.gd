class_name Level

var position: Vector2i
var connections: Array

func _init(pos: Vector2i) -> void:
	position = pos
	connections = []
	
func _to_string() -> String:
	return "{ position: %s, connections: %s } \n" % [position, connections]
	
func add_connection(level_position: Vector2i) -> void:
	if level_position not in connections:
		connections.append(level_position)
