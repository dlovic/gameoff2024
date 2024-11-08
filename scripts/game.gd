extends Node2D

@export_group("Generation settings")
@export var generation_mode = true
@export var levels_to_generate = 5
@export var room_size = 32
@export var room_gap = 4
@export var seed: int = 1337

var levels = {}

var current_level: Vector2i = Vector2i(0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize()

func unload_existing_level() -> void:
	# Find and remove any existing level instance
	var existing_level = get_node("Level")
	if existing_level != null:
		print("removing existing level...")
		remove_child(existing_level)
		existing_level.queue_free()  # Free the memory asynchronously
	else:
		print("no existing level found to remove.")

func load_level() -> void:
	print("current level: ", current_level)
	#print("levels: ", levels)
	#print("trying to load level scene: ", levels[current_level].level_scene)
	
	var level_scene = load("res://scenes/levels/" + levels[current_level].level_scene) as PackedScene
	if level_scene != null:
		print("loading predefined level scene: ", levels[current_level].level_scene)
		var level_instance = level_scene.instantiate()
		level_instance.name = "Level"
		
		$Player/Camera2D.enabled = true
		$Player.visible = true
		
		add_child(level_instance)
	else:
		print("error: level scene could not be loaded.")
	

func initialize() -> void:
	queue_redraw()
	$CanvasLayer/SeedLineEdit.text = String.num_int64(seed)
	
	if generation_mode:
		# generate levels and disable camera
		generate_levels()
		$Player/Camera2D.enabled = false
		$Player.visible = false
		current_level = Vector2i.ZERO
		
		unload_existing_level()
	else:
		# TODO: handle prefab levels here
		# load and instantiate the predefined level scene
		load_level()
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_generate") and generation_mode:
		generate_levels()
		
	if Input.is_action_just_pressed("toggle_generation_mode"):
		generation_mode = !generation_mode
		initialize()
		
	if !generation_mode:
		var map = $Level/Map as TileMapLayer
		var player = $Player as CharacterBody2D
		
		if map != null and player != null:
			# Get the TileMap's used rectangle and tile size
			var used_rect = map.get_used_rect()
			var tile_size = map.tile_set.tile_size  # Size of each tile

			# Calculate map boundaries
			var map_left = map.to_global(used_rect.position * tile_size).x
			var map_top = map.to_global(used_rect.position * tile_size).y
			var map_right = map_left + used_rect.size.x * tile_size.x
			var map_bottom = map_top + used_rect.size.y * tile_size.y

			# Debug print to verify boundaries
			# print("Map boundaries -> Left:", map_left, "Right:", map_right, "Top:", map_top, "Bottom:", map_bottom)

			# Check the player's position in relation to the boundaries
			var player_position = player.global_position
			var outside_direction = ""

			if player_position.x < map_left:
				outside_direction += "left"
			elif player_position.x > map_right:
				outside_direction += "right"
			
			if player_position.y < map_top:
				outside_direction += "top"
			elif player_position.y > map_bottom:
				outside_direction += "bottom"

			# Check if player is outside and print the direction
			if outside_direction != "":
				print("Player is outside the map on:", outside_direction, "at position:", player_position)
				
				if outside_direction == "top":
					current_level += Vector2i.UP
				elif outside_direction == "bottom":
					current_level += Vector2i.DOWN
				elif outside_direction == "right":
					current_level += Vector2i.RIGHT
				elif outside_direction == "left":
					current_level += Vector2i.LEFT
					
				unload_existing_level()
				load_level()
				
			#else:
				#print("Player is inside the map boundaries at position:", player_position)
	
func generate_levels() -> void:
	levels.clear()
	var rng = RandomNumberGenerator.new()
	rng.seed = seed
		
	var current_position = Vector2i(0,0)
	levels[current_position] = Level.new(current_position)
		
	while levels.size() < levels_to_generate:
		var direction = Vector2i()
		
		# horizontal or vertical
		if rng.randi_range(0, 1) == 0:
			direction.x = rng.randi_range(-1, 1)
			direction.y = 0
		else:
			direction.x = 0
			direction.y = rng.randi_range(-1, 1)
		
		current_position += direction
		
		if not levels.has(current_position):
			var new_level = Level.new(current_position)
			levels[current_position] = new_level
			
			# connections
			var previous_level: Level = levels[current_position - direction]
			previous_level.add_connection(new_level.position)
			new_level.add_connection(previous_level.position)
	
	print("generated levels", levels)
	
	# pick levels
	print("picking levels")	
	for level: Level in levels.values():
		var directions = level.connections.map(func(c): return get_direction(level.position, c))
		
		levels[level.position].level_scene = pick_level_scene(directions)
		print(level, directions)
	
	queue_redraw()
	pass
	
func pick_level_scene(directions: Array) -> String:
	var direction_labels: Array[String] = []
	
	if (directions.has(Vector2i.UP)):
		direction_labels.append('top')
	if (directions.has(Vector2i.DOWN)):
		direction_labels.append('bottom')
	if (directions.has(Vector2i.LEFT)):
		direction_labels.append('left')
	if (directions.has(Vector2i.RIGHT)):
		direction_labels.append('right')
		
	var available_levels = Array(DirAccess.open("res://scenes/levels").get_files())
	
	print(direction_labels)
	available_levels = available_levels.filter(func(level_name: String): return matches_directions(level_name, direction_labels))
	
	print(available_levels)
	
	return available_levels.pick_random()
	
func matches_directions(level_name: String, directions: Array[String]) -> bool:
	var level_directions = Array(level_name.replace("level_", "").replace(".tscn", "").split("_")).filter(func(dir: String): return dir == "top" or dir == "bottom" or dir == "left" or dir == "right")
	
	print("level directions", level_directions)
	
	return level_directions.size() == directions.size() and directions.all(func(dir: String): return level_directions.has(dir))
	
func get_direction(pos: Vector2i, target: Vector2i) -> Vector2i:
	return target - pos

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
	
func _on_seed_line_edit_text_submitted(new_text: String) -> void:
	seed = int(new_text)
	$CanvasLayer/SeedLineEdit.release_focus()
	generate_levels()
	pass # Replace with function body.
