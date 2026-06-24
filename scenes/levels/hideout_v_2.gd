extends Level

@export var grid_square_scene: PackedScene
@export var grid_size: int = 10
@export var tile_size: float = 1.0
@export var grid_height: float = 0.52

@onready var grid: Node3D = $Grid


func _ready() -> void:
	#spawn_centered_grid(100)
	enemy_spawn_timer.start()


func spawn_grid(grid_count: int) -> void:
	for x in range(grid_count):
		for z in range(grid_count):
			var square := grid_square_scene.instantiate() as Node3D
			grid.add_child(square)

			square.global_position = Vector3(
				x * tile_size,
				grid_height,
				z * tile_size
			)


func spawn_centered_grid(grid_count: int) -> void:
	var offset := (grid_count - 1) * tile_size * 0.5

	for x in range(grid_count):
		for z in range(grid_count):
			var square := grid_square_scene.instantiate() as Node3D
			grid.add_child(square)

			square.global_position = Vector3(
				(x * tile_size) - offset,
				grid_height,
				(z * tile_size) - offset
			)



func spawn_grid_square(pos: Vector3) -> void:
	var square := grid_square_scene.instantiate()
	square.global_position = pos
	add_child(square)

# square.global_position = Vector3(x, 0.02, z)
