function [parameters] = settings2parameters(settings)

% settings2parameters is used to convert from settings to parameters
% struct. The idea is, that "parameters" contains all observation-file/
% session-independent (global) settings, while "settings" contains 
% observation-file/session-dependent settings as well.
% 
% INPUT:    
%   settings        struct, settings for processing with PPP_main.m 
% OUTPUT:   
%   parameters     	struct, contains parts of settings struct
%
%  
% Revision:
% 	2023/08/04, MFG: improved export of variables
% 	2025/12/02, MFWG: change function to handle missing fields
% 
% This function belongs to raPPPid, Copyright (c) 2023, M.F. Glaner
% *************************************************************************



% define the equivalent variables
parameters.ORBCLK = settings.ORBCLK;
parameters.TROPO  = settings.TROPO;
parameters.IONO   = settings.IONO;
parameters.BIASES = settings.BIASES;
parameters.OTHER  = settings.OTHER;
parameters.AMBFIX = settings.AMBFIX;
parameters.ADJ    = settings.ADJ;
parameters.PROC   = settings.PROC;

% define the fields to remove from parameters.PROC
remove = {...
    'name', 'timeFrameFrom', 'timeFrameTo', 'timeFrame', ...
    'timeSpan_format_epochs', 'timeSpan_format_HOD', 'timeSpan_format_SOD', ...
    'reset_float', 'reset_fixed', 'reset_after', 'reset_bool_epoch', ...
    'reset_bool_min', 'exclude_epochs', 'excl_eps', 'excl_epochs_reset', ...
    'exclude', 'excl_partly', 'exclude_sats'};
% check which fields are existing and must be removed
existing = fieldnames(parameters.PROC);
ActuallyRemove = remove(ismember(remove, existing));
% remove these fields
parameters.PROC = rmfield(parameters.PROC, ActuallyRemove);



