#[compute]
#version 450

layout(local_size_x = 64, local_size_y = 1, local_size_z = 1) in;

// Buffers
layout(set = 0, binding = 0, std430) buffer Weights { float data[]; } weights;
layout(set = 0, binding = 1, std430) buffer Biases { float data[]; } biases;
layout(set = 0, binding = 2, std430) buffer Activations { float data[]; } activations;

layout(push_constant) uniform Constants {
    uint input_offset;
    uint output_offset;
    uint weight_offset;
    uint bias_offset;
    
    uint input_size;
    uint output_size;
    uint mode;          // Not used
    uint time_step;     // Not used
    
    float learning_rate;
    uint batch_size;
    uint total_neurons;
} params;

float sigmoid(float x) { return 1.0 / (1.0 + exp(-x)); }
float d_sigmoid(float y) { return y * (1.0 - y); }

void main() {
    uint id = gl_GlobalInvocationID.x;
    if (id >= params.output_size) return;

    // Identify which Batch Sample this thread is processing (Global Y)
    // For Modes 0, 1, 2: We dispatch Y = Batch Size
    uint batch_idx = gl_GlobalInvocationID.y;
    
    // Calculate the memory offset for this specific batch
    // Activations are stored as one giant flat array: [Sample 0...][Sample 1...]
    uint batch_mem_offset = batch_idx * params.total_neurons;


    float sum = 0.0;
    for (uint i = 0; i < params.input_size; i++) {
        // Input comes from current batch offset
        float val = activations.data[batch_mem_offset + params.input_offset + i];
        uint w_idx = params.weight_offset + (i * params.output_size) + id;
        sum += val * weights.data[w_idx];
    }
    sum += biases.data[params.bias_offset + id];
    activations.data[batch_mem_offset + params.output_offset + id] = sigmoid(sum);
}