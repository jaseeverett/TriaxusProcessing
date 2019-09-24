function data = CTD_QC(data,date_num,threshold)

I = true(length(data),1);
I(1) = false;
I(end) = false;

Ip1 = [false; I(1:end-1)];
Im1 = [I(2:end); false];

% testval(1) and testval(end) are left to NaN on purpose so that QC is
% raw for those two points. Indeed the test cannot be performed.
data1 = data(Im1);
data2 = data(I);
data3 = data(Ip1);

testval = abs(data2 - (data3 + data1)/2) - abs((data3 - data1)/2);

Spike = [false; testval > threshold; false];
data(Spike) = NaN; % Remove Spikes


% First do a linear interp to fill in the gaps.
fi_bad = find(isnan(data)==1);
fi_good = find(isnan(data)==0);
if isempty(fi_bad) == 0 & isempty(fi_good) == 0
    data(fi_bad) = interp1(date_num(fi_good),data(fi_good),date_num(fi_bad),'linear');
end

clear fi*
% Then do a nearest extrap to fill in the outside points
fi_bad = find(isnan(data)==1);
fi_good = find(isnan(data)==0);
if isempty(fi_bad) == 0 & isempty(fi_good) == 0
    data(fi_bad) = interp1(date_num(fi_good),data(fi_good),date_num(fi_bad),'nearest','extrap');
end
