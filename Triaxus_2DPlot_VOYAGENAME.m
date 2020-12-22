% function Triaxus_2DPlot_IN2017v04

% This code, plots up the triaxus data in a 2D contour plot of
% location x depth contoured by temperature or one of the LOPC variables

% The figures are saved by default with the built-in MATLAB print command,
% but they look much better if you install the 'export_fig' package from
% the Mathworks File Exchange
% (https://au.mathworks.com/matlabcentral/fileexchange/23629-export_fig)
% 
% Written by Jason Everett (UNSW, 2016)
% Last updated 24th September 2019

%%
clear
close all

% Directory where .mat files are saved
direc = 'TestData/output';
files = {'in2017_v04_Triaxus_Deploy3_20s.mat'};

ef = 0; % Switch to turn on export_fig

%% Adjust these max and min values as appropriate to get the figures looking good
for i = 1
    
    % You can set up different limits for each deployment if needed.
    
    if i == 1 % or use i < 5 to set these limits for a whole range of deployments
        maxD = 200; % Maximum depth for plotting
        minD = 0;
        
        rho.min = 1024; rho.max = 1027; rho.conts = rho.min:0.5:rho.max; % Density
        temp.min = 15; temp.max = 23; temp.conts = temp.min:0.05:temp.max; % Temperature
        chl.min = 0; chl.max = 0.6; chl.conts = chl.min:0.05:chl.max; % Chlorophyll
        counts.min = 2.5; counts.max = 4; counts.conts = counts.min:0.1:counts.max; % Abundance
        biomass.min = 1.5; biomass.max = 3; biomass.conts = biomass.min:0.1:biomass.max; % Biomass
        slope.min = -1.1; slope.max = -0.7; slope.conts = slope.min:0.01:slope.max; % NBSS Slope
        geomn.min = 320; geomn.max = 360; geomn.conts = geomn.min:2:geomn.max; % Geometric Mean
        
%     elseif i == 5
%         maxD = 150; % Maximum depth for plotting
%         
%         rho.min = 1024; rho.max = 1027; rho.conts = rho.min:0.5:rho.max;
%         temp.min = 15; temp.max = 21; temp.conts = temp.min:0.05:temp.max;
%         chl.min = 0; chl.max = 0.8; chl.conts = chl.min:0.05:chl.max;
%         counts.min = 3.5; counts.max = 5; counts.conts = counts.min:0.1:counts.max;
%         biomass.min = 0; biomass.max = 2000; biomass.conts = biomass.min:5:biomass.max;
%         slope.min = -1; slope.max = -0.6; slope.conts = slope.min:0.02:slope.max;
%         geomn.min = 230; geomn.max = 290; geomn.conts = geomn.min:2:geomn.max;
        
        
    end
   
    close
    clear s
    eval(['load ',direc,filesep,files{i},' s'])

    % X,Y location of the title and the fontsize.
    txt_x = 0.02;
    txt_y = 0.95;
    txt = 10;
    xlim_start = 0;
    xlim_end = ceil(s.grnddist(end));
    
    tit = files{i};
    tit = tit(1:end-4);
    
    figure
    h = gcf;
    set(h,'PaperOrientation','landscape');
    set(h,'PaperUnits','normalized');
    set(h,'PaperPosition', [0 0 1 1]);
    
        Triaxus_2D_plot
    
    set(gcf,'color','w')
    
    if ef == 1
        eval(['export_fig ',direc,filesep,file{i}(1:end-4),' -pdf -r300 -tif'])
    else
        eval(['print -dpdf ',direc,filesep,files{i}(1:end-4)])
    end
end
