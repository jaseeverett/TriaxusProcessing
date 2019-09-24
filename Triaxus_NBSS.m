clear
close all

Lim = [10^-3 10^2 10^-2 10^5];

%% Leg 15 vs 17
figure; ax1 = axes;


load in2015_v03_out/in2015_v03_Triaxus_Deploy5Leg1.mat
[h1, h2, h3] = OPC_NBSS_Plot(LOPC,Lim,ax1);
title('Leg 15')
export_fig in2015_v03_out/NBSS_Deploy5Leg1 -pdf

% Now do the summary figure
figure(100); ax = axes;
[h1, h2, h3] = OPC_NBSS_Plot(LOPC,Lim,ax,0);
set(h1,'color','r'); set(h2,'color','r'); set(h3,'color','r');
hold on

load in2015_v03_out/in2015_v03_Triaxus_Deploy5Leg3.mat

[h1(2), h2(2), h3(2)] = OPC_NBSS_Plot(LOPC,Lim,ax,0);
set(h1(2),'color','b'); set(h2(2),'color','b'); set(h3(2),'color','b');
legend(h1,'Leg 15','Leg 17')
export_fig in2015_v03_out/NBSS_Deploy5Leg1+3 -pdf

figure; ax2 = axes;
[h1, h2, h3] = OPC_NBSS_Plot(LOPC,Lim,ax2);
title('Leg 17')
export_fig in2015_v03_out/NBSS_Deploy5Leg3 -pdf







%% Leg 3 vs Leg 4
figure; ax1 = axes;


load in2015_v03_out/in2015_v03_Triaxus_Deploy1Leg3.mat
[h1, h2, h3] = OPC_NBSS_Plot(LOPC,Lim,ax1);
title('Leg 3')
export_fig in2015_v03_out/NBSS_Deploy1Leg3 -pdf

% Now do the summary figure
figure(100); ax = axes;
[h1, h2, h3] = OPC_NBSS_Plot(LOPC,Lim,ax,0);
set(h1,'color','r'); set(h2,'color','r'); set(h3,'color','r');
hold on

load in2015_v03_out/in2015_v03_Triaxus_Deploy1Leg4.mat

[h1(2), h2(2), h3(2)] = OPC_NBSS_Plot(LOPC,Lim,ax,0);
set(h1(2),'color','b'); set(h2(2),'color','b'); set(h3(2),'color','b');
legend(h1,'Leg 3','Leg 4')
export_fig in2015_v03_out/NBSS_Deploy1Leg3+4 -pdf

figure; ax2 = axes;
[h1, h2, h3] = OPC_NBSS_Plot(LOPC,Lim,ax2);
title('Leg 4')
export_fig in2015_v03_out/NBSS_Deploy1Leg4 -pdf



