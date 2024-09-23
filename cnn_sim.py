import argparse
import numpy as np

from abc import ABC, abstractmethod

class cnn:
    def compute_parameters(self, ifmap, kernel):
        N, C, W, H = ifmap.shape
        K, _, R, S = kernel.shape
        return (N, K, C, W, H, R, S)

    def compute(self, ifmap, kernel):
        pass

class cnn_traditional(cnn):
    def compute(self, ifmap, kernel):
        ifmap = np.array(ifmap)
        kernel = np.array(kernel)
        
        N, K, C, W, H, R, S = self.compute_parameters(ifmap, kernel)

        # Output dimensions: (N, K, W, H)
        output_tensor = np.zeros((N, K, W, H), dtype=np.uint8)

                # Perform the convolution operation (iterating over the 7 nested loops)
        for n in range(N):       # Loop over batch size
            for k in range(K):   # Loop over output channels (filters)
                for c in range(C):   # Loop over input channels
                    for w in range(W):   # Loop over output width
                        for h in range(H):   # Loop over output height
                            for r in range(R):   # Loop over kernel/filter height
                                for s in range(S):   # Loop over kernel/filter width
                                    output_tensor[n][k][w][h] += (
                                        ifmap[n][c][w + r - 1][h + s - 1] * kernel[k][c][r][s]
                                    )
        return output_tensor

        
class cnn_bitgroup(cnn):
    def __init__(self, Bi, Bw):
        self.Bi = Bi
        self.Bw = Bw
        
    def extract_bits_range(self, num, x, y):
        length = y - x + 1
        shifted_num = num >> x
        mask = (1 << length) - 1 
        return shifted_num & mask
        
    def compute(self, ifmap, kernel):
        ifmap = np.array(ifmap)
        kernel = np.array(kernel)
        
        N, K, C, W, H, R, S = self.compute_parameters(ifmap, kernel)

        # Output dimensions: (N, K, W, H)
        output_tensor = np.zeros((N, K, W, H), dtype=np.uint8)
        
        for n in range(N):       # Loop over batch size
            for k in range(K):   # Loop over output channels (filters)
                for c in range(C):   # Loop over input channels
                    for w in range(W):   # Loop over output width
                        for h in range(H):   # Loop over output height
                            for r in range(R):   # Loop over kernel/filter height
                                for s in range(S):   # Loop over kernel/filter width
                                    for bi in range(self.Bi): # I bit groups
                                        for bw in range(self.Bw): # W bit groups
                                            itensor_bg = self.extract_bits_range(ifmap[n][c][w + r - 1][h + s - 1], 2 * bi, 2 * bi + 1) * (2 ** (2*bi))
                                            ftensor_bg = self.extract_bits_range(kernel[k][c][r][s], 2 * bw, 2 * bw + 1) * (2 ** (2*bw))
                                            output_tensor[n][k][w][h] += itensor_bg * ftensor_bg

        return output_tensor

# Incomplete implementation
class cnn_sparsity_aware(cnn):
    def __init__(self, pe_size):
        self.pe_size = pe_size
        
    def calculate_sparsity(self, matrix):
        matrix = np.array(matrix)
        total_elements = matrix.size
        zero_elements = np.count_nonzero(matrix == 0)
        return zero_elements / total_elements

    def sort_sparsity_indices(self, sparsity_values):
        return sorted(range(len(sparsity_values)), key=lambda i: sparsity_values[i])

    def compute(self, ifmap, kernel):
        for n in range(N):       # Loop over batch size
            for k in range(K):   # Loop over output channels (filters)
                    for w in range(W):   # Loop over output width
                        for h in range(H):   # Loop over output height
                            # Extract the current window of the input tensor across channels
                            input_window = ifmap[n, 0:C, w:w+R, h:h+S]

                            # Calculate average activation sparsity of channel i
                            average_sparsity = []
                            for channel in input_window: # Average activation sparsity of channel i
                                average_sparsity.append(self.calculate_sparsity(channel))

                            # Sort channels by sparsity
                            sorted_channel = self.sort_sparsity_indices(average_sparsity)
                            
                            p = 0
                            PE = [[] for x in range(self.pe_size)]

                            # Assign activation to PE
                            for i in range(C):
                                for j in range(R):
                                    PE[p].append(input_window[sorted_channel[i]][j].tolist())
                                    p += 1
                                    if p == self.pe_size:
                                        p = 0

def create_input_tensor(N, C, W, H):
    return np.array(np.random.randint(0, 5, (N, C, W, H), dtype=np.uint8))

def create_kernel_tensor(K, C, R, S):
    # Filter dimensions: (K, C, R, S)
    filter_tensor = np.zeros((K, C, R, S), dtype=np.uint8)
    
    # Fill the filter with identity matrices (1s along the diagonal)
    for k in range(K):
        for c in range(C):
            for i in range(min(R, S)):  # Ensure it's square (R == S)
                filter_tensor[k][c][i][i] = 1
    return np.array((filter_tensor))

# Main function for handling command-line arguments
def main():
    parser = argparse.ArgumentParser(description='CNN computation modes and parameters')
    
    # Mode selection
    parser.add_argument('--mode', type=str, default="t", help='Mode of CNN operation: traditional, bitgroup, sparsity_aware')
    
    # CNN parameters
    parser.add_argument('--N', type=int, default=1, help='Batch size')
    parser.add_argument('--K', type=int, default=1, help='Number of filters (output channels)')
    parser.add_argument('--C', type=int, default=1, help='Number of input channels')
    parser.add_argument('--W', type=int, default=4, help='Output width')
    parser.add_argument('--H', type=int, default=4, help='Output height')
    parser.add_argument('--R', type=int, default=2, help='Kernel height')
    parser.add_argument('--S', type=int, default=2, help='Kernel width')

    args = parser.parse_args()

    # Generate input and kernel tensors
    input_tensor = create_input_tensor(args.N, args.C, args.W, args.H)
    kernel_tensor = create_kernel_tensor(args.K, args.C, args.R, args.S)

    print("Input Tensor:")
    print(input_tensor)
    print("\n")
    print("Kernel Tensor:")
    print(kernel_tensor)
    print("\n")
    # Instantiate the selected mode
    if args.mode == "t":
        cnn_model = cnn_traditional()
    elif args.mode == "bg":
        cnn_model = cnn_bitgroup(4, 4)  # Example bitgroup configuration
    elif args.mode == "sa":
        cnn_model = cnn_sparsity_aware(4)  # Example PE size
    else:
        raise ValueError(f"Unknown mode: {args.mode}")
    
    # Perform computation
    output = cnn_model.compute(input_tensor, kernel_tensor)
    
    print("Output Tensor:")
    print(output)

if __name__ == "__main__":
    main()