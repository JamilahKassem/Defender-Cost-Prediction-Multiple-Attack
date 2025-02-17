function [] = plot_function_backups(m,n,max_criticality,min_criticality,Ca,Cm,deviation,Na,h)
format rational;
Data.m = m;
Data.n = n;
Random_resources = true;
Number_of_attacks = Na;
if Number_of_attacks < 1
    fprintf('Number of attacks can not be less than 1\n');
    return;
end
if min_criticality >= max_criticality
    fprintf('minimum criticality cannot be less or equal maximum criticality\n');
    return;
end
Data.Ca = Ca;
Data.Cm = Cm;

backup_counts = [floor(m * 0.1),floor(m * 0.5),m];
Backups_per_resource = 1:10;

Data.target_node = 1;
Data.debug = false;

cost_attack  = zeros(size(backup_counts,2),size(Backups_per_resource,2), Number_of_attacks);
cost_defense = zeros(size(backup_counts,2),size(Backups_per_resource,2),Number_of_attacks);
Total_costs  = zeros(size(backup_counts,2),size(Backups_per_resource,2),1);

Data.backup_count = 200;
for i = 1:size(backup_counts,2)
    Data.backup_count = backup_counts(i);
    for j = 1:size(Backups_per_resource,2)
        if Random_resources
            Data.R = createR(Data.m,min_criticality,max_criticality,deviation);
        end
        Data.cost = zeros(Number_of_attacks,1);
        if Data.debug
            outputfile = "Backups per resource " + num2str(Backups_per_resource(j)) + ".txt";
            if j == 1
                Data.fileID = fopen(outputfile,'w');
            else
                Data.fileID = fopen(outputfile,'a');
            end
            fprintf(Data.fileID,'\n--------------------Started New Simulation Backups %d--------------------\n',Backups_per_resource(j));
        end
        Data.backup_per_resource = Backups_per_resource(j);
        [cost_attack(i,j,:),cost_defense(i,j,:)] = simulate_attack_multiple(Data,Number_of_attacks);
        Total_costs(i,j) = sum(cost_attack(i,j,:) + cost_defense(i,j,:));
        fprintf('Total cost %f For %d backups\n',Total_costs(i,j),Data.backup_per_resource);
        if Data.debug
            fprintf(Data.fileID,'attack cost [');
            for c = 1:Number_of_attacks
                if c == 1
                    fprintf(Data.fileID,'%f',cost_attack(i,j,c));
                else
                    fprintf(Data.fileID,',%f',cost_attack(i,j,c));
                end
            end
            fprintf(Data.fileID,']\n');
            fprintf(Data.fileID,'defense cost [');
            for c = 1:Number_of_attacks
                if c == 1
                    fprintf(Data.fileID,'%f',cost_defense(i,j,c));
                else
                    fprintf(Data.fileID,',%f',cost_defense(i,j,c));
                end
            end
            fprintf(Data.fileID,']\n');
            fclose(Data.fileID);
        end
    end
end

fprintf("Total Criticiality %d \nThe average ciriticality over nodes %s\n",sum(Data.R),strtrim(rats(sum(Data.R)/Data.n)));

legends = strings(1, size(backup_counts,2));

subplot(1,1,1,'Parent',h)
for i = 1:size(backup_counts,2)
    legends(i) = [num2str(backup_counts(i)),' backups'];
    plot(1:Backups_per_resource(end),Total_costs(i,:));
    if i == 1
        hold on;
    end
end
hold off;
xticks(Backups_per_resource);
lgd = legend(legends);
lgd.Position = [0.7, 0.65, 0.1, 0.1];
xlabel('Number of Backups per resource');
ylabel('Expected cost of attack');
grid on;
% set(h,'papersize',[6 5]);
% set(h, 'PaperPosition', [0 0 6 5]);
% file_name = ['backups_resource_Na_',num2str(Number_of_attacks),'_C_',num2str(min_criticality), ...
%     '-',num2str(max_criticality),'_Tr_',num2str(sum(Data.R)),'_Backups_for_resource_',num2str(Backups_per_resource(1)),'-',num2str(Backups_per_resource(end)), ...
%     '_m_',num2str(Data.m),'_deviation_',num2str(deviation),'_backups_',num2str(backup_counts(1)),'_',num2str(backup_counts(end)),'.pdf'];
% print(h,file_name,'-dpdf');
end

