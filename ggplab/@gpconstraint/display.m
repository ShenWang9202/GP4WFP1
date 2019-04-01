function display(obj)
% GPCONSTRAINT display method
%

if (length(obj) > 1)
  disp(' ');
  disp([inputname(1),' is a set of ' ...
        num2str(length(obj)), ' constraints (index to get individual constraints).'])
  disp(' ');
else
  disp(' ');
  disp([inputname(1) ' is a constraint ' symbolic(obj)])
  disp(' ');
end
