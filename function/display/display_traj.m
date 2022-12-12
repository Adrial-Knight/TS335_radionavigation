function display_traj(estimation, location, fig_name)
    figure("Name", fig_name)
    hold on
    plot(location(1,:), location(2, :), Color="#D95319")
    plot(estimation(1, :), estimation(2, :), Color="#127BCA")
    xlabel("X")
    ylabel("Y")
    legend(["Réelle", "Estimée"], "Location", "best")
end
