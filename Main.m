% close all;
clear;clc;
format rational;
Data.m = 20;
Data.n = 12;
Number_of_attacks = 7;
if Number_of_attacks < 1
    return;
end
max_criticality = 12;
min_criticality = 6;
Data.Cs = 0.1;
Data.Cm = 0.01;
Data.backup_count_resource = 10;
Data.backup_count = 10;

Data.debug = false;

deviations   = 0:25:0;
cost_attack  = zeros(size(deviations,2),Number_of_attacks);
cost_defense = zeros(size(deviations,2),Number_of_attacks);

for j = 1:size(deviations,2)
    Data.R = createR(Data.m,min_criticality,max_criticality,deviations(j));
    Data.cost = zeros(Number_of_attacks,1);
    if Data.debug
        outputfile = "deviations " + num2str(deviations(j)) + ".txt";
        if j == 1
            Data.fileID = fopen(outputfile,'w');
        else
            Data.fileID = fopen(outputfile,'a');
        end
        fprintf(Data.fileID,'\n--------------------Started New Simulation Deviation %d--------------------\n',deviations(j));
    end
    [cost_attack(j,:),cost_defense(j,:)] = simulate_attack_multiple(Data,Number_of_attacks);
    if Data.debug
        fprintf(Data.fileID,'attack cost [');
        for c = 1:size(cost_attack,2)
            if c == 1
                fprintf(Data.fileID,'%f',cost_attack(c));
            else
                fprintf(Data.fileID,',%f',cost_attack(c));
            end
        end
        fprintf(Data.fileID,']\n');
        fprintf(Data.fileID,'defense cost [');
        for c = 1:size(cost_defense,2)
            if c == 1
                fprintf(Data.fileID,'%f',cost_defense(c));
            else
                fprintf(Data.fileID,',%f',cost_defense(c));
            end
        end
        fprintf(Data.fileID,']\n');
        fclose(Data.fileID);
    end
end

fprintf("Total Criticiality %s \nThe average ciriticality over nodes %s\n",strtrim(rats(sum(Data.R))),strtrim(rats(sum(Data.R)/Data.n)));

h = figure;
Number_of_attacks = Number_of_attacks - 1;
temp = zeros(1,Number_of_attacks);
for j = 1:size(deviations,2)
    for k = 1:Number_of_attacks
        temp(k) = cost_attack(j,k);
    end
    plot(1:Number_of_attacks,temp);
    if j == 1
        hold on;
    end
    for k = 1:Number_of_attacks
        temp(k) = cost_defense(j,k);
    end
    plot(1:Number_of_attacks,temp);
    for k = 1:Number_of_attacks
        temp(k) = cost_defense(j,k) + cost_attack(j,k);
    end
    plot(1:Number_of_attacks,temp);
end

yline(sum(Data.R)/Data.n,'-','Tr / n');
hold off;
xlabel('Attack number');
ylabel('Expected cost of attack');
i = 1;
legends = strings(1, size(deviations,2) * 3);

for deviation = deviations
    text = 'Attack cost';
    legends(i) = text;
    i = i + 1;
    text = 'Relocating cost';
    legends(i) = text;
    i = i + 1;
    text = 'Total cost';
    legends(i) = text;
    i = i + 1;
end

ylim([0 inf]);
xticks(0:1:Number_of_attacks);
legend(legends);
grid on;
set(h,'papersize',[6 5]);
set(h, 'PaperPosition', [0 0 6 5]);
file_name = ['bias_Na_',num2str(Number_of_attacks),'_C_',num2str(min_criticality), ...
    '-',num2str(max_criticality),'_Tr_',num2str(sum(Data.R)),'_D_',num2str(deviations(1)),'-',num2str(deviations(end)), ...
    '_m_',num2str(Data.m),'_backups_',num2str(Data.backup_count),'.pdf'];
fprintf(['Created file ',file_name,'\n']);
fprintf('Total cost %f Total Criticality %f\n',sum(cost_attack+cost_defense),sum(Data.R));
print(h,file_name,'-dpdf');
fclose('all');