extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var level = load("res://scenes/level_1.tscn") as PackedScene
	var level_instance = level.instantiate()
	level_instance.name = "Level";
	
	add_child(level_instance)
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
