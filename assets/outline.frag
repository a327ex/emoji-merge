vec4 effect(vec4 vcolor, Image texture, vec2 tc, vec2 pc) {
  vec4 t = Texel(texture, tc);
  float x = 1.0/love_ScreenSize.x;
  float y = 1.0/love_ScreenSize.y;

  float a = 0.0;
  a += Texel(texture, vec2(tc.x - 2.0*x, tc.y - 2.0*y)).a;
  a += Texel(texture, vec2(tc.x - x, tc.y - 2.0*y)).a;
  a += Texel(texture, vec2(tc.x, tc.y - 2.0*y)).a;
  a += Texel(texture, vec2(tc.x + x, tc.y - 2.0*y)).a;
  a += Texel(texture, vec2(tc.x + 2.0*x, tc.y - 2.0*y)).a;
  a += Texel(texture, vec2(tc.x - 2.0*x, tc.y - y)).a;
  a += Texel(texture, vec2(tc.x - x, tc.y - y)).a;
  a += Texel(texture, vec2(tc.x, tc.y - y)).a;
  a += Texel(texture, vec2(tc.x + x, tc.y - y)).a;
  a += Texel(texture, vec2(tc.x + 2.0*x, tc.y - y)).a;
  a += Texel(texture, vec2(tc.x - 2.0*x, tc.y)).a;
  a += Texel(texture, vec2(tc.x - x, tc.y)).a;
  a += Texel(texture, vec2(tc.x + x, tc.y)).a;
  a += Texel(texture, vec2(tc.x + 2.0*x, tc.y)).a;
  a += Texel(texture, vec2(tc.x - 2.0*x, tc.y + 2.0*y)).a;
  a += Texel(texture, vec2(tc.x - x, tc.y + 2.0*y)).a;
  a += Texel(texture, vec2(tc.x, tc.y + 2.0*y)).a;
  a += Texel(texture, vec2(tc.x + x, tc.y + 2.0*y)).a;
  a += Texel(texture, vec2(tc.x + 2.0*x, tc.y + 2.0*y)).a;
  a += Texel(texture, vec2(tc.x - 2.0*x, tc.y + y)).a;
  a += Texel(texture, vec2(tc.x - x, tc.y + y)).a;
  a += Texel(texture, vec2(tc.x, tc.y + y)).a;
  a += Texel(texture, vec2(tc.x + x, tc.y + y)).a;
  a += Texel(texture, vec2(tc.x + 2.0*x, tc.y + y)).a;
  a = min(a, 1.0);

  return vec4(0.0, 0.0, 0.0, a);
}
