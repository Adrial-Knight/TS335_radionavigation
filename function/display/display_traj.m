function display_traj(estimation, location, fig_name)
    figure("Name", fig_name)
    hold on
    plot(estimation(1, :), estimation(2, :), ".", Color="#127BCA")
    plot(location(1,:), location(2, :), Color="#D95319")
    xlabel("X")
    ylabel("Y")
    legend(["Estimée", "Réelle"], "Location", "best")
end
