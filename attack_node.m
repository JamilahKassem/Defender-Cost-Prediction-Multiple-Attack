cost_attack_current = 0;
% if attacked_node > n
%     attacked_node = n;
% end
%% ------------------------- create new state start -------------------------
next_state_stack(number_next_states) = state;
next_state_stack(number_next_states).R = R;
next_state_stack(number_next_states).iteration_probability = iteration_probability;
next_state_stack(number_next_states).activated_alpha = activated_alpha(:,1:n~=attacked_node);
next_state_stack(number_next_states).alpha = alpha(:,1:n~=attacked_node);
%% -------------------------- create new state end --------------------------
% count the number of resources that might get hit
possible_hit_resources_count = nnz(alpha(:,attacked_node) ~= 0 & alpha(:,attacked_node) ~= 1);
if possible_hit_resources_count ~= 0
    hit_resources_set = createArray(1,possible_hit_resources_count,"hit_resources");
end
k = 1;
% counter for resources that might get hit
%% ---------------------- create attacked resources set start----------------
for j = 1:m
    if alpha(j,attacked_node) ~= 0
        if alpha(j,attacked_node) == 1
            cost_attack_current = cost_attack_current + R(j) * iteration_probability * Data.Ca;
        else
            % store data of all resources that might get hit
            hit_resources_set(k).alpha = alpha(j,attacked_node);
            hit_resources_set(k).criticality = R(j);
            hit_resources_set(k).index = j;
            k = k + 1;
        end
    end
end
%% ---------------------- count attacked resources set end-------------------

%% ------------------------------ debug states start-------------------------
if Data.debug
    fprintf(Data.fileID,"added state (%d,%d) [",attack_counter,number_next_states);
    first = true;
    for d2 = 1:m
        text = strtrim(rats(next_state_stack.R(d2)));
        if first
            first = false;
            fprintf(Data.fileID,"%s",text);
        else
            fprintf(Data.fileID,',%s',text);
        end
    end
    fprintf(Data.fileID,']\n');
end
%% ------------------------------ debug states end---------------------------

%% --------------------------- Permutations loop start-----------------------
if possible_hit_resources_count ~= 0
    Permutation = find_permutation(possible_hit_resources_count);
    % create permutations depending on number of attacked resources
    Number_of_permutation = size(Permutation,2);
    % initialize state array add one for miss state
    %% --------------------------- debug permutations start----------------------
    if Data.debug
        fprintf(Data.fileID,'attack permutations [');
        for d1 = 1:Number_of_permutation
            attacked_resources = Permutation(d1).attacked_node;
            fprintf(Data.fileID,"[");
            first = true;
            for d2 = 1:size(attacked_resources,2)
                d3 = attacked_resources(d2);
                if first
                    first = false;
                    fprintf(Data.fileID,"%d",hit_resources_set(d3).index);
                else
                    fprintf(Data.fileID,',%d',hit_resources_set(d3).index);
                end
            end
            fprintf(Data.fileID,']');
        end
        fprintf(Data.fileID,']\n');
    end
    %% --------------------------- debug permutations end------------------------
    %% ---------------------- iterate through permutations start-----------------
    % initialize probability to one since the total probability is the
    % product of all cases in permutation
    permutation_probability = ones(Number_of_permutation,1);
    for j = 1:Number_of_permutation
        attacked_resources1 = Permutation(j).attacked_node;
        total_attacked_criticality = 0;
        for k = 1:size(attacked_resources1,2)
            r1 = hit_resources_set(attacked_resources1(k)).index;
            total_attacked_criticality = total_attacked_criticality + hit_resources_set(attacked_resources1(k)).criticality;
            % subtract probability of previous permutations before setting hit probability
            if Data.debug
                fprintf(Data.fileID,'alpha %s permutation_probability(j) %s product %s\n',strtrim(rats(alpha(r1,attacked_node))),strtrim(rats(permutation_probability(j))),strtrim(rats(permutation_probability(j) * alpha(r1,attacked_node))));
            end
            permutation_probability(j) = permutation_probability(j) * alpha(r1,attacked_node);
            % permutation probability which is the product of individual probabilities
        end
        for k1 = 1:j-1
            % loop that removes previous probabilities from current
            % depending if the current probability is a part of the
            % previous for example P(A B C) = P(A B C) - P(A B C D) the
            % code itterates through all previous permutations checking if
            % current is part and then subtracts associate probability
            attacked_resources2 = Permutation(k1).attacked_node;
            intersect = true;
            if size(attacked_resources2,2) > size(attacked_resources1,2)
                for k2 = 1:size(attacked_resources1,2)
                    r1 = attacked_resources1(k2);
                    intersect = intersect && ismember(r1, attacked_resources2);
                end
                if intersect
                    if Data.debug
                        fprintf(Data.fileID,'result %s subtracted previous permutation %s\n',strtrim(rats(permutation_probability(j) - permutation_probability(k1))),strtrim(rats(permutation_probability(k1))));
                    end
                    permutation_probability(j) = permutation_probability(j) - permutation_probability(k1);
                end
            end
        end
        % add current cost to total cost
        cost_attack_current = cost_attack_current + total_attacked_criticality * permutation_probability(j) * iteration_probability;
        if Data.debug
            text = strtrim(rats(total_attacked_criticality * permutation_probability(j) * iteration_probability));
            fprintf(Data.fileID,'added cost %s\n',text);
        end
    end
    %% ---------------------- iterate through permutations end-------------------
    %% --------------------------- Permutations loop end-------------------------
end
cost_attack(attack_counter) = cost_attack(attack_counter) + cost_attack_current;
if Data.debug
    text = strtrim(rats(cost_attack_current));
    fprintf(Data.fileID,'added cost %s from attack %d to node %d\n',text,attack_counter,attacked_node);
end