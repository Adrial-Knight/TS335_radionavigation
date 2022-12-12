function display_DOP(DOP)
    figure("Name", "DOP")
    hold on
    dop_field = fieldnames(DOP);
    for i = 1:length(dop_field)
        plot(DOP.(dop_field{i}))
    end
    grid
    xlabel("t")
    axis tight
    legend(dop_field)
end
