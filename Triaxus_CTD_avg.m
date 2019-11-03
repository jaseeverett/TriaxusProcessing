function s = Triaxus_CTD_avg(files)

var = {'pressure', 'temperature', 'conductivity','salinity', 'chlorophyll', 'cdom'};

s = struct('time',[],'latitude',[],'longitude',[],'pressure',[],'temperature',[],...
    'conductivity',[],'salinity',[],'chlorophyll',[], 'cdom', []);

flag = {'temperature','conductivity','salinity','chlorophyll','cdom'};
f = struct('temperature',[],'conductivity', [], 'salinity',[],'chlorophyll',[],'cdom',[]);

for a = 1:length(files)
    
    load(files{a})
    
    disp(['CTD',num2str(a),' Start Time: ',datestr(avgStruct.time(1))])
    disp(['CTD',num2str(a),' End Time: ',datestr(avgStruct.time(end))])
    
    s.Filename{a} = files{a};
    s.time = [s.time; avgStruct.time'];
    s.latitude = [s.latitude; avgStruct.latitude'];
    s.longitude = [s.longitude; avgStruct.longitude'];
    clear tt
        
    %% load CTD data    
     for v = 1:length(var)
        eval(['s.',var{v},' = [s.',var{v},'; avgStruct.sensor.',var{v},'.data''];'])
     end
     
     for fl = 1:length(flag)
        eval(['f.',flag{fl},' = [f.',flag{fl},'; avgStruct.sensor.',flag{fl},'.flags''];'])
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

s.time = (raw.time(1):0.5/86400:raw.time(end))';
s.latitude = interp1(raw.time,raw.latitude, s.time);
s.longitude = interp1(raw.time,raw.longitude, s.time);

for i = 1:length(var)
    eval(['s.',var{i},' = interp1(raw.time,raw.',var{i},',s.time);'])
end

s.Filename = raw.Filename;
