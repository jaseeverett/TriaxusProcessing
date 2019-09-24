function EcoTrip = Triaxus_EcoTrip(files)

for a = 1:length(files)
    
    
    % Read the file
    fid = fopen(files{a},'r');
    if fid < 0
        error(['File ', files{a}, ' could not be opened']);
    end
    data = textscan(fid, '%s %s %f %f %f %f %f %f %f %f', 'Delimiter', '\t');
    fclose(fid);
    
    % Preallocate
    temp.datenum = zeros(length(data{1}), 1);
    temp.Chl = zeros(length(temp.datenum),1);
    temp.CDOM = zeros(length(temp.datenum), 1);
    temp.Backscatter = zeros(length(temp.datenum), 1);
    temp.Therm = zeros(length(temp.datenum), 1);
    
    fi_end = strfind(data{1}{1},',');
    date = datenum(data{1}{1}(1:fi_end-1),'yyyy-mm-ddTHH:MM:SS');

    %% Determine dates and column order

if date < datenum(2016,1,1)  % 2014/15 Cruises

    model_no = 'FLBBCD2K-2916';
    cols = [NaN NaN data{3}(1) NaN data{5}(1) NaN data{7}(1)];
    back = struct('wavelength',700,'column', find(cols == 700), 'dark', 51, 'scale', 1.381e-06);
    cdom = struct('wavelength',460,'column', find(cols == 460), 'dark', 48, 'scale', 0.0902,'max',4130);
    chloro = struct('wavelength',695,'column', find(cols == 695), 'dark', 52, 'scale', 0.0073,'max',4130);
    
elseif date <= datenum(2016,9,27) & date >= datenum(2016,8,31)  % One off substitute IN2016_v04
    
    model_no = 'BBFL2B-754';
    cols = [NaN NaN data{3}(1) NaN data{5}(1) NaN data{7}(1)];
    back = struct('wavelength',650,'column', find(cols == 650), 'dark', 45, 'scale', 4.352e-06);
    cdom = struct('wavelength',460,'column', find(cols == 460), 'dark', 39, 'scale', 0.0924,'max',4130);
    chloro = struct('wavelength',695,'column', find(cols == 695), 'dark', 46, 'scale', 0.0107,'max',4130);
    
    
else % The usual Ecotriplet post 2015 Triaxus loss
    
    % These are the co-efficients for the August 2016 Calibration
    model_no = 'FLBBCD2K-4049';
    cols = [NaN NaN data{3}(1) NaN data{5}(1) NaN data{7}(1)];
    %% These values haven't been updated to be correct
    back = struct('wavelength',700,'column', find(cols == 700), 'dark', 48, 'scale', 1.64e-06);
    cdom = struct('wavelength',460,'column', find(cols == 460), 'dark', 41, 'scale', 0.0938,'max',4130);
    chloro = struct('wavelength',695,'column', find(cols == 695), 'dark', 47, 'scale', 0.0074,'max',4130);

end
    
    disp(['Ecotriplet Model is ',model_no])
    disp(' ')

%     Extract data and calibrate
    for i = 1:length(temp.datenum)
        
        fi_end = strfind(data{1}{i},',');
        try % Try to use milliseconds to avoid identical dates
            temp.datenum(i) = datenum(data{1}{i}(1:fi_end-1),'yyyy-mm-ddTHH:MM:SS.FFF');
        catch % But milliseconds are removed if they are '00000' so we remove 'FFF'
            temp.datenum(i) = datenum(data{1}{i}(1:fi_end-1),'yyyy-mm-ddTHH:MM:SS');
        end
            
        temp.Chl(i) = data{4}(i);
        temp.CDOM(i) = data{8}(i);
        temp.Therm(i) = data{9}(i);
        clear fi1 fi2
    end
    
    if a == 1
        EcoTrip = temp; clear temp;
    else
        EcoTrip = merge_struct(EcoTrip,temp);
        clear temp
    end
    clear data
    
end


% Apply characterisation
EcoTrip.Chl(EcoTrip.Chl>=chloro.max) = NaN; % Remove data out of range
EcoTrip.Chl = chloro.scale.*(EcoTrip.Chl - chloro.dark);
EcoTrip.Chl(EcoTrip.Chl<0 & EcoTrip.Chl >-0.1) = 0; % Remove marginally negative data

EcoTrip.CDOM(EcoTrip.CDOM>=cdom.max) = NaN; % Remove data out of range
EcoTrip.CDOM = cdom.scale.*(EcoTrip.CDOM - cdom.dark);

EcoTrip.Backscatter = back.scale.*(EcoTrip.Backscatter - back.dark);



return

% function s = ecoTriplet(file, beta, chloro, cdom, press)

