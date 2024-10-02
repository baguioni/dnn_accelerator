import numpy as np
import argparse

def create_image_array(size):
    image_array = np.random.randint(0, 256, (size, size), dtype=np.uint8)
    return image_array
    
def create_ifmap_file(filename, ifmap, kernel):
    X, Y = ifmap.shape
    S, R = kernel.shape
    H = Y - S + 1
    W = X - R + 1
    
    with open(f"{filename}.dat", "w") as file:
        for w in range(W):  # Loop over output width
            for h in range(H):  # Loop over output height
                # Extract the sliding window of the feature map
                rows = ifmap[w:w + S]

                sliding_window = []
                for row in rows:
                    sliding_window.append([format(value, "02x") for value in row[h:h + R]])
                
                # display shape of sliding window
                flat_pe_input = ''.join([val for sublist in sliding_window for val in sublist])
                print(f"len: {len(flat_pe_input)}")
                file.write(flat_pe_input + "\n")  # Newline after each sliding window
    
    print(f"Data has been written to '{filename}.dat'")

def create_output_file(filename, output):
    H, W = output.shape

    with open(f"out-{filename}.dat", "w") as file:
        for w in range(W):  # Loop over output width
            for h in range(H):  # Loop over output height
                file.write(str(output[w][h]) + "\n")
    
    print(f"Data has been written to 'out-{filename}.dat'")

def convolve(ifmap, kernel):
    X, Y = ifmap.shape
    S, R = kernel.shape
    
    H = Y - S + 1
    W = X - R + 1    

    output = np.zeros((H, W), dtype=np.int16)

    for w in range(W):
        for h in range(H):
            for r in range(R):
                for s in range(S):
                    output[w][h] += ifmap[w+r][h+s] * kernel[r][s]
    return output

def main():
    parser = argparse.ArgumentParser(description="Convolve single channel image with a kernel")
    parser.add_argument('shape', type=int, help="Size")
    parser.add_argument('filename', type=str, help="Filename")
    
    args = parser.parse_args()

    ifmap = create_image_array(args.shape)
    print("Input feature map:")
    print(ifmap)
    kernel = np.array([[1, 0, 0],[0, 1, 0],[0, 0, 1]])

    result = convolve(ifmap, kernel)

    create_ifmap_file(args.filename, ifmap, kernel)
    create_output_file(args.filename, result)

if __name__ == "__main__":
    main()
