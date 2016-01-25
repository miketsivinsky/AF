% http://www.mathworks.com/matlabcentral/answers/23647-how-to-make-intensity-attenuated-image-or-defocused-image


% The basic approach is to convolve the focused image with
% the point spread function of the lens.
% What you use for the PSF depends on how accurate you want to be,
% but a simple approximation might be OK.
% Thus you might approximate the PSF with a circular disk,
% whose radius depends on the amount of defocusing needed, like this:

% some data - focused image, grey levels in range 0 to 1
focused_image = double(rgb2gray(imread('saturn.png')))/256;
% approximate psf as a disk
r = 10;   % defocusing parameter - radius of psf
[x, y] = meshgrid(-r:r);
disk = double(x.^2 + y.^2 <= r.^2);
disk = disk./sum(disk(:));
defocused_image = conv2(focused_image, disk, 'valid');
imshow(defocused_image);


% Another possible PSF is a Gaussian function.