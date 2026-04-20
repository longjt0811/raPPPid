function [dX_PCV_rec, los_PCV_r] = ...
    calc_PCV_rec(PCV_rec, j, el, az, settings, f1, f2, f3)
% This function calculates the receiver phase center variations for a
% specific GNSS satellite and the processed frequencies. Currently, it
% takes the nearest available correction (NO interpolation).
%
% INPUT:
%	PCV_rec         phase center variations from antex file
%   j               indices of processed frequencies
%   el              elevation [°] to satellite
%   az              azimuth [°] to satellite
%   settings        struct, processing settings from GUI
%   f1, f2, f3      frequencies of current satellite
% OUTPUT:
%	dX_PCV_rec      phase center variation range correction for processed
%                   observations (e.g., IF LC)
%   los_PCO_r       phase center variation range correction for raw
%                   observations
%
% Revision:
%   ...
%
% This function belongs to raPPPid, Copyright (c) 2023, M.F. Glaner
% *************************************************************************

los_PCV_r = [0,0,0];  	        % initialize phase center variation range correction

rec_PCV_azi = PCV_rec(2:end,1,1);        	% grid in azimuth
rec_PCV_zen = PCV_rec(1,2:end,1);          	% grid in zenith angle
PCV_rec_frq = PCV_rec(2:end, 2:end, :);     % PCV data for processed frequencies

ztd = 90 - el;          % zenith angle to satellite

if rec_PCV_azi == 0   	% no azimutal dependency
    % calculate for zenith distance difference to raster and index of nearest PCV in zenith distance
    d_zen = abs(rec_PCV_zen - ztd);
    idx_ztd = find(d_zen == min(d_zen),1);
    los_PCV_r(j) = PCV_rec_frq(1, idx_ztd, j); 	% get PCV for processed frequencies
%     % interpolation, makes results worse
%     for i = 1:n      	% linear interpolation zenith distance for processed frequencies
%         dX_PCV(i) = interp1(rec_PCV_zen, PCV_rec_frq(:,:,i), ztd);
%     end
    
else    % raster in azimuth and zenith angle, take nearest PCV correction (no interpolation)
    d_azi = abs(rec_PCV_azi - az);          % difference to raster in azimuth
    d_zen = abs(rec_PCV_zen - ztd);         % ... and zenith distance
    idx_azi = find(d_azi == min(d_azi),1);	% index of nearest PCV in azimuth
    idx_ztd = find(d_zen == min(d_zen),1); 	% ... and zenith distance
    los_PCV_r(j) = PCV_rec_frq(idx_azi, idx_ztd, j); 	% get PCV for processed frequencies
    % |||consider interpolation here (do not expect an impact on the results because at/below mm)
end

% convert to processed frequency
dX_PCV_rec = Convert2ProcFrqs(settings, j, los_PCV_r, f1, f2, f3, [0 0 0]);
