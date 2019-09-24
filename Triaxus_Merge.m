function s = Triaxus_Merge(LOPC_files, CTD_files, EcoTrip_files, Output_Name, ESD, avg_time, reprocess)

%%

s.int = avg_time/86400; % secs to average over
warning(['Time Averaging in Triaxus_Merge is set to ',num2str(avg_time),' secs'])

Output_Name = [Output_Name,'_',sprintf('%02d',avg_time),'s'];

% eval(['!rm ',Output_Name,'.mat'])
if nargin == 6
    reprocess = 1;
end


%% Get CTD data
if reprocess == 1 & strcmp(CTD_files{1}(1:6),'deploy')==0
    CTD = Triaxus_CTD(CTD_files);
    eval(['save ',Output_Name,'.mat -v7.3 CTD'])
elseif reprocess == 1 & strcmp(CTD_files{1}(1:6),'deploy')==1
    CTD = Triaxus_ProcessedCTD(CTD_files);
     eval(['save ',Output_Name,'.mat -v7.3 CTD'])
else
    eval(['load ',Output_Name,'.mat CTD'])
end

disp(['CTD Start Time: ',datestr(CTD.time(1))])
disp(['CTD End Time: ',datestr(CTD.time(end))])
disp(' ')


%% Merge LOPC Data files
if reprocess == 1
    LOPC = LOPC_Merge(LOPC_files,ESD);
    eval(['save ',Output_Name,'.mat LOPC -append'])
else
    eval(['load ',Output_Name,'.mat LOPC'])
end


%% Display stats
disp(['LOPC Start Time: ',datestr(LOPC.datenum(1))])
disp(['LOPC End Time: ',datestr(LOPC.datenum(end))])
disp(' ')

if ~isempty(EcoTrip_files)
    EcoTrip  = Triaxus_EcoTrip(EcoTrip_files);
    disp(['Ecotriplet Start Time: ',datestr(EcoTrip.datenum(1))])
    disp(['Ecotriplet End Time: ',datestr(EcoTrip.datenum(end))])
    disp(' ')
else
    % Apply characterisation
    EcoTrip.datenum = LOPC.datenum;
    EcoTrip.Chl = LOPC.datenum.*NaN;
    EcoTrip.CDOM = LOPC.datenum.*NaN;
    EcoTrip.Backscatter = LOPC.datenum.*NaN;
    
    disp('No Ecotriplet Data')
    disp(' ')
end

%% Merge LOPC with CTD and EcoTrip
disp('')
disp('Calculating running average of NBSS Data')
disp('')

%% OFFSET FACTOR
offset = 10; % number of metres to remove at start/end

%%
% start_time = CTD.time(1)+((60*offset)/86400);
% end_time = CTD.time(end)-((60*offset)/86400);

fi_st = find(CTD.pressure>offset & CTD.time >= LOPC.datenum(1),1,'first');
fi_en = find(CTD.pressure>offset & CTD.time <= LOPC.datenum(end),1,'last');

start_time = CTD.time(fi_st);
end_time = CTD.time(fi_en);

% warning('I am recreating time - Is this a problem with integration')
s.datenum = (start_time:s.int:end_time)';

%% Display stats
disp(['Triaxus Start Time: ',datestr(s.datenum(1))])
disp(['Triaxus End Time: ',datestr(s.datenum(end))])
disp(' ')

CTD.latitude = nan_replace(CTD.latitude,CTD.time);
CTD.longitude = nan_replace(CTD.longitude,CTD.time);

s.latitude = interp1(CTD.time,CTD.latitude,s.datenum);
s.longitude = interp1(CTD.time,CTD.longitude,s.datenum);

s.grnddist = cumsum([0; sw_dist(s.latitude,s.longitude,'km')]);

while min(diff(s.grnddist))<=0
    fi = find(diff(s.grnddist)<=0,1,'first');
    s.grnddist(fi+1) = s.grnddist(fi) + 1e-6;
end

% s.waterDepth = interp1q(CTD.time,CTD.waterDepth,s.datenum);
s.pressure = interp1(CTD.time,CTD.pressure,s.datenum);
s.temperature = interp1(CTD.time,CTD.temperature,s.datenum); % Use CTD temperature
s.conductivity = interp1(CTD.time,CTD.conductivity,s.datenum);

s.chl = interp1(EcoTrip.datenum,EcoTrip.Chl,s.datenum);
s.CDOM = interp1(EcoTrip.datenum,EcoTrip.CDOM,s.datenum);

s.salinity = interp1(CTD.time,CTD.salinity,s.datenum);

% There are some erroneous salinity and pressure values. I need to change
% from hard wiring this if possible.
s.salinity(s.salinity<=25) = NaN;
s.pressure(s.pressure>300) = NaN;
s.pressure(s.pressure<0) = NaN;

% Sort out bad pressure readings
s.pressure = nan_replace(s.pressure,s.datenum);

[SA,~,~] = gsw_SA_Sstar_from_SP(s.salinity,s.pressure,s.longitude,s.latitude);
s.rho = gsw_rho(SA,s.temperature,s.pressure);
clear SA


%%
s = LOPC_SubSample(s,LOPC);

%%
s.Output_Name = Output_Name;

%% Is the first dip up or down
s = Triaxus_Cast(s);

eval(['save ',s.Output_Name,'.mat s EcoTrip -append'])
clear LOPC
