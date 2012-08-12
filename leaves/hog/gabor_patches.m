function patches = gabor_patches(RF, num_orientations)
  patches = cell(1, num_orientations);
  [x, y] = meshgrid(-RF:RF, -RF:RF);
  orientations = linspace(0, pi-pi/num_orientations, num_orientations);
  sigma = 0.0036* (2*RF+1)^2 + 0.35* (2*RF+1) + 0.18
  lambda = sigma /0.8;
  gamma = 0.3;
  for o = 1:num_orientations
    u = x * cos(orientations(o)) + y * sin(orientations(o)); 
    v = - x * sin(orientations(o)) + y * cos(orientations(o));
    r = sqrt(u.^2 + v.^2);
    patches{o} = ...
	exp(-(u.^2 + (v  * gamma).^2) / (2 * sigma^2)) .* cos(2 * pi / lambda * u);
    patches{o} = patches{o} .* double(r <= RF);
    s = norm(patches{o}(:));
    patches{o} = (patches{o})/s;
  end;
%function
