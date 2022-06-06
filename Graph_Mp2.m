clc; 
%close all; 
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
spec.Cm = spec.Cl/4;

%% Intrinsic gain versus VGS for different L
VGS = (-spec.VDD:0.025:0).'; % [V], gate source voltage
L   = [60 100 150 200 500 1000]*1e-9; % [m], gate length
gm  = NaN(length(L),length(VGS));
gds = NaN(length(L),length(VGS));
gmIDS = NaN(length(L),length(VGS));
Av    = NaN(length(L),length(VGS));
Av_db = NaN(length(L),length(VGS));
VOV   = NaN(length(L),length(VGS));
w     = NaN(length(L),length(VGS));

Mp2.vds = -0.55;
Mp2.vsb = 0;

for kk = 1:length(L)
    Mp2.lg = L(kk);
    Mp2.w = 10*Mp2.lg;
    for i=1:length(VGS)
        Mp2.vgs = VGS(i);
        Mp2.vth = tableValueWref('vth', PRVT, Mp2.lg, Mp2.vgs, Mp2.vds, Mp2.vsb);
        Mp2.vov = - Mp2.vth + Mp2.vgs;
        Mp2 = mosNfingers(Mp2);
        Mp2 = mosOpValues(Mp2);
        
        VOV(kk,i) = Mp2.vov;
        gm(kk,i) = Mp2.gm;
        w(kk,i) = Mp2.w;
        gds(kk,i) = Mp2.gds;
        gmIDS(kk,i) = Mp2.gm/Mp2.ids;
        Av(kk,i) = Mp2.gm / Mp2.gds;
        Av_db(kk,i) = 20*log10(Mp2.gm / Mp2.gds);
                     
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


% %% Intrinsic gain versus VDS for different VGS with fixed L
% VDS = (-spec.VDD:0.025:0).'; % [V], gate source voltage
% VGS   = (-spec.VDD:0.2:0).'; % [m], gate length
% gm  = NaN(length(VGS),length(VDS));
% gds = NaN(length(VGS),length(VDS));
% gmIDS = NaN(length(VGS),length(VDS));
% Av    = NaN(length(VGS),length(VDS));
% Av_db = NaN(length(VGS),length(VDS));
% VOV   = NaN(length(VGS),length(VDS));
% w     = NaN(length(VGS),length(VDS));
% 
% Mp2.lg = 65*1e-9;
% Mp2.vsb = 0;
% 
% for kk = 1:length(VGS)
%     Mp2.vgs = VGS(kk);
%     for i=1:length(VDS)
%         Mp2.vds = VDS(i);
%         Mp2.vth = tableValueWref('vth', PRVT, Mp2.lg, Mp2.vgs, Mp2.vds, Mp2.vsb);
%         Mp2.vov = - Mp2.vth + Mp2.vgs;
%         Mp2.gm = 2*pi*spec.fGBW*spec.Cm;
%         Mp2.w = mosWidth('gm', Mp2.gm, Mp2);
%         Mp2 = mosNfingers(Mp2);
%         Mp2 = mosOpValues(Mp2);
%         
%         VOV(kk,i) = Mp2.vov;
%         gm(kk,i) = Mp2.gm;
%         w(kk,i) = Mp2.w;
%         gds(kk,i) = Mp2.gds;
%         gmIDS(kk,i) = Mp2.gm/Mp2.ids;
%         Av(kk,i) = Mp2.gm / Mp2.gds;
%         Av_db(kk,i) = 20*log10(Mp2.gm / Mp2.gds);
%                      
%     end
% end
% 
% %% Plot
% 
% close all;
% figure();
% subplot(221); plot(VDS,gm,'linewidth',2);
% xlabel('VDS (V)');
% ylabel('gm (mag)');
% grid on;
% title('gm vs. VDS for different channel lenght (W/L=10, VDS = 0.55V)');
% legend('60n','80n','100n','200n','500n','1000n');
% subplot(222); plot(VDS,gds,'linewidth',2);
% xlabel('VDS (V)');
% ylabel('gds (mag)');
% grid on;
% title('gds vs. VDS for different channel lenght (W/L=10, VDS = 0.55V)');
% legend('60n','80n','100n','200n','500n','1000n');
% subplot(223); plot(VDS,Av,'linewidth',2);
% xlabel('VDS (V)');
% ylabel('gm/gds (mag)');
% grid on;
% title('Intrinsic gain (gm/gds) vs. VDS for different channel lenght (W/L=10, VDS = 0.55V)');
% legend('60n','80n','100n','200n','500n','1000n');
% subplot(224); plot(VDS,gmIDS,'linewidth',2);
% xlabel('VDS (V)');
% ylabel('gm/IDS (mag)');
% grid on;
% title('Gain efficiency (gm/Ids) vs. VDS for different channel lenght (W/L=10, VDS = 0.55V)');
% legend('60n','80n','100n','200n','500n','1000n');
% 
% 
% 

