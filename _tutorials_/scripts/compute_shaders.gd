class_name TUTORIAL_SIMPLE_COMPUTE
extends RefCounted

# From godot tutorial: https://docs.godotengine.org/en/latest/tutorials/shaders/compute_shaders.html
func simple_compute_test():
	
	# Create a local rendering device. Need to check performance of doing so at some point.
	var rd := RenderingServer.create_local_rendering_device()
	# To submit tasks in and sync them with the render pipeline use this instead:
	# RenderingServer.get_rendering_device()
	
	# Load GLSL shader
	var shader_file := load("res://_tutorials_/shaders/simple_compute_shader.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	var shader := rd.shader_create_from_spirv(shader_spirv)
	
	# Prepare our data. We use floats in the shader, so we need 32 bit.
	var input := PackedFloat32Array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
	var input_bytes := input.to_byte_array()

	# Create a storage buffer that can hold our float values.
	# Each float has 4 bytes (32 bit) so 10 x 4 = 40 bytes
	var buffer := rd.storage_buffer_create(input_bytes.size(), input_bytes)
	
	
	# Create a uniform to assign the buffer to the rendering device
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	# V - This needs to match the "binding" in our shader file
	uniform.binding = 0 
	uniform.add_id(buffer)
	# V - The last parameter (the 0) needs to match the "set" in our shader file
	var uniform_set := rd.uniform_set_create([uniform], shader, 0) 
	
	# Create a compute pipeline
	var pipeline := rd.compute_pipeline_create(shader)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, 5, 1, 1)
	rd.compute_list_end()
	
	# Submit to GPU and wait for sync
	rd.submit()
	rd.sync()
	
	
	# Read back the data from the buffer
	var output_bytes := rd.buffer_get_data(buffer)
	var output := output_bytes.to_float32_array()
	print("Input: ", input)
	print("Output: ", output)
	
	# Free allocated RID
	rd.free_rid(pipeline)
	rd.free_rid(uniform_set)
	rd.free_rid(buffer)
	rd.free_rid(shader)
	rd.free()
	
