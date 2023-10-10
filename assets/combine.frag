vec4 effect(vec4 vcolor, Image texture, vec2 tc, vec2 pc) {
  vec4 t = Texel(texture, tc);
  return vec4(vcolor.rgb + t.rgb, t.a);
}
