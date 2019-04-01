function obj = monomial(varargin)
% MONOMIAL is a monomial class constructor.
%
%	X = MONOMIAL creates an empty monomial object X.
%
%	Monomials should be created using multiplication, division,
%	and powers (including square-root), starting from positive
%	constants, GP variables, or other monomials.
%
superiorto('gpvar')

switch nargin
  case 0
    % no arguments: produce an empty monomial
    obj.gpvars = {};
    obj.c = [];
    obj.a = [];
    obj = class(obj,'monomial');
  case 1
    % one argument: copy to a new object if monomial object
    if (isa(varargin{1},'monomial'))
      obj = varargin{1};
    % input is a GP variable
    elseif (isa(varargin{1},'gpvar'))
      obj.gpvars = {varargin{1}.label};
      obj.c = 1;
      obj.a = 1;
      obj = class(obj,'monomial');
    % input is GP variable's label (name)
    elseif ischar(varargin{1}) 
      obj.gpvars = {varargin{1}};
      obj.c = 1;
      obj.a = 1;
      obj = class(obj,'monomial');
    % input is a scalar value
    elseif isnumeric(varargin{1}) 
      if( varargin{1} < 0 )
        % scalar has to be a positive number
        error('Scalars in GP functions have to be positive numbers.');
      elseif( varargin{1} == 0 )
        % create a constant monomial except if scalar is zero
        % then create an empty monomial
        obj = monomial;
      else
        obj.gpvars = {};
        obj.c = varargin{1}; 
        obj.a = []; 
        obj = class(obj,'monomial');
      end
    else
      error('Argument should be another monomial, this is a copy constructor.')
    end 
  case 3
    % three arguments (gpvars,c,a)
    obj.gpvars = varargin{1};
    obj.c = varargin{2};
    obj.a = varargin{3};
    obj = class(obj,'monomial');
  otherwise
    error('Wrong number of input arguments')
end
