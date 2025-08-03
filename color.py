import argparse
import numpy as np
from PIL import Image, ImageDraw
import os

parser = argparse.ArgumentParser()
parser.add_argument('-p', '--pics', action="store_true")
parser.add_argument('-r', '--reference', action="store_true")
args = parser.parse_args()

'''
hardcoded color values
'''
colors = [(184,238,254),
          (255,229,100),
          (100,255,117),
          (48, 98, 156), 
          (231,101,247),
          (236,236,236), 
          (100,200,255)]

color_names = ["COLOR_W1",
               "COLOR_W2",
               "COLOR_W3",
               "COLOR_W4",
               "COLOR_W5",
               "COLOR_HOLD",
               "COLOR_SHOCK"]

if args.reference: 
    # Reference index, x value, delta y
    color_ref_info = [(0, 0.19, 0.6),
                      (1, 0.24, 0.28),
                      (2, 0.285, 0.28),
                      (4, 0.37, 0.40),
                      (5, 0.46, 0.31)]
    
    num_reference_colors = 6
    ref_path = "./ref_pics"
    os.makedirs(ref_path, exist_ok=True)
    ref_file_name = 'reference colors (neo-classic judgements).png'

    img = Image.open(os.path.join(ref_path,ref_file_name))
    height, width = img.size
    img_arr = np.array(img, dtype=np.uint8)
    draw = ImageDraw.Draw(img)
    
    ref_height = height // num_reference_colors
    
    for n, (ref_idx, ref_x, ref_dy_ratio) in enumerate(color_ref_info): 
        if ref_idx is None: 
            continue
        dy = int(ref_height * ref_dy_ratio)
        x, y = int(ref_x * width), ref_idx * ref_height + dy
        color = tuple(int(a) for a in img_arr[y,x,:3])
        colors[n] = color

        draw.line((0, y, width, y), fill=color, width=4)
        draw.line((x, 0, x, height), fill=color, width=4)

    img.save(os.path.join(ref_path,'picked_ref_colors.png'))


explosion_file = "ddr-hojin/Fallback Explosion.lua"

with open(explosion_file, "r") as f: 
    contents = f.readlines()


for i, (name, color) in enumerate(zip(color_names, colors)): 
    r,g,b = color
    l = 0.2126 * r + 0.7152 * g + 0.0722 * b
    hexcolor = ''.join([hex(c)[2:] for c in color])
    print(f"{name:>11}  {str(color):<17}{round(l,6):<9}   {'0x'+hexcolor:>10}")
    contents[i] = f"local {name} = color(\"#{hexcolor}\")\n"


hold_rgb = [f'{c/255:.3f}' for c in colors[5]]
for i,(color, c) in enumerate(zip(hold_rgb, 'RGB')): 
    contents[len(colors)+i] = f"local {color_names[5]}_{c} = {hold_rgb[i]}\n"

with open(explosion_file, "w") as f: 
    f.writelines(contents)


if args.pics: 
    pics_path = "./color_pics"
    os.makedirs(pics_path, exist_ok=True)
    for color, color_name in zip(colors, color_names): 
        color_array = np.full((50,50,3), color, dtype=np.uint8)
        color_img = Image.fromarray(color_array)
        color_img.save(os.path.join(pics_path, color_name) + ".png")
