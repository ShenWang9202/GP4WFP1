clc;
clear
%gpvar h0 h1 h2 h3 h4 h5 h6 h7 q0 q1 q2 q3 q4 q5 q6 q7 q8 S Z           % create three scalar GP variables
vn = 20;
% Create EPANET object using the INP file
inpname='tutorial4.inp'; 
% Net1 Net2 Net3 BWSN_Network_1 example tutorial2
d=epanet(inpname);
% h1 h2 h3 h4 h5 h6 h7 h8 q1 q2 q3 q4 q5 q6 q7 q8 q9 s p z
d2 =0;
d3 = 75.0;
d4 = 75.0;
d5 = 100.0;
d6 = 75.0;
d7 = 0.0;
href = 838.8;

X0 = [  700.0000;
        847.0541;
        844.6656;
        839.6855;
        836.8295;
        839.4702;
        841.1907;
        834.0000;
        617.4225;
        159.9140;
        55.5773;
        382.5086;
        29.3366;
        90.0860;
        44.4227;
        292.4225;
        617.4225;
        1.0000;
        0.90
        1.0;];

%gpvar h1 h2 h3 h4 h5 h6 h7 h8 q1 q2 q3 q4 q5 q6 q7 q8 q9 s z
gpvar W(vn)

f_mono = mono_approxi(d,X0,W);
% form an array of constraints
constrs = f_mono(1:15,:) == ones(15,1);
%constrs = [constrs; W(19)*838 == W(8);f_mono(16,:)<=1; W(1) == 700; W(8) == 838.8 ; W(18) == 1;W(1:18,:)<=1000*ones(18,1)];
constrs = [constrs; W(19)*href == W(8);W(1) == 700;f_mono(16,:)<=1; W(1:18,:).^(-1) <= (0.9*X0(1:18,:)).^(-1); W(1:18) <= 1.1*X0(1:18,:);W(19)==1];
% objective
obj = W(20);
% solve generalized GP and assign solution to GP variables
[obj_value, solution, status] = gpsolve(obj,constrs)
solution_array = cell2mat(solution(2))
solution = full(solution_array)


solution = [  700.0000;
        851.904;
        849.510;
        844.524;
        841.667;
        844.307;
        846.024;
        838.8;
        618.161;
        160.015;
        55.584;
        383.145;
        29.432;
        89.985;
        44.416;
        293.161;
        613.775;
        1.011;
        100000;];
verifyResult = verify(d,solution);
[m,n] = size(verifyResult);
for i = 1: m
    verifyResult(i)
end


for i = 1:16
    f_mono(i)
end