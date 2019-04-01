gpvar x y z             % create three scalar GP variables
m1 = 3.4*x^-0.33/z      % form a monomial
p1 = z*sqrt(m1)+0.1/m1  % form a posynomial
gp1 = max(1,x+y,p1)     % form a generalized posynomial

% form an array of constraints
constrs = [ m1==x, p1<=m1, 1<=y, gp1+p1<=5/y ]
% objective
obj = x+y+z
% solve generalized GP and assign solution to GP variables
[obj_value, solution, status] = gpsolve(obj,constrs)
assign(solution)