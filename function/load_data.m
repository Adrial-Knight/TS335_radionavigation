function [sat, PRN, Xloc] = load_data(GPS, traj)
    sat.ecef = load(GPS, "PRN", "XYZsat");
    PRN      = sat.ecef.PRN;
    sat.ecef = sat.ecef.XYZsat;
    
    Xloc.ned = load(traj, "Xloc");
    Xloc.ned = Xloc.ned.("Xloc");
end
