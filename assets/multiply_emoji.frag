uniform vec3 multiplier;

float map(float v, float old_min, float old_max, float new_min, float new_max) {
  return 
    ((v - old_min)/(old_max - old_min))*(new_max - new_min) + new_min;
}

float imap(float v, float min, float max) {
  return min*(1-v) + max*v;
}

vec4 effect(vec4 vcolor, Image texture, vec2 tc, vec2 pc) {
  vec4 t = Texel(texture, tc);
  float v = map(t.r, 0.47058, 1.0, 0.0, 1.0);
   vec3 scaled_multiplier = vec3(imap(v, multiplier.r, 1.0), imap(v, multiplier.g, 1.0), imap(v, multiplier.b, 1.0));
  return vec4(t.rgb*scaled_multiplier.rgb, t.a);
}
