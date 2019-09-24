function s = Triaxus_Cast(s)

% Find the cast numbers for each up/down of the Triaxus undulations
% Jason Everett (UNSW)
% October 2016

%%
MinExt = 0.2;

% Reduce to one cast only
[~,~,~,iext] = find_downcast(s.grnddist,s.pressure,s.temperature,1,MinExt);


% mPP = 20; %metres
% [~,MaxIdx] = findpeaks(s.pressure,'MinPeakProminence',mPP);
% [~,MinIdx] = findpeaks(-s.pressure,'MinPeakProminence',mPP);
% 
% iext = sort([MaxIdx; MinIdx]);


% Create my x resolution by finding the trough of each cast
if s.pressure(iext(1)) < s.pressure(iext(2)) % first iext is peak
    down = 1;
    up = 0;
elseif s.pressure(iext(1)) > s.pressure(iext(2)) % first iext is trough
    up = 1;
    down = 0;
end

% Create cast numbers
s.cast_no = s.grnddist.*NaN;
for d = 1:length(iext)-1
    s.cast_no(iext(d):iext(d+1)-1) = d;
end
% do last cast
d = d + 1;
s.cast_no(iext(d):length(s.cast_no)) = d;

% Insert the direstion of the cast (-1 is down, 1 is up)
% Calculate the reference points for just the up or down
c = 1;
ref = [];
for f = 1:floor(length(iext)/2)
    ref = [ref iext(c):iext(c+1)];
    c = c+2;
end

if down == 1
    s.cast_direc = ones(size(s.pressure));
    s.cast_direc(ref) = -1;
elseif up == 1
    s.cast_direc = ones(size(s.pressure)).*-1;
    s.cast_direc(ref) = 1;
end
