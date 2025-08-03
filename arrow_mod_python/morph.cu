__device__ void swap(float& a, float& b) {
  float t = a;
  a = b;
  b = t;
}

__device__ bool raycast(
  float x1, 
  float y1, 
  float x2, 
  float y2,
  float a, 
  float b
) { // return true if horzontal ray shot from (a,b) to the right
    // casts on to edge (x1,y1)<->(x2,y2) 
  if (fabsf(y1 - y2) < 1e-6f) {
    return false;
  }

  if (y2 < y1) {
    swap(y1,y2);
    swap(x1,x2);
  }

  if ((y1 <= b) && (b < y2)) { // within y-range

    // find x_intercept at y=b on polygon line
    /*
    y-y1 = m (x-x1)
    b-y1 = (y2-y1)/(x2-x1) * (xi-x1)
    (b-y1)*(x2-x1)/(y2-y1) = xi-x1
    xi = x1 + (b-y1)*(x2-x1)/(y2-y1)
    */
    float x_intercept = x1 + (b - y1) * (x2 - x1) / (y2 - y1);
    if (a < x_intercept) { 
      return true;
    }
  }

  return false;
}

__device__ bool withinPolygon(
  const int a, 
  const int b, 
  const float* const polygon_vertices, 
  const int polygon_edge_count
) {
  unsigned int count = 0;

  for (int e = 0; e < polygon_edge_count-1; e+=1) {
    float x1 = polygon_vertices[2*e];
    float y1 = polygon_vertices[2*e+1];
    float x2 = polygon_vertices[2*(e+1)];
    float y2 = polygon_vertices[2*(e+1)+1];
    
    if (raycast(x1,y1,x2,y2,a,b)) {
      count += 1; 
    }
  }
  // check last edge
  float x2 = polygon_vertices[0];
  float y2 = polygon_vertices[1];
  float x1 = polygon_vertices[2*(polygon_edge_count-1)];
  float y1 = polygon_vertices[2*(polygon_edge_count-1)+1];
  if (raycast(x1,y1,x2,y2,a,b)) {
    count += 1;
  }

  if (count % 2 == 1) { // point inside polygon norm
    return true;
  } else {
    return false;
  }
}

// for every pixel, if pixel colored, color around in polygon shape
extern "C" __global__ void morph(
  const unsigned char* const in_mask, 
  unsigned char* const out_mask, 
  const long long H, 
  const long long W,
  const long long fill,
  const float* const polygon_vertices, 
  const long long polygon_edge_count
) {

  int tx = blockDim.x * blockIdx.x + threadIdx.x;
  int ty = blockDim.y * blockIdx.y + threadIdx.y;
  if (tx >= W || tx < 0 || ty >= H || ty < 0 || in_mask[ty*W+tx] == 0) {
    // skip empty pixels
    return;
  }

  float minX = 1e30f;
  float maxX = -1e30f;
  float minY = 1e30f;
  float maxY = -1e30f;
  for (int i = 0; i < polygon_edge_count * 2; i += 2) {
    if (minX > polygon_vertices[i]) minX = polygon_vertices[i];
    if (maxX < polygon_vertices[i]) maxX = polygon_vertices[i];
  }
  for (int j = 1; j < polygon_edge_count * 2; j += 2) {
    if (minY > polygon_vertices[j]) minY = polygon_vertices[j];
    if (maxY < polygon_vertices[j]) maxY = polygon_vertices[j];
  }
  int iminX = static_cast<int>(floorf(minX));
  int imaxX = static_cast<int>(ceilf(maxX));
  int iminY = static_cast<int>(floorf(minY));
  int imaxY = static_cast<int>(ceilf(maxY));

  for (int i = iminX; i <= imaxX; i++) {
  for (int j = iminY; j <= imaxY; j++) {
    int sx = tx + i; 
    int sy = ty + j;
    if (sx >= 0 && sx < W && sy >= 0 && sy < H) {
      if (withinPolygon(i, j, polygon_vertices, polygon_edge_count)) {
        out_mask[sy*W+sx] = fill;
      }
    }
  }
  }
}