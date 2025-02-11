function [Movement_cost] = calculate_cost_movement(alpha1,alpha2,R,Cs)
number_resource_moves = alpha1 == 0 & alpha2 ~= 0;
number_resource_moves = sum(number_resource_moves,2)';
Movement_cost = sum(R .*  number_resource_moves) * Cs;
end