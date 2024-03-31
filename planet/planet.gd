@tool
extends Node3D

@export var radius: float = 1:
	get:
		return $Surface.radius
	set(new_radius):
		if get_node_or_null("Surface"):
			$Surface.radius = new_radius

@export var subdivisions:int = 0:
	get:
		return $Surface.subdivisions
	set(new_value):
		if get_node_or_null("Surface"):
			$Surface.subdivisions = new_value
		
