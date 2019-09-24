function [extreme, index, ismax] = getExtremes(x, n, minExt)

% getExtremes  -  get the extreme values of a vector by segmentation.
%
% [EXTREME, INDEX, ISMAX] = getExtremes(X, N) returns the extreme values,
% EXTREME, of vector X by segmenting X into N segments, computing the mean
% gradient of X in each segment and searching for minima and maxima through
% a gradient sign change.  Minima and maxima are also returned for the end
% segments.  The function also optionally returns the index, INDEX, of the
% actual extremes and a logical variable, ISMAX, set true if the extreme is
% a maximum.
%
% N is an optional argument; the default value is 10.  The value of N
% determines the resolution of the algorithm; larger values of N result in
% finer resolution.  In general, N should result in segments less than half
% the length of the required resolution.  The number of data points must be
% greater than 2 * N.
%
% [EXTREME, INDEX, ISMAX] = getExtremes(X, N, MINEXT) returns the extreme
% values as above, however extremes are restricted to extremes that have
% ranges greater than (MINEXT * maximum extreme range).  Default value for
% MINEXT is 0.1.
%
% NaN values are ignored.

narginchk(1, 3)
[r, c] = size(x);
if r ~= 1 && c ~= 1
   error('getExtremes: X must be a vector')
end

if r ~= 1
   x = x(:);
end

if nargin < 2
   n = 10;
end

nx = length(x);
if nx <= 2 * n
   error('getExtremes: insufficient data length for number of segments')
end

if nargin < 3
   minExt = 0.1;
end

% Sub-divide data and obtain gradients in each segment.

r = nx / n;
xr = zeros(2, n);
dyr = zeros(1, n);
for k = 1:n
   i = round((k - 1) * r) + 1;
   j = round(k * r);
   good = find(~isnan(x(i:j)));
   if ~isempty(good)
      good = good + i - 1;
      a = polyfit(good, x(good), 1);
      xr(1, k) = good(1);
      xr(2, k) = good(end);
      dyr(k) = a(1);
   end
end

% Find all changes of gradient in decimated data

gradChange = find(sign(dyr(1:n-1) .* dyr(2:n)) < 0);
m = length(gradChange);

% Handle no change of gradient separately

ismax = zeros(1, m + 2);
index = zeros(1, m + 2);
extreme = zeros(1, m + 2);
if m == 0
   r1 = floor(r);
   if (dyr(1) < 0)
      ismax(1) = 1;
      [extreme(1), index(1)] = max(x(1:r1));
      [extreme(2), index(2)] = min(x(1:r1));
   else
      ismax(2) = 1;
      [extreme(1), index(1)] = min(x(1:r1));
      [extreme(2), index(2)] = max(x(1:r1));
   end
   
   return;
end

% Handle start

i1 = 1;
i2 = xr(2, gradChange(1));
if (dyr(gradChange(1)) > 0)
   ismax(1) = 0;
   [extreme(1), index(1)] = min(x(i1:i2));
else
   ismax(1) = 1;
   [extreme(1), index(1)] = max(x(i1:i2));
end

% Find intermediate extremes

for k = 1:m
   i1 = xr(1, gradChange(k));
   i2 = xr(2, gradChange(k) + 1);
   if (dyr(gradChange(k)) > 0)
      ismax(k + 1) = 1;
      [extreme(k + 1), index(k + 1)] = max(x(i1:i2));
   else
      ismax(k + 1) = 0;
      [extreme(k + 1), index(k + 1)] = min(x(i1:i2));
   end
   
   index(k + 1) = index(k + 1) + i1 - 1;
end

% Handle end

i1 = xr(1, gradChange(m) + 1);
i2 = length(x);
if (dyr(gradChange(m) + 1) > 0)
   ismax(m + 2) = 1;
   [extreme(m + 2), index(m + 2)] = max(x(i1:i2));
else
   ismax(m + 2) = 0;
   [extreme(m + 2), index(m + 2)] = min(x(i1:i2));
end

index(m + 2) = index(m + 2) + i1 - 1;

% Since searches overlap, there is a chance of false minima or maxima where
% indices are not monotonic - this happens if the noise in the data is
% comparable to the range of the data in a segment.  These extremes are
% removed.

iRem = find(diff(index) < 0);
if ~isempty(iRem)
   for j = 1:length(iRem)
      i = iRem(j);
      if i == 1										% First extreme
         ismax(1) = NaN;
      else
         if i == length(index) - 1				% Last extreme
            ismax(end) = NaN;
         else											% Intermediate extreme
            ismax(i) = NaN;
            ismax(i + 1) = NaN;
         end
      end
   end
   
   i = find(isnan(ismax));
   extreme(i) = [];
   index(i) = [];
   ismax(i) = [];
end

% Remove extremes which don't meet our minimum range criteria.
% Remove invalid extremes at either end first

range = abs(diff(extreme));
maxRange = max(range);
range(2:end-1) = NaN;
iRem = find(range < maxRange * minExt);

% checkStart = 0;
% checkEnd = 1;
while ~isempty(iRem) && length(extreme) > 2
   if iRem(1) == 1									% First extreme
      ismax(1) = NaN;
      if ismax(3)
         [extreme(2), index(2)] = min(x(1:index(3)));
      else
         [extreme(2), index(2)] = max(x(1:index(3)));
      end
   end
   
   if iRem(end) == length(index) - 1			% Last extreme
      ismax(end) = NaN;
      if ismax(end-2)
         [extreme(end-1), index(end-1)] = min(x(index(end-2):nx));
      else
         [extreme(end-1), index(end-1)] = max(x(index(end-2):nx));
      end
      
      index(end-1) = index(end-1) + index(end-2) - 1;
   end
   
   i = find(isnan(ismax));
   extreme(i) = [];
   index(i) = [];
   ismax(i) = [];
   
   range = abs(diff(extreme));
   range(2:end-1) = NaN;
   iRem = find(range < maxRange * minExt);
end

% Remove intermediate invalid extremes

range = abs(diff(extreme));
iRem = find(range < maxRange * minExt);
while ~isempty(iRem) && length(extreme) > 3
   i = iRem(1);
   ismax(i) = NaN;
   ismax(i + 1) = NaN;
   
   if ismax(i + 2)
      [extreme(i + 2), index(i + 2)] = max(x(index(i):index(i + 2)));
   else
      [extreme(i + 2), index(i + 2)] = min(x(index(i):index(i + 2)));
   end
   
   index(i + 2) = index(i + 2) + index(i) - 1;
   i = find(isnan(ismax));
   extreme(i) = [];
   index(i) = [];
   ismax(i) = [];
   
   range = abs(diff(extreme));
   iRem = find(range < maxRange * minExt);
end
