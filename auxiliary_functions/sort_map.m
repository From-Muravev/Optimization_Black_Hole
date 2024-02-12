function [output, keys_map, values_map] = sort_map (input, options)
    arguments
        input containers.Map; 
        options.order char = "values"; 
        options.reverse logical = 0; 
    end
    k = keys(input); 
    v = cell2mat(values(input)); 
    
    % Default return
    output = input; 
    keys_map = k; 
    values_map = v; 
    
    if (options.order == "keys")
        [k_new, order] = sort(k); 
        if (options.reverse == 1)
            k_new = flip(k_new); 
            order = flip(order); 
        end
        v_new = v(order); 
        output = containers.Map(k_new, v_new); 
        keys_map = k_new; 
        values_map = v_new; 
    elseif (options.order == "values")
        [v_new, order] = sort(v); 
        if (options.reverse == 1)
            v_new = flip(v_new); 
            order = flip(order); 
        end
        k_new = k(order); 
        output = containers.Map(k_new, v_new); 
        keys_map = k_new; 
        values_map = v_new; 
    end
    
end

