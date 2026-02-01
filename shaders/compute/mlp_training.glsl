#[compute]
#version 450

layout(local_size_x = 64, local_size_y = 1, local_size_z = 1) in;

// Buffers
layout(set = 0, binding = 0, std430) buffer Weights { float data[]; } weights;
layout(set = 0, binding = 1, std430) buffer Biases { float data[]; } biases;
layout(set = 0, binding = 2, std430) buffer Activations { float data[]; } activations;
layout(set = 0, binding = 3, std430) buffer Deltas { float data[]; } deltas;
layout(set = 0, binding = 4, std430) buffer Targets { float data[]; } targets;

layout(set = 0, binding = 5, std430) buffer AdamMW { float data[]; } m_weights;
layout(set = 0, binding = 6, std430) buffer AdamVW { float data[]; } v_weights;
layout(set = 0, binding = 7, std430) buffer AdamMB { float data[]; } m_biases;
layout(set = 0, binding = 8, std430) buffer AdamVB { float data[]; } v_biases;

layout(push_constant) uniform Constants {
    uint input_offset;
    uint output_offset;
    uint weight_offset;
    uint bias_offset;
    
    uint input_size;
    uint output_size;
    uint mode;
    uint time_step;
    
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

    // --- MODE 0: Forward Pass (Parallel Batching) ---
    if (params.mode == 0) {
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

    // --- MODE 1: Backward Output (Parallel Batching) ---
    else if (params.mode == 1) {
        float act = activations.data[batch_mem_offset + params.output_offset + id];
        // Targets are also batched!
        // Assuming Targets layout matches Output Layer size * Batch Size
        uint target_idx = (batch_idx * params.output_size) + id;
        
        float error = act - targets.data[target_idx];
        deltas.data[batch_mem_offset + params.output_offset + id] = error * d_sigmoid(act);
    }

    // --- MODE 2: Backward Hidden (Parallel Batching) ---
    else if (params.mode == 2) {
        float error_sum = 0.0;
        for (uint i = 0; i < params.input_size; i++) {
             // Look at Deltas from the Next Layer (same batch)
             float next_delta = deltas.data[batch_mem_offset + params.input_offset + i];
             uint w_idx = params.weight_offset + (id * params.input_size) + i;
             error_sum += next_delta * weights.data[w_idx];
        }
        float act = activations.data[batch_mem_offset + params.output_offset + id];
        deltas.data[batch_mem_offset + params.output_offset + id] = error_sum * d_sigmoid(act);
    }

    // --- MODE 3: Adam Update (Gradient Accumulation) ---
    // We dispatch Y = 1 (Single thread per neuron, NOT per batch)
    // We loop internally to sum gradients from all batches.
    else if (params.mode == 3) {
        
        // 1. Accumulate Bias Gradient (Sum of Deltas)
        float sum_delta = 0.0;
        for(uint b = 0; b < params.batch_size; b++) {
            uint b_offset = b * params.total_neurons;
            sum_delta += deltas.data[b_offset + params.output_offset + id];
        }
        float avg_grad_b = sum_delta / float(params.batch_size); // Average Gradient

        // Update Bias (Adam)
        uint b_idx = params.bias_offset + id;
        float beta1 = 0.9; float beta2 = 0.999; float eps = 1e-8;
        
        m_biases.data[b_idx] = beta1 * m_biases.data[b_idx] + (1.0 - beta1) * avg_grad_b;
        v_biases.data[b_idx] = beta2 * v_biases.data[b_idx] + (1.0 - beta2) * avg_grad_b * avg_grad_b;
        
        float m_hat_b = m_biases.data[b_idx] / (1.0 - pow(beta1, params.time_step));
        float v_hat_b = v_biases.data[b_idx] / (1.0 - pow(beta2, params.time_step));
        
        biases.data[b_idx] -= params.learning_rate * m_hat_b / (sqrt(v_hat_b) + eps);

        // 2. Accumulate Weight Gradients
        // We own weights connecting INTO us from previous layer
        for (uint k = 0; k < params.input_size; k++) {
            
            float sum_grad_w = 0.0;
            
            // Loop over batch to calculate gradient for this specific weight
            for(uint b = 0; b < params.batch_size; b++) {
                uint b_offset = b * params.total_neurons;
                float d = deltas.data[b_offset + params.output_offset + id];
                float inp = activations.data[b_offset + params.input_offset + k];
                sum_grad_w += d * inp;
            }
            float avg_grad_w = sum_grad_w / float(params.batch_size);

            // Update Weight (Adam)
            uint w_idx = params.weight_offset + (k * params.output_size) + id;
            
            m_weights.data[w_idx] = beta1 * m_weights.data[w_idx] + (1.0 - beta1) * avg_grad_w;
            v_weights.data[w_idx] = beta2 * v_weights.data[w_idx] + (1.0 - beta2) * avg_grad_w * avg_grad_w;
            
            float m_hat_w = m_weights.data[w_idx] / (1.0 - pow(beta1, params.time_step));
            float v_hat_w = v_weights.data[w_idx] / (1.0 - pow(beta2, params.time_step));
            
            weights.data[w_idx] -= params.learning_rate * m_hat_w / (sqrt(v_hat_w) + eps);
        }
    }
}