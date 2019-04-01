clc;
clear;
close all;

% Create EPANET object using the INP file
inpname='tutorial4.inp';
% Net1 Net2 Net3 BWSN_Network_1 example tutorial2
d=epanet(inpname);
d.plot('nodes','yes','links','yes','highlightnode',{'1','8'},'highlightlink',{'7'},'fontsize',8);
d.getNodeNameID % the Name of each node   head of each node
d.getLinkNameID % the Name of each pipe   flow of each pipe
d.getNodesConnectingLinksID %
d.getConnectivityMatrix
%% Simulate all

% Another way to Simulate all
d.openHydraulicAnalysis;
d.initializeHydraulicAnalysis;
tstep=1; Velocity=[];Pressure=[];T=[]; Demand=[]; Head=[];Flows=[];TankVolume=[]; HeadLoss = [];
d.getTimeHydraulicStep
%d.setTimeHydraulicStep(1800);
%d.getTimeHydraulicStep
% index constant
TankIndex = Constants4WDN.TankIndex;
PumpIndex = Constants4WDN.PumpIndex;
SpeedIndexInXX0 = Constants4WDN.SpeedIndexInXX0;
%
Head_Reservior = Constants4WDN.Head_Reservior;
Reservior_index = Constants4WDN.Reservior_index;
Hp = Constants4WDN.Hp;
ReferenceHead = Constants4WDN.ReferenceHead;

while (tstep>0)
    t=d.runHydraulicAnalysis;   %current simulation clock time in seconds.
    Velocity=[Velocity; d.getLinkVelocity];
    Pressure=[Pressure; d.getNodePressure];
    Demand=[Demand; d.getNodeActualDemand];
    TankVolume=[TankVolume; d.getNodeTankVolume];
    HeadLoss=[HeadLoss; d.getLinkHeadloss];
    Head=[Head; d.getNodeHydaulicHead];
    Flows=[Flows; d.getLinkFlows];
    T=[T; t];
    tstep=d.nextHydraulicAnalysisStep;
end
d.closeHydraulicAnalysis
%% Get Solution from EPANET
[m,n] = size(T);
XX = [];
for i = 1:m
    XX = [XX; Head(i,7) Head(i,1:6) Head(i,8)  Flows(i,1:9) 1];
end
XX = XX';
d.getNodeNameID;
Demand = Demand';
Demand = [Demand(7,:);Demand(1:6,:); Demand(8,:)];
Solution = [];
Demand_known = [];
for i = 1:12 % demand changes 5 times during simulation
    Solution = [Solution XX(:,6*(i-1)+1)];
    Demand_known = [Demand_known Demand(:,6*(i-1)+1)];
end
Demand_known(1,:) = 0;
Demand_known = Demand_known(1:end-1,:);
[m,n] = size(Demand_known);
Error_All = cell(n,1);
Relative_Error_All = [];
Final_Error_All = [];
XSolution = [];
for i = 1:n
    %% initial conditions
    X0 = [  700.0;
        0;
        0;
        0;
        0;
        0;
        0;
        Solution(8,i);
        600;
        0;
        0;
        0;
        0;
        0;
        0;
        0;
        0;
        1;
        %         100000;
        ];
    
    %X0 = Solution(:,2)
    
    vn = 18;
    % %gpvar H1 H2 H3 H4 H5 H6 H7 H8 Q1 Q2 Q3 Q4 Q5 Q6 Q7 Q8 Q9 s
    gpvar W(vn)
    gpvar Aux_Var(2) % P = Aux_Var(1); Z=Aux_Var(2)
    X = [];
    Aux = [];
    base = 1.0001;
    X = [X;X0];
    Error = [];
    Iteration_Error = 1;
    C_estimate = [];
    
    while(Iteration_Error >= 0.1)
        [Xsolution,Aux_solution,c_estimate_value] = formgp(W,Aux_Var,d,X0,vn,base,Demand_known(:,i)');
        C_estimate = [C_estimate c_estimate_value];
        X = [X Xsolution];
        Aux = [Aux Aux_solution];
        X0 = Xsolution;
        Iteration_Error = norm(X(:,end)-X(:,end-1));
        Error = [Error Iteration_Error];
    end
    
    Error_All{i} = Error;
    
    h = figure;
    title(strcat('Times:',string(i),'Error'));
    plot(Error);
    saveas(h,sprintf('Error %d.png',(i)))
    close(h)
    
    h = figure;
    title(strcat('Times:',string(i),'C_{estimate}'))
    plot(C_estimate')
    saveas(h,sprintf('C_estimate %d.png',(i)))
    close(h)
    XSolution = [XSolution X(:,end)];
    Final_Error = norm(X(:,end)-Solution(i));
    Final_Error_All = [Final_Error_All Final_Error];
    relative_error = Iteration_Error/norm(Solution(i));
    Relative_Error_All = [Relative_Error_All relative_error];
end
Final_Error_All
Relative_Error_All