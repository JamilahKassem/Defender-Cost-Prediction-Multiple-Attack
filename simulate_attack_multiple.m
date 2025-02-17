function [cost_attack,cost_defense] = simulate_attack_multiple(Data,total_attacks)
% Simulate all probabilities and cost for an attack on a node given alpha
% returns an array with total cost at each attack

%% ------------------------------- Read Data start---------------------------
n = Data.n;
m = Data.m;
R = Data.R;
%% ------------------------------- Read Data end-----------------------------
cost_attack = zeros(total_attacks,1);
cost_defense = zeros(total_attacks,1);
iteration_probability = 1;
% counter used to itterate through attacks
attack_counter = 1;
% counter used to itterate through states
state_counter = 1;
% nunber of saved states to be itterated though
number_current_states = 1;
% number of states used for next stack
number_next_states = 1;
% total numner of itterations
iteration_counter = 1;
while attack_counter < total_attacks + 1
    if attack_counter ~= 1
        current_state = current_state_stack(state_counter);
        R = current_state.R;
        alpha_previous = current_state.alpha;
        activated_alpha = current_state.activated_alpha;
        iteration_probability = current_state.iteration_probability;
        %% ------------------------------ debug states start-------------------------
        if Data.debug
            fprintf(Data.fileID,'\n-------------------------Started iteration %d for attack %d--------------------------\n',state_counter,attack_counter);
            for number_current_states_debug = state_counter+1:number_current_states
                state_to_print = current_state_stack(number_current_states_debug);
                fprintf(Data.fileID,"remaining state (%d,%d) m = %d probability %s [",attack_counter,number_current_states_debug,state_to_print.m,strtrim(rats(state_to_print.probability)));
                first = true;
                for d2 = 1:state_to_print.m
                    text = strtrim(rats(state_to_print.R(d2)));
                    if first
                        first = false;
                        fprintf(Data.fileID,"%s",text);
                    else
                        fprintf(Data.fileID,',%s',text);
                    end
                end
                fprintf(Data.fileID,']\n');
            end
            fprintf(Data.fileID,'activated alpha\n');
            for d1 = 1:m
                first = true;
                for d2 = 1:n
                    text = activated_alpha(d1,d2);
                    if first
                        first = false;
                        fprintf(Data.fileID,"%d",text);
                    else
                        fprintf(Data.fileID,'%s',convertCharsToStrings(repmat(' ',1,space)));
                        fprintf(Data.fileID,'%d',text);
                    end
                    space = 12 - size(text,2);
                end
                fprintf(Data.fileID,'\n');
            end
        end
        %% ------------------------------ debug states end---------------------------
        state_counter = state_counter + 1;
    end
    %% ------------------------------ debug R start--------------------------
    if Data.debug
        fprintf(Data.fileID,'R size %d set [',m);
        first = true;
        for i = 1:m
            text = strtrim(rats(R(i)));
            if first
                first = false;
                fprintf(Data.fileID,"%s",text);
            else
                fprintf(Data.fileID,",%s",text);
            end
        end
        fprintf(Data.fileID,']\n');
    end
    %% ------------------------------ debug R end----------------------------
    if attack_counter == 1
        alpha = createA(R,n,[],Data);
        % create A matrix
        activated_alpha = alpha ~= 0;
        alpha_backup = create_backup_A(alpha,Data);
        temp = alpha_backup ~= 0;
        activated_alpha = activated_alpha | temp;
    else
        if Data.debug
            fprintf(Data.fileID,'Generating new alpha matrix\n');
        end
        alpha = createA(R,n,activated_alpha,Data);
        % create A matrix
    end
    %% ------------------------------ debug alpha start--------------------------
    if Data.debug
        fprintf(Data.fileID,'alpha\n');
        for i = 1:size(alpha,1)
            first = true;
            for j = 1:size(alpha,2)
                text = strtrim(rats(alpha(i,j)));
                if first
                    first = false;
                    fprintf(Data.fileID,"%s",text);
                else
                    fprintf(Data.fileID,'%s',convertCharsToStrings(repmat(' ',1,space)));
                    fprintf(Data.fileID,'%s',text);
                end
                space = 12 - size(text,2);
            end
            fprintf(Data.fileID,'\n');
        end
    end
    %% ------------------------------ debug alpha end----------------------------
    %% ----------------------------- No bias alpha end---------------------------
    if attack_counter ~= 1
        cost_defense(attack_counter - 1) = cost_defense(attack_counter - 1) + calculate_cost_movement(activated_alpha,alpha,R,Data.Cm);
    end

    temp = alpha ~= 0;
    activated_alpha = activated_alpha | temp;

    [iteration_probabilities,Targeted_nodes,number_of_nodes] = select_nodes_for_attack(alpha,n,Data.target_node);
    % create an array of attacked nodes
    for i = 1:number_of_nodes
        attacked_node = Targeted_nodes(i);
        iteration_counter = iteration_counter + 1;
        iteration_probability = iteration_probabilities(i);
        attack_node;
    end
    %% ------------------------------- debug cost start--------------------------
    if Data.debug
        fprintf(Data.fileID,"Attack cost for attack %d cost [",attack_counter);
        first = true;
        for d1 = 1:total_attacks
            text = strtrim(rats(cost_attack(d1)));
            if first
                first = false;
                fprintf(Data.fileID,"%s",text);
            else
                fprintf(Data.fileID,',%s',text);
            end
        end
        fprintf(Data.fileID,']\n');
        fprintf(Data.fileID,"Defense cost for attack %d cost [",attack_counter);
        first = true;
        for d1 = 1:total_attacks
            text = strtrim(rats(cost_defense(d1)));
            if first
                first = false;
                fprintf(Data.fileID,"%s",text);
            else
                fprintf(Data.fileID,',%s',text);
            end
        end
        fprintf(Data.fileID,']\n');
    end
    %% ------------------------------- debug cost end----------------------------
    if attack_counter == 1 || state_counter > number_current_states
        number_current_states = number_next_states - 1;
        number_next_states = 1;
        current_state_stack = next_state_stack;
        attack_counter = attack_counter + 1;
        state_counter = 1;
        n = n - 1;
    end
