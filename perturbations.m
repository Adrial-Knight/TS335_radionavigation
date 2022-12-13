%% Init 
close all; clear; clc; dbstop if error;
addpath("function", "function/conversion", "data");
[sat, PRN, Xloc] = load_data("donnees_GPS_TP", "trajectoire_TP");

%% Parametres
% -- variance du  bruit: interferences
sigma2 = linspace(0, 1e6, 100);
Nsim   = 1;  % nombre de repetition de la simulation (lisser la courbe)

% -- bias sur un satellite
bias  = linspace(-3000, 5000, 100);
sat_bias = 4;  % entre 1 et 8

%% Estimation de trajectoires interferees
% -- coordonnees du point de reference en llh et ECEF (Centre_terre,x,y,z)
ref.llh  = [deg2rad(44+48/60); deg2rad(-35/60); deg2rad(0)];  % Talence
ref.ecef = llh2xyz(ref.llh).';

% -- comparaison avec le veritable trajet en coordonnes ECEF
Xloc.ecef = ned2ecef(Xloc.ned, ref.ecef, ref.llh(1), ref.llh(2));

% -- estimations des erreurs dues aux interferences
N = length(sigma2);
loss.interf = zeros(1, N);
for i = 1:N
    for j = 1:Nsim
        PRN_interf  = PRN + sqrt(sigma2(i)) * randn(size(PRN));
        target.ecef = eval_traj(ref, sat.ecef, PRN_interf);
        loss.interf(i) = loss.interf(i) + norm(target.ecef - Xloc.ecef);
    end
    loss.interf(i) = loss.interf(i) / Nsim;
end

% -- estimations des erreurs dues aux multi-trajets
M = length(bias);
loss.multi = zeros(1, M);
for i = 1:M
    PRN_multi_t = PRN;
    PRN_multi_t(sat_bias, :) = PRN(sat_bias, :) + bias(i);
    target.ecef = eval_traj(ref, sat.ecef, PRN_multi_t);
    loss.multi(i) = norm(target.ecef - Xloc.ecef);
end

%% Affichage
close all
figure("Name", "Interferences")
plot(sigma2, loss.interf, Color="#127BCA")
grid
xlabel("Variance du bruit de mesure")
ylabel("Erreur quadratique")

figure("Name", "Multi-trajets")
plot(bias, loss.multi, Color="#127BCA")
grid
xlabel("Biais sur le satellite " + sat_bias)
ylabel("Erreur quadratique")
