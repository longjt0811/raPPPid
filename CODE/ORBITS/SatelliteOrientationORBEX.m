function SatOr_ECEF = SatelliteOrientationORBEX(Ttr, prn, ATT)
% This function calculates the orientation of a GNSS satellite using the
% attitude information of a ORBEX file. The ORBEX file was read-in using 
% read_orbex.m
%
% INPUT:
%   Ttr         [sow], time of signal transmission
%   prn         raPPPid satellite number 
%   ATT         struct, attitude data from ORBEX file (input.ORBCLK.OBX.ATT)
% OUTPUT:
%	...
%
% Revision:
%   ...
%
% This function belongs to raPPPid, Copyright (c) 2025, M.F. Wareyka-Glaner
% *************************************************************************


% initialize satellite orientation and quaternions
SatOr_ECEF = NaN(3,3);
q0 = []; q1 = []; q2 = []; q3 = [];


% calculate time difference between tranmission time and ORBEX time stamps
dt = abs(Ttr - ATT.sow);


% check if nearest attitude information is closer than 0.5 seconds
if min(dt) < 0.5       
    % avoid interpolation, simply take nearest satellite attitude information
    idx = (dt == min(dt));
    q0 = ATT.q0(idx, prn);
    q1 = ATT.q1(idx, prn);
    q2 = ATT.q2(idx, prn);
    q3 = ATT.q3(idx, prn);

else
    % interpolate between two nearest attitude data entries
    dtt = Ttr - ATT.sow;
    idx1 = find(dtt > 0, 1, 'last');        % index of last attitude
    idx2 = find(dtt < 0, 1, 'first');       % index of next attitude
    % calculate interval fraction
    f = (Ttr - ATT.sow(idx1)) / (ATT.sow(idx2) - ATT.sow(idx1));
    % get last and next quaternion
    quat_1 = [ATT.q0(idx1,prn) ATT.q1(idx1,prn) ATT.q2(idx1,prn) ATT.q3(idx1,prn)];
    quat_2 = [ATT.q0(idx2,prn) ATT.q1(idx2,prn) ATT.q2(idx2,prn) ATT.q3(idx2,prn)];
    if ~isempty(quat_1) && ~isempty(quat_2)
        try
            % 'quatinterp' requires Aerospace Toolbox
            quat = quatinterp(quat_1, quat_2, f, 'slerp');
        catch
            % dirty implementation as replacement
            quat = QuaternionsSLERP(quat_1, quat_2, dtt(idx1), dtt(idx2));
        end
        q0 = quat(1); q1 = quat(2); q2 = quat(3); q3 = quat(4);        
    end
end


% calculate satellite orientation from quaternions
if ~isempty(q0) && ~isempty(q1) && ~isempty(q2) && ~isempty(q3)
    SatOr_ECEF = Quaternion2Matrix(q0(1), q1(1), q2(1), q3(1))';
end