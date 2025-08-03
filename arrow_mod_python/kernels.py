import cupy as cp

def __get_kernel(filename, func_name): 
  with open(filename, 'r') as f: 
    boundary_kernel_code = '\n'.join(f.readlines())
    return cp.RawKernel(boundary_kernel_code, func_name)


def get_morph_kernel(): 
  return __get_kernel('morph.cu', 'morph')
