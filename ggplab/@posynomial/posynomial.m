function obj = posynomial(varargin)
% POSYNOMIAL is a posynomial class constructor.
%
%	X = POSYNOMIAL creates an empty posynomial object X.
%
%	Posynomials can be constructed from positive constants, 
%	GP variables, monomials, and other posynomials, using 
%	addition and multiplication.
%	Division is not allowed between posynomials, but a posynomial 
%	can be divided by a monomial to produce another posynomial.
%
superiorto('gpvar', 'monomial');

switch nargin
  case 0
    % no argument: create empty posynomial
    obj.mono_terms = 0;
    obj.monomials = {};
    obj.gpvars = {};
    obj = class(obj,'posynomial');
    return
  case 1 % one argument
    % copy to a new object if posynomial
    if (isa(varargin{1},'posynomial'))
      obj = varargin{1};
    % input is a monomial
    elseif (isa(varargin{1},'monomial'))
      obj.mono_terms = 1;
      obj.monomials{1} = varargin{1};
      obj.gpvars = varargin{1}.gpvars;
      obj = class(obj,'posynomial');
    % input is a gpvar
    elseif (isa(varargin{1},'gpvar'))
      obj = posynomial(monomial(varargin{1}));
    % input is a scalar value
    elseif isnumeric(varargin{1}) 
      obj = posynomial(monomial(varargin{1}));
    end
  otherwise
    % check that first arg is a monomial and assume others are 
    if (isa(varargin{1},'monomial'))
      obj.mono_terms = nargin;
      obj.monomials{1} = varargin{1};
      obj.gpvars = varargin{1}.gpvars;
      for k = 2:nargin
        obj.monomials{k} = varargin{k};
        obj.gpvars = union(varargin{k}.gpvars, obj.gpvars);
      end
      obj = class(obj,'posynomial');
    else
      error('Multiple inputs should be monomials!')
    end
end
