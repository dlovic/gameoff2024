extends Node2D

@export var levels_to_generate = 5
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
	
	pass # Replace with function body.
	
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
		draw_room(level)

func draw_room(position: Vector2i) -> void:
	var room_size = 32
	var gap = 4
	var center_offset = get_viewport_rect().size / 2
	
	# Calculate screen position, accounting for room size and gap
	var screen_position = Vector2i(center_offset) + (position * (room_size + gap))
	var rect = Rect2i(screen_position, Vector2i(room_size, room_size))
	
	draw_rect(rect, Color.WHITE)

	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
