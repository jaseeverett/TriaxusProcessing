resx = 100; %200;
resy = 50; %100;

biores = 5;
physres = 20:0.5:30; %3;
masterres = 12;

eval(['grnddist = s.grnddist(fiT',num2str(i),').*1e3;']); % dist needs to be m - same units as depth

% eval(['X = grnddist(1):abs(range(grnddist))/resx:grnddist(end);']);
% X = X';
% eval(['Y = min(s.SSdepth(fiT',num2str(i),')):range(s.SSdepth(fiT',num2str(i),'))/resy:max(s.SSdepth(fiT',num2str(i),'));']);

eval(['[XI,YI,ZI] =    find_downcast(grnddist,s.SSdepth(fiT',num2str(i),'),s.sigma(fiT',num2str(i),'));']);
eval(['[XXI,YYI,ZZI] = find_downcast(grnddist,s.SSdepth(fiT',num2str(i),'),vari((fiT',num2str(i),'),',num2str(ii),'));']);

% warning off MATLAB:griddata:DuplicateDataPoints
% eval(['[XI,YI,ZI] =    griddata(grnddist,s.SSdepth(fiT',num2str(i),'),s.sigma(fiT',num2str(i),'),X,Y);']);
% eval(['[XXI,YYI,ZZI] = griddata(grnddist,s.SSdepth(fiT',num2str(i),'),vari((fiT',num2str(i),'),',num2str(ii),'),X,Y);']);
% warning on MATLAB:griddata:DuplicateDataPoints

% Flip matrix to get them orientated correctly
if flip(i) == 1
    ZI = fliplr(ZI);
    ZZI = fliplr(ZZI);
    plt_trak = flipud(grnddist);
else
    plt_trak = grnddist;
end

row = i; col = 1;
figprep
box on
[c h cf] = contourf(XXI,YYI,ZZI,masterres);
shading flat

eval(['set(gca,','''clim'',','[min(vari(fiT_all,',num2str(ii),')) max(vari(fiT_all,',num2str(ii),'))])'])
caxis manual

if i == rows
    cb = colorbar;
    set(cb,'Position',[0.925 0.07 0.02 0.8],'fontsize',9)
end

hold on
box on
% Add SeaSoar Track
eval(['h2 = scatter(plt_trak,s.SSdepth(fiT',num2str(i),'),''k.'',''SizeData'',5);']);

% Add sigma-t as white contours
[c3 h3] = contour(XI,YI,ZI-1000,physres,'linecolor','w','linewidth',1.5,'LineStyle','-');
clabel(c3,h3,'Color','w','fontsize',7,'FontWeight','bold');

% Add waterdepth
% hold on
% if flip(i) == 1
%     eval(['fill([min(grnddist); grnddist; max(grnddist)],[max(s.waterDepth(fiT',num2str(i),')); flipud(s.waterDepth(fiT',num2str(i),')); max(s.waterDepth(fiT',num2str(i),'))],[0 0 0]);']);
% elseif flip(i) == 0
%     eval(['fill([min(grnddist); grnddist; max(grnddist)],[max(s.waterDepth(fiT',num2str(i),')); s.waterDepth(fiT',num2str(i),'); max(s.waterDepth(fiT',num2str(i),'))],[0 0 0]);']);
% end

for a = 1:length(flip) 
    eval(['max_xlim(a) = max([s.grnddist(fiT',num2str(a),',(end)) - s.grnddist(fiT',num2str(a),'(1))]);']);
end

set(gca,'YDir','reverse')
% ylim([0 max(s.waterDepth(fiT_all))]);

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
    set(gca,'XTickLabel','')
    set(gca,'XTickLabel',num2str((get(gca,'XTick')./1e3)'));
    xlabel('Distance along transect (km)')
end

% if i == round(rows/2)
    ylabel('Depth (m)')
% end

set(gca,'fontsize',9);
title(['Transect ',num2str(i)])
clear X* Y* Z* grnddist

box on