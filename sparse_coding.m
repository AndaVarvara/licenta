function [B, S, stat] = reg_sparse_coding(X, num_bases, Sigma, beta, gamma, num_iters, batch_size, initB, fname_save)
% Regularized sparse coding
%
% Inputs
%       X           -data samples, column wise 
%       num_bases   -number of bases
%       Sigma       -smoothing matrix for regularization
%       beta        -smoothing regularization
%       gamma       -sparsity regularization
%       num_iters   -number of iterations 
%       batch_size  -batch size
%       initB       -initial dictionary
%       fname_save  -file name to save dictionary
%
% Outputs
%       B           -learned dictionary
%       S           -sparse codes
%       stat        -statistics about the training
pars = struct; %group related data into fields
pars.patch_size = size(X,1);
pars.num_patches = size(X,2);
pars.num_bases = num_bases;
pars.num_trials = num_iters;
pars.beta = beta; % beta: sparsity penalty parameter
pars.gamma = gamma;
pars.VAR_basis = 1; % maximum L2 norm of each dictionary atom

if ~isa(X, 'double')
    X = cast(X, 'double'); %make X double
end

if isempty(Sigma)
	Sigma = eye(pars.num_bases);
end

%?
if exist('batch_size', 'var') && ~isempty(batch_size) %exist w/ 2 arguments?
    pars.batch_size = batch_size; 
else
    pars.batch_size = size(X, 2);
end

if exist('fname_save', 'var') && ~isempty(fname_save)
    pars.filename = fname_save;
else
    pars.filename = sprintf('Results/reg_sc_b%d_%s', num_bases, datestr(now, 30));	%formats the data in num_bases and datestr according to' '
                                  % datestr creates a character array                                            
                                                             
pars

% initialize basis
if ~exist('initB') || isempty(initB)
    %?
    B = rand(pars.patch_size, pars.num_bases)-0.5; %array of random numbers 
	B = B - repmat(mean(B,1), size(B,1),1);  %?
    B = B*diag(1./sqrt(sum(B.*B))); %l2norm
else
    disp('Using initial B...'); %display that
    B = initB;
end

[L M]=size(B);

t=0;
% statistics variable
stat= [];
stat.fobj_avg = [];
stat.elapsed_time=0;

%????????????????????
% optimization loop
while t < pars.num_trials
    t=t+1;
    start_time= cputime; %total CPU time (in seconds)
    stat.fobj_total=0;    
    % Take a random permutation of the samples
    indperm = randperm(size(X,2));
end

