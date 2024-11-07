class_name Level

var position: Vector2i
var connections: Array
var level_scene: String

func _init(pos: Vector2i) -> void:
	position = pos
	connections = []
	level_scene = ""
	
func _to_string() -> String:
	return "{\n position: %s,\n connections: %s,\n level_scene: %s\n } \n" % [position, connections, level_scene]
	
func add_connection(level_position: Vector2i) -> void:
	if level_position not in connections:
		connections.append(level_position)
