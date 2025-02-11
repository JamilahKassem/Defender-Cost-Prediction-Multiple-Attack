function [result] = find_permutation(m)
i = 1;
result(i).attacked_node = 1:m;
i = 2;
for max_step = 1:m-1
    hit_count = m-max_step;
    indices = 1:hit_count;
    result(i).attacked_node = indices;
    i = i + 1;
    shift = zeros(hit_count,1);
    current_shift = 1;
    while shift(hit_count) < max_step
        shift(current_shift) = shift(current_shift) + 1;
        while shift(current_shift) > max_step
            current_shift = current_shift + 1;
            shift(current_shift) = shift(current_shift) + 1;
        end
        temp = current_shift;
        while current_shift > 1
            current_shift = current_shift - 1;
            shift(current_shift) = shift(temp);
        end
        indices_iteration = indices + flip(shift)';
        result(i).attacked_node = indices_iteration;
        i = i + 1;
    end
end
end