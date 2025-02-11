classdef state
    % states of the system at each attack level
    properties
        R
        iteration_probability {mustBeNumeric}
        % m {mustBeNumeric}
        alpha
        activated_alpha
    end
end