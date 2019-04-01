function [res] = solve(prob)
% GPPROBLEM/SOLVE solves a geometric programming optimization problem.
%
% prob: gpproblem object
%

% get the global setting for the preferred GP solver (default is empty)
% test if global var GP_SOLVER is present in the workspace
str_whos = whos('global');
str_whos = {str_whos.name};
if ~any( strcmp(str_whos,'GP_SOLVER') )
  GP_SOLVER = [];
else
  global GP_SOLVER
end

% test if QUIET flag is present in the workspace
if ~any( strcmp(str_whos,'QUIET') )
  QUIET = [];
else
  global QUIET
end

% solver invocation
% if global gp_solver variable is empty, then use default gp_m solver
if isempty( GP_SOLVER )
  [res] = call_gp_m(prob,QUIET);
elseif strcmp(GP_SOLVER, 'mosek')
  [res] = call_mosek(prob);
else
 error(['Unknown GP solver is specified in GP_SOLVER: ', ...
         GP_SOLVER, '.', char(10) ... 
        'Right now we only support external Mosek solver.']);
end

%*********************************************************************
% call stanford gp solver (wrapper)
%*********************************************************************
function [r] = call_gp_m(r,quiet_flag)

% gp_m calling sequence:
[x,status,lambda,nu] = gpposy(r.A,r.b,r.szs',r.G,r.h,[],[],quiet_flag);

if( strcmp(status, 'Solved') )
  r.flag = 1;
elseif(  strcmp(status, 'Infeasible') )
  r.flag = -1;
elseif(  strcmp(status, 'Failed') )
  r.flag = 0;
else
  r.flag = [];
end

% status options:
%
%   1        Function converged to a solution x.
%   0        Number of iterations exceeded MAXITERS.
%  -1        Starting point is not strictly feasible.

if( r.flag == 1 )
  disp('Problem succesfully solved.');
  r.status = 'Solved';

  % retrieve optimal solution
  vars = r.gpvars;
  nums = x(1:length(vars));

  array = []; array_name = []; sol = {};

  for k = 1:length(vars)
    str = vars{k};
    ind = strfind(str, '__array__');
    if isempty(ind) % have a scalar variable
      sz = size(sol);
      sol{sz(1)+1,1} = vars{k};
      sol{sz(1)+1,2} = nums(k);
    else          % have an array
      array_index = str2num( str( ind+9 : end ) );
      if( array_index == 1 )
        if( length(array) > 0 )
          sz = size(sol);
          sol{sz(1)+1,1} = array_name;
          sol{sz(1)+1,2} = array;
        end
        array_name = str( 1 : ind-1 );
        array = [nums(k)];
      else
        array = [array; nums(k)];
      end
    end
  end
  % assign the last array
  if( length(array) > 0 )
    sz = size(sol);
    sol{sz(1)+1,1} = array_name;
    sol{sz(1)+1,2} = array;
  end
  r.solution = sol;

  % compute the optimal objective value
  r.obj_value = eval(r.obj,r.solution);

elseif( r.flag == 0 )
  r.status = 'Failed';
elseif( r.flag == -1 )
  r.status = 'Infeasible';
else
  error(['GP solver has returned an unknown status flag.' char(10) ...
        'Please report this bug.']);
end
return;

%*********************************************************************
% call mosek's gp solver (wrapper)
%*********************************************************************
function [r] = call_mosek(r)

% convert gp_m szs vector into mosek's map vector (including equalities)
szs = [r.szs ones(1,2*length(r.h))];
map = [];

for k = 1:length(szs)
  map = [map (k-1)*ones(1,szs(k))];
end

% add equality constraints as double inequalities
if( ~isempty(r.G) )
  A = [r.A; r.G; -r.G];
  c = [r.b; r.h; 1./r.h];
else
  A = r.A;
  c = r.b;
end

% mosek mskgpopt calling sequence:
[res] = mskgpopt(c,A,map');

r.status = res.sol.itr.solsta;

% populate results
if( strcmp(r.status,'OPTIMAL') )

  % retrieve optimal solution
  vars = r.gpvars;
  nums = exp(res.sol.itr.xx(1:length(vars)));

  array = []; array_name = []; sol = {};

  for k = 1:length(vars)
    str = vars{k};
    ind = strfind(str, '__array__');
    if isempty(ind) % have a scalar variable
      sz = size(sol);
      sol{sz(1)+1,1} = vars{k};
      sol{sz(1)+1,2} = nums(k);
    else          % have an array
      array_index = str2num( str( ind+9 : end ) );
      if( array_index == 1 )
        if( length(array) > 0 )
          sz = size(sol);
          sol{sz(1)+1,1} = array_name;
          sol{sz(1)+1,2} = array;
        end
        array_name = str( 1 : ind-1 );
        array = [nums(k)];
      else
        array = [array; nums(k)];
      end
    end
  end
  % assign the last array
  if( length(array) > 0 )
    sz = size(sol);
    sol{sz(1)+1,1} = array_name;
    sol{sz(1)+1,2} = array;
  end
  r.solution = sol;

  % compute the optimal objective value
  r.obj_value = eval(r.obj,r.solution);

end
return;
