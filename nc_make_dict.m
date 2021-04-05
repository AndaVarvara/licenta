img_path = 'Data/Training/';
number_of_patches = 80000;
overlap = 1;
scale = 3;
patch_sizel = 3;

%[Y,sizeh,sizel] = sample_dictionary(img_path,number_of_patches,scale,patch_sizel,overlap);

%[Xh, Xl] = rnd_smp_patch(img_path, '*.bmp', patch_sizel, number_of_patches, scale);
[Xh, Xl] = rnd_smp_patch_noF(img_path, '*.bmp', patch_sizel, number_of_patches, scale);
