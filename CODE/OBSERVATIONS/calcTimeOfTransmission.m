function [Ttr, tau] = calcTimeOfTransmission(pseudorange, gps_time, dT_sat, dT_rel)
% This function calculates the runtime tau and the time of transmission Ttr.
%
% INPUT:
%   pseudorange     pseudorange [m]
%   gps_time        GPS time of epoch [sow]
%   dT_sat          satellite clock error [s]
%   dT_rel          relativistic correction [s]
% OUTPUT:
%	tau             runtime of the signal [s]
%   Ttr             time of transmission [sow]
%
% Revision:
%   ...
%
% This function belongs to raPPPid, Copyright (c) 2025, M.F. Wareyka-Glaner
% *************************************************************************

% calculate sum of satellite clock error and relativistic correction
dT_sat_rel = dT_sat + dT_rel;



% calculate approximate signal runtime from satellite to receiver
tau = (pseudorange + Const.C*dT_sat_rel)/Const.C;


% calculate time of transmission in seconds of week:
% time of transmission = time of observation - runtime
Ttr = gps_time - tau;