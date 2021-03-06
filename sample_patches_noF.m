function [HP, LP] = sample_patches_noF(im, patch_size, patch_num, upscale)

if size(im, 3) == 3,
    hIm = rgb2gray(im);
else
    hIm = im;
end

% generate low resolution counter parts
lIm = imresize(hIm, 1/upscale, 'bicubic');
lIm = imresize(lIm, size(hIm), 'bicubic');
[nrow, ncol] = size(hIm);

x = randperm(nrow-2*patch_size-1) + patch_size;
y = randperm(ncol-2*patch_size-1) + patch_size;

[X,Y] = meshgrid(x,y);

xrow = X(:);
ycol = Y(:);

if patch_num < length(xrow),
    xrow = xrow(1:patch_num);
    ycol = ycol(1:patch_num);
end

patch_num = length(xrow);

hIm = double(hIm);
lIm = double(lIm);

H = zeros(patch_size^2,     length(xrow));
L = zeros(patch_size^2,   length(xrow));
  
% TODO: aici valorile din xrow nu sunt prea aleatoare

for ii = 1:patch_num,    
    row = xrow(ii);
    col = ycol(ii);
    
    Hpatch = hIm(row:row+patch_size-1,col:col+patch_size-1);
    Lpatch = lIm(row:row+patch_size-1,col:col+patch_size-1);
   
    HP(:,ii) = Hpatch(:) - mean(Hpatch(:));
    LP(:,ii) = Lpatch(:) - mean(Lpatch(:));  % Scadem media sau nu?
end