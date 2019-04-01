clc;
clear;
close all;
%% Hydraulic Analysis
% Create EPANET object using the INP file
inpname='tutorial4.inp';
% inpname='ctown.inp';
% Net1 Net2 Net3 BWSN_Network_1 example tutorial2
d=epanet(inpname);
%d.plot('nodes','yes','links','yes','highlightnode',{'1','8'},'highlightlink',{'7'},'fontsize',8);

Velocity=[];
Pressure=[];
T=[];
Demand=[];
Head=[];
Flows=[];
TankVolume=[];
HeadLoss = [];
LinkSettings = [];

% Another way to Simulate all
d.openHydraulicAnalysis;
d.initializeHydraulicAnalysis;
tstep=1;
d.getTimeHydraulicStep
%d.setTimeHydraulicStep(1800);
%d.getTimeHydraulicStep
% index constant
% TankIndex = Constants4WDN.TankIndex;
% PumpIndex = Constants4WDN.PumpIndex;
% SpeedIndexInXX0 = Constants4WDN.SpeedIndexInXX0;
% %
% Head_Reservior = Constants4WDN.Head_Reservior;
% Reservior_index = Constants4WDN.Reservior_index;
% Hp = Constants4WDN.Hp;
% ReferenceHead = Constants4WDN.ReferenceHead;

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
    LinkSettings = [LinkSettings;d.getLinkSettings];
    tstep=d.nextHydraulicAnalysisStep;
end
d.closeHydraulicAnalysis

%% Get Solution from EPANET
[m,n] = size(T);

PipeIndex = d.getLinkPipeIndex;
PumpIndex = d.getLinkPumpIndex;
ValveIndex = d.getLinkValveIndex;
NodeJunctionIndex = d.getNodeJunctionIndex;
ReservoirIndex = d.getNodeReservoirIndex;
NodeTankIndex = d.getNodeTankIndex;

% Settings for all types of links
PipeRoughness = LinkSettings(:,PipeIndex);
PumpSpeed = LinkSettings(:,PumpIndex);
ValveSettings = LinkSettings(:,ValveIndex);

% Generate Solution for later validation.
Solution = [];
for i = 1:m
    Solution = [Solution; [Head(i,:) Flows(i,:) PumpSpeed(i,:)]];
end
Solution = Solution';

%% Generate Mass and Energy Matrice
NodeNameID = d.getNodeNameID; % the Name of each node   head of each node
LinkNameID = d.getLinkNameID; % the Name of each pipe   flow of each pipe

NodesConnectingLinksID = d.getNodesConnectingLinksID; %
[m,n] = size(NodesConnectingLinksID);
NodesConnectingLinksIndex = zeros(m,n);

for i = 1:m
    for j = 1:n
        NodesConnectingLinksIndex(i,j) = find(strcmp(NodeNameID,NodesConnectingLinksID{i,j}));
    end
end
NodesConnectingLinksIndex
% Generate MassEnergyMatrix
[m1,n1] = size(NodeNameID);
[m2,n2] = size(LinkNameID);
MassEnergyMatrix = zeros(n2,n1);

for i = 1:m
    MassEnergyMatrix(i,NodesConnectingLinksIndex(i,1)) = -1;
    MassEnergyMatrix(i,NodesConnectingLinksIndex(i,2))= 1;
end
% Display
MassEnergyMatrix


%% Generate Mass Matrix

MassMatrix = MassEnergyMatrix(:,NodeJunctionIndex)';
size(MassMatrix)

%% Generate Energy Matrix

EnergyPipeMatrix = MassEnergyMatrix(PipeIndex,:);
EnergyPumpMatrix = MassEnergyMatrix(PumpIndex,:);
EnergyValveMatrix = MassEnergyMatrix(ValveIndex,:);

%% Generate Demand for NodeJuncion;

Demand_known = Demand(:,NodeJunctionIndex);
size(Demand_known)