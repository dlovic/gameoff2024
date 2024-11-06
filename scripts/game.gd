extends Node2D

@export_group("Generation settings")
@export var generation_mode = false
@export var levels_to_generate = 5
@export var room_size = 32
@export var room_gap = 4

var levels = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize()
		
func initialize() -> void:
	queue_redraw()
	
	if generation_mode:
		# generate levels and disable camera
		generate_levels()
		$Player/Camera2D.enabled = false
		$Player.visible = false
		
		# Find and remove any existing level instance
		var existing_level = get_node("Level")
		if existing_level != null:
			print("removing existing level...")
			remove_child(existing_level)
			existing_level.queue_free()  # Free the memory asynchronously
		else:
			print("no existing level found to remove.")
	else:
		# load and instantiate the predefined level scene
		var level_scene = load("res://scenes/level_1.tscn") as PackedScene
		if level_scene != null:
			print("loading predefined level scene...")
			var level_instance = level_scene.instantiate()
			level_instance.name = "Level"
			
			$Player/Camera2D.enabled = true
			$Player.visible = true
			add_child(level_instance)
		else:
			print("error: level scene could not be loaded.")
	
func _physics_process(delta: float) -> void:
	if (Input.is_action_just_pressed("debug_generate")):
		generate_levels()
		
	if (Input.is_action_just_pressed("toggle_generation_mode")):
		generation_mode = !generation_mode
		initialize()
	
func generate_levels() -> void:
	levels.clear()
		
	var current_position = Vector2i(0,0)
	levels[current_position] = Level.new(current_position)
		
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
		
		if not levels.has(current_position):
			var new_level = Level.new(current_position)
			levels[current_position] = new_level
			
			# connections
			var previous_level: Level = levels[current_position - direction]
			previous_level.add_connection(new_level.position)
			new_level.add_connection(previous_level.position)
	
	print("generated levels", levels)
	
	queue_redraw()
	pass

func _draw() -> void:
	if !generation_mode:
		return
	
	for level: Level in levels.values():
		draw_level(level.position)
		
		for connection in level.connections:
			draw_level_connection(level.position, connection)
			
	# draw start and end on top of connections
	draw_level(levels.keys()[0], Color.GREEN)
	draw_level(levels.keys()[-1], Color.BLUE)

func draw_level(position: Vector2i, color = Color.WHITE) -> void:
	var center_offset = get_viewport_rect().size / 2
	
	# Calculate screen position, accounting for room size and gap
	var screen_position = Vector2i(center_offset) + (position * (room_size + room_gap))
	var rect = Rect2i(screen_position, Vector2i(room_size, room_size))
	
	draw_rect(rect, color)

	pass
	
func draw_level_connection(from_position: Vector2i, to_position: Vector2i) -> void:
	var center_offset = Vector2i(get_viewport_rect().size / 2)
	var from_screen_position = center_offset + (from_position * (room_size + room_gap)) + Vector2i(room_size / 2, room_size / 2)
	var to_screen_position = center_offset + (to_position * (room_size + room_gap)) + Vector2i(room_size / 2, room_size / 2)
	
	draw_line(from_screen_position, to_screen_position, Color.WHITE, 4)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass # Replace with function body.
