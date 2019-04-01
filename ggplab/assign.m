function assign(dict)
% ASSIGN  Assigns values to GP variables as given in the input cell array.
%
%	ASSIGN( gp_vars_values ) takes as the input a cell array of
%	specified GP variables along with their values, and assigns
%	each of the variables to its value.
%
%	gp_vars_values: n-by-2 cell array of GP variable names and values
%	
%	Example: gp_vars_values = {'x' 1; 'y' 2; 'w' ones(25,1)}
%	then, assign( gp_vars_values ) will transform GP variables
%	x y w from gpvars into doubles.
%

sz = size(dict);
if( ~isa(dict,'cell') || sz(2) ~= 2 )
  error('The input argument should be a cell array with 2 columns.');
end

for k = 1:sz(1)
  assignin('base',dict{k,1},dict{k,2});
%%  % added support for structures (rasha's patch 01/26/06)
%%  if ~strcmp(dict{k,1},'') 
%%    disp([dict{k,1} '=' num2str(dict{k,2}) ';']);
%%    evalin('caller',[dict{k,1} '=' num2str(dict{k,2}) ';']);
%%  end
end
