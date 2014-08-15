uniform float lineWidth;
uniform float lineDepth;
uniform vec4 geometryClip;

attribute vec2 line;
attribute vec4 position4;

// External
vec3 getPosition(vec4 xyzw);

void getLineGeometry(vec4 xyzw, float edge, out vec3 left, out vec3 center, out vec3 right) {
  vec4 delta = vec4(1.0, 0.0, 0.0, 0.0);

  center =                 getPosition(xyzw);
  left   = (edge > -0.5) ? getPosition(xyzw - delta) : center;
  right  = (edge < 0.5)  ? getPosition(xyzw + delta) : center;
}

vec3 getLineJoin(float edge, vec3 left, vec3 center, vec3 right) {
  vec2 join = vec2(1.0, 0.0);

  if (center.z < 0.0) {
    vec4 a = vec4(left.xy, right.xy);
    vec4 b = a / vec4(left.zz, right.zz);

    vec2 l = b.xy;
    vec2 r = b.zw;
    vec2 c = center.xy / center.z;

    vec4 d = vec4(l, c) - vec4(c, r);
    float l1 = dot(d.xy, d.xy);
    float l2 = dot(d.zw, d.zw);

    if (l1 + l2 > 0.0) {
      
      if (edge > 0.5 || l2 == 0.0) {
        vec2 nl = normalize(l - c);
        vec2 tl = vec2(nl.y, -nl.x);

        join = tl;
      }
      else if (edge < -0.5 || l1 == 0.0) {
        vec2 nr = normalize(c - r);
        vec2 tr = vec2(nr.y, -nr.x);

        join = tr;
      }
      else {
        vec2 nl = normalize(d.xy);
        vec2 nr = normalize(d.zw);

        vec2 tl = vec2(nl.y, -nl.x);
        vec2 tr = vec2(nr.y, -nr.x);

        vec2 tc = normalize(tl + tr);
      
        float cosA = dot(nl, tc);
        float sinA = max(0.1, abs(dot(tl, tc)));
        float factor = cosA / sinA;
        float scale = sqrt(1.0 + factor * factor);

        join = tc * scale;
      }
    }
    else {
      return vec3(0.0);
    }
  }
    
  return vec3(join, 0.0);
}

vec3 getLinePosition() {
  vec3 left, center, right, join;

  float edge = line.x;
  float offset = line.y;

  vec4 p = min(geometryClip, position4);
  getLineGeometry(p, edge, left, center, right);
  join = getLineJoin(edge, left, center, right);
  
  float width = lineWidth;
  if (lineDepth < 1.0) {
    width /= mix(1.0/max(0.001, -center.z), 1.0, lineDepth);
  }
  
  return center + join * offset * width;
}