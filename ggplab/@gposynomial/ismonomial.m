function r = ismonomial(obj)
% GPOSYNOMIAL/ISMONOMIAL  Checks whether the input general posynomial is a monomial.
%
%   This is true when a GP variable, a monomial, or a posynomial with a single
%   term are casted as a generalized posynomial.

if( strcmp(obj.op,'obj') )
  r = ismonomial( obj.args{:} );
  return;
end

if( strcmp(obj.op,'*') )
  r = ismonomial( obj.args{1} ) && ismonomial( obj.args{2} );
  return;
end

if isnumeric(obj.op)
  r = ismonomial( obj.args{:} );
  return;
end

% otherwise max and plus cannot give a monomial
r = 0;
