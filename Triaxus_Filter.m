function data = Triaxus_Filter(data,time,sm_time)

% where
% data is the vector to be smoothed.
% time is time as a datenum
% sm_time is the smoothing time in seconds.

% August 2019 - This is the function that I envisage will do all the
% filtering for the MissLink project. It willoperate in 3 steps. It will
% 1) replace NaNs, 2) replace outliers and 3) use a Savitsky-Golay filter 
% to remove the noise from the data.
% I believe a 5 minute filter is probably reasonable for most data, with a
% 1 minute filter for the GPS data.

% Last Updated: September 2021
% Jason Everett (UNSW/UQ)

[~,idx] = unique(time,'legacy');

dt = diff(time(idx))*86400;
dt = [dt; dt(end)];
med = median(dt);
framelen = round(sm_time/med);

% Replace outliers with linear interp

% This fill was not working correctly when the instrument was on the
% deck for a long time and then went into the water as the median was all
% messed up. Now we use a moving window method to determine contextual 
% outliers instead of global outliers. 
% Changed 30th September 2021.
% data_outlier = filloutliers(data(idx), 'linear', 'median');  % This data_uni is now only the unique data
data_outlier = filloutliers(data(idx), 'linear', 'movmedian', framelen);

 % Replace missing data with nearest values
data_miss = fillmissing(data_outlier,'linear');


% Update to use the Savitzky-Golay filtering
order = 3; % Third order polynomial

% Make sure framelen is shorter or equal to the length of data_miss
framelen = min([length(data_miss) framelen]); 

if rem(framelen,2) == 0
    framelen = framelen - 1;
end

if framelen > order
    data_filt = sgolayfilt(data_miss,order,framelen);
else
    data_filt = data_miss;
    disp('Not filtering because the framelength is less than the polynomical order')
end
    
% Go back and add in replicates for the non-unique data
data = data_filt(dsearchn(time(idx),time));

% Now ensure that all the data is greater than zero?
data(data <= 0) = 0.01;


% OLD NAN REPLACE CODE
% data_uni = nan_replace(data(idx),time(idx),'nearest'); % This data_uni is now only the unique data


% OLD FILTERING CODE
% a = 1;
% windowSize = round(sm_time/med);
% 
% if windowSize*3 > length(time)
%     windowSize = round(length(time) * 0.2);
% end
% 
% b = (1/windowSize)*ones(1,windowSize);
% data_uni_filt = filtfilt(b,a,data_uni);



