function P = P_calc(F,F_abs)
    size_F = size(F);
    for i = drange(1:size_F(2))
        P(i) = abs(F(i)/sum(F_abs));
    end
end

