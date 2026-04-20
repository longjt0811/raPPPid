function Epoch = cycleSlip_TimeDiff(Epoch, use_column, settings)
% This function detects cycle slips with differencing the last epochs. For
% example, triple-differencing might be reasonable. Implemented only for
% single-frequency processing, use dLi-dLi difference otherwise.
%
% INPUT:
%   settings        settings of processing from GUI
%   Epoch           data from current epoch
%   use_column      columns of used observation, from obs.use_column
% OUTPUT:
%   Epoch       updated with detected cycle slips
%
% Revision:
%   2023/11/03, MFWG: adding QZSS
%
% This function belongs to raPPPid, Copyright (c) 2023, M.F. Glaner
% *************************************************************************


%% Preparations
nominal_dt = 0.5;                              % expected time step (s)
thresh_m = settings.OTHER.CS.TD_threshold;   % threshold

% get raw phase-observations on 1st frequency for current epoch [m]
L1_gps  = Epoch.obs(Epoch.gps,  use_column{1,1});
L1_glo  = Epoch.obs(Epoch.glo,  use_column{2,1});
L1_gal  = Epoch.obs(Epoch.gal,  use_column{3,1});
L1_bds  = Epoch.obs(Epoch.bds,  use_column{4,1});
L1_qzss = Epoch.obs(Epoch.qzss, use_column{5,1});
L1  = [L1_gps; L1_glo; L1_gal; L1_bds; L1_qzss];

if ~settings.INPUT.rawDataAndroid
    % convert phase to [m] if necessary (e.g., RINEX file)
    lambda_1 = Const.C ./ Epoch.f1;     % wavelength [m]
    L1 = L1 .* lambda_1;                % convert from [cy] to [m]
end


%% Handle necessary variables
% move phase observations and time of past epochs "down"
Epoch.cs_phase_obs(2:end,:) = Epoch.cs_phase_obs(1:end-1,:);
Epoch.cs_time_obs(2:end,:) = Epoch.cs_time_obs(1:end-1,:);

% delete old values
Epoch.cs_phase_obs(1,:) = NaN;
Epoch.cs_time_obs(1,:) = NaN;

% save phase observations and time of current epoch
Epoch.cs_phase_obs(1,Epoch.sats) = L1;
Epoch.cs_time_obs(1, Epoch.sats) = Epoch.gps_time;

% set zeros to NaN to be on the safe side during differencing (e.g.,
% observation could be 0 in the RINEX file)
Epoch.cs_phase_obs(Epoch.cs_phase_obs==0) = NaN;




%% Perform cycle-slip detection
if ~settings.KINE.satellite.bool

    % build time difference
    phase_epoch = Epoch.cs_phase_obs(:,Epoch.sats);
    L_diff_n = diff(phase_epoch, settings.OTHER.CS.TD_degree,1);

    % check if time difference is above specified threshold
    cs_found = abs(L_diff_n) > thresh_m;

    % if a cycle slip is found delete the phase observations of the last epochs
    % otherwise also in the next few epochs a cycle slip is detected
    % Epoch.cs_phase_obs(:,Epoch.sats(cs_found)) = NaN;

    % save detected cycle slips
    Epoch.cs_found = Epoch.cs_found | cs_found';

    % save L1 time difference
    Epoch.cs_L1_diff = L_diff_n;

else    

    Y  = Epoch.cs_phase_obs(:, Epoch.sats);
    T  = Epoch.cs_time_obs(:,  Epoch.sats);
    Ns = size(Y,2);

    % Residuals (difference for slip detection)
    L_diff_n = NaN(1, Ns);
    for j = 1:Ns
        y = flipud(Y(:,j));
        t = flipud(T(:,j));
        v = find(~isnan(y) & ~isnan(t));
        if numel(v) < 5
            continue
        end

        i  = v(end);
        k0 = v(end-1);  k1 = v(end-2);  k2 = v(end-3);  k3 = v(end-4);
        t0=t(k0); ti=t(i);
        y0=y(k0); yi=y(i);
        t_prev = [t(k3); t(k2); t(k1); t0];
        y_prev = [y(k3); y(k2); y(k1); y0];

        t0c  = t_prev(1);
        tt   = t_prev - t0c;
        tti  = ti - t0c;
        p    = polyfit(tt, y_prev, 2);
        yhat = polyval(p, tti);

        L_diff_n(j) = yi - yhat;   % meters
    end

    cs_found = false(1, Ns);
    for j = 1:Ns
        if ~isnan(L_diff_n(j))
            dt = T(1,j) - T(2,j);  % step (s) from newest two epochs
            if isnan(dt) || dt <= 0, dt = nominal_dt; end
            local_thresh = thresh_m * (dt/nominal_dt);   % scale

            cs_found(j)  = abs(L_diff_n(j)) > local_thresh;
        end
    end

    if any(cs_found)
        slipped = find(cs_found);
        for jj = slipped
            gcol = Epoch.sats(jj);       % global sat index
            res  = L_diff_n(jj);         % residual in meters
            fprintf('Cycle Slip by Time Difference Method at epoch %d\n', Epoch.q);
            fprintf('For Sat %d, with residual = %.3f m\n', gcol, res);
        end
    end

    Epoch.cs_L1_diff = L_diff_n;
    Epoch.cs_found = Epoch.cs_found | cs_found';

    % Clearing past history for sats that slipped
    if any(cs_found)
        slipped = find(cs_found);
        for jj = slipped
            gcol = Epoch.sats(jj);
            Epoch.cs_phase_obs(2:end, gcol) = NaN;
            Epoch.cs_time_obs(2:end,  gcol) = NaN;
        end
    end

end