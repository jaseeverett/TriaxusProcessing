function Triaxus_QC_Plot(s)

figure

subplot(4,1,1)
plot(s.datenum,s.pressure,'.b')
ylabel('Depth')
datetick('x','HH:MM','keeplimits')
xl = get(gca,'XLim');

title(s.Output_Name,'Interpreter','None')

subplot(4,1,2)
plot(s.datenum,s.Flow.Velocity,'.b')
set(gca,'XLim',xl)
ylabel('Velocity')
datetick('x','HH:MM','keeplimits')

subplot(4,1,3)
plot(s.datenum,log10(s.Biomass),'.b')
set(gca,'XLim',xl)
ylabel('Biomass')
datetick('x','HH:MM','keeplimits')

subplot(4,1,4)
plot(s.datenum,log10(s.Abundance),'.b')
set(gca,'XLim',xl)
xlabel('Time')
ylabel('Abundance')
datetick('x','HH:MM','keeplimits')

set(gcf,'color','w')

eval(['export_fig ',s.Output_Name, '_QC -r300 -png'])

close