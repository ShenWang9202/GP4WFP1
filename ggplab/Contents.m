% GGPLAB Toolbox
% Version 1.00 May-22-2006
%
% Toolbox information
%
% GP objects
%   gpvar         - Creates GP variable(s)
%   monomial      - Creates a monomial object
%   posynomial    - Creates a posynomial object
%   gposynomial   - Creates a generalized posynomial object
%   gpconstraint  - Creates a GP constraint object
%   gpproblem     - Creates a GP problem (either standard or generalized GP)
%
% Related functions
%   gpvars        - Lists all GP variables in the workspace
%   show          - Display a whole array or a matrix of GP objects
%   gpsolve       - Solves a GP (or GGP) problem
%   eval          - Evaluates a GP function or constraint
%   assign        - Assigns numeric values to GP variables
%
% GP solver functions
%   gpcvx         - Solver for GPs in convex form
%   gpposy        - Solver for GPs in posynomial form 
%   gppd2         - Internal primal-dual interior point solver called by gpcvx
%   lse           - Evaluates log-sum-exp function value
%
% Credits:
%   Almir Mutapcic (object library), Kwangmoo Koh (solver), Seungjean Kim (solver),
%   Lieven Vandenberghe (original solver), and Stephen Boyd (general trouble maker).
