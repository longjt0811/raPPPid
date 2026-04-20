function q_ = QuaternionsSLERP(q1, q2, dt_1, dt_2)
% This function performs SLERP (Spherical Linear Interpolation) between two
% quaternions. It is better to use quatinterp, which requires the Aerospace
% Toolbox.
%
% INPUT:
%   q1, q2              1x4, quaternions to interpolate
%   dt_1, dt_2          [s], time difference to ORBEX timestamps for q1, q2
% OUTPUT:
%	q_                  1x4, linear interpolation of quat_1 and quat_2
%
% Revision:
%   ...
%
% This function belongs to raPPPid, Copyright (c) 2025, M.F. Wareyka-Glaner
% *************************************************************************


t = abs(dt_1) / (abs(dt_1) + abs(dt_2));

% dot product between quaternions
dotp = dot(q1, q2);

% avoid long path during interpolation (use shortest rotation)
if dotp < 0
    q2 = -q2;
    dotp = -dotp;
end

% if quaternions are very close, use a linear interpolation
if dotp > 0.9995            % random threshold
    q = (1-t)*q1 + t*q2;
    q_ = q / norm(q);
    return
end

% Angle between quaternions
theta = acos(dotp);

% SLERP (Spherical Linear Interpolation)
q_ = (sin((1-t)*theta)*q1 + sin(t*theta)*q2) / sin(theta);


