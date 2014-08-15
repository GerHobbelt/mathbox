uniform float arrowSize;
uniform float arrowSpace;

attribute vec4 position4;
attribute vec3 arrow;
attribute vec2 attach;

// External
vec3 getPosition(vec4 xyzw);

void getArrowGeometry(vec4 xyzw, float near, float far, out vec3 left, out vec3 right, out vec3 start) {
  right = getPosition(xyzw);
  left  = getPosition(vec4(near, xyzw.yzw));
  start = getPosition(vec4(far, xyzw.yzw));
}

mat4 getArrowMatrix(float size, vec3 left, vec3 right, vec3 start) {
  
  vec3 diff = left - right;
  float l = length(diff);
  if (l == 0.0) {
    return mat4(1.0, 0.0, 0.0, 0.0,
                0.0, 1.0, 0.0, 0.0,
                0.0, 0.0, 1.0, 0.0,
                0.0, 0.0, 0.0, 1.0);
  }

  // Construct TBN matrix around shaft
  vec3 t = normalize(diff);
  vec3 n = normalize(cross(t, t.yzx + vec3(.1, .2, .3)));
  vec3 b = cross(n, t);
  
  // Shrink arrows when vector gets too small, cubic ease asymptotically to y=x
  diff = right - start;
  l = length(diff) * arrowSpace;
  float mini = clamp((3.0 - l / size) * .333, 0.0, 1.0);
  float scale = 1.0 - mini * mini * mini;
  
  // Size to 2.5:1 ratio
  size *= scale;
  float sizeNB = size / 2.5;

  // Anchor at end position
  return mat4(vec4(n * sizeNB,  0),
              vec4(b * sizeNB,  0),
              vec4(t * size, 0),
              vec4(right,  1.0));
}

vec3 getArrowPosition() {
  vec3 left, right, start;
  
  getArrowGeometry(position4, attach.x, attach.y, left, right, start);
  mat4 matrix = getArrowMatrix(arrowSize, left, right, start);
  return (matrix * vec4(arrow.xyz, 1.0)).xyz;

}