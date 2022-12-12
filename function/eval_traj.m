function [XYZ, DOP] = eval_traj(ref, sat, PRN)
%EVAL_TRAJ estime la trajectoire d'une cible a partir de donnees GPS
%   ref: point de références en coordonnées cartésiennes ECEF [x, y, z]
%   sat: enregistrements xyz des satellites [satellite, 3, echantillons]
%   PRN: (Pseudo Random Noise), pseudo-distance GPS

    T = length(PRN);     % nombre d'echantillons disponnbles
    X = zeros(4, T+1);   % vecteur d'etat [x, y, z, b]
    X(:, 1) = [ref.ecef.', 0];  % la reference avec un biais horloge nul

    % Dilution Of Precision
    DOP = struct("DOP", zeros(1, T), "PDOP", zeros(1, T), ...
                "VDOP", zeros(1, T), "HDOP", zeros(1, T));

    % Matrice de passage ECEF -> NED pour la matrice H
    lambda = ref.llh(1);
    phi = ref.llh(2);
    P = [-sin(lambda)*cos(phi),  sin(lambda)*sin(phi), -cos(lambda), 0;
          sin(phi),              cos(phi),              0,           0;
          cos(lambda)*cos(phi), -cos(lambda)*sin(phi), -sin(lambda), 0;
          0,                     0,                     0,           1];
    
    for t = 1:T
        % extraction des donnees utiles pour l'instant t
        xyz.rec = X(1:3, t);      % position precedente t-1 (decalage init)
        xyz.sat = sat(:, :, t)';  % positions cartesiennes des satellites
        prn = PRN(:, t);          % pseudo distances GPS de la cible
        
        % satellites valides
        valid_sat = ~isnan(prn);
        nb_valid  = sum(valid_sat);
        xyz.sat   = xyz.sat(:, valid_sat);
        prn       = prn(valid_sat);
        
        % linéarisation
        % -- ordre 0
        h0 = vecnorm(xyz.rec - xyz.sat).';
        
        % -- ordre 1
        diff = xyz.rec - xyz.sat;
        r = vecnorm(diff);
        H = [diff./r; ones(1, nb_valid)];
    
        % estimation de la position et du biais
        Z = prn - h0 + H.' * X(:, t);
        X(:, t+1) = Z.' * pinv(H);

        % evaluation des DOP
        G = P.'*H;               % matrice H convertie dans le repere NED
        D = diag(inv(G*G.'));  % elements diagonnaux de (H^T H)^-1 en NED      
        DOP.DOP(t)  = sqrt(sum(D));
        DOP.PDOP(t) = sqrt(sum(D(1:3)));
        DOP.HDOP(t) = sqrt(D(1) + D(2));
        DOP.VDOP(t) = sqrt(D(3));
    end

    % Extraction des resultats: retire le point de reference et le biais
    XYZ = X(1:3, 2:end);  % positions cartesiennes estimee de la cible
end
