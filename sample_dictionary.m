function [Y,sizeh,sizel]=sample_dictionary(img_path,number_of_patches,scale,patch_sizel,overlap)

img_list=dir(fullfile([img_path, '*.bmp']));%lists the content of the directory of that respective path (lists all training images)
number_of_img=size(img_list,1);

numel_img=zeros(number_of_img,1);     % numar de pixeli din imagine
patches_in_img=zeros(number_of_img,1); 

%get the number of elements of each image
for i=1:number_of_img
   numel_img(i)=numel(imread([img_path,img_list(i).name]))/3; %matrix containing size of each image
end

% ?
patches_in_img=fix(number_of_patches*numel_img/sum(numel_img)); % number of patches in ONE image
% ?? clear numel_img

Yh=[];
Yl=[];

for i=1:number_of_img
    current_img=rgb2gray(imread([img_path,img_list(i).name]));
    %?
    img_sizel=size(current_img); %a row vector with image's size [row column]
    img_sizel=(fix(img_sizel./scale))*scale;%generate size of cropped image  
    current_img=current_img(1:img_sizel(1),1:img_sizel(2));
    
    %imgl = imresize(current_img, 1/scale);
    %imgl = imresize(imgl,scale);
    
    imgl=current_img;
    feat_scale=2;
    %size of the upsampled image
    img_sizeh = img_sizel.*scale ;
    

     % extract gradient feature from lIm using f1,f2,f3,f4 in sec.3.2 of [1]
        % from an upsampled image of size feat_scale=2.
    imgm = imresize(imgl, feat_scale, 'bicubic');
    imgh = imresize(imgl, scale, 'bicubic');
    
    patch_sizeh = patch_sizel*scale;
    patch_sizem = patch_sizel*feat_scale; %image by factor of two using Bicubic interpolation, and then extract gradient features from it
    fea=[]; %feature extraction operator
    %feature vectors for each patch
    fea(:,:,1) = conv2(double(imgm),[-1,0,1],'same'); %the central part of the 2D conv that is the same size as imgm
    fea(:,:,2) = conv2(double(imgm),[-1,0,1]','same');
    fea(:,:,3) = conv2(double(imgm),[1,0,-2,0,1],'same');
    fea(:,:,4) = conv2(double(imgm),[1,0,-2,0,1]','same');

    %? why not img_size-ceil(patch_size/2.0)+1
    ygrid = ceil(patch_sizel/2.0):patch_sizel-overlap:img_sizel(1)-patch_sizel; %how patch travels on rows
    xgrid = ceil(patch_sizel/2.0):patch_sizel-overlap:img_sizel(2)-patch_sizel;
    %add last patch to make sure that complete image is recovered.Patch may be
    %written twice -trivial
    ygrid = [ygrid, img_sizel(1)-patch_sizel];
    xgrid = [xgrid, img_sizel(2)-patch_sizel];
    
    [x,y] = meshgrid(xgrid,ygrid); %%X is a matrix where each row is a copy of xgrid, and Y is a matrix where each column is a copy of ygrid
    x=x(:);%makes x a column vector
    y=y(:);
    t1=randperm(length(y));%a row vector containing a random permutation of the integers from 1 to length(y)
    t2=randperm(length(x));
    ygrid=y(t1); %a matrix in which all rows are t1???
    ygrid=ygrid(1:patches_in_img(i)); %only use as many grid elements as needed
    xgrid=x(t2);
    xgrid=xgrid(1:patches_in_img(i));
    
    %grid for upsampled image
    xgridm = (xgrid - 1)*feat_scale + 1; %why?
    ygridm = (ygrid - 1)*feat_scale + 1;
    
    %grid for recovered image
    xgridh = (xgrid-1)*scale + 1;
    ygridh = (ygrid-1)*scale + 1;
    
    count=0;
    allPatchH=[];
    allPatchM=[];
    
    for j=1:patches_in_img(i)
         %extract patch and its transpose accounting for two patches in
         %the dictionary
         count=count+1;
         patchH = imgh(ygridh(j):ygridh(j)+patch_sizeh-1,xgridh(j):xgridh(j)+patch_sizeh-1); %high resol patch has patch_size and is situated at a certain spot
         patchHt=patchH';
         
         %extract patches from each gradient map at each location
         patchM = fea(ygridm(j):ygridm(j)+patch_sizem-1,xgridm(j):xgridm(j)+patch_sizem-1,:);
         patchMt= permute(patchM,[2,1,3]);%rearranges the dimensions of A so that they are in the order specified by the vector
         
         %We subtract the mean pixel value for each patch, so that the dictionary represents image textures rather
         %than absolute intensities
         allPatchH(:,count) = patchH(:)-mean(patchH(:)); %mean returns the mean of the elem. of patchH
         allPatchM(:,count) = patchM(:); 
         %?
         count = count + 1;
         allPatchH(:,count) = patchHt(:)-mean(patchH(:));
         allPatchM(:,count) = patchMt(:);
         
    end
    
    %concatenate patches sampled from each image
    Yh=[Yh,allPatchH];
    Yl=[Yl,allPatchM];
    
    %concatenate the sampled patches
    sizeh=size(Yh,1); %the length of dimension 1
    sizel=size(Yl,1);
    Y=[Yh;Yl]; 
   
end
    