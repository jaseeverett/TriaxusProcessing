
depth_res = 1; % depth resolution of the new grid (m)
minext = 0.1;
interpVert = 1;

rows = 6; cols = 1;

%% 
num = 1; figprep_MNF
[XXI,YYI,ZZI] = find_downcast(s.grnddist,s.pressure,s.temperature, depth_res, minext, interpVert);
XXI = XXI(:,2:end-1); YYI = YYI(:,2:end-1); ZZI = ZZI(:,2:end-1);  % remove first and last cast
xlim_start = XXI(1,1); xlim_end = XXI(1,end);

[C h] = contourf(XXI,YYI,ZZI,temp.conts,'edgecolor','none');
xlim([xlim_start xlim_end])

caxis([temp.min temp.max])
cb1 = colorbar;
colormap(h1,jet)
hold on
p = plot(s.grnddist,s.pressure,'color',[0.5 0.5 0.5],'linewidth',0.1);
contour(XXI,YYI,ZZI,[20 20], 'linecolor', 'w', 'lineWidth', 1);
contour(XXI,YYI,ZZI,[20 20], ':', 'linecolor', 'k', 'lineWidth', 1);

set(gca,'ydir','r','fontsize',txt,'ytick',[50:50:maxD+50])
set(gca,'XTickLabel','')
tx1 = text(txt_x,txt_y,'A) Temperature','horizontalalignment','l','units','normalized','fontsize',txt-3, 'color',fc);
ylabel('Depth (m)')
xlim([xlim_start xlim_end])
ylim([minD maxD])

% title(tit,'Interpreter','none')

%% 
num = 2; figprep_MNF
[XXI,YYI,ZZI] = find_downcast(s.grnddist,s.pressure,s.chl, depth_res, minext, interpVert);
XXI = XXI(:,2:end-1); YYI = YYI(:,2:end-1); ZZI = ZZI(:,2:end-1);  % remove first and last cast
[C h] = contourf(XXI,YYI,ZZI,chl.conts,'edgecolor','none');
caxis([chl.min chl.max])
cb2 = colorbar;
colormap(h2,jet)
hold on
% p = plot(s.grnddist(1:10),s.pressure(1:10),'.k','markersize',1);
set(gca,'ydir','r','fontsize',txt,'ytick',[50:50:maxD+50])
set(gca,'XTickLabel','')
tx2 = text(txt_x,txt_y,'B) Chl. \ita\rm (mg m^{-3})','horizontalalignment','l','units','normalized','fontsize',txt-3, 'color',fc);
ylim([minD maxD])

contour(XXI,YYI,ZZI,[0.1 0.1], 'linecolor', 'w', 'lineWidth', 1);
contour(XXI,YYI,ZZI,[0.1 0.1], ':', 'linecolor', 'k', 'lineWidth', 1);

% [XXI,YYI,ZZI] = find_downcast(s.grnddist,s.pressure,s.rho, depth_res, minext, interpVert);
% [C h] = contour(XXI,YYI,ZZI,rho.conts,'edgecolor',[0.5 0.5 0.5]);
clabel(C,h,'LabelSpacing',150,'color',[0.5 0.5 0.5],'fontsize',6);
xlim([xlim_start xlim_end])
ylim([minD maxD])

