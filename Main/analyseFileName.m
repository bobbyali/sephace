% =========================================================================
% analyseFileName.m
%   Rehan Ali, 4th Nov 2006
%              Updated 4th October 2008

%   Strips out focal distance information from image filenames 
%   e.g. HeLa1_1705_trans.ics.bmp  --> 1705 um
%   Now also extracts decimal information
%   e.g. 3hr_Point0001_FITC-Time3s-Z274.85.bmp --> 274.85
%
%   Inputs:     fileName        String filename 
%               prefix          String char(s) preceding numbers of interest
%   Outputs:    n               Numeric value required
% =========================================================================

function [n] = analyseFileName(fileName,prefix)

    numregion = 0;
    numdecimal = 0;
    count = 1;
    arrN = 0;
    arrD = 0;
    n = 0;  % non-decimal value
    d = 0;  % decimal value
    pos = 1;
    
    % find location of prefix in filename string
    if (regexpi(fileName, prefix) > 0) 
        pos = regexpi(fileName, prefix) + length(prefix);
    end
    
    for i = pos : length(fileName)
        % check if current character is numeric
        if ~isempty(str2num(fileName(i)))
            % if current char 
            if numregion == 0
                arrN(count) = str2num(fileName(i));
                numregion = 1;
                count = count + 1;
            elseif numregion == 1 && numdecimal == 1
                arrD(count) = str2num(fileName(i));
                count = count + 1;
            elseif numregion == 1
                arrN(count) = str2num(fileName(i));
                count = count + 1;
            end
        elseif fileName(i) == '.' && numregion == 1
            if isempty(str2num(fileName(i+1)))
                break
            else
                numdecimal = 1;
                count = 1;
            end
        else
            % if nonnumeric but we were previously in a numeric region,
            % then terminate code
            if numregion == 1
                break
            end
        end
        
    end
    
    %arrN
    %arrD
    arrN = fliplr(arrN);
    for k = 1 : length(arrN)
        n = n + arrN(k)*10^(k-1);
    end
    
%     % append decimal part
%     for k = 1 : length(arrD)
%         d = d + arrD(k)*10^(-1*k);
%     end
%     n = n + d;
%     