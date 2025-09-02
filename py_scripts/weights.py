import tensorflow as tf
import numpy as np
import os
import matplotlib.pyplot as plt

# ==============================================================================
# 1. Model Definition and Training
# ==============================================================================
print("Loading MNIST dataset...")
mnist = tf.keras.datasets.mnist
(x_train, y_train), (x_test, y_test) = mnist.load_data()

# Normalize the input images to be between 0 and 1
x_train, x_test = x_train / 255.0, x_test / 255.0

print("Building the model...")
# Define a model with the same architecture as our Verilog implementation
model = tf.keras.models.Sequential([
    tf.keras.layers.Flatten(input_shape=(28, 28)),
    tf.keras.layers.Dense(32, activation='relu'),
    tf.keras.layers.Dense(10)  # No softmax needed as argmax is done in hardware
])

# Compile and train the model
model.compile(optimizer='adam',
              loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
              metrics=['accuracy'])

print("Training the model...")
history = model.fit(x_train, y_train, epochs=5, validation_split=0.1, verbose=1)

print("\nEvaluating the model...")
test_loss, test_acc = model.evaluate(x_test, y_test, verbose=2)
print(f"Final test accuracy: {test_acc:.4f}")

# ==============================================================================
# 2. Weight and Bias Extraction and Analysis
# ==============================================================================
print("\n--- Extracting weights and biases ---")

# Layer 1 (Hidden Layer)
weights_l1 = model.layers[1].get_weights()[0]
biases_l1 = model.layers[1].get_weights()[1]

# Layer 2 (Output Layer)
weights_l2 = model.layers[2].get_weights()[0]
biases_l2 = model.layers[2].get_weights()[1]

# Print weight statistics for analysis
print(f"Layer 1 weights: shape={weights_l1.shape}, min={weights_l1.min():.4f}, max={weights_l1.max():.4f}")
print(f"Layer 1 biases: shape={biases_l1.shape}, min={biases_l1.min():.4f}, max={biases_l1.max():.4f}")
print(f"Layer 2 weights: shape={weights_l2.shape}, min={weights_l2.min():.4f}, max={weights_l2.max():.4f}")
print(f"Layer 2 biases: shape={biases_l2.shape}, min={biases_l2.min():.4f}, max={biases_l2.max():.4f}")

# ==============================================================================
# 3. Quantization and File Writing
# ==============================================================================
def float_to_q15(x, scale_factor=None):
    """
    Converts a float to a 16-bit signed fixed-point (Q15) integer.

    Args:
        x: Input array of floats
        scale_factor: Optional custom scale factor. If None, uses 2^15

    Returns:
        Quantized values as int16
    """
    if scale_factor is None:
        scale_factor = 2**15

    # Scale the float values
    scaled_val = x * scale_factor

    # Round to the nearest integer
    rounded_val = np.round(scaled_val)

    # Clip to valid int16 range to prevent overflow
    clipped_val = np.clip(rounded_val, -32768, 32767)

    return clipped_val.astype(np.int16)

def analyze_quantization_error(original, quantized, scale_factor=2**15):
    """Analyze the quantization error"""
    reconstructed = quantized.astype(np.float32) / scale_factor
    error = np.abs(original - reconstructed)
    print(f"Quantization error: mean={error.mean():.6f}, max={error.max():.6f}, std={error.std():.6f}")
    return error

def write_mem_file(data, filename, include_header=True):
    """
    Writes a numpy array to a .mem file in 16-bit hex format.

    Args:
        data: Input numpy array
        filename: Output filename
        include_header: Whether to include descriptive header
    """
    # Flatten the data and convert to Q15
    flat_data = data.flatten()
    quantized_data = float_to_q15(flat_data)

    # Analyze quantization error
    print(f"\nProcessing {filename}:")
    analyze_quantization_error(flat_data, quantized_data)

    print(f"Writing {len(quantized_data)} values to {filename}...")

    # Create output directory if it doesn't exist
    os.makedirs(os.path.dirname(filename) if os.path.dirname(filename) else '.', exist_ok=True)

    with open(filename, 'w') as f:
        if include_header:
            f.write(f"// Automatically generated weights for {filename}\n")
            f.write(f"// Original shape: {data.shape}\n")
            f.write(f"// Flattened length: {len(quantized_data)}\n")
            f.write(f"// Data range: [{flat_data.min():.6f}, {flat_data.max():.6f}]\n")
            f.write(f"// Quantization: Q15 format (scale = 2^15)\n")
            f.write("//\n")

        for i, val in enumerate(quantized_data):
            # Format as 4-digit hex, handling two's complement for negative numbers
            # Convert to unsigned 16-bit representation for hex formatting
            int_val = int(val)
            if int_val < 0:
                hex_val = format(65536 + int_val, '04x')  # Two's complement conversion
            else:
                hex_val = format(int_val, '04x')
            f.write(f"{hex_val}")
            if i < len(quantized_data) - 1:  # Add newline except for last element
                f.write("\n")

    print(f"Successfully wrote {filename}")

# ==============================================================================
# 4. Generate Hardware Memory Files
# ==============================================================================

# Create output directory
output_dir = "hardware_weights"
os.makedirs(output_dir, exist_ok=True)

# The Verilog module reads weights for each output neuron sequentially.
# TensorFlow's weight matrix is [input_neurons, output_neurons].
# We need to transpose it so that weights for a single output neuron are contiguous.
write_mem_file(weights_l1.T, f"{output_dir}/weights_l1.mem")
write_mem_file(biases_l1, f"{output_dir}/biases_l1.mem")
write_mem_file(weights_l2.T, f"{output_dir}/weights_l2.mem")
write_mem_file(biases_l2, f"{output_dir}/biases_l2.mem")

