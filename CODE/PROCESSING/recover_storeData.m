function [storeData, success] = recover_storeData(results_path)
% This function recovers/rebuilds the variable storeData from the data in
% the text files of results_float.txt and (potentially) results_fixed.txt
%
% INPUT:
%	results_path        string, path to results folder of processing
% OUTPUT:
%	storeData           struct, contains recovered fields (e.g., position)
%   success         boolean, true if loading was successful
% 
% Revision:
%   2025/08/07, MFWG: improving function (more generic)
%
% This function belongs to raPPPid, Copyright (c) 2023, M.F. Glaner
% *************************************************************************

% ||| only the following data is read out from the textfiles:
%     coordinates, troposphere (estimation)



%% initialize
success = false;
storeData = struct;
storeData.float_reset_epochs = 1;
storeData.gpstime = [];
storeData.dt_last_reset = [];
storeData.NO_PARAM = [];
storeData.obs_interval = [];
storeData.float = [];
storeData.param = []; storeData.param_sigma = []; storeData.param_var = [];
storeData.exclude = [];	storeData.cs_found = [];
storeData.PDOP = []; storeData.HDOP = []; storeData.VDOP = [];
storeData.zhd = []; storeData.zwd = [];
storeData.N_1 = []; storeData.N_var_1 = []; storeData.residuals_code_1 = []; storeData.residuals_doppler_1 = [];
storeData.N_2 = []; storeData.N_var_2 = []; storeData.residuals_code_2 = []; storeData.residuals_doppler_2 = [];
storeData.N_3 = []; storeData.N_var_3 = []; storeData.residuals_code_3 = []; storeData.residuals_doppler_3 = [];
storeData.fixed = []; storeData.ttff = [];
storeData.refSatGPS = []; storeData.refSatGLO = []; storeData.refSatGAL = []; storeData.refSatBDS = []; storeData.refSatQZS = [];
storeData.param_fix = []; storeData.param_var_fix = [];
storeData.HMW_12 = []; storeData.HMW_23 = []; storeData.HMW_13 = [];
storeData.residuals_code_fix_1 = []; storeData.residuals_phase_fix_1 = [];
storeData.residuals_code_fix_2 = []; storeData.residuals_phase_fix_2 = [];
storeData.residuals_code_fix_3 = []; storeData.residuals_phase_fix_3 = [];
storeData.N_WL_12 = []; storeData.N_NL_12 = [];
storeData.N_WL_23 = []; storeData.N_NL_23 = [];
storeData.N1_fixed = []; storeData.N2_fixed = []; storeData.N3_fixed = [];
storeData.iono_fixed = []; storeData.iono_corr = []; storeData.iono_mf = []; storeData.iono_vtec = [];
storeData.cs_pred_SF = []; storeData.cs_L1C1 = [];
storeData.cs_dL1dL2 = []; storeData.cs_dL1dL3 = []; storeData.cs_dL2dL3 = [];
storeData.cs_L1D1_diff	= []; storeData.cs_L2D2_diff = []; storeData.cs_L3D3_diff = [];
storeData.cs_L1_diff = [];
storeData.cs_WL_12_diff = []; storeData.cs_var_12 = [];
storeData.cs_WL_13_diff = []; storeData.cs_var_13 = [];
storeData.cs_WL_23_diff = []; storeData.cs_var_23 = [];
storeData.mp_C1_diff_n = []; storeData.mp_C2_diff_n = []; storeData.mp_C3_diff_n = [];
storeData.constraint = []; storeData.iono_est = [];
storeData.C1 = []; storeData.C2 = []; storeData.C3 = [];
storeData.L1 = []; storeData.L2 = []; storeData.L3 = [];
storeData.C1_bias = []; storeData.C2_bias = []; storeData.C3_bias = [];
storeData.L1_bias = []; storeData.L2_bias = []; storeData.L3_bias = [];
storeData.mp1 = []; storeData.mp2 = []; storeData.MP_c = []; storeData.MP_p = [];

storeData.ORDER_PARAM = {'x'; 'y'; 'z'; 'v_x'; 'v_y'; 'v_z'; 'zwd'};



%% read settings_summary.txt
summary_path = results_path;
if ~isfile(summary_path);   summary_path = [summary_path '/settings_summary.txt'];   end

if isfile(summary_path)
    % open and read
    fid = fopen(summary_path);
    TXT = textscan(fid,'%s', 'delimiter','\n', 'whitespace','');
    TXT = TXT{1};
    fclose(fid);

    % detect number of estimated parameters
    bool_no_param = contains(TXT, 'Number of estimated parameters:');
    if any(bool_no_param)
        line_param = TXT{bool_no_param};
        idx = strfind(line_param, ':');
        storeData.NO_PARAM = str2double(line_param(idx+1:end));
    end
end



%% read out results of float solution from results file
floatpath = [results_path '/results_float.txt'];
if isfile(floatpath)
    storeData = recover_storeData_float(floatpath, storeData);
end



%% read out results of fixed solution from textfile
fixedpath = [results_path '/results_fixed.txt'];
if isfile(fixedpath)
    storeData = recover_storeData_fixed(fixedpath, storeData);
end


success = true;

