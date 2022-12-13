function display_quadratic_error(x1, x2)
    error = vecnorm(x1 - x2);
    figure("Name", "Erreur quadratique")
    plot(error, Color="#127BCA")
    grid
    axis tight
    xlabel("t");
    fprintf("Ecart maximal: " + max(error) + "m\n")
end
