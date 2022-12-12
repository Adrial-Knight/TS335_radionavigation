%% Init 
close all; clear; clc; dbstop if error;
addpath("function", "function/conversion", "function/display", "data");
[sat, PRN, Xloc] = load_data("donnees_GPS_TP", "trajectoire_TP");

%% Estimation de la trajectoire
% -- coordonnees du point de reference en llh et ECEF (Centre_terre,x,y,z)
ref.llh  = [deg2rad(44+48/60); deg2rad(-35/60); deg2rad(0)];  % Talence
ref.ecef = llh2xyz(ref.llh).';

% -- estimation
[target.ecef, DOP] = eval_traj(ref, sat.ecef, PRN);

%% Conversion des coordonnees pour affichage / comparaison
target.ned = ecef2ned(target.ecef, ref.ecef, ref.llh(1), ref.llh(2));
Xloc.ecef  = ned2ecef(Xloc.ned, ref.ecef, ref.llh(1), ref.llh(2));
deviation  = max(vecnorm(Xloc.ned(1:2, :) - target.ned(1:2, :), 2));

%% Affichage
close all
% -- trajectoires
display_traj(target.ned, Xloc.ned, "Coordonnees NED")
display_traj(target.ecef,Xloc.ecef,"Coordonnees ECEF")

fprintf("Ecart maximal: " + deviation + "m\n")

% -- DOP, PDOP, VDOP et HVOP
display_DOP(DOP)
