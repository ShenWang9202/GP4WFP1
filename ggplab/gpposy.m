function [x,status,lambda,nu] = gpposy(A,b,szs,varargin)

% [x,status,lambda,nu] = gpposy(A,b,szs,G,h,l,u,quiet)
%
% solves the geometric program in posynomial form
%
%  minimize    sum_k b0_k*x1^A0_{k1}*...*xn^A0_{kn}
%  subject to  sum_k bi_k*x1^Ai_{k1}*...*xn^Ai_{kn} <= 1, i=1,...,m,
%              hi*x1^G_{i1}*...*xn^G_{in} = 1,            i=1,...,p,
%              li <= xi <= ui,                            i=1,...,n,
%
% where variables are x1,...,xn and the problem data are bi_k, Ai_{kj},
% for i = 1,...,m, hi, G_{ij} for i = 1,...,p.
%
% Calling sequences:
%
%  [x,status,lambda,nu] = gpposy(A,b,szs)
%  [x,status,lambda,nu] = gpposy(A,b,szs,G,h)
%  [x,status,lambda,nu] = gpposy(A,b,szs,G,h,l,u)
%  [x,status,lambda,nu] = gpposy(A,b,szs,G,h,l,u,quiet)
%
% Examples:
%
%  [x,status,lambda,nu] = gpposy(A,b,szs,G,h)
%  [x,status,lambda,nu] = gpposy(A,b,szs,[],[],[],[],quiet)
%
% Input arguments:
%
% - A:         (sum_i n_i) x n matrix;  A   = [A0' A1' ... Am' ]'
% - b:         (sum_i n_i) vector;      b   = [b0' b1' ... bm' ]'
% - szs:       dimensions of Ai and bi; szs = [n0 n1 ... nm]'
%              where Ai is (ni x n) and bi is (ni x 1)
% - G:         p x n matrix
% - h:         p-vector
% - l:         n-vector; lower bound for x
% - u:         n-vector; upper bound for x
% - quiet:     boolean variable; suppress all the print messages if true
%
% Output arguments:
%
% - x:         n-vector; primal optimal point
% - nu:        (sum_i n_i) vector;  nu = [nu0' nu1' ... num']'
%              optimal sensitivity for constraints Ai*x + bi = yi
% - mu:        (sum_i l_i) vector;  mu = [mu0' mu1' ... mul']'
%              optimal sensitivity for constraints G*x + h = 0
% - lambda:    m-vector, optimal sensitivity for inequality constraints
% - status:    string; 'INFEASIBLE', 'SOLVED', or 'FAILED'
%              
% gpposy changes the problem data into posynomial form and calls the the
% sovler, gpcvx.m.

%----------------------------------------------------------------------
%       INITIALIZATION
%----------------------------------------------------------------------

% PARAMETERS
LOWER_BOUND = 1e-100;
UPPER_BOUND = 1e+100;

n   = size(A,2);     % # of variables (x1,..,xn)

% VARIABLE ARGUMENT HANDLING
defaults  = {[],[],LOWER_BOUND*ones(n,1),UPPER_BOUND*ones(n,1),false};
givenArgs = ~cellfun('isempty',varargin);
defaults(givenArgs) = varargin(givenArgs);
[G,h,l,u,quiet]  = deal(defaults{:});

% CONVERT PROBLEM DATA INTO CONVEX FORM
b = log(b); h = log(h); l = log(l); u = log(u);

if ( ~(all(isfinite(b)) && all(isfinite(h))) )
    disp('ERROR: Too small value of b or h');
    x = []; status = 'FAILED'; lambda = []; nu = [];
    return;
end
%----------------------------------------------------------------------
%       Call gpcvx
%----------------------------------------------------------------------
[x,status,lambda,empty,nu] = gpcvx(A,b,szs,G,h,l,u,quiet);

% CONVERT SOLUTION TO POSYNOMIAL FORM
x = exp(x);
