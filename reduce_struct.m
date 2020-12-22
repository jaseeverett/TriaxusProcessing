function s = reduce_struct(s, fi, min_size, orient, dimen)

% This function reduce's the size of structure by removing all values
% except those defined by fi. If the length of the field is less than min_size, it is
% ignored. If no min_size is defined, the default of 1 is used.
% As of Feb 2009, this function can now handle matrices, however it will
% always assume the larger dimension is the dimension to be reduced. If
% the dimensions are equal in length, it will reduce the first dimension.
% If it is a character matrix, it will reduce the first dimension.
%
% Useage: s = reduce_struct(s,fi,min_size);
%
% Jason Everett (UNSW) June 2008
% Updated Feb 2009
% Updated Mar 2020

if nargin == 2
    % The minimum size of a vector to reduce
    min_size = 1;
end

% if nargin == 3
%     
% end



% Get a list of fieldnames
NAMES = fieldnames(s);

for a = 1:length(NAMES) % Do for all fieldnames
    
    % At least one dimension must be greater than min
    if eval(['length(s.',char(NAMES(a)),')']) > min_size
        
        % If its a char array both dimensions must be greater than 1
        
        if eval(['ischar(s.',char(NAMES(a)),') == 1 & size(s.',char(NAMES(a)),',1) > 1 & size(s.',char(NAMES(a)),',2) > 1'])
            eval(['s.',char(NAMES(a)),' = s.',char(NAMES(a)),'(fi,:);']) % Reduce by first dimension
            
        elseif eval(['ischar(s.',char(NAMES(a)),')'])
            % Do nothing for chars with 1 dimensions
            
            
        elseif eval(['size(s.',char(NAMES(a)),',1) == 1 | size(s.',char(NAMES(a)),',2) ==1'])
            if nargin ~= 4
                eval(['s.',char(NAMES(a)),' = s.',char(NAMES(a)),'(fi);'])
                
            elseif nargin == 4
                
                if strcmp(orient,'Vert') == 1 & eval(['size(s.',char(NAMES(a)),',2) == 1'])
                    eval(['s.',char(NAMES(a)),' = s.',char(NAMES(a)),'(fi,1);'])
                    
                elseif strcmp(orient,'Horiz') == 1  & eval(['size(s.',char(NAMES(a)),',1) == 1'])
                    %                     eval(['size(s.',char(NAMES(a)),',2) == 1'])
                    eval(['s.',char(NAMES(a)),' = s.',char(NAMES(a)),'(1,fi);'])
                end
            end
            
            
            % If its not char and its a vector
        elseif eval(['size(s.',char(NAMES(a)),',1) == 1']) & strcmp(orient,'Vert') ==1
            
            
        elseif eval(['size(s.',char(NAMES(a)),',2) ==1'])
            
            eval(['s.',char(NAMES(a)),' = s.',char(NAMES(a)),'(fi);'])
            
            
            
            
            
            
        elseif eval(['size(s.',char(NAMES(a)),',1)  < size(s.',char(NAMES(a)),',2)']) % Matrix (small,large )
            if exist('dimen','var')
                if dimen == 1
                    eval(['s.',char(NAMES(a)),' = s.',char(NAMES(a)),'(fi,:);'])
                elseif dimen == 2
                    eval(['s.',char(NAMES(a)),' = s.',char(NAMES(a)),'(:,fi);'])
                end
            else
                eval(['s.',char(NAMES(a)),' = s.',char(NAMES(a)),'(:,fi);'])
            end
            
        elseif eval(['size(s.',char(NAMES(a)),',2)  < size(s.',char(NAMES(a)),',1)']) % Matrix (n,n) - Use default (large,small)
            eval(['s.',char(NAMES(a)),' = s.',char(NAMES(a)),'(fi,:);'])
        elseif eval(['size(s.',char(NAMES(a)),',1)  == size(s.',char(NAMES(a)),',2)']) % Equal size, reduce first
            eval(['s.',char(NAMES(a)),' = s.',char(NAMES(a)),'(fi,:);'])
            
        else
            error('Data does not satisfy criteria in reduce_struct.m')
        end
        
    else
        % Do nothing - not of minimum size
        %        disp(['s.',char(NAMES(a)),' = s.',char(NAMES(a)),';'])
        %          eval(['s.',char(NAMES(a)),' = s.',char(NAMES(a)),';']) %
    end
    
end
