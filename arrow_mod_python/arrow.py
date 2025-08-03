import cv2
import numpy as np
import cupy as cp
from kernels import *
import os
import re
import math

outfolder = 'replace with own folder path'

def save_mask(mask, name, color=(255,255,255)): 
  arrow = np.zeros_like(mask, shape=(H,W,4))
  arrow[:,:,:3] = color
  arrow[:,:,3] = mask
  cv2.imwrite(name, arrow)

def remove_matches(dir, names): 
  files = os.listdir(dir)
  for f in files: 
    for n in names: 
      if re.match(n, f): 
        os.remove(os.path.join(dir, f))
        break


MANHATTAN = 0
EUCLIDEAN = 1
LINF = 2
POLYGON = 3

BS = 32

morph_kernel = get_morph_kernel()
def morph(input, output, H, W, dist, fillval): 
  if dist<=0: 
    return
  GH = H//BS if H%BS==0 else (H//BS)+1
  GW = W//BS if W%BS==0 else (W//BS)+1

  polygon = None
  shape = 'OCTAGON'

  if shape == 'UMBRELLA': 
    sqrt_dist = round(math.sqrt(dist*dist/2))
    polygon = ((0, -dist),
              (sqrt_dist, -sqrt_dist),
              (dist, 0),
              (sqrt_dist, sqrt_dist),
              (0, dist),
              (-sqrt_dist, sqrt_dist),
              (-dist, 0),
              (-sqrt_dist, -sqrt_dist))
    
  elif shape == 'OCTAGON': 
    half = dist / (1 + 2 / math.sqrt(2))      # d = h + 2h/root(2)
    polygon = ((half, -dist),                 # d = h(1+2/root(2))
               (dist, -half),                 # h = d/(1+2/root(2))
               (dist, half),
               (half, dist),
               (-half, dist),
               (-dist, half),
               (-dist, -half),
               (-half, -dist)) 
    
    # s = []
    # for x,y in polygon: 
    #   s.append(f'{x: 10.4f}{y: 10.4f}')
    # print('['+'\n '.join(s)+']')

    polygon = cp.array(polygon, dtype=np.float32)
  
  morph_kernel((GW,GH), (BS,BS), 
               (input,output,H,W,fillval,polygon,
                0 if polygon is None else polygon.shape[0]))

explosion_size = 17
dist = 30.5
overlay_thickness = dist - explosion_size
overlay_opacity = 1.0
receptor_thickness = 14.5
overlay_color = (250,250,250)

receptors = cv2.imread('receptor.png',
                       cv2.IMREAD_UNCHANGED)
receptors[np.all(receptors==[0,0,0,255], axis=2)] = 0
cv2.imwrite('_receptor_no_boundary.png', receptors)
print(receptors.shape) # y, x, c
receptor_mask = cp.array(receptors[:,:,3]) # y, x
new_receptor_mask = cp.copy(receptor_mask)
morph(receptor_mask, new_receptor_mask, receptor_mask.shape[0], receptor_mask.shape[1],
      receptor_thickness, 255)
receptors = cp.asnumpy(receptors)
receptor_mask = cp.asnumpy(receptor_mask)
new_receptor_mask = cp.asnumpy(new_receptor_mask)
receptors[receptor_mask-new_receptor_mask != 0] = [0,0,0,255]

black_length = 0
black_toggle = False
for i in range(receptor_mask.shape[1]): 
  if not black_toggle and np.all(receptors[100,i]==[0,0,0,255]): 
    black_toggle = True
    black_length = 1
  elif black_toggle and np.any(receptors[100,i]!=[0,0,0,255]): 
    black_toggle = False
    print(f'black length: {black_length}')
  else: 
    black_length += 1

cv2.imwrite(os.path.join(outfolder, '_Down Go Receptor Go 2x1 (res 128x64).png'), receptors)
cv2.imwrite('_receptor_preview.png', receptors)

original = cv2.imread('./original.png', 
                        cv2.IMREAD_UNCHANGED)

arrow_mask = original[:,:,3]
RES = 64
new_res = 72
pad_size = round(arrow_mask.shape[1] * (new_res / RES - 1)) // 2
arrow_mask = np.pad(arrow_mask, pad_size)

H,W = arrow_mask.shape

arrow_mask = cp.array(arrow_mask)

outer_mask = cp.copy(arrow_mask)
morph(arrow_mask, outer_mask, H, W, dist, 255)
inner_mask = cp.copy(arrow_mask)
morph(arrow_mask, inner_mask, H, W, dist-overlay_thickness, 255)

overlay_mask = outer_mask - inner_mask
overlay_mask = cp.asnumpy(overlay_mask)
overlay_mask = np.round(
  overlay_mask.astype(np.float32) * overlay_opacity).astype(np.uint8)

black_length = 0
black_toggle = False
for i in range(overlay_mask.shape[1]): 
  if not black_toggle and overlay_mask[100,i]==255: 
    black_toggle = True
    black_length = 1
  elif black_toggle and overlay_mask[100,i]!=255: 
    black_toggle = False
    print(f'overlay length: {black_length}')
  else: 
    black_length += 1

explosion_mask = cp.copy(arrow_mask)
morph(arrow_mask, explosion_mask, H, W, explosion_size, 255)
explosion_mask = cp.asnumpy(explosion_mask)


save_mask(overlay_mask // 4 + explosion_mask // 3, '_preview.png', overlay_color)


overlay_name = 'Down Press'
explosion_name = 'Down Tap Explosion Dim'
postfix = f' (res {new_res}x{new_res}).png'
remove_matches(outfolder, [overlay_name+'*', explosion_name+'*'])
save_mask(overlay_mask, os.path.join(outfolder, overlay_name+postfix), overlay_color)
save_mask(explosion_mask, os.path.join(outfolder, explosion_name+postfix))