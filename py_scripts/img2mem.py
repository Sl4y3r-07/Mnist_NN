import sys
import numpy as np
from PIL import Image

def float_to_q15(x):
    x = np.clip(x, -0.9999, 0.9999)
    q15_val = int(np.round(x * (2**15)))
    # 2's complement for -ves
    if q15_val < 0:
        q15_val = (1 << 16) + q15_val
    return q15_val

def image_to_mem(image_path, mem_path):
    img = Image.open(image_path).convert("L").resize((28, 28))
    img_arr = np.array(img, dtype=np.float32) / 255.0

    flat_arr = img_arr.flatten()

    with open(mem_path, "w") as f:
        for val in flat_arr:
            q15_val = float_to_q15(val)
            f.write("{:04x}\n".format(q15_val))
    print(f"Total values written are: {len(flat_arr)}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python image_to_mem.py <input_image> <output_mem>")
    else:
        image_to_mem(sys.argv[1], sys.argv[2])
