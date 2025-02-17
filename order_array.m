function [array] = order_array(array,n)
for i1 = 1:n
    for j1 = 1:n
        for i2 = 1:n
            for j2 = 1:n
                Ind1 = (i1-1)*n+j1;
                Ind2 = (i2-1)*n+j2;
                if array(Ind1) > array(Ind2)
                    temp = array(Ind1,1:3);
                    array(Ind1,1:3) = array(Ind2,1:3);
                    array(Ind2,1:3) = temp;
                end
            end
        end
    end
end
end

