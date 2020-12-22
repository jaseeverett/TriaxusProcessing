% This function will check the start/end time of an CTD nc file

%
% Jason Everett (UQ)
% Written 22 December 2020

function Triaxus_CTD_CheckTimes(file)

% Get start time
ncid = netcdf.open(file);
varid = netcdf.inqVarID(ncid,'time');
y = netcdf.getAtt(ncid,varid,'units');
y = datenum(y(end-19:end));

t.time = ncread(file,"time");

tt = t.time./86400./1e3 + y;

disp(['CTD ',cell2mat(file), ' Start Time: ',datestr(tt(1))])
disp(['CTD ',cell2mat(file), ' End Time: ',datestr(tt(end))])
disp(' ')
