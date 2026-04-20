function fixed = HMW_fixing(HMW, Epoch, elev, intv, settings, fixed)
% Fixes the SD WL ambiguities with the corresponding the HMW LC and moving 
% average.
% 
% INPUT:
%   HMW        	n x 410, Hatch-Melbourne-Wübbena LC [cyc]
%   Epoch       struct, epoch-specific data for current epoch
%   elev	    sats x 1, vector, elevation of satellites [°]
%   intv    	interval of observations [s]
%   settings    struct, processing settings
%   fixed       410 x 1, fixed SD WL ambiguities (e.g., EW, WL)
% OUTPUT:
%   fixed   	410 x 1, updated with fixed (or released) SD WL ambiguities
% 
% Revision:
%   2026/03/09, MFWG: improving code for fwd-bwd and readability
% 
% This function belongs to raPPPid, Copyright (c) 2023, M.F. Glaner
% *************************************************************************


%% Preparations

n = size(HMW,1);                                % number of epochs of HMW LC
eps2fix = settings.AMBFIX.HMW_window/intv;      % consider HMW fixing window

% make sure that HMW is sorted over epochs in the case of backwards first
if ~Epoch.bool_2nd && (strcmp(settings.ADJ.filter.direction, 'Backwards') || strcmp(settings.ADJ.filter.direction, 'Bwd-Fwd'))
    HMW = flipud(HMW);
end

% check if more HMW LC epochs available than fixing window
if n > eps2fix
    % if ~Epoch.bool_2nd
        from = n - eps2fix;
        to = n;
    % elseif Epoch.bool_2nd
    %     % second run
    %     from = Epoch.q;
    %     to = Epoch.q + eps2fix;
    %     if to > n
    %         % the epoch with the change of filter direction is within fixing window
    %         from = n - eps2fix;
    %         to = n;
    %     end
    % end
    HMW = HMW(from:to, : );         % cut out relevant part of HMW matrix
end




%% call fixing function

% GPS
if settings.INPUT.use_GPS && any(Epoch.gps) && Epoch.refSatGPS ~= 0
    fixed = fix_EW_MW(HMW, Epoch.sats(Epoch.gps), Epoch.refSatGPS, elev(Epoch.gps), settings, fixed);
end
% Galileo
if settings.INPUT.use_GAL && any(Epoch.gal) && Epoch.refSatGAL ~= 0
    fixed = fix_EW_MW(HMW, Epoch.sats(Epoch.gal), Epoch.refSatGAL, elev(Epoch.gal), settings, fixed);
end
% BeiDou
if settings.INPUT.use_BDS && any(Epoch.bds) && Epoch.refSatBDS ~= 0
    fixed = fix_EW_MW(HMW, Epoch.sats(Epoch.bds), Epoch.refSatBDS, elev(Epoch.bds), settings, fixed);
end
% QZSS
if settings.INPUT.use_QZSS && any(Epoch.qzss) && Epoch.refSatQZS ~= 0
    fixed = fix_EW_MW(HMW, Epoch.sats(Epoch.qzss), Epoch.refSatQZS, elev(Epoch.qzss), settings, fixed);
end




function fixed = fix_EW_MW(HMW, prns, refSat, elev, settings, fixed)
% INPUT:
%   HMW        	n x 410, Hatch-Melbourne-Wübbena LC [cyc]
%   prns        sats x 1, satellites of current GNSS and epoch
%   refSat	    reference satellite of current GNSS
%   elev    	interval of observations [s]
%   n           number of epochs with HMW data
%   settings    struct, processing settings
%   fixed       410 x 1, fixed SD WL ambiguities (e.g., EW, WL)
% OUTPUT:
%   fixed   	410 x 1, updated with fixed (or released) SD WL ambiguities
% *************************************************************************


% preparations
cutoff = settings.AMBFIX.cutoff;
HMW_refSat = HMW(:,refSat);         % collected HMW LC of reference satellite
HMW_gnss = HMW(:, prns);            % extract only relevant satellites
n = size(HMW_gnss, 1);              % number of epochs with HMW data

% replace zeros with NaN for reference satellite and other satellites
HMW_refSat(HMW_refSat == 0) = NaN;
HMW_gnss(HMW_gnss == 0)     = NaN;


% condition which satellites are of interest for fixing:
% 1) satellites should have more than half MW-observations 
sum_nan = sum(isnan(HMW_gnss));
remove = ( sum_nan > n/2 );
% 2) satellites which are under fixing cutoff
remove = remove | ( elev < cutoff )';
% 3) satellites where HMW LC of current epoch is NaN
remove = remove | isnan(HMW_gnss(end,:));
% exclude these satellites:
prns(remove) = [];
HMW_gnss(:, remove) = [];


% calculate average
HMW_SD = HMW_refSat - HMW_gnss;             % collected HMW LC single differenced to reference satellite
%     std_MW = std(MW_SD, 'omitnan');               % stdev of collected HMW LC, [cycles]
mean_HMW = mean(HMW_SD, 'omitnan');         % mean of collected HMW LC, [cycles]
HMW_round = round(mean_HMW);                % rounded mean of collected HMW LC
dist_round = abs(mean_HMW - HMW_round);   	% distance mean to rounded mean
dist_HMW = abs(mean_HMW' - fixed(prns));    % distance to current EW fix


% look for satellites to fix or release the EW ambiguity
already_fixed = ~isnan(fixed(prns));        % prns of already fixed gps satellites
release =  already_fixed & dist_HMW    > settings.AMBFIX.HMW_release;
fix_now = ~already_fixed' & dist_round < settings.AMBFIX.HMW_thresh;
% fix or release ambiguity
fixed(prns(release)) = NaN;
fixed(prns(fix_now)) = HMW_round(fix_now);


% loop to print message to command window
if ~settings.INPUT.bool_parfor && (any(fix_now) || any(release))
    for i = 1:numel(prns)
        if release(i)
            fprintf('\tHMW LC Fix for PRN %03d released (THRESHOLD exceeded)...                 \n', prns(i));
        end
    end
end

