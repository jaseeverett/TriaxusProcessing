function s = Triaxus_CTD(files)

s = struct('time',[],'latitude',[],'longitude',[],'pressure',[],'temperature',[],...
    'conductivity',[],'PAR',[],'trans',[],'oxygen',[],'sensorProcValue',[],'sensorFlag',[]);
s.time2 = [];

for a = 1:length(files)
    
    %% load CTD data
    var = {'time','latitude','longitude','sensorFlag','sensorProcValue'};
    
    for v = 1:length(var)
        eval(['t.',var{v},' = ncread(files{a},var{v});'])
    end
    %     t = nc_run(files{a},var);
    
    if strcmp(files{a},'ctd/processing/scan/in2018_t01001Ctd.nc')==1
        t.latitude = t.latitude + 65;
        t.longitude = t.longitude - 120;
    end
    s.nc{a} = ncinfo(files{a});
    s.Filename{a} = files{a};
    
    t.time = double(t.time);
    t.latitude = double(t.latitude);
    t.longitude = double(t.longitude);
    
    %% Convert time to MATLAB datenum
    
    % Get start time
    ncid = netcdf.open(files{a});
    varid = netcdf.inqVarID(ncid,'time');
    y = netcdf.getAtt(ncid,varid,'units');
    y = datenum(y(end-19:end));
    
    scanRate = str2num(ncreadatt(files{a},'/','ScanRate'));
    dimid = netcdf.inqDimID(ncid,'scan');
    [~,nScans(a)] = netcdf.inqDim(ncid,dimid);
    
    tt = t.time./86400./1e3 + y;
    
    s.time = [s.time; tt];
   
    disp(['CTD',num2str(a),' Start Time: ',datestr(tt(1))])
    disp(['CTD',num2str(a),' End Time: ',datestr(tt(end))])
    disp(' ')

    %% Add location information
    s.latitude = [s.latitude; t.latitude];
    s.longitude = [s.longitude; t.longitude];
    
    %% Data flagged 128-143 is bad
    s.sensorFlag = [s.sensorFlag t.sensorFlag];
    s.sensorProcValue = [s.sensorProcValue t.sensorProcValue];
    
    sensorNameid = netcdf.inqVarID(ncid,'sensorName');
    s.sensor = netcdf.getVar(ncid,sensorNameid)';
    
    activeSensorid = netcdf.inqVarID(ncid,'activeSensorIndex');
    s.activeSensor = netcdf.getVar(ncid,activeSensorid)'+1;
    
    % Reduce sensor's to those used for this deployment
    s.sensor = cellstr(s.sensor(s.activeSensor,:));
    
    
    clear r c t ncid varid
    
end

% %% MNF workaround to fix time errors
% t0 = s.time(1);
% dt = 1.0/scanRate;
% dtt = datenum(0, 0, 0, 0, 0, dt);
% endTime = t0 + dtt * sum(nScans);
% 
% s.time = transpose(linspace(t0, endTime, sum(nScans)));


%% Deal with bad data

if min(s.sensorFlag(:)) < 0
    disp('Flags are signed')
    s.sensorProcValue(s.sensorFlag>=-128 & s.sensorFlag<=-65) = NaN;
elseif min(s.sensorFlag(:)) > 0
    s.sensorProcValue(abs(s.sensorFlag)>=128 & abs(s.sensorFlag)<=191) = NaN;
end


%% Work out which sensors are on the Triaxus for this deployment

% Pressure
fi =  find(~cellfun('isempty',strfind(s.sensor,'DigiQuartz Pressure'))==1);
if ~isempty(fi)
    s.pressure = double(s.sensorProcValue(fi,:)');
    
elseif isempty(fi)
    % The variable is probably named 'Pressure'
    s.pressure = double(s.sensorProcValue(strcmp(s.sensor,'Pressure'),:)');
end

if max(abs(diff(s.pressure))) > 2
    s.pressure(abs(diff(s.pressure))>2) = NaN;
    warning('Removing Dodgy spikes in pressure data')
end


clear fi fi2

% Temperature
fi =  find(~cellfun('isempty',strfind(s.sensor,'Primary Temperature'))==1);
if ~isempty(fi); s.temperature = double(s.sensorProcValue(fi,:)'); end
clear fi

fi =  find(~cellfun('isempty',strfind(s.sensor,'Secondary Temperature'))==1);
if ~isempty(fi); s.backup_temperature = double(s.sensorProcValue(fi,:)'); end
clear fi

% Conductivity
fi =  find(~cellfun('isempty',strfind(s.sensor,'Primary Conductivity'))==1);
if ~isempty(fi); s.conductivity = double(s.sensorProcValue(fi,:)'); end
clear fi

fi =  find(~cellfun('isempty',strfind(s.sensor,'Secondary Conductivity'))==1);
if ~isempty(fi); s.backup_conductivity = double(s.sensorProcValue(fi,:)'); end
clear fi

% PAR
fi =  find(~cellfun('isempty',strfind(s.sensor,'PAR'))==1);
if ~isempty(fi); s.PAR = double(s.sensorProcValue(fi,:)'); end
clear fi

% Oxygen
fi =  find(~cellfun('isempty',strfind(s.sensor,'Primary Oxygen'))==1);
if ~isempty(fi); s.oxygen = double(s.sensorProcValue(fi,:)'); end
clear fi

% Transmission
fi =  find(~cellfun('isempty',strfind(s.sensor,'Transmission'))==1);
if ~isempty(fi); s.transmission = double(s.sensorProcValue(fi,:)'); end
clear fi

%% Remove out of range data
s.temperature(s.temperature > 40 | s.temperature < - 5) = NaN;

% Salinity
%  Note that the input values of conductivity need to be in units of mS/cm (not S/m).
s.salinity =  gsw_SP_from_C(s.conductivity.*1e3/100,s.temperature,s.pressure);
s.salinity(s.salinity > 40) = NaN;

