function [x,status,lambda,nu,mu] = gpcvx(A,b,szs,varargin)

% [x,status,lambda,nu,mu] = gpcvx(A,b,szs,G,h,l,u,quiet)
%
% solves the geometric program in convex form
%
%  minimize    lse(y0)
%  subject to  lse(yi) <= 0,   i=1,...,m,
%              Ai*x+bi = yi,   i=0,...,m,
%              G*x+h = 0,
%              li <= xi <= ui, i=1,...,n
%
% where lse is defined as  lse(y) = log sum_i exp yi,
% and the dual problem,
%
%  maximize    b0'*nu0 + ... + bm'*num + h'*mu + lambdal'*l - lambdau'*u +
%                 entr(nu0) + lambda1*entr(nu1/lambda1) + 
%                 ,..., + lambdam*entr(num/lambdam)
%  subject to  nui >= 0,         i=0,...,m,
%              lambdai >= 0,     i=1,...,m,
%              1'*nu0 = 1
%              1'*nui = lambdai, i=1,...,m,
%              A0'*nu0 + ... + Am'*num + G'*mu + lambdau - lambdal = 0,
%
% where entr is defined as  entr(y) = -sum_i yi*log(yi).
%
% Calling sequences:
%
%  [x,status,lambda,nu,mu] = gpcvx(A,b,szs)
%  [x,status,lambda,nu,mu] = gpcvx(A,b,szs,G,h)
%  [x,status,lambda,nu,mu] = gpcvx(A,b,szs,G,h,l,u)
%  [x,status,lambda,nu,mu] = gpcvx(A,b,szs,G,h,l,u,quiet)
%
% Examples:
%
%  [x,status,lambda,nu,mu] = gpcvx(A,b,szs,G,h)
%  [x,status,lambda,nu,mu] = gpcvx(A,b,szs,[],[],[],[],quite)
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
%              dual variables for constraints Ai*x + bi = yi
% - mu:        (sum_i l_i) vector;  mu = [mu0' mu1' ... mul']'
%              dual variables for constraints G*x + h = 0
% - lambda:    m-vector, dual variables for inequality constraints
% - status:    string; 'Infeasible', 'Solved', or 'Failed'
%              
% gpcvx sets up phase 1 and phase 2 and calls the real sovler, gppd2.m.

%----------------------------------------------------------------------
%       INITIALIZATION
%----------------------------------------------------------------------

% PARAMETERS
LOWER_BOUND = -250;
UPPER_BOUND = +250;

% DIMENSIONS
N  = size(A,1);     % # of terms in the obj. and inequalities
n  = size(A,2);     % # of variables (x1,..,xn)
m  = length(szs)-1; % # of inequalities
n0 = szs(1);        % # of terms in the objective

% VARIABLE ARGUMENT HANDLING
defaults  = {[],[],LOWER_BOUND*ones(n,1),UPPER_BOUND*ones(n,1),false};
givenArgs = ~cellfun('isempty',varargin);
defaults(givenArgs) = varargin(givenArgs);
[G,h,l,u,quiet]  = deal(defaults{:});

% MATLAB LIMIT OF LOWER/UPPER BOUNDS
l(l<LOWER_BOUND) = LOWER_BOUND;
u(u>UPPER_BOUND) = UPPER_BOUND;

if (isempty(G)) 
    G = zeros(0,n);
    h = zeros(0,1);
end
p  = size(G,1);     % # of (terms in) the equality constraints

% E is a matrix s.t. [1'*y0  1'*y1  ... 1'*ym ]' = E*y
indsl = cumsum(szs);
indsf = indsl-szs+1;
lx    = zeros(N,1);
lx(indsf) = 1;
E = sparse(cumsum(lx),[1:N],ones(N,1));

%----------------------------------------------------------------------
%               PHASE I
%----------------------------------------------------------------------

% solves the feasibility problem
%
%  minimize    s
%  subject to  lse(yi) <= s,     i=1,...,m,
%              Ai*x+bi = yi,     i=0,...,m,
%              G*x+h = 0,
%              li <= xi <= ui,   i=1,...,n
%
% where lse is defined as  lse(y) = log sum_i exp yi,
%
% For phase I
% 1) change objective function to s
% 2) change constraints from fi(x) <= 0 to fi(x) <= s
% 3) add bound constraints; li <= xi <= ui
%
% Hence, we set up a new objective and constraints, 
%    i.e., A,b,G,h and szs for Phase I optimization.
%
% Change the size vector, szs.
%
% Change A and b
%          s    xi
%   A1 = [ 1 | 0 0 0      b1 = [ 0      <- (a1) new objective
%         ---+------             -
%         -1 |
%         -1 |A(ineq)            b      <- (a2) new inequalities
%         -1 |
%         ---+------             -
%         -1 |-1 0 0             l1
%         -1 | 0-1 0             l2     <- (a4) l <= xi
%         -1 | 0 0-1             l3
%         ---+------             -
%         -1 | 1 0 0            -u1
%         -1 | 0 1 0            -u2     <- (a6) xi <= u
%         -1 | 0 0 1 ];         -u3 ];

