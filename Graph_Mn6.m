%clc; 
%close all; 
%clear;

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





%% Intrinsic gain versus VGS for different L
VGS = (0:0.025:spec.VDD).'; % [V], gate source voltage
L   = [65 100 150 200 500 1000]*1e-9; % [m], gate length
gm  = NaN(length(L),length(VGS));
gds = NaN(length(L),length(VGS));
gmIDS = NaN(length(L),length(VGS));
Av    = NaN(length(L),length(VGS));
Av_db = NaN(length(L),length(VGS));
VOV   = NaN(length(L),length(VGS));
w     = NaN(length(L),length(VGS));

Mn6.vds = 0.55;
Mn6.vsb = 0;
for kk = 1:length(L)
    Mn6.lg = L(kk);
    Mn6.w = 10*Mn6.lg;
    for i=1:length(VGS)
        Mn6.vgs = VGS(i);
        Mn6.vth = tableValueWref('vth', NRVT, Mn6.lg, Mn6.vgs, Mn6.vds, Mn6.vsb);
        Mn6.vov = - Mn6.vth + Mn6.vgs;
        %Mn6.w = mosWidth('ids', Mn6.ids, Mn6);
        Mn6 = mosNfingers(Mn6);
        Mn6 = mosOpValues(Mn6);
        
        VOV(kk,i) = Mn6.vov;
        gm(kk,i) = Mn6.gm;
        w(kk,i) = Mn6.w;
        gds(kk,i) = Mn6.gds;
        gmIDS(kk,i) = Mn6.gm/Mn6.ids;
        Av(kk,i) = Mn6.gm / Mn6.gds;
        Av_db(kk,i) = 20*log10(Mn6.gm / Mn6.gds);
                     
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
title('Gain efficiency (gm/Ids) vs. VOV for different channel lenght (W/L=10, VDS = 0.55V)');
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
% VDS =  (0.0:0.025:spec.VDD).'; % [V], gate source voltage
% VGS   =  (0:0.2:spec.VDD).'; % [m], gate length
% gm  = NaN(length(VGS),length(VDS));
% gds = NaN(length(VGS),length(VDS));
% gmIDS = NaN(length(VGS),length(VDS));
% Av    = NaN(length(VGS),length(VDS));
% Av_db = NaN(length(VGS),length(VDS));
% VOV   = NaN(length(VGS),length(VDS));
% w     = NaN(length(VGS),length(VDS));
% 
% Mn6.lg = 65*1e-9;
% Mn6.vsb = 0;
% 
% for kk = 1:length(VGS)
%     Mn6.vgs = VGS(kk);
%     for i=1:length(VDS)
%         Mn6.vds = VDS(i);
%         Mn6.vth = tableValueWref('vth', NRVT, Mn6.lg, Mn6.vgs, Mn6.vds, Mn6.vsb);
%         Mn6.vov = - Mn6.vth + Mn6.vgs;
%         Mn6.gm = 2*pi*spec.fGBW*spec.Cl;
%         Mn6.w = mosWidth('gm', Mn6.gm, Mn6);
%         Mn6 = mosNfingers(Mn6);
%         Mn6 = mosOpValues(Mn6);
%         
%         VOV(kk,i) = Mn6.vov;
%         gm(kk,i) = Mn6.gm;
%         w(kk,i) = Mn6.w;
%         gds(kk,i) = Mn6.gds;
%         gmIDS(kk,i) = Mn6.gm/Mn6.ids;
%         Av(kk,i) = Mn6.gm / Mn6.gds;
%         Av_db(kk,i) = 20*log10(Mn6.gm / Mn6.gds);
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
