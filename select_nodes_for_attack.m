function [iteration_probabilities,Targeted_nodes,Number_of_nodes] = select_nodes_for_attack(alpha,n,target_node)
if target_node > n
    target_node = n;
end
Number_of_nodes = 1;
iteration_probabilities = ones(1,1);
Targeted_nodes = ones(1,1) * target_node;
end

