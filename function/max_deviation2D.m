function deviation = max_deviation2D(x1, x2)
    diff.x = abs(x1(1, :) - x2(1, :));  % distance au centre selon x
    diff.y = abs(x1(2, :) - x2(2, :));  % distance au centre selon x
    distance = sqrt(diff.x.^2 + diff.y.^2);
    maxi = max(distance);

    diff2D = x1(1:2, :) - x2(1:2, :);
    deviation.N1   = max(vecnorm(diff2D, 1));
    deviation.N2   = max(vecnorm(x1(1:2, :) - x2(1:2, :), 2));
    deviation.Ninf = max(vecnorm(diff2D, Inf));
    ;
end
