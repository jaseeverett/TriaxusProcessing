function var1 = nan_replace(var1,var2,method)
%
% This function replaces NaNs in 1-D data, by interpolating between missing
% points using the method defined by the user. If no method is defined, the
% default, 'linear' is used.
%
% Var2 is required as a constant to interp against.
%
% If the missing data is the first or last pts, the functions finds these
% points and replaces them with the nearest non-NaN pt. This is due to a
% limitation of the matlab interp function which will only replace data
% between valid extreme points
%
% Useage: var1 = nan_replace(var1,var2,method)
%
% Written by Jason Everett (UNSW) in September 2009
% The replacement of end values was updated October 2009

if nargin == 2
    method = 'linear';
elseif nargin ~= 3
    error('Incorrect number of inputs into nan_replace')
end

fi = find(isnan(var1)==1); % find nans
fj = find(isnan(var1)==0); % % find non nans

if isempty(fi)
    return
end


disp(' ')
warning('Replacing Missing NaN''s')

% interp to replace nans
var1(fi) = interp1(var2(fj),var1(fj), var2(fi),method);

% recheck for nans. If they still exists are this point its likely they are
% at the start or end
fi = find(isnan(var1)==1); % find nans

if fi
   % Check start
   if fi(1) == 1
       df = find(diff(fi)>1);   % Find where the NaNs stop

       if isempty(df) % if empty, all the fi are in a row.
           df = fi(end);
       end
       var1(1:df) = var1(df+1); % Replace the NaNs with the first non-NaN
       disp(['The first ',num2str(df),' value(s) were replaced with the ',num2str(df+1), ' value'])
   end
end

fi = find(isnan(var1)==1); % find nans

if fi
    % Check end
    if fi(end) == length(var1)
         
        df = find(diff(fi)>1,1,'last' )+1;   % Find where the NaNs stop
        if isempty(df)
            df = fi(1);
        end
        var1(df:end) = var1(df-1);       
        disp(['The final ',num2str(length(df:fi(end))),' value(s) were replaced with the ',num2str(df-1), ' value'])
    end  
end

fi = find(isnan(var1)==1); % recheck for nans

if fi
    error('Could not replace all NaNs. Not sure why. Recheck code')
else
    disp('All NaN''s removed')
end


