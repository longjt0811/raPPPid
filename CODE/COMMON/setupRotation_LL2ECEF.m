function R = setupRotation_LL2ECEF(lat, lon)
% Creates the rotation matrix from Local Level (LL, North-East-Up) to 
% ECEF. The rotation matrix can be interpreted as the axes of the LL frame 
% expressed in the ECEF frame. Local Level origin in point with latitude 
% and longitude. For details check:
% Galileo High Accuracy Service Reference User Algorithm - Technical Note
% 
% 
% INPUT:
%   lat         latitude of the receiver [rad]
%   lon         longitude of the receiver [rad]
% OUTPUT:
%	R           3x3, rotation matrix from Local Level to ECEF frame
%
% This function belongs to raPPPid, Copyright (c) 2023, M.F. Glaner
% *************************************************************************

R = zeros(3);

% North
R(1,1) = -sin(lat)*cos(lon);
R(2,1) = -sin(lat)*sin(lon);
R(3,1) =  cos(lat);

% East
R(1,2) = -sin(lon);
R(2,2) =  cos(lon);
R(3,2) =  0;

% Up (Left-handed)
R(1,3) =  cos(lat)*cos(lon);
R(2,3) =  cos(lat)*sin(lon);
R(3,3) =  sin(lat);
