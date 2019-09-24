% This script creates our own sub plots. They are more manipulatable than
% Matlab's own ones, allowing you to minimise the space between plots. In
% its current form, the script will not work as intended if a single
% colorbar is placed on one side. It will compress all the axes on the same
% edge as the colorbar.
%
% Jason Everett (UNSW)
% Last Edited: 8th December 2009

set(gcf,'Units','normalized')

r = [repmat([1:rows]',1,cols)]';
c = [repmat(1:cols,rows,1)]';

row = r(num); col = c(num);

if rows == 1
    vspc = 0;
else
    vspc = 0.01; %0.008;%0.03; %0.005; % Space between rows
end

if cols == 1;
    hspc = 0;
else
    hspc = 0.02; %0.015; % Space between columns
end

left = 0.075; % 0.06 Space left on the left
right = 0.075; %0.15 %0.09; % Space left on the right
% bot = 0.075;
bot = 0.11; %0.075; %0.08;
top = 0.05;

titl = 0.02; % If no title is needed, this can be set to 0;

wdth = (1.0 - left - right-(cols-1)*hspc)/cols;
hgt = ((1.0 - bot -top -(rows-1)*vspc)/rows) - titl;

h = axes('position',[left+(col-1)*(wdth+hspc) (1.0-top-row*(hgt+titl+vspc)) wdth hgt]);
eval(['h',num2str(num),' = h;'])