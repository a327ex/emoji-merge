uniform float hue;

vec3 hue_shift(vec3 color, float hue) {
  float s = sin(hue);
  float c = cos(hue);
  return (color*c) + (color*s)*mat3(vec3(0.167444, 0.329213, -0.496657), vec3(-0.327948, 0.035669, 0.292279), vec3(1.250268, -1.047561, -0.202707)) + dot(vec3(0.299, 0.587, 0.114), color)*(1.0 - c);
}

vec4 effect(vec4 vcolor, Image texture, vec2 tc, vec2 pc) {
  vec4 t = Texel(texture, tc);
  return vec4(hue_shift(t.rgb, hue), t.a);
}
