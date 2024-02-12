function res_sum = Sum_up_to_i(array, i)
    res_sum = 0;
    for j = drange(1:i)
        res_sum = res_sum + array(j);
    end
end

