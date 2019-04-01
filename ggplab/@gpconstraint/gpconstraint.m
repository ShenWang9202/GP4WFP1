function constr = gpconstraint(varargin)
% GPCONSTRAINT is a GP constraint class constructor.
%
%	Inequality operators between GP objects, such as positive
%	scalars, GP variables, monomials, posynomials, and generalized
%	posynomials (when valid) return GPCONSTRAINT objects.
%	These GPCONSTRAINT objects can be assigned to variables, for example,
%	  constr1 = x*y <= z;
%	  constr2 = x^5 == 1;
%	are two valid GP constraints.
%
%	A set of constraint is represented as an array of GP constraints, i.e.,
%	  constr_set = [constr1 constr2];
%
%	You can also define GP constraints using:
%	  constr = gpconstraint('constraint string')
%
if nargin == 0 % create an empty constraint
  constr.lhs    = [];
  constr.type   = [];
  constr.rhs    = [];
  constr.gpvars = {};
  constr = class(constr,'gpconstraint');
  return;
end

if nargin == 1 % one argument
  % invoke copy constructor if the new object is gpconstraint
  if isa(varargin{1},'gpconstraint')
    constr = varargin{1};
    return;
  end
end

if nargin == 3
  % standard argument list
  constr.lhs      = varargin{1};
  constr.type     = varargin{2};
  constr.rhs      = monomial(varargin{3});
  if( isnumeric(constr.lhs) )
    constr.lhs    = monomial(constr.lhs);
    constr.gpvars = constr.rhs.gpvars;
  elseif( isa(constr.lhs,'gpvar') )
    constr.lhs    = monomial(constr.lhs);
    constr.gpvars = union(constr.lhs.gpvars, constr.rhs.gpvars );
  else
    constr.gpvars = union(constr.lhs.gpvars, constr.rhs.gpvars);
  end
  constr = class(constr,'gpconstraint');
  return;
end
