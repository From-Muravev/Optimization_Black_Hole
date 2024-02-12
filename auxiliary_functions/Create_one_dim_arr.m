function rand_arr = Create_one_dim_arr(size, lim)
    arguments
        size = 18;
        lim = 1;
    end
    switch lim
        case 1
            rand_arr = randi([0, 1], [1, size]);
        case 10
            rand_arr =  10.*rand(size,1);
            rand_arr = transpose(rand_arr(:));
    end
end

