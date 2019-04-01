function [A,b,G,h,x,nu] = mkgp_sparse(n,szs,p,seed, sparsity)
%
% function [A,b,G,h,x,nu] = mkgp_sparse(n,szs,p,seed, sparsity)
%
% Input Arguments:
%
% n   : # of rows of A.
% szs : size variable of each objective and inequality constraints.
% p   : # of rows of G.
% seed: seed of random number generation.
% sparsity: sparsity of A and G matrix.
%
% Output Arguments:
% 
% A,b,G,h : Problem data of a random GP in convex form.

rand('state',seed);
randn('state',seed);

if size(szs,1) < size(szs,2),  szs = szs';  end;
m = length(szs)-1;  
N = sum(szs);

% E is a matrix s.t. [1'*y0  1'*y1  ... 1'*ym ]' = E*y
indsl = cumsum(szs);
indsf = indsl-szs+1;
lx    = zeros(N,1);
lx(indsf) = 1;
E = sparse(cumsum(lx),[1:N],ones(N,1));

disp('pass')
% random nu > 0
nu = rand(N,1);

% 1'*nu = 1
nu(1:szs(1)) = nu(1:szs(1))/sum(nu(1:szs(1)));

% random A
A = sprandn(N,n,sparsity); % A = A - nu*(nu'*A)/(nu'*nu);

% random x
x = randn(n,1)/10;
x(x> 3) =  3;
x(x<-3) = -3;

% b0 is random
b = zeros(N,1);
b(1:szs(1)) = randn(szs(1),1);

% other bi's are constructed so that f(Ai*x+bi) = zi with 
% random positive initial slacks z
z = rand(m,1);
b(szs(1)+1:N) = -A(szs(1)+1:N,:)*x - ...
                E(2:m+1,szs(1)+1:N)'*(z + log(szs(2:m+1))); 

% rnadom G
for i = 1:100
    G = sprandn(p,n,sparsity);
    if (condest(G*G') < 1e16) break; end
end
% G*x + h = 0
h = -G*x;
