function [x,status,la,nu,mu] = gppd2(A,b,szs,x0,G,h,phase1,quiet)

% [x,nu,mu,la,status] = gppd2(A,b,szs,x0,G,h,phase1,quiet)
%
% solves the geometric program in convex form with a starting point.
%
%  minimize    lse(y0)
%  subject to  lse(yi) <= 0,   i=1,...,m,
%              Ai*x+bi = yi,   i=0,...,m,
%              G*x+h = 0,
%
% where lse is defined as  lse(y) = log sum_i exp yi,
%
% and the dual problem,
%
%  maximize    b0'*nu0 + ... + bm'*num + h'*mu +
%                 entr(nu0) + la1*entr(nu1/la1) + 
%                 ,..., + lam*entr(num/lam)
%  subject to  nui >= 0,         i=0,...,m,
%              lai >= 0,     i=1,...,m,
%              1'*nu0 = 1
%              1'*nui = lai, i=1,...,m,
%              A0'*nu0 + ... + Am'*num + G'*mu = 0,
%
% where entr is defined as  entr(y) = -sum_i yi*log(yi).
%
% x0 should satisfy the primal inequality constraints.
%
% Input arguments:
%
% - A:         (sum_i n_i) x n matrix; A = [A0' A1' ... Am' ]'
% - b:         (sum_i n_i) vector;   b = [b0' b1' ... bm' ]'
% - szs:       dimensions of Ai and bi; szs = [Nob n1 ... nm]' 
%              where Ai is (ni x n) and bi is (ni x 1)
% - x0:        n-vector; MUST BE STRICTLY FEASIBLE FOR INEQUALITIES
% - G:         p x n matrix
% - h:         p-vector
% - phase1:    boolean variable; indicator for phase I and phase II
%              true -> Phase I, false -> Phase II
% - quiet:     boolean variable; suppress all the print messages if true
%
% Output arguments:
%
% - x:         n-vector; primal optimal point
% - nu:        (sum_i n_i) vector;  nu = [nu0' nu1' ... num']'
%              dual variables for constraints Ai*x + bi = yi
% - mu:        p vector; mu = [mu1 ... mup]'
%              dual variables for constraints G*x + h = 0
% - la:        m vector; la = [lambda1 ... lambdam]'
%              dual variables lambda; la_i = sum(nu_i)
% - status:    scalar;
%              2	Function converged to a solution x.
%              1	Phase I success; x(1:szs(1)) <= 0.
%             -1	Number of iterations exceeded MAXITERS.
%             -2	Starting point is not strictly feasible.
%             -3	Newton step calculation failure.

%----------------------------------------------------------------------
%               INITIALIZATION
%----------------------------------------------------------------------

% PARAMETERS
ALPHA   = 0.01;     % backtracking linesearch parameter (0,0.5]
BETA    = 0.5;      % backtracking linesearch parameter (0,1)
MU      = 2;        % IPM parameter: t update
MAXITER = 500;      % IPM parameter: max iteration of IPM
EPS     = 1e-8;     % IPM parameter: tolerance of surrogate duality gap
EPSfeas = 1e-8;     % IPM parameter: tolerance of feasibility

% DIMENSIONS
[N,n] = size(A); m = length(szs)-1; p = size(G,1); n0 = szs(1);
if (isempty(G)), G = zeros(0,n); h = zeros(0,1); end

warning off all;

% SPARSE ZERO MATRIX
Opxp = sparse(p,p);

% SUM MATRIX: E is a matrix s.t. [1'*y0  1'*y1  ... 1'*ym ]' = E*y
indsl = cumsum(szs); 
indsf = indsl-szs+1;
lx    = zeros(N,1);
lx(indsf) = 1;
E = sparse(cumsum(lx),[1:N],ones(N,1));

x = x0;
% f1m is a LHS vector of inequality constraints s.t [f1' ... fm']'
y = A*x+b;
[f,expyy] = lse(E,y);
f1m       = f(2:m+1);

% CHECK THE INITIAL CONDITIONS
if (max(f1m) >= 0)
   if (~quiet) disp(['x0 is not strictly feasible.']); end
   la = []; nu = []; mu = [];
   status = -2;
   return;
end;

% INITIAL DUAL POINT
la = -1./f1m;   % positive value with duality gap 1.
nu = ones(N,1); % ANY value.
mu = ones(p,1); % ANY value.

step = Inf;

if (~quiet) disp(sprintf('\n%s %15s %11s %20s %18s \n',...
    'Iteration','primal obj.','gap','dual residual','previous step.')); end

%----------------------------------------------------------------------
%               MAIN LOOP
%----------------------------------------------------------------------
for iters = 1:MAXITER

    gap = -f1m'*la;

    % UPDATE T
    % update t only when the current x is not to far from the cetural path.
    if (step > 0.5)
        t = m*MU/gap;
    end

    % CALCULATE RESIDUALS
    % gradfy = exp(y)./(E'*(E*exp(y)));
    gradfy   = expyy./(E'*(E*expyy));
    resDual  = A'*(gradfy.*(E'*[1;la])) + G'*mu;
    resPrim  = G*x + h;
    resCent  = [-la.*f1m-1/t];
    residual = [resDual; resCent; resPrim];

    if (~quiet) disp(sprintf('%4d %20.5e %16.5e %14.2e %16.2e',...
        iters,f(1),-f1m'*la,norm(resDual),step)); end

    % STOPPING CRITERION FOR PHASE I
    if ((phase1 == true) & max(x(1:szs(1))) < 0)
        nu = gradfy.*(E'*[1;la]);
        status = 1;
        return;
    end;
    % STOPPING CRITERION FOR PHASE I & II
    if ( (gap <= EPS) & ...
            (norm(resDual) <= EPSfeas) & (norm(resPrim) <= EPSfeas) )
        % this calculation of nu is correct only when reached to optimal
        nu = gradfy.*(E'*[1;la]);
        status = 2;
        return;
    end;

    % CALCULATE NEWTON STEP
    diagL1  = sparse(1:m+1,1:m+1,[0;-la./f1m]);
    diagL2  = sparse(1:m+1,1:m+1,[1;la]);
    diagG1  = sparse(1:N,1:N,gradfy);
    diagG2  = sparse(1:N,1:N,gradfy.*(E'*[1;la]));

    EGA = E*diagG1*A;
    H1  = EGA'*(diagL1-diagL2)*EGA + A'*diagG2*A;

    dz  = -[ H1, G'   ; ...
             G , Opxp ]...
           \ ...
           [EGA'*[1;-1./(t*f1m)]+G'*mu ; resPrim ];

    % PERTURB KKT WHEN (ALMOST) SINGULAR
    %  add small diagonal terms when the matrix is almost singular.
    perturb = EPS;
    while (any(isinf(dz)))
       dz = -([ H1, G'; G , Opxp ] + sparse(1:n+p,1:n+p,perturb))...
             \ ...
             [EGA'*[1;-1./(t*f1m)]+G'*mu ; resPrim ];
        % increase the size of diagonal term if still singular
        perturb = perturb*10;
    end
    % ERROR CHECK FOR NEWTON STEP CALCULATION
    if (any(isnan(dz)))
        nu = gradfy.*(E'*[1;la]);
        status = -3;
        return;
    end

    dx  = dz(1:n); dy  = A*dx; dmu = dz(n+[1:p]');
    dla = -la./f1m.*(E(2:m+1,:)*(gradfy.*dy))+resCent./f1m;

    % BACKTRACKING LINESEARCH
    negIdx = (dla < 0);
    if (any(negIdx))
        step = min( 1, 0.99*min(-la(negIdx)./dla(negIdx)) );
    else
        step = 1;
    end
    while (1)
        newx    = x  + step*dx;
        newy    = y  + step*dy;
        newla   = la + step*dla;
        newmu   = mu + step*dmu;
        [newf,newexpyy] = lse(E,newy);
        newf1m  = newf(2:end);

        % UPDATE RESIDUAL
        % newGradfy = exp(newy)./(E'*(E*exp(newy)));
        newGradfy = newexpyy./(E'*(E*newexpyy));

        newResDual  = A'*(newGradfy.*(E'*[1;newla])) + G'*newmu;
        newResPrim  = G*newx + h;
        newResCent  = [-newla.*newf1m-1/t];
        newResidual = [newResDual; newResCent; newResPrim];
        
        if ( max(newf1m) < 0 && ...
             norm(newResidual) <= (1-ALPHA*step)*norm(residual) )
            break;
        end
        step = BETA*step;
    end;
    % UPDATE PRIMAL AND DUAL VARIABLES
    x  = newx; mu = newmu; la = newla; y = A*x+b;
    [f,expyy] = lse(E,y); f1m = f(2:m+1);
end
if (iters >= MAXITER)
    if (~quiet) disp(['Maxiters exceeded.']); end
    nu = gradfy.*(E'*[1;la]);
    status = -1;
    return;
end
