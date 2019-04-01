function r = gpproblem(varargin)
% GPPROBLEM is a GP problem class constructor.
%
%	Define GP problem via:
%	  problem = GPPROBLEM(obj, constr_set, type)   % pass objects as inputs
%	  problem = GPPROBLEM('obj', constr_set, type) % pass objective as a string
%
% 	Here type should be either: 'min' or 'max'.
%
%	GPPROBLEM can be solved by invoking SOLVE method, i.e.,
%	  problem = solve(problem)
%
%	GPPROBLEM object has many fields and some of the important ones are:
%
%	status - the status of the problem
%	type - type of the problem
%
%	gpvars - original problem's GP variables
%	new_gpvars - newly introduced GP variables (due to GGP -> GP conversion)
%
%	solution - GP problem solution
%
%	obj - the objective function
%	obj_value - the objective function value
%	std_obj - the standardized objective function (after GGP -> GP conversion)
%
%	constr - problem's original constraints
%	new_constr - newly introduced constraints (due to GGP -> GP conversion)
%
%	std_ineq - collection of all standardized inequalities (after GGP conversion)
%	std_eq - collection of all standardized equalities (after GGP conversion)
%
%	A - matrix A passed to internal gpposy solver
%	b - vector b
%	szs - vector szs 
%	G - matrix G
%	h - vector h 
%	(data A, b, szs, G, and h are all sparse matrices passed to gpposy)
%	

%******************************************************************************
% constructor calls
%******************************************************************************
if nargin == 0
  % no argument: create an empty gp problem 
  r.status = 'Unsolved';
  r.flag   = 0;
  r.type   = []; 

  r.gpvars = {}; 
  r.new_gpvars = {};
  r.new_gpvars_count = 0;

  r.solution = []; 

  r.obj       = []; 
  r.obj_value = []; 
  r.std_obj   = []; 

  r.constr       = [];
  r.constr_value = [];
  r.constr_dual  = [];

  r.new_constr   = {};

  r.std_ineq = {};
  r.std_eq   = {};

  r.A = []; r.b = []; r.szs = [];
  r.G = []; r.h = [];

  r.nu    = [];
  r.mu    = [];
  r.lambda = [];

  r = class(r,'gpproblem');
  return;
end

if nargin == 1
  % copy constructor
  if isa(varargin{1},'gpproblem')
    F = varargin{1};
    return;
  else
    error(['Single input to gpproblem constructor should be a GP problem.'...
          char(10) 
          'If you are trying to form an unconstrained GP problem, then use:'...
          char(10) 'gpproblem(obj, [])']);
  end
end

if nargin == 2
  % default optimization problem type is minimization
  r = gpproblem(varargin{1}, varargin{2},'min');
  return;
end

