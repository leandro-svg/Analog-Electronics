clc; 
close all; 
clear;

addpath(genpath('circuitDesign'));
addpath(genpath('functions'));
addpath(genpath('models'));

load('UMC65_RVT.mat');

%% Initializations
designkitName		= 'umc65';
circuitTitle		= 'Analog Design - Project';
elementList.nmos	= {'Mn3','Mn4','Mn6'};
elementList.pmos	= {'Mp1','Mp2','Mp5','Mp7','Mp8'};

spec.VDD        = 1.1;
choice.maxFingerWidth = 10e-6;
choice.minFingerWidth = 200e-9;

simulator			= 'spectre';
simulFile			= 0;
simulSkelFile		= 0;
analog			= cirInit('analog',circuitTitle,'top',elementList,spec,choice,...
						designkitName,NRVT,PRVT,simulator,simulFile,simulSkelFile);
analog			= cirCheckInChoice(analog, choice);

%% Project: circuit
disp('                                                       ');
disp('  VDD          VDD                    VDD              ');
disp('   |             |                      |              ');
disp('  Mp8-+---------Mp7---------------------Mp5            ');
disp('   |--+          |                      |              ');
disp('   |          +--+--+         node 3->  +-----+---OUT  ');
disp('   |          |     |                   |     |        ');
disp('   |    IN1--Mp1   Mp2--IN2             |     |        ');
disp('   |          |     |                   |     |        ');
disp('   | node 1-> |     | <-node 2          |     Cl       ');
disp('   |          |--+  +------+-Cm---Rm----+     |        ');
disp(' Ibias        |  |  |      |    ↑       |     |        ');
disp('   |         Mn3-+-Mn4     |  node 4    |     |        ');
disp('   |          |     |      +-----------Mn6    |        ');
disp('   |          |     |                   |     |        ');
disp('  GND        GND   GND                 GND   GND       ');



%% EX1: Specs
spec.fGBW       = 100e6;    % [Hz] GBW frequency
spec.Cl         = 1e-12;   % [F] load capacitance

%% Intrinsic gain versus VGS for different L
VGS = (0:0.025:spec.VDD).'; % [V], gate source voltage
L   = [60 80 100 200 500 1000]*1e-9; % [m], gate length
gm  = NaN(length(L),length(VGS));
gds = NaN(length(L),length(VGS));
gmIDS = NaN(length(L),length(VGS));
Av    = NaN(length(L),length(VGS));
Av_db = NaN(length(L),length(VGS));
VOV   = NaN(length(L),length(VGS));
w     = NaN(length(L),length(VGS));


Mn4.vsb = 0;
Mp2ids = 20.6e-6;
for kk = 1:length(L)
    Mn4.lg = L(kk);
    Mn4.w = 10*Mn4.lg
    for i=1:length(VGS)
        Mn4.vgs = VGS(i);
        Mn4.vds = VGS(i);
        Mn4.vth = tableValueWref('vth', NRVT, Mn4.lg, Mn4.vgs, Mn4.vds, Mn4.vsb);
        Mn4.vov = - Mn4.vth + Mn4.vgs;
        %Mn4.w = mosWidth('ids', Mn4.ids, Mn4);
        Mn4 = mosNfingers(Mn4);
        Mn4 = mosOpValues(Mn4);
        
        VOV(kk,i) = Mn4.vov;
        gm(kk,i) = Mn4.gm;
        w(kk,i) = Mn4.w;
        gds(kk,i) = Mn4.gds;
        gmIDS(kk,i) = Mn4.gm/Mn4.ids;
        Av(kk,i) = Mn4.gm / Mn4.gds;
        Av_db(kk,i) = 20*log10(Mn4.gm / Mn4.gds);
                     
    end
end

%% Plot

close all;
figure();
subplot(221); plot(VGS,gm,'linewidth',2);
xlabel('VGS (V)');
ylabel('gm (mag)');
grid on;
title('gm vs. VGS for different channel lenght (W/L=10, VDS = 0.55V)');
legend('60n','80n','100n','200n','500n','1000n');
subplot(222); plot(VGS,gds,'linewidth',2);
xlabel('VGS (V)');
ylabel('gds (mag)');
grid on;
title('gds vs. VGS for different channel lenght (W/L=10, VDS = 0.55V)');
legend('60n','80n','100n','200n','500n','1000n');
subplot(223); plot(VGS,Av,'linewidth',2);
xlabel('VGS (V)');
ylabel('gm/gds (mag)');
grid on;
title('Intrinsic gain (gm/gds) vs. VGS for different channel lenght (W/L=10, VDS = 0.55V)');
legend('60n','80n','100n','200n','500n','1000n');
subplot(224); plot(VGS,gmIDS,'linewidth',2);
xlabel('VGS (V)');
ylabel('gm/IDS (mag)');
grid on;
title('Gain efficiency (gm/Ids) vs. VGS for different channel lenght (W/L=10, VDS = 0.55V)');
legend('60n','80n','100n','200n','500n','1000n');

figure();
subplot(221); plot(VOV.',gm.','linewidth',2);
xlabel('VOV (V)');
ylabel('gm (mag)');
grid on;
title('gm vs. VOV for different channel lenght (W/L=10, VDS = 0.55V)');
legend('60n','80n','100n','200n','500n','1000n');
subplot(222); plot(VOV.',gds.','linewidth',2);
xlabel('VOV (V)');
ylabel('gds (mag)');
grid on;
title('gds vs. VOV for different channel lenght (W/L=10, VDS = 0.55V)');
legend('60n','80n','100n','200n','500n','1000n');
subplot(223); plot(VOV.',Av.','linewidth',2);
xlabel('VOV (V)');
ylabel('gm/gds (mag)');
grid on;
title('Intrinsic gain (gm/gds) vs. VOV for different channel lenght (W/L=10, VDS = 0.55V)');
legend('60n','80n','100n','200n','500n','1000n');
subplot(224); plot(VOV.',gmIDS.','linewidth',2);
xlabel('VOV (V)');
ylabel('gm/IDS (mag)');
grid on;
title('Gain efficiency (gm/Ids) vs. VGS for different channel lenght (W/L=10, VDS = 0.55V)');
legend('60n','80n','100n','200n','500n','1000n');

figure();
subplot(211); semilogy(VGS,w,'linewidth',2);
xlabel('VGS (V)');
ylabel('w (m)');
grid on;
title('w vs. VGS for different channel lenght (W/L=10, VDS = 0.55V)');
legend('60n','80n','100n','200n','500n','1000n');

subplot(212); semilogy(VOV.',w.','linewidth',2);
xlabel('VOV (V)');
ylabel('w (m)');
grid on;
title('w vs. VOV for different channel lenght (W/L=10, VDS = 0.55V)');
legend('60n','80n','100n','200n','500n','1000n');



