function ecef = ned2ecef(coord_ned, ref_ecef, lambda, phi)
%ECEF2NED convertit des coordonnees NED en ECEF
%   coord_ned: tableau de coordonnees a convertir [N, 3]
%   ref_ned  : point de reference en ned [x, y, z]
%   lambda   : latitude du point de reference
%   phi      : longititude du point de reference

    transfer_mat = [-sin(lambda)*cos(phi), sin(phi),  cos(lambda)*cos(phi);
                     sin(lambda)*sin(phi), cos(phi), -cos(lambda)*sin(phi);
                    -cos(lambda),          0,        -sin(lambda)];
    
    ecef = transfer_mat * coord_ned + ref_ecef;
end
