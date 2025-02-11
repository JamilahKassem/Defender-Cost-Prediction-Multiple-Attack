classdef index_state
    % indices stack for ordering after creating a new A matrix
    properties
        used
        i {mustBeNumeric}
        index {mustBeNumeric}
        start {mustBeNumeric}
        last {mustBeNumeric}
        indices
    end
end