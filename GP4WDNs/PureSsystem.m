clc;
clear;
close all;

% Create EPANET object using the INP file
inpname='tutorial4price4.inp'; 
% Net1 Net2 Net3 BWSN_Network_1 example tutorial2
d=epanet(inpname);
%d.plot('nodes','yes','links','yes','highlightnode',{'1','8'},'highlightlink',{'7'},'fontsize',8);

%% Simulate all

% Another way to Simulate all
d.openHydraulicAnalysis;
d.initializeHydraulicAnalysis;
tstep=1;Velocity=[];Pressure=[];T=[]; Demand=[]; Head=[];Flows=[];TankVolume=[]; HeadLoss = [];Efficiency=[];Energy=[];Settings=[];Status=[];
TimeString={};controlstringSet = [];ctrlstringGet={};
control_string1 = 'LINK 9';
control_string3 = ' AT TIME';
%d.getTimeHydraulicStep
%d.setTimeHydraulicStep(1800);
%d.getTimeHydraulicStep
% index constant
%d.getBinComputedNodeDemand
TimeStep = d.getTimeHydraulicStep;
speedbase = 0.8;
while (tstep>0)
    t=d.runHydraulicAnalysis;   %current simulation clock time in seconds.    
    Velocity=[Velocity; d.getLinkVelocity];
    Pressure=[Pressure; d.getNodePressure];
    Demand=[Demand; d.getNodeActualDemand];
    TankVolume=[TankVolume; d.getNodeTankVolume];
    HeadLoss=[HeadLoss; d.getLinkHeadloss];
    Head=[Head; d.getNodeHydaulicHead];
    Flows=[Flows; d.getLinkFlows];
    Efficiency = [Efficiency; d.getLinkEfficiency];
    Energy = [Energy;d.getLinkEnergy];
    Status = [Status;d.getLinkStatus];
    Settings = [Settings;d.getLinkSettings];
    timestring = num2str((t+TimeStep));
    TimeString = [TimeString; timestring];
    ctrls = d.getControls;
    ctrlstringGet = [ctrlstringGet;ctrls.Control];
    speed_pump = (t*1.0/double(TimeStep))/100.0 + speedbase;
    control_string2= strcat(32,num2str(speed_pump),32);
    Control = strcat(control_string1,control_string2,control_string3,32,timestring);
    controlstringSet = strvcat(controlstringSet,Control);
    % set pump speed
     d.setControls(1,Control);
%     ctrls.Type
%     ctrls.LinkID
%     ctrls.Setting
%     ctrls.NodeID
%     ctrls.Value
%     ctrls.Control
    T=[T; t];
    tstep=d.nextHydraulicAnalysisStep;
end
d.closeHydraulicAnalysis

%% verify model
% XX = [];
% for i = 1:(Hp+1)
%     XX = [XX Head(i,7) Head(i,1:6) Head(i,8)  Flows(i,1:9) 1];
% end
% 
% XX = XX';
% %test LinEQ4WDN
% k = 1;
% NodeDemand1 = getNodeDemand(k,d,Hp);
% %verify Aeq beq
% [Aeq,beq]=LinEQ4WDN(d,NodeDemand1,18,XX);
% Aeq * XX - beq
% %test nlcon4WDN
% [c,ceq] = nlcon4WDN(XX,d,18);

