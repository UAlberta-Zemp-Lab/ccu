 clc
 clear all;
 close all;

% bits = hadamard(256); 
% bits=randi([-1, 2], [1,256]);
bits(1:64,1:256)=2;
bits(1:64,1:64)=hadamard(64);
%%
input.COM='COM7';
input.VNN=-250;               % VNN to set
input.VPP=250;                 % VPP to set
input.VNNc=200;               % VNN current Limit
input.VPPc=200;               % VPP current limit
input.TrOd=100;                 % Delay to send out trigger 0 to 65ms
input.ImgMode='US';           % imaging mode US or PA
input.Qswitch=390;            % laser Qswitch 250 to 550
input.TimerInterval=0.5;     % Refreshing intervals in seconds max 1 second
input.VoltageTolerance=5;     % Tolerance for voltage
input.BiasPatern=bits;        % biasing patersn N*M (N=seq. (max 512), M=256)  -1=VNN, 0=GND, 1=VPP, 2=High impedance
%%
CCU(input);                   % program and monitor the CCU
%%
