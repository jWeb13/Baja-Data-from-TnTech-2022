% 
%  Copyright (C) 2020 Jeff Webster - All Rights Reserved
%  Contact: Jeff Webster jswebster42@tntech.edu 
% 
%  Instructions: change the line that sets filename to point at your file
%  For example if you have a data file called 'example.csv' in the folder
%  with this script just remove the current line that says
%  "filename = '../data/6-04-22/LOGS/land_mo2.csv';"
%  and replace it with
%  "filename = './example.csv';"
% and when you run it should load and display the gps data
%  there is plenty of other data in these files that isn't plotted by this
%  script, but you can see what data it is by the 2nd row has descriptions of 
%  the data listed in order
% Data files with a number followed by .csv are raw data files pulled from
% the ecu and other data files have been trimmed and named accordingly to
% the event that they came from.


clear all, close all, clc

filename = '../data/6-04-22/LOGS/land_mo2.csv'; 
[~, ~, data] = xlsread(filename);
version = 0;
if (data{1, 1} == 'version:')
    version = data{1, 2};
end
fprintf("Data file version: %d\n", version);
set(0, 'DefaultFigureRenderer', 'painters');
set(0,'DefaultFigureWindowStyle','normal'); % Undock all figures.
set(0,'DefaultFigureColor','w'); % Set default figure background color.
set(0,'DefaultLineLineWidth',1); % Set default line size.
set(0,'DefaultAxesFontSize',12); % Set default axes font size.
set(0,'DefaultTextFontSize',12); % Set default text font size.
set(0,'DefaultLineMarkerSize',10); % Set default marker size.
set(0,'DefaultAxesFontWeight','bold'); % Set the default axes font to bold.
set(0,'DefaultTextFontWeight','bold'); % Set the default text font to bold.

if (version > 2) %After version 2 we include column headers
    Array=csvread(filename, 2, 0); 
elseif (version > 0)
    Array=csvread(filename, 1, 0); 
else
    Array=csvread(filename); 
end
primaryRPM = Array(:, 2);
start = 1;
limit = length(Array);

timeRange = start:limit;
time = Array(timeRange, 1)*0.001;
primaryRPM = Array(:, 2);
secondaryRPM = Array(:, 3);
tireSize = 22.2
final_drive_ratio = 7.4;
speed = secondaryRPM .* ((tireSize * 0.5 * 0.00595)/(final_drive_ratio));

if (version >= 4)
    latitude = Array(timeRange, 23);
    longitude= Array(timeRange, 24);
    altitude = Array(timeRange, 25);
    gpsSpeed = Array(timeRange, 26);
end
    
fig = figure('Name','Engine RPM');
ax(1) = subplot(1, 1, 1);
ZoomHandle = zoom(fig);
set(ZoomHandle,'Motion','horizontal')
plot(time, primaryRPM), hold on;
grid on;
ylabel("Engine Shaft Speed (rpm)");
xlabel("time (s)");

fig = figure('Name','Vehicle Speed');
ax(2) = subplot(1, 1, 1);
ZoomHandle = zoom(fig);
set(ZoomHandle,'Motion','horizontal')
plot(time, speed), hold on;
plot(time, gpsSpeed), hold on;
grid on;
ylabel("Engine Shaft Speed (rpm)");
xlabel("time (s)");
legend('wheel speed', 'gps');

lat(1) = latitude(1);
lon(1) = longitude(1);
alt(1) = altitude(1);
t(1) = time(1);
sp(1) = gpsSpeed(1);
for i=2:limit-start
    if (latitude(i) ~= latitude(i-1))
        lat(length(lat)+1) = latitude(i);
        lon(length(lon)+1) = longitude(i);
        alt(length(alt)+1) = altitude(i);
        t(length(t)+1) = time(i);
        sp(length(sp)+1) = gpsSpeed(i);
    end
end

smoothLat = interp1(1:length(lat), lat, 1:0.05:length(lat));
smoothLon = interp1(1:length(lon), lon, 1:0.05:length(lon));
smoothAlt = interp1(1:length(alt), alt, 1:0.05:length(alt));
st = interp1(1:length(time), time, 1:0.05:length(time));
ssp = interp1(1:length(sp), sp, 1:0.05:length(sp));
figure('Name', '3D GPS Speed Heatmap');
colormap jet
hold off;
s = scatter3(smoothLat, smoothLon, smoothAlt, 2, ssp);
hold on;
plot3(smoothLat, smoothLon, smoothAlt);
a = colorbar;
a.Label.String = 'Speed (mph)';
xlabel("latitude"), ylabel("longitude"), zlabel("altitude (m)")

datatipRow = dataTipTextRow('time',st);
altitudeDatatipRow = dataTipTextRow('altitude(m)',smoothAlt);
speedDatatipRow = dataTipTextRow('speed',ssp);
s.DataTipTemplate.DataTipRows(end+1) = datatipRow;
s.DataTipTemplate.DataTipRows(end+2) = altitudeDatatipRow;
s.DataTipTemplate.DataTipRows(end+3) = speedDatatipRow;
set(gca, 'Xdir', 'reverse')

linkaxes(ax, 'x');

%%
figure('Name', 'Satelite View');
s = geoplot(lat,lon,'-*');
datatipRow = dataTipTextRow('time',t);
altitudeDatatipRow = dataTipTextRow('altitude',alt);
speedDatatipRow = dataTipTextRow('speed',sp);
s.DataTipTemplate.DataTipRows(end+1) = datatipRow;
s.DataTipTemplate.DataTipRows(end+2) = altitudeDatatipRow;
s.DataTipTemplate.DataTipRows(end+3) = speedDatatipRow;
geobasemap satellite

% uif = uifigure;
% g = geoglobe(uif);
% geoplot3(g,lat,lon,alt,'c')