if nargin == 3
  % no solution information until solve is invoked
  r = gpproblem;
  if( strcmp(varargin{3},'min') || strcmp(varargin{3},'max') || ...
      strcmp(varargin{3},'feas') )
    r.type = varargin{3};
  else
    error('Unknown problem type. Valid entries are ''min'', ''max'', and ''feas''.');
  end

  % process objective function
  r.obj = varargin{1};

  % assign zero value if problem objective is empty (feasibility problem)
  if( isempty(r.obj) )
    r.obj = 0;
  end

  % check that objective is a scalar (not an array)
  if( length(r.obj) > 1 )
    error('Objective must be a 1x1 input or an empty matrix, it cannot be an array.');
  end
  % make sure objective is a gp type object
  if ischar(r.obj) 
    r.obj = evalin('caller',r.obj);
  elseif isa(r.obj, 'gpvar')
    r.obj = monomial(r.obj);
  elseif ( isnumeric(r.obj) )
    % have a feasibility problem
    r.type = 'feas';
    r.obj  = monomial(r.obj);
  end

  % create a standard GP objective function for the given problem type
  switch r.type
    case 'min'
      [r.std_obj new_con new_vars] = standardize(r.obj,r.new_gpvars_count);

      r.new_constr = {r.new_constr{:} new_con{:}};
      r.new_gpvars = {r.new_gpvars{:} new_vars{:}};
      r.new_gpvars_count = r.new_gpvars_count + length(new_vars);

    case 'feas'
      r.std_obj = monomial; % create an empty monomial as the objective
    case 'max'
      if( isa(r.obj, 'monomial') )
        r.std_obj = 1/r.obj;
      else
        error('GP maximization problem is only allowed with a monomial objective.')
      end
  end

  % populate gp problem vars with initial objective variables
  r.gpvars = r.obj.gpvars; 

  % process constraints and return inequlities and equalities
  r.constr = varargin{2};

  % go through constraint set and process constraints 
  for k = 1:length(r.constr)
    current = r.constr(k);
    % add current constraint gp variables to the problem gpvars
    r.gpvars = union(current.gpvars, r.gpvars);
    % check for inequalities/equalities
    if( strcmp(current.type, '<=') )
      [std_lhs new_con new_vars] = standardize(current.lhs,r.new_gpvars_count);
      r.std_ineq{end+1} = std_lhs/current.rhs;

      r.new_constr = {r.new_constr{:} new_con{:}};
      r.new_gpvars = {r.new_gpvars{:} new_vars{:}};
      r.new_gpvars_count = r.new_gpvars_count + length(new_vars);
    elseif ( strcmp(current.type, '==') )
      r.std_eq{end+1} = current.lhs/current.rhs; 
    end
  end

  % go through the newly created constraints and process them 
  for k = 1:length(r.new_constr)
    current = r.new_constr{k};
    r.std_ineq{end+1} = current.lhs/current.rhs;
  end 

  % creating matrices that will be passed to GP solvers
  % count number of monomials in the objective and all constraints
  if( isa(r.std_obj,'monomial') )
    Arows = 1;
  else
    Arows = r.std_obj.mono_terms;
  end

  for k = 1:length(r.std_ineq)
    ineq = r.std_ineq{k};
    if( isa(ineq,'monomial') )
      Arows = Arows + 1;
    else
      Arows = Arows + ineq.mono_terms;
    end
  end

  Grows = 0;
  for k = 1:length(r.std_eq)
    eq = r.std_eq{k};
    if( isa(eq,'monomial') )
      Grows = Grows + 1;
    else
      Grows = Grows + eq.mono_terms;
    end
  end

  % construct a list of all gp variables
  total_gpvars = {r.gpvars{:} r.new_gpvars{:}};
  Acols = length(total_gpvars); Gcols = Acols;
  global GPVAR_LIST;
  GPVAR_LIST = total_gpvars;
  % GPVAR_LIST = unique(total_gpvars)

  % matrix initialization
  A = sparse(Arows,Acols);
  c = sparse(Arows,1);
  szs = [];

  G = sparse(Grows,Gcols);
  h = sparse(Grows,1);

  % add objective to the matrix A
  if( isa(r.std_obj,'monomial') )
    szs = [1];
    index_map = find_index_map(r.std_obj);
    if( ~isempty(index_map) ) % it is empty if current is a constant
      A(1,index_map) = r.std_obj.a;
    end
    if( ~isempty(r.std_obj.c) )
      c(1) = r.std_obj.c;
    else
      c(1) = 0; % feasibility problem
    end

  else % standardized objective is a posynomial
    szs = [r.std_obj.mono_terms];
    for k=1:szs
      current = r.std_obj.monomials{k};
      index_map = find_index_map(current);
      if( ~isempty(index_map) ) % it is empty if current is a constant
        A(k,index_map) = current.a;
      end
      c(k) = current.c;
    end
  end    

  % add constraint inequalities to the matrix A
  ptr = szs;
  for k = 1:length(r.std_ineq)
    ineq = r.std_ineq{k};
    if( isa(ineq,'monomial') )
      szs = [szs 1];
      index_map = find_index_map(ineq);
      ptr = ptr + 1;
      A(ptr,index_map) = ineq.a;
      c(ptr) = ineq.c;

    else % standardized inequality is a posynomial
      szs = [szs ineq.mono_terms];
      for m=1:ineq.mono_terms
        current = ineq.monomials{m};
        index_map = find_index_map(current);
        ptr = ptr + 1;
        % (01/26/06 fix by rasha) fixed a bug where we did not deal 
        % with posyinomials containing constants
        if( ~isempty(index_map) ) % it is empty if current is a constant
          A(ptr,index_map) = current.a;
        end
        c(ptr) = current.c;
      end
    end    
  end

  % add constraint equalities to the matrix G
  for k = 1:length(r.std_eq)
    eq = r.std_eq{k};
    index_map = find_index_map(eq);
    G(k,index_map) = eq.a;
    h(k) = eq.c;
  end

  r.A = A; r.b = c; r.szs = szs;
  if( length(r.std_eq) > 0 )
    r.G = G; r.h = h;
  end
  
  return; % end of default (three) argument constructor
end

%******************************************************************************
% helper functions
%******************************************************************************
function [index_map] = find_index_map(monomial)
global GPVAR_LIST;

vars = monomial.gpvars;
index_map = [];

for k = 1:length(vars)
  [tf, loc] = ismember(vars{k}, GPVAR_LIST); % return location (index)
  index_map = [index_map loc];
end
return;

%******************************************************************************
function [std_obj,new_constr,new_gpvars] = standardize(obj,new_gpvars_count);
%******************************************************************************
% standardize a generalized posynomial by converting it into GP inequalities
% and reducing the original function to a GP problem valid function.
%
new_constr = {};
new_gpvars = {};

% first see if the object can be reduced using eval command
% for example, we could have a monomial that was casted as a generalized posynomial, etc.

obj = eval( obj, {'' []} );

