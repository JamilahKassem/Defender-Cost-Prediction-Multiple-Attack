function [R] = createR(m,min,max,devation)
R = max:-(max-min)/(m-1):min;
average = sum(R) / m;
if devation ~= 0
    for i = 1:m
        if R(i) < average
            R(i) = R(i) - (R(i) - min) * devation / 100;
        else
            R(i) = R(i) + (max - R(i)) * devation / 100;
        end
    end
end
R(2:m-1) = round(R(2:m-1) * (max / 2 * m) / sum(R(1:m)));
end

