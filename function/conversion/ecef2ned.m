function ned = ecef2ned(coord_ecef, ref_ecef, lambda, phi)
%ECEF2NED convertit des coordonnees ECEF en NED
%   coord_ecef: tableau de coordonnees a convertir [N, 3]
%   ref_ecef  : point de reference en ecef [x, y, z]
%   lambda    : latitude du point de reference
%   phi       : longititude du point de reference
    
    transfer_mat = [-sin(lambda)*cos(phi), -sin(lambda)*sin(phi), cos(lambda);
                    -sin(phi),              cos(phi),             0;
                    -cos(lambda)*cos(phi), -cos(lambda)*sin(phi), -sin(lambda)];
    
    ned = transfer_mat * (coord_ecef - ref_ecef);
end