end

state_counter = 1;
number_current_states = size(current_state_stack,2);
while state_counter <= number_current_states
    current_state = current_state_stack(state_counter);
    R = current_state.R;
    activated_alpha = current_state.activated_alpha;
    alpha = createA(R,n,activated_alpha,Data);
    %% ------------------------------ debug states start-------------------------
    if Data.debug
        fprintf(Data.fileID,'\n-------------------------Started iteration %d for attack %d--------------------------\n',state_counter,attack_counter);
        for number_current_states_debug = state_counter+1:number_current_states
            state_to_print = current_state_stack(number_current_states_debug);
            fprintf(Data.fileID,"remaining state (%d,%d) m = %d probability %s [",attack_counter,number_current_states_debug,state_to_print.m,strtrim(rats(state_to_print.probability)));
            first = true;
            for d2 = 1:state_to_print.m
                text = strtrim(rats(state_to_print.R(d2)));
                if first
                    first = false;
                    fprintf(Data.fileID,"%s",text);
                else
                    fprintf(Data.fileID,',%s',text);
                end
            end
            fprintf(Data.fileID,']\n');
        end
        fprintf(Data.fileID,'alpha previous\n');
        for d1 = 1:m
            first = true;
            for d2 = 1:n
                text = strtrim(rats(alpha_previous(d1,d2)));
                if first
                    first = false;
                    fprintf(Data.fileID,"%s",text);
                else
                    fprintf(Data.fileID,'%s',convertCharsToStrings(repmat(' ',1,space)));
                    fprintf(Data.fileID,'%s',text);
                end
                space = 12 - size(text,2);
            end
            fprintf(Data.fileID,'\n');
        end
    end
    %% ------------------------------ debug states end---------------------------
    state_counter = state_counter + 1;
    cost_defense(attack_counter - 1) = cost_defense(attack_counter - 1) + calculate_cost_movement(activated_alpha,alpha,R,Data.Cm);
end
if Data.debug
    fprintf(Data.fileID,'Total bumber of iterations %d\n',iteration_counter);
end
end