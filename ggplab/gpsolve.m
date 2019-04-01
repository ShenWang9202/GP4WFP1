function [obj_value, solution, status] = gpsolve(varargin)
% GPSOLVE Solves a geometric programming optimization problem. 
%
%	GPSOLVE calls the internal primal-dual interior point solver
%	in order to solve the specified GP problem.
%	GPSOLVE calling sequence is:
%
%	[obj_value, solution, status] = gpsolve(obj, constr_array, flag)
%
%	where inputs are:
%	obj          - objective function for the GP problem 
%	constr_array - array of problem constraints
%	flag         - 'min' or 'max' (optional, default is 'min')
%
%	and outputs are:
%	obj_value - the optimal objective value (a number)
%	solution  - a cell array of GP variable names and their optimal values
%	status    - the problem status flag
%
%	The status can be 'Solved' (if the optimization was successful),
%	'Infeasible' (if the problem was determined to be infeasible), and
%	'Failed' (if the optimization was not successful).
%
%	The inputs can also be empty arrays. If the objective is an empty
%	array or a constant, then GPSOLVE solves a feasibility problem.
%	If the constraint array is empty, then we have an unconstrained GP.
%
%	Internally GPSOLVE creates a GP problem object (gpproblem) and
%	calls its solve method.
%

if nargin == 2 
  obj    = varargin{1};
  constr = varargin{2};
  flag   = 'min';
elseif nargin == 3
  obj    = varargin{1};
  constr = varargin{2};
  flag   = varargin{3};
else
  error('Wrong number of input arguments.')
end

gp_problem_obj = gpproblem(obj, constr, flag);
result_obj = solve(gp_problem_obj);

obj_value = result_obj.obj_value;
solution  = result_obj.solution;
status    = result_obj.status;
