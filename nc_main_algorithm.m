% Main algo

clear all
close all

% Load dictionaries from where we saved them
dict_file = 'Training/rnd_patches_noF_3_80000_s3.mat';
load(dict_file)

% Load a test image
test_image = 'Data/Test/Child_input.png';
I = imread(test_image);
I = double(rgb2gray(I));

% Restrict image size
I = I(30:90, 30:90);

imshow(I/255)

% Make I low resolution
upscale = 3;
lIm = imresize(I, 1/upscale, 'bicubic');
lIm = imresize(lIm, size(I), 'bicubic');
figure;
imshow(lIm/255)

% TODO: transformarea low-res schimba pozitia imaginii!

[rows, cols] = size(I);

patch_size = 3;

I_hr = zeros(rows, cols);

% Fara overlap
for row = 1: patch_size : rows - patch_size + 1
    for col = 1: patch_size : cols - patch_size + 1
        y_orig = lIm(row:row+patch_size-1, col:col+patch_size-1);
        y_orig = y_orig(:);
        
        % Preprocesare y
        mean_y = mean(y_orig);
        y = y_orig - mean_y;
        
        D_tilda = Xl;
        y_tilda = y;
        
        % Do Sparse Coding - prepare parameters
        param.mode=2;        % penalized formulation
        param.lambda=1;  
        param.numThreads=-1; % number of processors/cores to use; the default choice is -1
                             % and uses all the cores of the machine
        param.lambda2 = 0;
        
        % Do Sparse Coding - run
        alpha=mexLasso(y_tilda, D_tilda, param);
        
        % Reconstruct high-res patch
        y_hr = Xh * alpha;
        
        % Readaugare componenta continua
        y_hr = y_hr + mean_y;
        
        % Punem la loc in imaginea high-res totala
        I_hr(row:row+patch_size-1, col:col+patch_size-1) = reshape(y_hr, 3, 3);
        
        fprintf("Done patch row %d, col %d\n", row, col);
    end
end

figure
imshow(I_hr / 255);