Files:
1. loader.v
2. top_nn.v
3. flatten.v
4. fully_connected1.v
5. fully_connected2.v
6. relu.v
7. argmax.v

Memory:
1. weights_l1.mem
2. weights_l2.mem
3. biases_l1.mem
4. biases_l2.mem

Image to mem:
- img2mem.py

For generating weights:
- weights.py

Commands:
- python3 img2mem.py <image> <out.mem>
- iverilog -o final.vvp top_nn.v flatten.v fully_connected1.v fully_connected2.v argmax.v relu.v loader.v
- vvp final.vvp


