function [] = downloadAntexFromCODE()
% This function downloads M14.atx, M20.atx, and I20.atx from the FTP server
% of CODE (Center of Orbit Determination Europe)
%
% INPUT:
%   []
% OUTPUT:
%	[]
%
% Revision:
%   2025/12/23, MFWG: switch to new server according to [IGSMAIL-8642]
%
% This function belongs to raPPPid, Copyright (c) 2023, M.F. Wareyka-Glaner
% *************************************************************************



% define origin of files
host = 'http://www.aiub.unibe.ch/download/';
folder = 'CODE_MGEX/CODE/';

% define files and target to download
files = {'M14.ATX'; 'M20.ATX'; 'I20.ATX'};
target = [Path.DATA, 'ANTEX/'];

% atx-files are not small and server might be slow -> increase timeout
woptions = weboptions;
woptions.Timeout = 60;      % use 60s (usually 5s is the default value)

% download
for i = 1:3
    fprintf('Download %s ... \n', files{i})
    try
        websave([target files{i}], [host folder files{i}], woptions);
    catch
        fprintf(2, 'Download failed %s! \n', files{i})
    end
end

% print success
fprintf('Download finished. \n')








