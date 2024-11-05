extends Node2D

@export var levels_to_generate = 5
@export var room_size = 32
@export var room_gap = 4

var levels = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var level = load("res://scenes/level_1.tscn") as PackedScene
	#var level_instance = level.instantiate()
	#level_instance.name = "Level";
	#
	#add_child(level_instance)
	
	generate_levels()
	$Player/Camera2D.enabled = false
	
	
func _physics_process(delta: float) -> void:
	if (Input.is_action_just_pressed("debug_generate")):
		generate_levels()
	
func generate_levels() -> void:
	levels = []
	
	for i in range(1, levels_to_generate + 1):
		print("level: ", i)
		
	var current_position = Vector2i(0,0)
	levels.append(current_position)
		
	while levels.size() < levels_to_generate:
		var direction = Vector2i()
		
		# horizontal or vertical
		if randi_range(0, 1) == 0:
			direction.x = randi_range(-1, 1)
			direction.y = 0
		else:
			direction.x = 0
			direction.y = randi_range(-1, 1)
		
		current_position += direction
		
		if levels.find(current_position) == -1:
			levels.append(current_position)
	
	print(levels)
	
	queue_redraw()
	pass

func _draw() -> void:
	for level in levels:
		draw_room_connections(level)
		draw_room(level)
		
	# TODO: quickfix, redraw first and last room
	draw_room(levels[0])
	draw_room(levels[levels.size() - 1])

func draw_room(position: Vector2i) -> void:
	var center_offset = get_viewport_rect().size / 2
	
	# Calculate screen position, accounting for room size and gap
	var screen_position = Vector2i(center_offset) + (position * (room_size + room_gap))
	var rect = Rect2i(screen_position, Vector2i(room_size, room_size))
	var color = Color.WHITE
	
	var level_position = levels.find(position);
	
	if level_position == 0:
		color = Color.GREEN
	elif level_position == levels.size() - 1:
		color = Color.BLUE
	
	draw_rect(rect, color)

	pass
	
func draw_room_connections(position: Vector2i) -> void:
	var center_offset = Vector2i(get_viewport_rect().size / 2)
	var cardinal_directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	
	for direction in cardinal_directions:
		var neighbour_position = position + direction
		
		if levels.has(neighbour_position):
			var from_screen_position = center_offset + (position * (room_size + room_gap)) + Vector2i(room_size / 2, room_size / 2)
			var to_screen_position = center_offset + (neighbour_position * (room_size + room_gap)) + Vector2i(room_size / 2, room_size / 2)	
	
			draw_line(from_screen_position, to_screen_position, Color.WHITE, 4)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

	pass # Replace with function body.
