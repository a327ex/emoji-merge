vec4 effect(vec4 vcolor, Image texture, vec2 tc, vec2 pc) {
  vec4 t = Texel(texture, tc);
  float g = 0.21*t.r + 0.72*t.g + 0.07*t.b;
  return vec4(g, g, g, t.a);
}

