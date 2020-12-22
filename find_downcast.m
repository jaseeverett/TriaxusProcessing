function [XI,YI,ZI,iext] = find_downcast(x_var,y_var,z_var,depth_res, minext,interpVert)

% This function finds the troughs of all the SeaSoar up/down casts and
% creates a new X grid which originates at these troughs. The Y-resolution
% is defined by depth_res (optional), otherwise it is set at 1 m. A linear
% interp is completed for Z at each depth increment along the original data.
% A mean of the Z value at each depth is taken from the cast to the left
% and right of the new X grid.
% Thanks to Lyndsay Pender (CSIRO) for access to his SeaSoar scripts from
% which this function was derived.
%
% function [XI YI ZI] = find_downcast(s,Z-Variable,depth_res)
%
% where:
%
% s is the matlab structure containing all the seasoar data
% Z_Variable is the data to be plotted on the z-axis
% depth_res is the resolution of the depth interpolation (optional)

% Created by Jason Everett (UNSW) - 13th May 2008
% Updated 6th June 2015



if nargin == 5
    interpVert = 0;
end

if nargin == 4
    minext = 0.1;
    interpVert = 0;
end

if nargin == 3
    depth_res = 1; % depth resolution of the new grid (m)
    minext = 0.1;
    interpVert = 0;
end

if nargin < 3
    error('Incorrect number of input variables. A min of 3 is required')
end

% x and y should be vectors
if size(x_var,1) == 1
    x_var = x_var';
    disp('x_var is not a nx1 vector - transposing')
end
if size(y_var,1) == 1
    y_var = y_var';
    disp('y_var is not a nx1 vector - transposing')
end


%% I have commented out this bit because it isn't used. Not sure why
% FROM HERE
% p0 = median(y_var);
% tol = median(abs(diff(y_var)))/2;
% i = find(y_var > p0 - tol & y_var < p0 + tol); % No. of crossings
% TO HERE

% Jason - I'm not sure how this calculates m.
% The larger the m value, the finer the resolution
% m must be less than half the length of y.
% m_f = 2.5; % 2.5 original value
% m = floor(m_f * max(2, length(find(diff(i) > 5))));

% trying this instead....

m = floor(length(y_var)/2.5);


if length(y_var) > 2 * m
    % There are often repeated X. It doesn't seem to affect the code in
    % this situation so I turn the warnings off
    warning('off','MATLAB:polyfit:RepeatedPointsOrRescale')
    [~, iext] = getExtremes(y_var, m, minext);
    warning('on','MATLAB:polyfit:RepeatedPointsOrRescale')
    
else
    if length(y_var) == 1
        %         ext = y_var;
        iext = 1;
    else
        [~, imin] = min(y_var);
        [~, imax] = max(y_var);
        if imin < imax
            iext(1) = imin;
            %             ext(1) = y_var(imin);
            iext(2) = imax;
            %             ext(2) = y_var(imax);
        elseif imin > imax
            iext(1) = imax;
            %             ext(1) = y_var(imax);
            iext(2) = imin;
            %             ext(2) = y_var(imin);
        else
            iext = imin;
            %             ext = y_var(imin);
        end
    end
end


%% COMMENTED OUT AND REPLACED WITH FINAL LINE
% peak = []; trough = [];
% Create my x resolution by finding the trough of each cast
% if y_var(iext(1)) < y_var(iext(2)) % first iext is peak
%     XI = x_var(iext);
%     XI = x_var(iext(2:2:end));
%     peak = 1;
%     trough = 0;
% elseif y_var(iext(1)) > y_var(iext(2)) % first iext is trough
%     XI = x_var(iext(1:2:end-1));
%     XI = x_var(iext);
%     trough = 1;
%     peak = 0;
% end


if interpVert == 0
    
    
    XI = NaN; YI = NaN; ZI = NaN;
%     warning('no interp of variables in find_downcast - only finding cast max/min')
    return
elseif interpVert == 1
    
    
    XI = x_var(iext);
    
    
    
    
    %% Start Interpolating onto grid
    
    
    % y resolution is simply 1m
    YI = 1:depth_res:max(y_var(iext)); % max depth of all the peaks/troughs
    
    % Change to matrices
    XI = repmat(XI',length(YI),1);
    YI = repmat(YI',1,size(XI,2));
    ZI = ones(size(YI)).*NaN;
    
    % Now interp z onto the grid
    %   - get all the data between two min depths
    %   - interp based on depth and grnddist
    
    % if peak == 1
    %     s_iext = 1;
    %     f_iext = length(iext)-1;
    % elseif trough == 1
    %     s_iext = 2;
    %     f_iext = length(iext);
    % end
    %
    
    s_iext = 1;
    f_iext = length(iext);
    
    warning off MATLAB:interp1:NaNinY
    
    % xxx
    for i = s_iext:f_iext
        %     count = count + 1;
        for ii = 1:size(YI,1)
            
            if i == 1
                
                % Just right side
                [r_y,idx] = sort(y_var(iext(i):iext(i+1)),'ascend');
                fi = find(diff(r_y) == 0);
                
                for iii = 1:length(fi)
                    r_y(fi(iii)+1,1) = r_y(fi(iii)) + 1e-12;
                end
                
                
                r_z = z_var(iext(i):iext(i+1));
                r_z = r_z(idx);
                r_var = interp1(r_y,r_z,YI(ii,1)); % right side variables
                
                l_var = NaN;
                
            elseif i ~= f_iext %All the middle ones
                
                
                [l_y,idx] = sort(y_var(iext(i-1):iext(i)),'ascend');
                
                % Some depths are equal - need to differentiate
                fi = find(diff(l_y) == 0);
                for iii = 1:length(fi)
                    l_y(fi(iii)+1,1) = l_y(fi(iii)) + 1e-12;
                end
                l_z = z_var(iext(i-1):iext(i));
                l_z = l_z(idx);
                l_var = interp1(l_y,l_z,YI(ii,1)); % left side variables
                
                
                clear fi idx
                
                %% Right side
                
                [r_y,idx] = sort(y_var(iext(i):iext(i+1)),'ascend');
                fi = find(diff(r_y) == 0);
                
                for iii = 1:length(fi)
                    r_y(fi(iii)+1,1) = r_y(fi(iii)) + 1e-12;
                end
                
                
                r_z = z_var(iext(i):iext(i+1));
                r_z = r_z(idx);
                r_var = interp1(r_y,r_z,YI(ii,1)); % right side variables
                
                
            elseif i == f_iext % Just the left one
                
                [l_y,idx] = sort(y_var(iext(i-1):iext(i)),'ascend');
                
                % Some depths are equal - need to differentiate
                fi = find(diff(l_y) == 0);
                for iii = 1:length(fi)
                    l_y(fi(iii)+1,1) = l_y(fi(iii)) + 1e-12;
                end
                l_z = z_var(iext(i-1):iext(i));
                l_z = l_z(idx);
                l_var = interp1(l_y,l_z,YI(ii,1)); % left side variables
                
                r_var = NaN;
                
                clear fi idx
            end
            
            % The way this is currently coded, it assumes that the new downcast
            % is equidistant between the left and right casts
            ZI(ii,i) = mean([l_var r_var],'omitnan');
        end
        
    end
    
    warning on MATLAB:interp1:NaNinY
    
end
