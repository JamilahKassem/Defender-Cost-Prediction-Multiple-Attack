function [alpha] = createA(R,n,activated_alpha,Data)
m = size(R,2);
alpha = zeros(m,n);
average_criticality_for_node = sum(R) / n;
% Calculate the criticality needed to be able to fill a node

k = 1;
% number of high resources that have criticality higher than average
criticality_resource = R;
% alpha remaining fore resource
for i = 1:m
    if criticality_resource(i) < average_criticality_for_node
        break;
    else
        % set all resources that can fill node
        while criticality_resource(i) >= average_criticality_for_node
            alpha(i,k) = average_criticality_for_node / R(i);
            criticality_resource(i) = criticality_resource(i) - average_criticality_for_node;
            k = k + 1;
        end
    end
end
i = 1;
i2 = m;
current_criticality_node = average_criticality_for_node;
while i < i2 && k < n
    % set remaining alpha for high resources
    if criticality_resource(i) <= current_criticality_node
        alpha(i,k) = criticality_resource(i) / R(i);
        current_criticality_node = current_criticality_node - criticality_resource(i);
        criticality_resource(i) = 0;
        i = i + 1;
    else
        while criticality_resource(i2) <= current_criticality_node && i2 > 1
            alpha(i2,k) = criticality_resource(i2) / R(i2);
            current_criticality_node = current_criticality_node - criticality_resource(i2);
            criticality_resource(i2) = 0;
            i2 = i2 - 1;
        end
        alpha(i2,k) = current_criticality_node / R(i2);
        criticality_resource(i2) = criticality_resource(i2) - current_criticality_node;
        k = k + 1;
        current_criticality_node = average_criticality_for_node;
    end
end
for i = 1:m
    alpha(i,n) = 1 - sum(alpha(i,1:n-1));
end
if size(activated_alpha,2) ~= 0
    if Data.debug
        fprintf(Data.fileID,'alpha unarranged\n');
        for d1 = 1:m
            first = true;
            for d2 = 1:n
                text = strtrim(rats(alpha(d1,d2)));
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
    C = zeros(n);
    
    for i = 1:n
        for j = 1:n
            C(i, j) = -dot(alpha(:, i), activated_alpha(:, j));
        end
    end
    
    costUnmatched = -min(size(C)) * min(C, [], 'all');
    % Step 2: Apply the Hungarian algorithm
    [assignment, ~] = matchpairs(C, costUnmatched);
    
    % Step 3: Permute the columns of A
    A_permuted = zeros(m,n);
    if Data.debug
        fprintf(Data.fileID,"Original [");
        first = true;
        for d1 = 1:n
            if first
                first = false;
                fprintf(Data.fileID,"%d",assignment(d1, 2));
            else
                fprintf(Data.fileID,",%d",assignment(d1, 2));
            end
        end
        fprintf(Data.fileID,"]\n");
        fprintf(Data.fileID,"Arranged [");
        first = true;
        for d1 = 1:n
            if first
                first = false;
                fprintf(Data.fileID,"%d",assignment(d1, 1));
            else
                fprintf(Data.fileID,",%d",assignment(d1, 1));
            end
        end
        fprintf(Data.fileID,"]\n");
    end
    for k = 1:n
        A_permuted(:, assignment(k, 2)) = alpha(:, assignment(k, 1));
    end
    alpha = A_permuted;
end