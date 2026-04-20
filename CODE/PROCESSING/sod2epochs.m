function [PROC_epochs] = sod2epochs(RINEX, epochheader, PROC_epochs, version)
% Settings for the processing epochs are in seconds or hours of day. This 
% function calculates from which epoch to which epoch of the RINEX file the
% processing should run.
% 
% INPUT:
%   RINEX           cell array, read in RINEX file
%   epochheader     vector, indices of the epoch-headers in RINEX
%   PROC_epochs     start and end epoch of processing [sod]
%   version         version of RINEX file    
% OUTPUT:
%   PROC_epochs     start and end epoch of processing [number of epoch]
%
% Revision:
%   2025/08/14, MFWG: switch to cal2gpstime
%
% This function belongs to raPPPid, Copyright (c) 2023, M.F. Glaner
% *************************************************************************


%% Read time of observation epochs
no_headers = numel(epochheader);        % number of epoch (headers) in RINEX
headers = RINEX(epochheader);           % get epoch headers
time_epochs = NaN(no_headers, 1);       % initialize time vector, [sow]

for i = 1:no_headers
    if version == 2                         % RINEX-file is version 2
        % linvales = year (2-digit) | month | day | hour | min | sec | epoch flag |
        %            string with satellites (e.g. 'G30G13G 2R 5E22J 7')
        lvalues = textscan(headers{i},'%f %f %f %f %f %f %d %2d%s','delimiter',',');
        lvalues{1} = lvalues{1} + 2000;
    elseif version == 3 || version == 4 	% RINEX-file is version 3 or 4
        % linvalues = year | month | day | hour | minute | second |
        %             Epoch flag | number of observed satellites| empty |
        %             receiver clock offset
        lvalues = textscan(headers{i},'%*c %f %f %f %f %f %f %d %2d %f');
    end
    % convert date into gps-time [sow]
    emptyCells = cellfun(@isempty, lvalues);
    if ~any(emptyCells(1:6))        % simple header check (e.g., last epoch broken)
        [~, time_epochs(i)] = cal2gpstime([lvalues{1}, lvalues{2}, lvalues{3}, lvalues{4}, lvalues{5}, lvalues{6}]);
    end
end


%% Determine epochs to process
% convert time of the RINEX epoch headers from [sow] in [sod]
time_epochs = mod(time_epochs, 86400);

% find nearest start epoch
start_dt = abs(PROC_epochs(1) - time_epochs); 
start_idx = find(start_dt == min(start_dt));
% find nearest end epoch
end_dt = abs(PROC_epochs(2) - time_epochs); 
end_idx = find(end_dt == min(end_dt));

% save beginning ane end epoch of processing
PROC_epochs(1) = start_idx(1);
PROC_epochs(2) = end_idx(end);

% check if setting of time span is sensible
if PROC_epochs(1) == PROC_epochs(2)
    errordlg({'Start and end of procesing are outside of observation file.', ...
        'Complete RINEX file is processed instead.'}, 'Time Span Error');
    PROC_epochs(1) = 1;
    PROC_epochs(2) = no_headers;
end

