function A = merge_struct(varargin)
%  A =  merge_struct
% 
%   This function is a rewrite of Jos can der Geest's functions catstruct
%   The old function would only use one of the values if there were two
%   fields with the same name. This function actually merges the values of
%   those fields into the new field.
%   
%   eg. S1.Salinty = [35.1 35.2 35.3]; and S2.Salinty = [35.4 35.5 35.6];
%   The new structure would be S.Salinty = [35.1 35.2 35.3 35.4 35.5 35.6];
% 
% Jason Everett 2016 (UNSW)



%   Useage: X = CATSTRUCT(S1,S2,S3,...) concates the structures S1, S2, ... 
%   into one structure X.
%
%   See also CAT, STRUCT, FIELDNAMES, STRUCT2CELL

% for Matlab R13
% version 2.0 (sep 2007)
% (c) Jos van der Geest
% email: jos@jasen.nl

% History
% Created:  2005
% Revisions
%   2.0 (sep 2007) removed bug when dealing with fields containing cell arrays (Thanks to Rene Willemink)

N = nargin ;

narginchk(1,Inf) ;

for ii=1:N
    X = varargin{ii} ;
    if ~isstruct(X)
        error(['Argument #' num2str(ii) ' is not a structure.']) ;
    end
    FN{ii} = fieldnames(X);
    VAL{ii} = struct2cell(X);
end

FN = cat(1,FN{:});
VAL = cat(1,VAL{:});

UFN = unique(FN) ; %UFN = Unique Field Names

for a = 1:length(UFN)
    
    fi = find(strcmp(UFN(a),FN)==1); % Finds the refs for all instances of the UFN

    if length(fi) == 4
        MERGE{a,:} = [VAL{fi(1)}; VAL{fi(2)}; VAL{fi(3)}; VAL{fi(4)}];
    elseif length(fi) == 3
        MERGE{a,:} = [VAL{fi(1)}; VAL{fi(2)}; VAL{fi(3)}];
    elseif length(fi) == 2
        MERGE{a,:} = [VAL{fi(1)}; VAL{fi(2)}];
    elseif length(fi) == 1
        MERGE{a,:} = VAL{fi};
    end


end

A = cell2struct(MERGE, UFN);


