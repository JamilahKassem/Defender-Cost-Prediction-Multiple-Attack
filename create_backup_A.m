function [alpha_backup] = create_backup_A(alpha,backup_count,Data)
    n = size(alpha,2);
    if backup_count > size(alpha,1)
        backup_count = size(alpha,1);
    end
    alpha_backup = zeros(size(alpha));
    minimum_intersection = -1;
    minimum_shift = 1;
    for shift = 1:n-1
        alpha_backup(1:backup_count,1:n-shift) = alpha(1:backup_count,shift+1:end);
        alpha_backup(1:backup_count,n-shift+1:n) = alpha(1:backup_count,1:shift);
        dotproduct = alpha_backup ~= 0;
        dotproduct = dotproduct .* alpha;
        intersection = sum(sum(dotproduct,2) .* Data.R');
        if intersection < minimum_intersection || minimum_intersection == -1
            minimum_intersection = intersection;
            minimum_shift = shift;
        end
    end
    alpha_backup(1:backup_count,1:n-minimum_shift) = alpha(1:backup_count,minimum_shift+1:end);
    alpha_backup(1:backup_count,n-minimum_shift+1:n) = alpha(1:backup_count,1:minimum_shift);
end