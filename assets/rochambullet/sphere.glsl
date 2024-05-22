// author:    gist.github.com/aggregate1166877/a889083801d67917c26c12a98e7f57a7
// modifier:  github.com/thedotmatrix -- to run natively with love2d
// license:   creativecommons.org/publicdomain/zero/1.0/
float fx = -1.1; // -1.0 is BARREL, 0.1 is PINCUSHION. For planets, ideally -1.1 to -4.
float fx_scale = 1.1; // Play with this to slightly vary the results.
bool dynamic_crop = false; // Guesses the crop amount with an admittedly badly inaccurate formula.
bool manual_crop = true; // Cut out the junk outside the sphere.
float manual_amount = 0.95; // Higher value = more crop.
vec2 distort(vec2 p) {
  float d = length(p);
  float z = sqrt(1.0 + d * d * fx);
  float r = atan(d, z) / 3.14159;
  r *= fx_scale;
  float phi = atan(p.y, p.x);
  return vec2(r*cos(phi)+.5,r*sin(phi)+.5);
}
vec4 effect( vec4 COLOR, Image TEXTURE, vec2 texture_coords, vec2 screen_coords ) {
  vec2 xy = (2.0 * texture_coords);
  xy.x = xy.x - 1.0;
  xy.y = xy.y - 1.0;
  // Dynamic crop adjustment. -0.5 is equavalent to 'none'.
  float d_adjust = -0.5;
  if (dynamic_crop) {
    d_adjust = (fx/4.0) * -0.6;
  }
  // Perform distortion if needed.
  vec4 tex;
  float d = length(xy);
  if (d < 1.0 - d_adjust) {
    xy = distort(xy);
    tex = Texel(TEXTURE, xy);
    COLOR = tex;
  }
  else {
    COLOR.a = 0.0;
  }
  // Apply manual crop.
  if (manual_crop && d > manual_amount) {
    COLOR.a = 0.0;
  }
  return COLOR;
}
