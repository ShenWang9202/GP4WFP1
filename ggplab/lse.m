function [f,expyy] = lse(E,y)
% 
% LSE finds log-sum-exp values.
%
% It calculates log(E*exp(y)), with special handling of extreme y values.
% 

% ymax is a vector of maximum exponent values of each posynomial.
%
% ex: log(exp(y1)+exp(y2)+exp(y3)), log(exp(y4)+exp(y5))
%     ymax = [max(y1,y2,y3); max(y4,y5)]
%
% note: min(y) are substracted and added to handle the case when all the
%       exponents of a posynomial are negative.
%       i.e., 0 0 0 -3 -4 -> max value should be -3

ymax  = full(max(E*sparse(1:length(y),1:length(y),y-min(y)),[],2))+min(y);
expyy = exp(y-E'*ymax);
f     = log(E*expyy)+ymax;
