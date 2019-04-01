function display(obj)
% GPPROBLEM display method
%

if strcmp(obj.type,'min') 
  str_type = 'minimization';
elseif strcmp(obj.type,'max')
  str_type = 'maximization';
elseif strcmp(obj.type,'feas')
  str_type = 'feasibility';
end;

disp(' ');

if( strcmp(obj.status,'Unsolved') )
  disp([inputname(1),' is a GP ' str_type ' problem with status: ' ...
        obj.status '.' char(10) char(10) ...
        'Its objective function is:' char(10) char(10) ...
        '  ' symbolic(obj.obj) char(10) char(10) ...
        'and it has ' ...
        num2str(length(obj.constr)) ' constraint(s).' ])

elseif( strcmp(obj.status,'Solved') )
  disp([inputname(1),' is a GP ' str_type ' problem with status: ' ...
        obj.status char(10) '.' ...
        'Its optimal objective value is: ' num2str(obj.obj_value)])

elseif( strcmp(obj.status,'OPTIMAL') )
  disp([inputname(1),' is a GP ' str_type ' problem with status: ' ...
        obj.status ' (it was solved using Mosek).' char(10) ...
        'Its optimal objective value is: ' num2str(obj.obj_value)])

elseif( strcmp(obj.status,'Failed') )
  disp([inputname(1),' is a GP ' str_type ' problem with status: ' ...
        obj.status '.' char(10) ...
        'Try reformulating your problem.'])

elseif( strcmp(obj.status,'Infeasible') )
  disp([inputname(1),' is a GP ' str_type ' problem with status: ' ...
        obj.status '.' char(10) ...
        'Try reformulating your problem.'])
else
  error('Unknown status flag. Please report this bug.');
end

disp(' ');
