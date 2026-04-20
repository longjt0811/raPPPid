function [sinex, manual_sinex, CODE_dcb, archive, brdc_TGD] = CheckBiasSource(settings)
% This function checks which source of biases is used.
% 
% INPUT:
%   settings        struct, processing settings (from GUI)
% OUTPUT:
%	sinex           boolean, biases from SINEX file?
%   manual_sinex    boolean, biases from manually selected Bias SINEX file?
%   CODE_dcb        boolean, biases from CODE DCB files?
%   archive         boolean, biases from stream archive applied?
%   brdc_TGD        boolean, Time Group Delays from broadcast message applied?
% 
%
% Revision:
%   ...
%
% This function belongs to raPPPid, Copyright (c) 2026, M.F. Wareyka-Glaner
% *************************************************************************


% check if applied biases originated from SINEX Bias file
sinex = strcmp(settings.BIASES.phase(1:3), 'WHU') || ...
    any(strcmp(settings.BIASES.code, {'CAS Multi-GNSS DCBs','CAS Multi-GNSS OSBs','DLR Multi-GNSS DCBs','CODE OSBs','CNES OSBs','IGS','CODE MGEX','WUM MGEX','WCC MGEX','CNES MGEX','GFZ MGEX','HUST MGEX','CNES postprocessed'}));


% check for manually selected SINEX Bias file
manual_sinex = strcmp(settings.BIASES.code, 'manually') && settings.BIASES.code_manually_Sinex_bool;


% check for biases from CODE DCB files
CODE_dcb = strcmp(settings.BIASES.code, 'CODE DCBs (P1P2, P1C1, P2C2)') || ... 
    (strcmp(settings.BIASES.code, 'manually') && settings.BIASES.code_manually_DCBs_bool);


% check if biases from archived real-time correction stream are applied
archive = settings.ORBCLK.bool_precise~=1   &&  (strcmpi(settings.ORBCLK.CorrectionStream, 'CNES Archive') || strcmp(settings.ORBCLK.CorrectionStream, 'CAS Archive'));


% check if Time Group Delays are applied
brdc_TGD = strcmp(settings.BIASES.code, 'Broadcasted TGD');