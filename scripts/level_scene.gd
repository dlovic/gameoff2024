extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var entrances = {}
	
	for node in get_tree().get_nodes_in_group("LevelEntrances"):
		if node is LevelEntrance:
			entrances[node.direction] = node
	
	print(entrances)
	
	var player = $"../Player"
	var game = get_tree().root.get_node("Game") as Game
	var direction = get_direction_enum(game.current_level - game.last_level)
	var is_start = game.last_level == game.current_level
	
	# start
	if is_start:
		player.position = $PlayerSpawnPosition.position
	else:
		player.position = entrances[direction].position
		
	# level change
	if direction != LevelEntrance.Direction.Up and !is_start:
		player.velocity = Vector2.ZERO
	
	(player.get_node("TrailParticles") as GPUParticles2D).restart()
	(player.get_node("DustParticles") as GPUParticles2D).restart()

func get_direction_enum(dir: Vector2i) -> LevelEntrance.Direction:
	if dir == Vector2i.UP:
		return LevelEntrance.Direction.Up
	if dir == Vector2i.DOWN:
		return LevelEntrance.Direction.Down
	if dir == Vector2i.LEFT:
		return LevelEntrance.Direction.Left
	if dir == Vector2i.RIGHT:
		return LevelEntrance.Direction.Right
		
	return LevelEntrance.Direction.Up
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
