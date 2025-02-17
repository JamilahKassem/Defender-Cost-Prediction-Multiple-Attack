function [Movement_cost] = calculate_cost_movement(activated_alpha,alpha,R,Cm)
number_resource_moves = activated_alpha == 0 & alpha ~= 0;
number_resource_moves = sum(number_resource_moves,2)';
Movement_cost = sum(R .*  number_resource_moves) * Cm;
end