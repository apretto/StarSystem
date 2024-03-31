@tool
extends MeshInstance3D

@export var radius:float = 1:
	set(new_value):
		radius = new_value
		generate_icosphere_mesh()
@export var subdivisions:int = 0:
	set(new_value):
		subdivisions = new_value
		generate_icosphere_mesh()

func _ready():
	generate_icosphere_mesh()

func generate_icosphere_mesh():
	var phi = (1.0 + sqrt(5.0)) * 0.5; # golden ratio
	var a = 1.0
	var b = 1.0 / phi

	var vertices = [
		Vector3(0, b, -a),
		Vector3(b, a, 0),
		Vector3(-b, a, 0),
		Vector3(0, b, a),
		Vector3(0, -b, a),
		Vector3(-a, 0, b),
		Vector3(0, -b, -a),
		Vector3(a, 0, -b),
		Vector3(a, 0, b),
		Vector3(-a, 0, -b),
		Vector3(b, -a, 0),
		Vector3(-b, -a, 0)
	].map(func(vert): return vert.normalized())
	
	var surface_array = []
	var indices = PackedInt32Array()
	indices.append_array([1, 2, 0])
	indices.append_array([2, 1, 3])
	indices.append_array([4, 5, 3])
	indices.append_array([8, 4, 3])
	indices.append_array([6, 7, 0])
	indices.append_array([9, 6, 0])
	indices.append_array([10, 11, 4])
	indices.append_array([11, 10, 6])
	indices.append_array([5, 9, 2])
	indices.append_array([9, 5, 11])
	indices.append_array([7, 8, 1])
	indices.append_array([8, 7, 10])
	indices.append_array([5, 2, 3])
	indices.append_array([1, 8, 3])
	indices.append_array([2, 9, 0])
	indices.append_array([7, 1, 0])
	indices.append_array([9, 11, 6])
	indices.append_array([10, 7, 6])
	indices.append_array([11, 5, 4])
	indices.append_array([8, 10, 4])
	
	var point_lookup = {}
	for sub in range(subdivisions):
		var new_indices = PackedInt32Array()
		for i in range(0, indices.size(), 3):
			var point_a = indices[i]
			var point_b = indices[i+1]
			var point_c = indices[i+2]
			var point_ab
			var point_bc
			var point_ca
			
			var lookup_ab = [min(point_a, point_b), max(point_a, point_b)]
			var lookup_bc = [min(point_b, point_c), max(point_b, point_c)]
			var lookup_ca = [min(point_c, point_a), max(point_c, point_a)]
			
			if point_lookup.has(lookup_ab):
				point_ab = point_lookup[lookup_ab]
			else:
				point_ab = vertices.size()
				vertices.append((vertices[point_a] + vertices[point_b]).normalized())
				point_lookup[lookup_ab] = point_ab
				
			if point_lookup.has(lookup_bc):
				point_bc = point_lookup[lookup_bc]
			else:
				point_bc = vertices.size()
				vertices.append((vertices[point_b] + vertices[point_c]).normalized())
				point_lookup[lookup_bc] = point_bc
				
			if point_lookup.has(lookup_ca):
				point_ca = point_lookup[lookup_ca]
			else:
				point_ca = vertices.size()
				vertices.append((vertices[point_c] + vertices[point_a]).normalized())
				point_lookup[lookup_ca] = point_ca
				
			new_indices.append_array([
				point_a, point_ab, point_ca,
				point_ab, point_b, point_bc,
				point_bc, point_c, point_ca,
				point_ab, point_bc, point_ca
			])
		indices = new_indices
		
	var vertices_array = PackedVector3Array(vertices.map(func(v): return v * radius))
	var normals = PackedVector3Array(vertices)
	var uvs = PackedVector2Array(vertices.map(cartesian_to_uv))
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = vertices_array
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	surface_array[Mesh.ARRAY_TEX_UV] = uvs

	mesh.clear_surfaces()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)

func cartesian_to_uv(cartesian : Vector3) -> Vector2:
	var u = 0.5 + (atan2(cartesian.x, cartesian.z) / (2 * PI))
	var v = 0.5 - (sin(cartesian.y) / PI)
	return Vector2(u, v)
