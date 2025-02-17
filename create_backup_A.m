function [alpha_backup] = create_backup_A(alpha,Data)
    backup_count = Data.backup_count;
    backup_per_resource = Data.backup_per_resource;
    
    n = size(alpha,2);

    if backup_per_resource>=n
        backup_per_resource = n-1;
    end
    if backup_count > size(alpha,1)
        backup_count = size(alpha,1);
    end
    alpha_backup = zeros(size(alpha));
    temp_alpha = zeros(size(alpha));
    intersections = zeros(1,n-1);
    shifts = zeros(1,n-1);
    for shift = 1:n-1
        temp_alpha(1:backup_count,1:n-shift) = alpha(1:backup_count,shift+1:end);
        temp_alpha(1:backup_count,n-shift+1:n) = alpha(1:backup_count,1:shift);
        dotproduct = temp_alpha ~= 0;
        dotproduct = dotproduct .* alpha;
        intersection = sum(sum(dotproduct,2) .* Data.R');
        if shift == 1
            intersections(1) = intersection;
            shifts(1) = shift;
        else
            saved = false;
            for i = 1:shift
                if intersection > intersections(i)
                    for j = shift+1:-1:i+1
                        intersections(j) = intersections(j-1);
                        shifts(j) = shifts(j-1);
                    end
                    saved = true;
                    intersections(i) = intersection;
                    shifts(i) = shift;
                    break;
                end
            end
            if ~saved
                intersections(i) = intersection;
                shifts(i) = shift;
            end
        end
    end
    for i = 1:backup_per_resource
        shift = shifts(i);
        alpha_backup(1:backup_count,1:n-shift) = alpha_backup(1:backup_count,1:n-shift) + alpha(1:backup_count,shift+1:end);
        alpha_backup(1:backup_count,n-shift+1:n) = alpha_backup(1:backup_count,n-shift+1:n) + alpha(1:backup_count,1:shift);
    end
end