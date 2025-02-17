function [] = Main()
    close all;
    m=20;
    n=12;
    min_criticality=6;
    max_criticality=12;
    Cost_move=0.1;
    Cost_attack=2/3;
    deviation=0;
    Na=6;
    
    %% Create Plot Interface
    f=figure('Visible','off');
    subgroup1 = uipanel('Parent', f, 'Units', 'normal', 'Position', [0 0 1 1]);
    subgroup1_plotbox = uipanel('Parent', subgroup1, 'Units', 'normal', 'Position', [0 .1 1 .9]);
    sugroup1_controls = uipanel('Parent', subgroup1, 'Units', 'normal', 'Position', [0 0 1 .1]);
    
    uicontrol('Style','text', 'Units', 'normal','Position',[0 0 .05 .8],'String',...
        'm','Parent', sugroup1_controls,'FontSize',12);
    uicontrol('Style', 'edit','string',num2str(m), 'Units', 'normal',...
        'Position', [.05 .1 .05 .8],'Callback', @Setm,'Parent', sugroup1_controls );
    
    uicontrol('Style','text', 'Units', 'normal','Position',[0.1 0 .05 .8],'String',...
        'n','Parent', sugroup1_controls,'FontSize',12);
    uicontrol('Style', 'edit','string',num2str(n), 'Units', 'normal',...
        'Position', [.15 .1 .05 .8],'Callback', @Setn,'Parent', sugroup1_controls );
    
    uicontrol('Style','text', 'Units', 'normal','Position',[0.2 0 .12 .8],'String',...
        'Criticality','Parent', sugroup1_controls,'FontSize',12);
    uicontrol('Style', 'edit','string',num2str(min_criticality), 'Units', 'normal',...
        'Position', [.32 .1 .05 .8],'Callback', @SetCn,'Parent', sugroup1_controls );
    
    uicontrol('Style','text', 'Units', 'normal','Position',[0.37 0 .02 .8],'String',...
        '-','Parent', sugroup1_controls,'FontSize',12);
    uicontrol('Style', 'edit','string',num2str(max_criticality), 'Units', 'normal',...
        'Position', [.39 .1 .05 .8],'Callback', @SetCm,'Parent', sugroup1_controls );
    
    uicontrol('Style','text', 'Units', 'normal','Position',[0.44 0 .05 .8],'String',...
        'Cm','Parent', sugroup1_controls,'FontSize',12);
    uicontrol('Style', 'edit','string',num2str(Cost_move), 'Units', 'normal',...
        'Position', [.49 .1 .05 .8],'Callback', @SetCv,'Parent', sugroup1_controls );
    
    uicontrol('Style','text', 'Units', 'normal','Position',[0.54 0 .05 .8],'String',...
        'Ca','Parent', sugroup1_controls,'FontSize',12);
    uicontrol('Style', 'edit','string',num2str(Cost_attack), 'Units', 'normal',...
        'Position', [.59 .1 .05 .8],'Callback', @SetCa,'Parent', sugroup1_controls );
    
    uicontrol('Style','text', 'Units', 'normal','Position',[0.64 0 .12 .8],'String',...
        'deviation','Parent', sugroup1_controls,'FontSize',12);
    uicontrol('Style', 'edit','string',num2str(deviation), 'Units', 'normal',...
        'Position', [.76 .1 .05 .8],'Callback', @Setdeviation,'Parent', sugroup1_controls );
    
    uicontrol('Style','text', 'Units', 'normal','Position',[0.81 0 .05 .8],'String',...
        'Na','Parent', sugroup1_controls,'FontSize',12);
    uicontrol('Style', 'edit','string',num2str(Na), 'Units', 'normal',...
        'Position', [.86 .1 .05 .8],'Callback', @SetNa,'Parent', sugroup1_controls );
    
    uicontrol('Style', 'pushbutton','string','Plot', 'Units', 'normal',...
        'Position', [.91 .1 .09 .8],'Callback', @PlotStart,'Parent', sugroup1_controls );
    f.Visible = 'on';
    %% Create Plot Interface

    %% Create First Interface

    %% Create First Interface

    PlotStart();

    function PlotStart(~,~)
        % subgroup1.Visible = 'off';
        plot_function(m,n,max_criticality,min_criticality,Cost_attack,Cost_move,deviation,Na,subgroup1_plotbox)
    end
    
    function Setm(src,~)
        str=get(src,'String');
        if isempty(str2num(str))
            set(src,'string','20');
            warndlg('Input must be numerical');
        else
            m=str2num(str);
        end
    end
    function Setn(src,~)
        str=get(src,'String');
        if isempty(str2num(str))
            set(src,'string','12');
            warndlg('Input must be numerical');
        elseif str2num(str) < Na
            set(src,'string',num2str(n));
            warndlg('Number of nodes cannot be less than the number of attacks');
        else
            n=str2num(str);
        end
    end
    function SetNa(src,~)
        str=get(src,'String');
        if isempty(str2num(str))
            set(src,'string','12');
            warndlg('Input must be numerical');
        elseif str2num(str) > n
            set(src,'string',num2str(Na));
            warndlg('Number of attacks cannot be greate than the number of nodes');
        else
            Na=str2num(str);
        end
    end
    function SetCv(src,~)
        str=get(src,'String');
        if isempty(str2num(str))
            set(src,'string','0.1');
            warndlg('Input must be numerical');
        else
            Cost_move=str2num(str);
        end
    end
    function SetCa(src,~)
        str=get(src,'String');
        if isempty(str2num(str))
            set(src,'string','0.01');
            warndlg('Input must be numerical');
        else
            Cost_attack=str2num(str);
        end
    end
    function Setdeviation(src,~)
        str=get(src,'String');
        if isempty(str2num(str))
            set(src,'string','0');
            warndlg('Input must be numerical');
        else
            deviation=str2num(str);
        end
    end
    function SetCn(src,~)
        str=get(src,'String');
        if isempty(str2num(str))
            set(src,'string','6');
            warndlg('Input must be numerical');
        elseif str2num(str) > max_criticality
            set(src,'string',num2str(min_criticality));
            warndlg('Min crticality cannot be greater than max criticality');
        else
            min_criticality=str2num(str);
        end
    end
    function SetCm(src,~)
        str=get(src,'String');
        if isempty(str2num(str))
            set(src,'string','12');
            warndlg('Input must be numerical');
        elseif str2num(str) < min_criticality
            set(src,'string',num2str(max_criticality));
            warndlg('Max crticality cannot be less than min criticality');
        else
            max_criticality=str2num(str);
        end
    end
end