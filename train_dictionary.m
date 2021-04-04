function [Dh, Dl] = train_dictionary(Y,lambda,sizeh,sizel,codebook_size)

 sparsity_function='L1';
 epsilon=[]; % epsilon: epsilon for epsilon-L1 sparsity
 number_of_iter=50;
 batch_size=5000;
 file_name_save=[];
 pars=[]; % pars: additional parameters to specify
 
 % joint learning of the dictionary
 %minimize the error between dictionaries by balancing the cost terms
Y(1:sizeh,:) = 1/sqrt(sizeh)*Y(1:sizeh,:); %1/dimension of the high-resolution image patches in vector form*elements of HR dictionary
Y(1+sizeh:end,:) = 1/sqrt(sizel)*Y(1+sizeh:end,:); %1/dimension of the low-resolution image patches in vector form*elements of LR dictionary

Y = Y(:, 1:100000);
Ynorm = sqrt(sum(Y.^2, 1)); %l2 norm of the dictionary

Y = Y(:, Ynorm > 0.00001); %??
Y = Y./repmat(sqrt(sum(Y.^2, 1)), size(Y,1), 1); %??

% initial B matrix of codebook size
Binit = Y(:, randperm(size(Y, 2),codebook_size));

[Dict] = sparse_coding(Y, codebook_size, 100*lambda/2, sparsity_function, epsilon, number_of_iter,batch_size, file_name_save, pars, Binit);
%[D] = reg_sparse_coding(X, dict_size, [], 0, lambda, 40
Dh = Dict(1:sizeh, :);
Dl = Dict(sizeh+1:end, :);

%???????
% normalize the dictionary extractd by the norm of the dictionary
Dh = Dh./repmat(sqrt(sum(Dh.^2, 1)), sizeh, 1);
Dl = Dl./repmat(sqrt(sum(Dl.^2, 1)), sizel, 1);

save('Data/Dictionary/Dictionary2.mat', 'Dh', 'Dl');

end