if( isa(obj,'gposynomial') )

  % have a positive fractional power
  if( isnumeric(obj.op) ) 
    if( isa(obj.args{1},'gposynomial') )
      [posy,new_con,new_vars] = standardize(obj.args{1},new_gpvars_count);
      std_obj = (posy)^(obj.op);

      new_gpvars_count = new_gpvars_count + length(new_vars);
      new_constr = {new_constr{:} new_con{:}};
      new_gpvars = {new_gpvars{:} new_vars{:}};

    else % argument is a posynomial or monomial, etc.
      epi_var = monomial(['temp__' num2str(new_gpvars_count)]);
      new_gpvars_count = new_gpvars_count + 1;
      new_gpvars{end+1} = epi_var.gpvars{:};

      lhs = obj.args{1};
      new_constr{end+1} = lhs <= epi_var;

      std_obj = epi_var^(obj.op); 
    end

  % have a max operation
  elseif( strcmp(obj.op, 'max') )
    epi_var = monomial(['temp__' num2str(new_gpvars_count)]);
    new_gpvars_count = new_gpvars_count + 1;
    new_gpvars{end+1} = epi_var.gpvars{:};
    for k=1:length(obj.args)
      if( isa(obj.args{k},'gposynomial') )
        [posy,new_con,new_vars] = standardize(obj.args{k},new_gpvars_count);

        new_gpvars_count = new_gpvars_count + length(new_vars);
        new_constr = {new_constr{:} new_con{:}};
        new_gpvars = {new_gpvars{:} new_vars{:}};

        new_constr{end+1} = posy <= epi_var;

      else % argument is a posynomial or monomial, etc.
        lhs = obj.args{k};
        new_constr{end+1} = lhs <= epi_var;
      end
    end
    std_obj = epi_var; 

  % have an addition operation
  elseif( strcmp(obj.op, '+') )
    % have three cases depending if an argument is gposy or not
    arg1_flag = isa(obj.args{1},'gposynomial');
    arg2_flag = isa(obj.args{2},'gposynomial');

    % could eliminate this checking but that might be too much recursion
    if( arg1_flag & arg2_flag )
      [std_obj1, new_con1, new_gpvars1] = standardize(obj.args{1},new_gpvars_count);
      new_gpvars_count = new_gpvars_count + length(new_gpvars1);

      [std_obj2, new_con2, new_gpvars2] = standardize(obj.args{2},new_gpvars_count);
      new_gpvars_count = new_gpvars_count + length(new_gpvars2);

      std_obj = std_obj1 + std_obj2;
      new_constr = {new_constr{:} new_con1{:} new_con2{:}};
      new_gpvars = {new_gpvars{:} new_gpvars1{:} new_gpvars2{:}};

    elseif( arg1_flag & ~arg2_flag )
      [std_obj1, new_con1, new_gpvars1] = standardize(obj.args{1},new_gpvars_count);
      new_gpvars_count = new_gpvars_count + length(new_gpvars1);

      std_obj = std_obj1 + obj.args{2};
      new_constr = {new_constr{:} new_con1{:}};
      new_gpvars = {new_gpvars{:} new_gpvars1{:}};

    elseif( ~arg1_flag & arg2_flag )
      [std_obj2, new_con2, new_gpvars2] = standardize(obj.args{2},new_gpvars_count);
      new_gpvars_count = new_gpvars_count + length(new_gpvars2);

      std_obj = obj.args{1} + std_obj2;
      new_constr = {new_constr{:} new_con2{:}};
      new_gpvars = {new_gpvars{:} new_gpvars2{:}};
    end

  % have a multiplication operation
  elseif( strcmp(obj.op, '*') )
    % have three cases depending if an argument is gposy or not
    arg1_flag = isa(obj.args{1},'gposynomial');
    arg2_flag = isa(obj.args{2},'gposynomial');

    % could eliminate this checking but that might be too much recursion
    if( arg1_flag & arg2_flag )
      [std_obj1, new_con1, new_gpvars1] = standardize(obj.args{1},new_gpvars_count);
      new_gpvars_count = new_gpvars_count + length(new_gpvars1);

      [std_obj2, new_con2, new_gpvars2] = standardize(obj.args{2},new_gpvars_count);
      new_gpvars_count = new_gpvars_count + length(new_gpvars2);

      std_obj = std_obj1 * std_obj2;
      new_constr = {new_constr{:} new_con1{:} new_con2{:}};
      new_gpvars = {new_gpvars{:} new_gpvars1{:} new_gpvars2{:}};

    elseif( arg1_flag & ~arg2_flag )
      [std_obj1, new_con1, new_gpvars1] = standardize(obj.args{1},new_gpvars_count);
      new_gpvars_count = new_gpvars_count + length(new_gpvars1);

      std_obj = std_obj1 * obj.args{2};
      new_constr = {new_constr{:} new_con1{:}};
      new_gpvars = {new_gpvars{:} new_gpvars1{:}};

    elseif( ~arg1_flag & arg2_flag )
      [std_obj2, new_con2, new_gpvars2] = standardize(obj.args{2},new_gpvars_count);
      new_gpvars_count = new_gpvars_count + length(new_gpvars2);

      std_obj = obj.args{1} * std_obj2;
      new_constr = {new_constr{:} new_con2{:}};
      new_gpvars = {new_gpvars{:} new_gpvars2{:}};
    end
  end

else % we already have a posynomial or monomial, etc...
  std_obj = obj;

end

return;