%% 
num = 3; figprep_MNF
[XXI,YYI,ZZI] = find_downcast(s.grnddist,s.pressure,log10(s.Abundance), depth_res, minext, interpVert);
XXI = XXI(:,2:end-1); YYI = YYI(:,2:end-1); ZZI = ZZI(:,2:end-1);  % remove first and last cast
[C h] = contourf(XXI,YYI,ZZI,counts.conts,'edgecolor','none');
caxis([counts.min counts.max])
cb3 = colorbar;
set(cb3,'XTickLabel',num2str(round(10.^(get(cb3,'XTick')),1)'))
colormap(h3,jet)
hold on
set(gca,'ydir','r','fontsize',txt,'ytick',[50:50:maxD+50])
set(gca,'XTickLabel','')
tx3 = text(txt_x,txt_y,'C) log_{10} Zooplankton Abundance (ind. m^{-3})','horizontalalignment','l','units','normalized','fontsize',txt-3, 'color',fc);
ylabel('Depth (m)')
xlim([xlim_start xlim_end])
ylim([minD maxD])

%% 
num = 4; figprep_MNF
[XXI,YYI,ZZI] = find_downcast(s.grnddist,s.pressure,log10(s.Biomass), depth_res, minext, interpVert);
XXI = XXI(:,2:end-1); YYI = YYI(:,2:end-1); ZZI = ZZI(:,2:end-1);  % remove first and last cast
contourf(XXI,YYI,ZZI,biomass.conts,'edgecolor','none');
caxis([biomass.min biomass.max])
cb4 = colorbar;
set(cb4,'XTickLabel',num2str(round(10.^(get(cb4,'XTick')),1)'))
colormap(h4,jet)

hold on
% p = plot(s.grnddist(1:10),s.pressure(1:10),'.k','markersize',1);
set(gca,'ydir','r','fontsize',txt,'ytick',[50:50:maxD+50])
set(gca,'XTickLabel','')
tx4 = text(txt_x,txt_y,'D) log_{10} Zooplankton Biomass (mg m^{-3})','horizontalalignment','l','units','normalized','fontsize',txt-3, 'color',fc);
xlim([xlim_start xlim_end])
ylim([minD maxD])

%% 
num = 5; figprep_MNF
[XXI,YYI,ZZI] = find_downcast(s.grnddist,s.pressure,s.NBSS_Slope, depth_res, minext, interpVert);
XXI = XXI(:,2:end-1); YYI = YYI(:,2:end-1); ZZI = ZZI(:,2:end-1);  % remove first and last cast
[C ch] = contourf(XXI,YYI,ZZI,slope.conts,'edgecolor','none');
caxis([slope.min slope.max])
cb5 = colorbar;
cmap = colormap(h5,jet);
cmap = flipud(cmap);
colormap(h5,cmap)

hold on
% p = plot(s.grnddist(1:10),s.pressure(1:10),'.k','markersize',1);
set(gca,'ydir','r','fontsize',txt,'ytick',[50:50:maxD+50])
set(gca,'XTickLabel','')
tx5 = text(txt_x,txt_y,'E) NBSS Linear Slope','horizontalalignment','l','units','normalized','fontsize',txt-3, 'color',fc);
ylabel('Depth (m)')
xlim([xlim_start xlim_end])
ylim([minD maxD])

%% 
num = 6; figprep_MNF
[XXI,YYI,ZZI] = find_downcast(s.grnddist,s.pressure,s.GeoMn.*1e6, depth_res, minext, interpVert);
XXI = XXI(:,2:end-1); YYI = YYI(:,2:end-1); ZZI = ZZI(:,2:end-1);  % remove first and last cast
[C ch] = contourf(XXI,YYI,ZZI,geomn.conts,'edgecolor','none');
caxis([geomn.min geomn.max])
cb6 = colorbar;
cmap = colormap(h6,jet);
hold on
% p = plot(s.grnddist(1:10),s.pressure(1:10),'.k','markersize',1);
set(gca,'ydir','r','fontsize',txt,'ytick',[50:50:maxD+50])
tx6 = text(txt_x,txt_y,'F) Geometric Mean Size (\mum)','horizontalalignment','l','units','normalized','fontsize',txt-3, 'color',fc);
xlim([xlim_start xlim_end])
ylim([minD maxD])

%% 
xtick = get(gca,'XTick');
xticklabel = get(gca,'XTickLabel');

% If you want the plot to display longitude, change s.latitute to s.longtiude
xlat = roundn(s.latitude(dsearchn(s.grnddist,xtick')),-2);
YT = max(get(gca,'YLim'));

% set(gca,'XTickLabel','')

% for a = 1:length(xtick)
%     eval(['xtick_txt = {''',xticklabel{a,:},''';''(',num2str(xlat(a,:)),')''};']);
%     tx(a) = text(xtick(a),YT,xtick_txt,'horizontalalignment','center','verticalalignment','top','fontsize',txt);
%     clear xtick_txt
% end

tx_bot = text(s.grnddist(end)/2,YT+90,'Distance along transect (km)','horizontalalignment','center','fontsize',txt);