% FORM SZS
szs1    = [1; szs(2:end); ones(2*n,1) ];

% FORM INITIAL X
if (p == 0)
    xinit = zeros(n,1);
else
    xinit = G'*((G*G')\h);
end

% FORM INITIAL S
%  sinit = max(fi,0) since fi <= si and 0 <= si

y = A*xinit+b;
[f,expyy] = lse(E,y);
finit = f(2:m+1);
linit = -xinit+l;
uinit = +xinit-u;
sinit = max([0; finit; linit; uinit]) + 1; % + 1 is for margin.

% FORM A AND B
A1 = [+1            , sparse(1,n);...
      -ones(N-n0,1) , A(n0+1:N,:);...
      -ones(n,1)    ,-speye(n)   ;...
      -ones(n,1)    ,+speye(n)   ];
b1 = [ 0; b((n0+1):N); l; -u ];

% FORM G AND H
G1 = [spalloc(size(G,1),1,0), G];
h1 = [h];

% CALL THE INTERNAL GP SOLVER
[x,status,lambda,nu,mu] = gppd2(A1,b1,szs1,[sinit;xinit],G1,h1,true,quiet);

% EXTRACT X FROM [S; X]
x0 = x(2:n+1);

y = A*x0+b;
[f,expyy] = lse(E,y);
f1m       = f(2:m+1);

% FEASIBILITY CHECK OF PHASE I SOLUTION
if (status <= 0 || max([f1m; -Inf]) >= 0)
    status = 'Infeasible';
    if (~quiet) disp(status); end
    return
end
clear A1 b1 G1 h1 x01 szs1;        

%----------------------------------------------------------------------
%               PHASE II
%----------------------------------------------------------------------

% solves the geometric program in convex form
%
%  minimize    lse(y0)
%  subject to  lse(yi) <= 0,   i=1,...,m,
%              Ai*x+bi = yi,   i=0,...,m,
%              G*x+h = 0,
%              li <= xi <= ui, i=1,...,n
%
% where lse is defined as  lse(y) = log sum_i exp yi,
%
% Change A and b to add the bound of x into the inequality constraints.
%           
%   A2 = [  A         b2 = [ b
%         ------            ----
%         -1 0 0             l1
%          0-1 0             l2     <- li <= xi
%          0 0-1             l3
%         ------            ----
%          1 0 0            -u1     <- xi <= ui
%          0 1 0            -u2
%          0 0 1 ];         -u3 ];

szs2 = [ szs ; ones(2*n,1) ];
A2   = [ sparse(A); -speye(n); speye(n) ];
b2   = [ b; l; -u ];

% CALL THE INTERNAL GP SOLVER
[x,status,lambda,nu,mu] = gppd2(A2,b2,szs2,x0,G,h,false,quiet);

if (status <= 0)
    status = 'Failed';
    if (~quiet) disp(status); end
    return
else
    status = 'Solved';
    if (~quiet) disp(status); end
    return
end
