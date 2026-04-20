function file_status = CurlDownload(target, source, bool_print)
% This function downloads a specified file with curl (e.g., from 
% ftps://bdspride.com).
% 
% INPUT:
%   target          string, path to local file
%   source          string, adress of file to download
% OUTPUT:
%	file_status     
%
% Revision:
%   ...
%
% This function belongs to raPPPid, Copyright (c) 2025, M.F. Wareyka-Glaner
% *************************************************************************

file_status = 0;

% check if file exists already
[path, file, ~] = fileparts(target);
if isfile(target) || isfile([target '.mat']) || isfile([path '/' file]) || isfile([path '/' file '.mat'])
    file_status = 1;
    return
end



% build command string for command line
command = ['curl --ssl-reqd --user anonymous:anonymous -k -o "' ...
           target '" "' source '"'];

% use command line
[status, cmdout] = system(command);

% check if download was successful
if status == 0
    file_status = 1;
elseif bool_print
    disp(cmdout);
end