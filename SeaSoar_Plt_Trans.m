% This script plots the entire seasoar transects with all variables on the
% one figure

masterres = 100; % 12
cl = [0.3 0.3 0.3];
%% Define the variables required for the plotting
% The track of the SeaSoar through the watercolumn
eval(['Depth = s.Depth(fiT',num2str(i),');']);
% Distance along the ground
eval(['grnddist = s.grnddist(fiT',num2str(i),').*1e3;']); % dist needs to be m - same units as depth
eval(['Variable = vari(fiT',num2str(i),',ii);'])

%% Plot the data
% Send the data to find_downcast which interps vertical casts between the
% two SeaSoar casts
depth_res = 1; % depth resolution of the new grid (m)
minext = 0.1;
interpVert = 1;

[XXI,YYI,ZZI] = find_downcast(grnddist,Depth,Variable, depth_res, minext, interpVert);

row = ii; col = 1;
figprep_SS

[C h] = contourf(XXI,YYI,ZZI,masterres,'edgecolor','none');

hold on

if ii == 1 | samevar == 1
    [XI,YI,ZI] = find_downcast(grnddist,Depth,s.temperature, depth_res, minext, interpVert);
    cont_res = 13:0.25:24;
    lcont_res = 13:24;
    [c1,h1] = contour(XI,YI,ZI,lcont_res,'color','k');
%     set(h1(:),'Linewidth',1);
    set(h1(:),'Linewidth',0.6);
    clabel(c1,h1,'labelspacing',200,'Fontweight','b');
    for ci=1:length(cont_res)
        if isempty(find(cont_res(ci) == lcont_res))
            [c1,h1] = contour(XI,YI,ZI,[cont_res(ci) cont_res(ci)],'color','k');
%             set(h1(:),'Linewidth',0.35);
            set(h1(:),'Linewidth',0.2);
        end
    end
    
    
else
    [XI,YI,ZI] = find_downcast(grnddist,Depth,s.sigmaT, depth_res, minext, interpVert);
    cont_res = 1024:.1:1028;
    lcont_res = 1024:.5:1028;
    [c1,h1] = contour(XI,YI,ZI,lcont_res,'color','k');
%     set(h1(:),'Linewidth',1);
    set(h1(:),'Linewidth',0.6);
    clabel(c1,h1,'labelspacing',200,'Fontweight','b','color','k');
    for ci=1:length(cont_res)
        if isempty(find(cont_res(ci) == lcont_res))
            [c1,h1] = contour(XI,YI,ZI,[cont_res(ci) cont_res(ci)],'color','k');
%             set(h1(:),'Linewidth',0.35);
            set(h1(:),'Linewidth',0.2);
        end
    end
end

% shading flat

% Set caxis - commented out June 7th to debug
% disp(['Caxis manual commented out'])
set(gca,'clim',[nanmin(Variable(isinf(Variable)==0)) nanmax(Variable(isinf(Variable)==0))])
caxis manual

hold on

% Cruise Track
%Depth(1:50:end) = NaN;
h2 = scatter(grnddist(1:1:end), Depth(1:1:end),'.','MarkerEdgeColor',cl,'SizeData',50);
h3 = plot(grnddist, Depth,'-','color',[0.5 0.5 0.5],'linewidth',0.8);

% Add waterdepth
% fill([min(grnddist); grnddist; max(grnddist)],[max(waterDepth); waterDepth; max(waterDepth)],[0 0 0]);
set(gca,'YDir','reverse')

if flip == 1
    set(gca,'XDir','reverse')
end

box on

% title(vari_name(ii),'fontsize',9)
% 
% if a == 3
%     text(max(grnddist)-1e3,115,vari_name(ii),'fontsize',9,'backgroundcolor','w')
% elseif a == 7
%     text(159000,115,vari_name(ii),'fontsize',9,'backgroundcolor','w')
% end


% Colorbar
cb = colorbar;
gca_pos = get(gca,'Position');

pos = get(cb,'Position');
set(cb,'Position',[pos(1)+0.075 pos(2)+0.025 pos(3) pos(4)-0.05]);
eval(['cb',num2str(ii),' = cb;'])


% Position: [0.8424 0.7786 0.0446 0.1738]
set(gca,'Position',gca_pos)


set(gca,'fontsize',9);


ylabel('Depth (m)','fontsize',9)

%     if a == 3
%         set(gca,'XTick',[0.5 1.5 2.5 3.5 4.5 5.5 6.5].*1e4);
%     end

if ii ~= rows
    set(gca,'XTickLabel','')

elseif ii == rows
    xlabel('Distance along transect (km)')
end

clear X* Y* Z* Depth grnddist Variable offset
