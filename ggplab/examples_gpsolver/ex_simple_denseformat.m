%----------------------------------------------------------------------
%
%       SIMPLE GP EXAMPLE 1
%
%----------------------------------------------------------------------
%
%   minimize:   x^2 + y^2 + z^2
%   subject to: y <= 2/3;
%               x * y = 1; 
%               y * z = 1; 
%
%   In this problem, we can find an analytic solution of the
%   above optimization problem.
%   The optimal solution is y = 2/3 and x = 3/2, z = 3/2.

clear all; close all;

%----------------------------------------------------------------------
%      PROBLEM DATA IN POSYNOMIAL FORM (DENSE FORMAT)
%----------------------------------------------------------------------

A   = [ 2  0  0 ;...
        0  2  0 ;...
        0  0  2 ;...
        0  1  0 ];
b   = [ 1 1 1 3/2 ]';
szs = [ 3; 1 ];
G   = [ 1  1  0 ;
        0  1  1 ];
h   = [1 1]';

%----------------------------------------------------------------------
%      SOLVE THE PROBLEM IN POSYNOMIAL FORM
%----------------------------------------------------------------------
[x1,status1,lambda1,nu1] = gpposy(A,b,szs,G,h);
sol_posy = x1

%----------------------------------------------------------------------
%      SOLVE THE PROBLEM IN CONVEX FORM
%----------------------------------------------------------------------
[x2,status2,lambda2,nu2,mu2] = gpcvx(A,log(b),szs,G,log(h));
sol_cvx = exp(x2)