% ECOTRIPLET - convert an ECO triplet data file to matlab structure
%
% S = ECOTRIPLET(FILE) converts the ECO file, FILE, into the output
% structure S using default calibration factors.  S has the following
% fields:
% time      The sample time as a matlab date.
% ecoPress  The sample pressure.
% ecoBp     The particle backscatter intensity (m^-1).
% ecoChloro The sample chlorophyll concentration (ug/l).
% ecoCdom   The CDOM concentration (ppb).
%
% Each of these fields in turn is a structure with the following fields:
% name    The data name.
% value    The array of values for the data type.
% dataType The type of data as a string.
% units    The data units as a string;
%
% S = ECOTRIPLET(FILE, BETA) converts the ECO file using calibration data
% for backscatter contained in the structure, BETA.  BETA has the following
% fields:
% column  The column that the data resides in within the file.
% dark    The calibration dark counts.
% scale   The calibration scale term.
% salt    The nominal salinity.
% X       The scattering equation X factor - see Wetlabs manual.
%
% S = ECOTRIPLET(FILE, BETA, CHLORO) in addition uses the calibration
% structure, CHLORO, to calibrate the chlorophyll data.  CDOM has the
% following fields:
% column  The column that the data resides in within the file.
% dark    The calibration dark counts.
% scale   The calibration scale term.
%
% S = ECOTRIPLET(FILE, BETA, CHLORO, CDOM) in addition uses the calibration
% structure, CDOM, to calibrate the CDOM data.  CDOM has the same fields
% as CHLORO.
%
% S = ECOTRIPLET(FILE, BETA, CHLORO, CDOM, PRESS) in addition uses the
% calibration structure, PRESS, to calibrate the pressure data.  Press has
% the following fields:
% column  The column that the data resides in within the file.
% offset  The calibration offset.
% scale   The calibration scale term.

% Check arguments and set defaults

% Modifications by Mark Baird 6 Aug 2010
error(nargchk(1, 5, nargin));

if nargin < 5
    % press = struct('column', 10, 'offset', -3.234, 'scale', 0.032);
    press = struct('column', 10, 'offset', -4.448, 'scale', 0.069);
end

if nargin < 4
    % cdom = struct('column', 8, 'dark', 35, 'scale', 0.0781);
    cdom = struct('column', 8, 'dark', 35, 'scale', 0.0781);
end

if nargin < 3
    chloro = struct('column', 6, 'dark', 48, 'scale', 0.0117);
end

if nargin < 2
    %    beta = struct('column', 4, 'dark', 50, 'scale', 3.793e-06, ...
    %        'lambda', 650, 'theta', 117.0, 'salt', 35.5, 'X', 1.1);
    beta = struct('column', 4, 'dark', 50, 'scale', 3.793e-06, ...
        'lambda', 660, 'theta', 117.0, 'salt', 35.5, 'X', 1.1);
end

% Read the file
fid = fopen(file);
if fid < 0
    error(['File ', file, ' could not be opened']);
end

textscan(fid, '%s', 1, 'Delimiter', '\n');
data = textscan(fid, '%s %s %d %d %d %d %d %d %d %d', 'Delimiter', '\t');
fclose(fid);

% Extract data and calibrate
time = zeros(length(data{1}), 1);
v1 = zeros(length(time), 1);
v2 = zeros(length(time), 1);
v3 = zeros(length(time), 1);
v4 = zeros(length(time), 1);
for i = 1:length(time)
    try
        time(i) = datenum([data{1}{i}, ' ', data{2}{i}], ...
            'mm/dd/yy HH:MM:SS');
        
        v1(i) = data{press.column}(i);
        v2(i) = data{cdom.column}(i);
        v3(i) = data{chloro.column}(i);
        v4(i) = data{beta.column}(i);
    catch theError
    end
end

% Do basic calibration
i = find(time ~= 0);
time = time(i);
v1 = v1(i) * press.scale + press.offset;
v2 = (v2(i) - cdom.dark) * cdom.scale;
v3 = (v3(i) - chloro.dark) * chloro.scale;
v4 = (v4(i) - beta.dark) * beta.scale;

% Process backscatter to get volume scattering of particles
delta = 0.09;
betaSW = 1.38 * (beta.lambda / 500.0) ^ -4.32 * ...
    (1 + 0.3 * beta.salt / 37.0) * 1e-4 * ...
    (1 + cos(pi * beta.theta / 180.0) ^ 2 * (1 - delta) / (1 + delta));

bP = 2 * pi * 1.1 * (v4 - betaSW);

% Create the output structure
timeS = struct('name', 'Time', 'value', time, 'dataType', 'Time', ...
    'units', 'days since year 0');

pressS = struct('name', 'ECO Pressure', 'value', v1, ...
    'dataType', 'Pressure', 'units', 'dbar');

cdomS = struct('name', 'ECO CDOM', 'value', v2, 'dataType', 'CDOM', ...
    'units', 'ppb');

chloroS = struct('name', 'ECO Chlorophyll', 'value', v3, ...
    'dataType', 'Chlorophyll', 'units', 'ug/l');

bPS = struct('name', 'ECO Backscatter', 'value', bP, ...
    'dataType', 'Backscatter', 'units', 'm^-1');

s = struct('time', timeS, 'ecoPress', pressS, 'ecoCdom', ...
    cdomS, 'ecoChloro', chloroS, 'ecoBp', bPS);
