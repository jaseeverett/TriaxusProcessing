resx = 100; %200;
resy = 50; %100;

biores = 5;
physres = 3;
masterres = 12;

eval(['grnddist = s.grnddist(fiT',num2str(i),').*1e3;']); % dist needs to be m - same units as depth

% Flip matrix to get them orientated correctly

if flip(i) == 1
    plt_trak = flipud(grnddist);
else
	plt_trak = grnddist;
end

row = i; col = 1;
figprep

% Add SeaSoar Track
eval(['h2 = scatter(plt_trak,s.SSDepth(fiT',num2str(i),'),''k.'',''SizeData'',5);']);


% Add waterdepth
hold on
if flip(i) == 1
    eval(['fill([min(grnddist); grnddist; max(grnddist)],[max(s.waterDepth(fiT',num2str(i),')); flipud(s.waterDepth(fiT',num2str(i),')); max(s.waterDepth(fiT',num2str(i),'))],[0 0 0]);']);
elseif flip(i) == 0
    eval(['fill([min(grnddist); grnddist; max(grnddist)],[max(s.waterDepth(fiT',num2str(i),')); s.waterDepth(fiT',num2str(i),'); max(s.waterDepth(fiT',num2str(i),'))],[0 0 0]);']);
end

box on
set(gca,'YDir','reverse')
ylim([0 max(s.waterDepth(fiT_all))]);

%% Set xlim %%
% All transects should line up
% The length of each transect should be equal

if i == 1
    for b = 1:rows
        eval(['xlim_max(b) = abs(diff(s.grnddist(fiT',num2str(b),'([end 1])))).*1e3;'])
    end
% long_tran = find(max(xlim_max)==xlim_max);
end
    
xlim([grnddist(1) grnddist(1)+max(xlim_max)]);

if i ~= rows
    set(gca,'XTickLabel','')
elseif i == rows
    set(gca,'XTickLabel',num2str((get(gca,'XTick')./1e3)'));
    xlabel('Distance along transect (km)')
end

ylabel('Water Depth (m)')

set(gca,'fontsize',9);
title(['Transect ',num2str(i)])
clear X* Y* Z* grnddist
