% GPVARS Displays all the GP variables defined in the workspace.
%
%	GPVARS will list all the GP variables present in the workspace,
%	together with their size, bytes size, and class.
%
gpvars__names = []; gpvars__whos = whos;
for gpvars__k = 1:length(gpvars__whos)
  if strcmp(gpvars__whos(gpvars__k).class, 'gpvar')
    gpvars__names = [gpvars__names gpvars__whos(gpvars__k).name ' '];  
  end
end

disp(' ');
disp('Available GP variables are:')
disp(' ');
if isempty(gpvars__names)
  disp('  None.');
else
  eval(['whos ' gpvars__names])
end
disp(' ');

clear gpvars__names gpvars__whos gpvars__k;
