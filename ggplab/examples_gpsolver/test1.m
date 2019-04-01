%----------------------------------------------------------------------
%
%       TEST 1
%
%----------------------------------------------------------------------
%
%    This script is for testing GP solver.
%    It generates various random problem data and solves this problem.
%    mkgp is a Matlab function that generates random problem data
%    which is originally written by Lieven Vandenberghe and
%    modified by Kwangmoo Koh.

close all; clear all;

randn('state',0);
rand('state',0);

% the size of problem data.
%
% n : # of variable
% m : # of inequality constraints
% w : # of terms in each inequality constraint
% p : # of equality constraints
%        m*w >= n >= p in general.
% s : # of average variables per monomial
%

n = 100; m = 100; w = 5; p = 50; nnz = 5000;
sparsity = nnz/(n*m*w)

disp(sprintf('n = %d, m = %d, w = %d, p = %d, nnz = %d',n,m,w,p,nnz))
szs = w*ones(m+1,1);

% generate random problem data
disp('setting up the problem data...');
[A,b,G,h,x0,nu] = mkgp(n, szs, p, 0, sparsity);

disp('solving the problem...');
% solve the problem using gpcvx
tic
[x1,status1,lambda1,nu1,mu1] = gpcvx(A,b,szs,G,h);
toc
