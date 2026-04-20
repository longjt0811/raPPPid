function [] = MapMoviePlot(lat, lon, bool_true, lat_true, lon_true, station_date, floatfix)
% This function plots the PPP trajectory one epoch after another on a map.
% If available also the reference trajectory is plotted
% 
% INPUT:
%   lat             [°], latitude of PPP trajectory
%   lon             [°], longitude of PPP trajectory
%   bool_true       boolean, true if reference trajectory is available
%   lat_true        [°], latitude of reference trajectory
%   lon_true        [°], longitude of reference trajectory
%   station_date    string, date of the observation
%   floatfix        string, float/fix
% OUTPUT:
%	[]
%
% Revision:
%   ...
%
% This function belongs to raPPPid, Copyright (c) 2025, M.F. Wareyka-Glaner
% *************************************************************************


fig_map = figure('Name','Map Movie Plot', 'units','normalized', 'outerposition',[0 0 1 1], 'NumberTitle','off', 'Color', 'w');

% animation setup
n = numel(lat);     % number of epochs
sec_total = 3;      % total time of animation [s]
sec_pause = sec_total/n;        % duration of pause

% initial plot
h_trajectory = geoplot(lat, lon, '-', 'LineWidth', 2, 'Color', 'r');
title([station_date ', ' floatfix], 'fontsize',11, 'FontWeight','bold')
hold on

% plot reference trajectory
if bool_true
    h_reference = geoplot(lat_true, lon_true, 'ro', 'MarkerSize', 4, 'LineWidth', 1, 'Color', 'g');
end

% highlight first position
h_current = geoplot(lat(1), lon(1), 'bx', 'LineWidth', 2, 'MarkerSize', 10);

% create legend
if bool_true
    legend([h_trajectory h_reference, h_current], {'Trajectory', 'Reference', 'Current Epoch'})
else
    legend([h_trajectory, h_current], {'Trajectory', 'Current Epoch'} )
end

% loop over data points to plot current position and animate movement
for q = 1:n
    set(h_current, 'XData', lat(q), 'YData', lon(q));       % update current position
    pause(sec_pause)
end