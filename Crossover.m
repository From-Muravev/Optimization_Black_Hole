function res = Crossover(res_ruletka)
    res = [];
    size_res_ruletka = size(res_ruletka);
    n_children = size_res_ruletka(1)/2;
    P = get_P(size_res_ruletka(1));
    for iterations = 1:n_children
        % Ищем двух родителей
        cur_par_all = Ruletka(P, res_ruletka, 2);
        % Сейчас у нас просто 2 хромосомы
        % Для кроссовера у нас два алгоритма:
        % 1. Для массивов
        % 2. Для целочисленных значений
        % Поэтому мы транспонируем, чтобы отделить одно от другого
        
        % Для того, чтобы этот массив потом транспонировать обратно
        before_res = [];
        num_item = 1;
        for items_of_cur_par = cur_par_all
            % Сейчас item - либо все рациональные числа х_i, либо массив 0 и 1
            if length(items_of_cur_par{1}) == 18
                % Создаем маску
                a1 = Create_one_dim_arr();
                a2 = [];
                for j = 1:length(a1)
                    if a1(j) == 0
                        a2(end + 1) = 1;
                    else
                        a2(end + 1) = 0;
                    end
                end
                % Применяем маску
                y1 = [];
                y2 = [];
                item_from_first = items_of_cur_par{1};
                item_from_second = items_of_cur_par{2};
                for j = drange(1:18)
                    y1(end+1) = item_from_first(j) * a1(j) + item_from_second(j) * a2(j);
                    y2(end+1) = item_from_second(j) * a1(j) + item_from_first(j) * a2(j);
                end
            else
                % Создаем маску
                a1 = rand*(1);
                item_from_first = items_of_cur_par{1};
                item_from_second = items_of_cur_par{2};
                % Применяем маску
                y1 = a1*item_from_first + (1-a1)*item_from_second;
                y2 = (1-a1)*item_from_first + a1*item_from_second;
            end
            before_res = [before_res; {y1 y2}];
            num_item = num_item + 1;
        end
        res = [res;transpose(before_res)];
    end
end

function P = get_P(size_array)
    r = rand(1, size_array);
    P = r / sum(r);
end
