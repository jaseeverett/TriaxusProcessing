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
if reprocess == 1 & strcmp(CTD_files{1}(1:4),'scan')==1
    CTD = Triaxus_CTD(CTD_files);
    eval(['save ',Output_Name,'.mat -v7.3 CTD'])
elseif reprocess == 1 & (strcmp(CTD_files{1}(1:6),'deploy')==1)
    CTD = Triaxus_CTD_deploy(CTD_files);
    eval(['save ',Output_Name,'.mat -v7.3 CTD'])
elseif reprocess == 1 & (strcmp(CTD_files{1}(1:3),'avg')==1)
    CTD = Triaxus_CTD_avg(CTD_files);
    eval(['save ',Output_Name,'.mat -v7.3 CTD'])
    
else
    eval(['load ',Output_Name,'.mat CTD'])
end


disp(' ')
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
% offset = 50; % number of metres to remove at start/end

% Trying to halve the distance as we are losing too much... 21/Sept/'21
offset = 25; % number of metres to remove at start/end
fi_st = find(CTD.pressure>offset & CTD.time >= LOPC.datenum(1),1,'first');
fi_en = find(CTD.pressure>offset & CTD.time <= LOPC.datenum(end),1,'last');
start_time = CTD.time(fi_st);
end_time = CTD.time(fi_en);

% offset = 10; % number of minutes to remove at start/end
% fi_st = find(CTD.time >= LOPC.datenum(1),1,'first');
% fi_en = find(CTD.time <= LOPC.datenum(end),1,'last');
% start_time = CTD.time(fi_st) + offset*60/86400;
% end_time = CTD.time(fi_en) - offset*60/86400;

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

s.pressure = interp1(CTD.time,CTD.pressure,s.datenum);
s.temperature = interp1(CTD.time,CTD.temperature,s.datenum); % Use CTD temperature
s.conductivity = interp1(CTD.time,CTD.conductivity,s.datenum);

%% Is the first dip up or down
s = Triaxus_Cast(s);
rm_cast = 2; % % Remove 2 casts on each side to avoid dodgy deployment stuff.

fi_cast = find(s.cast_no > rm_cast & s.cast_no <= max(s.cast_no) - rm_cast);
s = reduce_struct(s,fi_cast);

%% Continue with processing
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


% Smooth the flow data a little.
smooth_time = 120;

dt = diff(LOPC.datenum)*86400;
dt = [dt; dt(end)];

% Do chosen flow first
LOPC.Flow.Dist = Triaxus_Filter(LOPC.Flow.Dist, LOPC.datenum, smooth_time);
LOPC.Flow.Velocity = LOPC.Flow.Dist ./ dt; % m s-1
LOPC.Flow.Vol = LOPC.Flow.Dist .* LOPC.Param.SA;
LOPC.Flow.TotalVol = sum(LOPC.Flow.Vol);

if isfield(LOPC.Flow,'Meter')
    LOPC.Flow.Meter.Dist = Triaxus_Filter(LOPC.Flow.Meter.Dist, LOPC.datenum, smooth_time);
    LOPC.Flow.Meter.Velocity = LOPC.Flow.Meter.Dist ./ dt; % m s-1
    LOPC.Flow.Meter.Vol = LOPC.Flow.Meter.Dist .* LOPC.Param.SA;
    LOPC.Flow.Meter.TotalVol = sum(LOPC.Flow.Meter.Vol);
end

if isfield(LOPC.Flow,'Transit')
    LOPC.Flow.Transit.Dist = Triaxus_Filter(LOPC.Flow.Transit.Dist, LOPC.datenum, smooth_time);
    LOPC.Flow.Transit.Velocity = LOPC.Flow.Transit.Dist ./ dt; % m s-1
    LOPC.Flow.Transit.Vol = LOPC.Flow.Transit.Dist .* LOPC.Param.SA;
    LOPC.Flow.Transit.TotalVol = sum(LOPC.Flow.Transit.Vol);
end

% TODO At this stage there is no code to do Oblique volumes directly for the
% triaxus data. I should write this at some point. For the purposes of the
% Missing Link project, I do this in MissLink_MNF for comparison.


%%
s = LOPC_SubSample(s,LOPC);

%%
s.Output_Name = Output_Name;

%% Plot QC plots
% Triaxus_QC_Plot(s)

eval(['save ',s.Output_Name,'.mat s EcoTrip -append'])
clear LOPC
