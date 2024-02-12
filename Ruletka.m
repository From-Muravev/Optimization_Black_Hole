function res = Ruletka(P, cur_gen, n)
    % Крутим, чтобы выпало какое-то значение
    random_prob = rand(1,n,'single');
    res = [];
    % Находим значение победителя
    for i = drange(1:n)
        x = find_winner(random_prob(i), 1, P);
        res = [res; x{1}];
    end

    function winner = find_winner(random_prob_cur, i, P)
        if random_prob_cur <= Sum_up_to_i(P, i)
            winner = {cur_gen(i,:)};
        else
            winner = find_winner(random_prob_cur, i + 1, P);
        end
    end
end
