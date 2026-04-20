function [dT_clk, noclock] = satelliteClock(sv, Ttr, preciseClk)
% Calculate precise satellite clock from precise clock file (*.clk).
%
% INPUT:
% 	sv              satellite vehicle number
% 	Ttr             transmission time (GPStime)
% 	preciseClk      precise clocks read with read_precise_clocks.m
%
% OUTPUT:
%   dT_clk          satellite clock correction [s]
%   noclock         true if satellite should not be used (missing clock information)
% 
% uses lininterp1 (c) 2010, Jeffrey Wu
%
% Revision:
%   2025/02/12, MFWG: added missing conversion [mm/..] to [m/..] (corr2brdc)
%   2025/09/13, MFWG: change structure
%   2025/10/02, MFWG: move brdc+corr2brdc to satelliteClockBrdc.m
%
% This function belongs to raPPPid, Copyright (c) 2023, M.F. Glaner
% *************************************************************************


noclock = false;   

% cut noPoints sampling points around Ttr to accelerate interpolation
points = 20;
midPoints = points/2 + 1;

% get and prepare data for interpolation
idx = find(abs(preciseClk.t-Ttr) == min(abs(preciseClk.t-Ttr)));    % index of nearest precise clock
idx = idx(1);                                   % preventing errors
if idx < midPoints                              % not enough data before
    time_idxs = 1:points;                       % take data from beginning
elseif idx > length(preciseClk.t)- points/2     % not enough data afterwards
    no_el = numel(preciseClk.t);                % take data until end
    time_idxs = (no_el-points) : (no_el);
else                                            % enough data around
    time_idxs = (idx-points/2) : (idx+points/2);% take data around point in time
end
t_prec_clk = preciseClk.t(time_idxs);           % time of precise clocks
value_prec_clk = preciseClk.dT(time_idxs,sv);   % values of precise clocks

% check values used for interpolation
if any(value_prec_clk == 0)
    % one of the values to interpolate is 0 -> do not use
    dT_clk = 0;         % satellite is excluded outside this function in modelErrorSources.m
    noclock = true;   
    return
end

% interpolate satellite clock
dT_clk = lininterp1(t_prec_clk, value_prec_clk, Ttr);       % linear is fast (results hardly change compared to polynomial)




% % approximate satellite clock drift
% diff_clk = preciseClk.dT(idx+1, sv) - preciseClk.dT(idx, sv);
% diff_time = (preciseClk.t(idx+1) - preciseClk.t(idx));
% dT_clk_drift = diff_clk / diff_time;