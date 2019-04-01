function r = isequal(m1, m2)
% MONOMIAL/ISEQUAL  Checks if two monomials are equal.
% Example: x*y and y*x are equal.
%

% make sure both are monomials
m1 = monomial(m1);
m2 = monomial(m2);

% assume true state (monomials are equal)
r = 1; 
% first check if they have same number of gpvars
if( length(m1.gpvars) ~= length(m2.gpvars) )
  r = 0; % monomials cannot be equal
  return;
end

% check that both have the same variables
if ~isempty(setdiff(m1.gpvars, m2.gpvars))
  r = 0; % monomials cannot be equal
  return;
end

% now check that both have the same exponents
for k = 1:length(m1.gpvars)
  [tf, loc] = ismember( m1.gpvars{k}, m2.gpvars );
  % check the variable exponents
  if( m1.a(k) ~= m2.a(loc) )
    r = 0; % monomial are not equal
    return;
  end
end
