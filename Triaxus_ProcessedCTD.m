function s = Triaxus_ProcessedCTD(files)

var = {'woce_date','woce_time','latitude','longitude','pressure','temperature',...
    'salinity','chlorophyll','cdom'};

s = struct('time',[],'woce_date',[],'woce_time',[],'latitude',[],'longitude',[],'pressure',[],'temperature',[],...
    'salinity',[],'chlorophyll',[],'cdom',[]);

% var = {'woce_date','woce_time','latitude','longitude','distance','pressure','temperature',...
%     'salinity','chlorophyll','cdom'};

% s = struct('time',[],'woce_date',[],'woce_time',[],'latitude',[],'longitude',[],'distance',[],'pressure',[],'temperature',[],...
%     'salinity',[],'chlorophyll',[],'cdom',[]);


flag = {'temperature','salinity','chlorophyll','cdom'};
f = struct('temperature',[],'salinity',[],'chlorophyll',[],'cdom',[]);

for a = 1:length(files)
    
    s.nc{a} = ncinfo(files{a});
    s.Filename{a} = files{a};
    
    tt = ncread(files{a},'time')./(24*60) + datenum(1900,1,1,0,0,0); 
    disp(['CTD',num2str(a),' Start Time: ',datestr(tt(1))])
    disp(['CTD',num2str(a),' End Time: ',datestr(tt(end))])
    
    s.time = [s.time; tt];
    clear tt
        
    %% load CTD data    
     for v = 1:length(var)
        eval(['s.',var{v},' = [s.',var{v},'; ncread(''',files{a},''',''',var{v},''')];'])
     end
     
     for fl = 1:length(flag)
        eval(['f.',flag{fl},' = [f.',flag{fl},'; ncread(''',files{a},''',''',flag{fl},'Flag'')];'])
     end
    clear r c t ncid varid 
    
    

end

% Apply flags and replace bad data with NaN;
% Flags: 'Good = 0; Suspect = 69; Bad = 133; Missing = 141; Unprocessed = 192'
for i = 1:length(flag)
    eval(['s.',flag{i},'(f.',flag{i},' ~= 0 & f.',flag{i},' ~= 192) = NaN;'])
end

raw = s;
clear s

%% Now change time resolution to 0.5 s

s.time = raw.time(1):0.5/86400:raw.time(end);

for i = 1:length(var)
    eval(['s.',var{i},' = interp1(raw.time,raw.',var{i},',s.time);'])
end

s.nc = raw.nc;
s.Filename = raw.Filename;

s.conductivity = s.salinity.*NaN;
