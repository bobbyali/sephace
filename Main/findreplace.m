% =========================================================================
% findreplace.m
% Rehan Ali, 24th July 2008
%
% Find a substring within a longer string, and replace it with another string
%
% Input:
%   string_main         Main string
%   string_find         Sub-string to locate
%   string_replace      String to replace 'find' sub-string with
%   
% Output:
%   new_string          New output string
%
% Version 1.0  -  Set up function to find single character strings
% =========================================================================  

function new_string = findreplace(string_main,string_find,string_replace)

    new_string = [];
    
    if length(string_find) > 1
        
        % fill this in for multi-char search-replaces

        L = length(string_main);
        l = length(string_find);
        k = strfind(string_main,string_find);
        p = 0;
        i = 1;
        
        while p == 0                
            if isempty(find(k == i))
                new_string = [new_string string_main(i)];
                i = i + 1;
            else
                new_string = [new_string string_replace];
                i = i + l;
            end    
            
            if i > L
                p = 1;
            end
        end
        
    else
        
        % look for single char strings
        for i = 1 : length(string_main)
            if string_main(i) == string_find
                new_string = [new_string string_replace];
            else
                new_string = [new_string string_main(i)];
            end
        end

    end
