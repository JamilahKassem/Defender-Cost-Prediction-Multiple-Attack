function [] = plot_function(m,n,max_criticality,min_criticality,Ca,Cm,deviation,Na,h,save_plot)
format rational;
Data.m = m;
Data.n = n;
Data.target_node = 1;
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
% change to mc
Data.Cm = Cm; 
% change to mr
Data.backup_count = 10;
Data.backup_per_resource = 4;

Data.debug = false;

if Random_resources
    Data.R = createR(Data.m,min_criticality,max_criticality,deviation);
end
Data.cost = zeros(Number_of_attacks,1);
if Data.debug
    outputfile = "deviations " + num2str(deviation) + ".txt";
    Data.fileID = fopen(outputfile,'w');
    fprintf(Data.fileID,'\n--------------------Started New Simulation Deviation %d--------------------\n',deviation);
end
[cost_attack,cost_defense] = simulate_attack_multiple(Data,Number_of_attacks);
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

fprintf("Total Criticiality %s \nThe average ciriticality over nodes %s\n",strtrim(rats(sum(Data.R))),strtrim(rats(sum(Data.R)/Data.n)));

subplot(1,1,1,'Parent',h)
x_axis = 1:Number_of_attacks;
plot(x_axis,cost_attack(x_axis));
hold on;
plot(x_axis,cost_defense(x_axis));
temp = cost_defense + cost_attack;
plot(x_axis,temp(x_axis));

yline(sum(Data.R)/Data.n,'-','Tr / n');
hold off;
xlabel('Attack number');
ylabel('Expected cost of attack');

ylim([0 Inf]);
xticks(0:1:Number_of_attacks);
legend('Attack cost','Relocating cost','Total cost');
hold off;
grid on;
fclose('all');
% set(h,'papersize',[6 5]);
% set(h, 'PaperPosition', [0 0 6 5]);
if save_plot
    file_name = ['bias_Na_',num2str(Number_of_attacks),'_C_',num2str(min_criticality), ...
        '-',num2str(max_criticality),'_Tr_',num2str(sum(Data.R)),'_D_',num2str(deviation), ...
        '_m_',num2str(Data.m),'_backups_',num2str(Data.backup_count),'.pdf'];
    exportgraphics(h, file_name)
    fprintf(['Created file ',file_name,'\n']);
end
fprintf('Total cost %f Total Criticality %f\n',sum(cost_attack+cost_defense),sum(Data.R));
end

