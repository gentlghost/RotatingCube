extends Node2D

@export var perspective: bool = false
@export var distance: float = 2
@export var scaled: float = 150
@export var width: float = 3
@export var color: Color = Color.GREEN
@export var speed: float = 1.0

var angle = 0;

var points: PackedVector3Array = [
	Vector3(-1, -1, 1), Vector3(-1, 1, 1),
	Vector3(1, 1, 1), Vector3(1, -1, 1),
	Vector3(-1, -1, -1), Vector3(-1, 1, -1),
	Vector3(1, 1, -1), Vector3(1, -1, -1),
]

@onready var projected = PackedVector2Array()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("close"):
		get_tree().quit()

func _draw() -> void:
	for point in points:
		var rot = point
		rot = vec3_rotation_x(rot, angle)
		rot = vec3_rotation_y(rot, angle)
		rot = vec3_rotation_z(rot, angle)
		var project = vec3_2_projection(rot, perspective) * scaled
		projected.append(project)
	
	for i in range(0, 4):
		connect_points(i, (i + 1) % 4, projected)
		connect_points(i + 4, ((i + 1) % 4) + 4, projected)
		connect_points(i, i + 4, projected)
	
	projected.clear()

func _process(delta: float) -> void:
	angle += speed * delta
	queue_redraw()

func connect_points(i: int, j: int, proj: PackedVector2Array) -> void:
	draw_line(proj[i], proj[j], color, width)

"""Projection"""
func vec3_2_projection(vec: Vector3, perspect: bool = false) -> Vector2:
	var z: float = 1 / (distance - vec.z) if perspect else 1.0
	
	var projection = [
		[z, 0, 0],
		[0, z, 0]
	]
	
	var x = vec.x * projection[0][0] + vec.y * projection[0][1] + vec.z * projection[0][2]
	var y = vec.x * projection[1][0] + vec.y * projection[1][1] + vec.z * projection[1][2] 
	return Vector2(x, y)

"""Rotation methods"""
"""
	[      1][      0][      0]
x = [      0][ sin(a)][-cos(a)]
	[      0][ cos(a)][ sin(a)]
"""
func vec3_rotation_x(vec: Vector3, theta: float) -> Vector3:
	var y = vec.y * sin(theta) + vec.z * -cos(theta)
	var z = vec.y * cos(theta) + vec.z * sin(theta)
	return Vector3(vec.x, y, z)

"""
	[ sin(a)][      0][-cos(a)]
y = [      0][      1][      0]
	[ cos(a)][      0][ sin(a)]
"""
func vec3_rotation_y(vec: Vector3, theta: float) -> Vector3:
	var x = vec.x * sin(theta) + vec.z * -cos(theta)
	var z = vec.x * cos(theta) + vec.z * sin(theta)
	return Vector3(x, vec.y, z)

"""
	[ sin(a)][-cos(a)][      0]
z = [ cos(a)][ sin(a)][      0]
	[      0][      0][      1]
"""
func vec3_rotation_z(vec: Vector3, theta: float) -> Vector3:
	var x = vec.x * sin(theta) + vec.y * -cos(theta)
	var y = vec.x * cos(theta) + vec.y * sin(theta)
	return Vector3(x, y, vec.z)
