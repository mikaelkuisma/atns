function handles = resetSimulation(handles)

Data = handles.Data;
GI = Data.GuildInfo;
handles.Simulation.Binit = vertcat(Data.Guilds.binit);
handles.Results = initializeResultStruct(GI,0,0,handles.Options.Outputs);

% Set axes properties
handles.tab_simulate.axes_biomass.Title.String = handles.Options.Axes_1.Title.String;
handles.tab_simulate.axes_biomass.Title.FontSize = handles.Options.Axes_1.Title.FontSize;
handles.tab_simulate.axes_catch.Title.String = handles.Options.Axes_2.Title.String;
handles.tab_simulate.axes_catch.Title.FontSize = handles.Options.Axes_2.Title.FontSize;

% Delete existing children of axis and remove all handles
handles.tab_simulate.all(ismember(handles.tab_simulate.all, ...
    [handles.tab_simulate.axes_biomass.Children ; handles.tab_simulate.axes_catch.Children])) = [];
handles.plots.BiomassFishGuild = plot([]);
handles.plots.BiomassFishGuildPerSpecies = plot([]);
handles.plots.CatchFishGuildYearly = plot([]);
handles.plots.CatchFishGuildCumulative = plot([]);
handles.plots.CatchFishGuildYearlyPerSpecies = plot([]);
handles.plots.CatchFishGuildCumulativePerSpecies = plot([]);
delete([handles.tab_simulate.axes_biomass.Children ; handles.tab_simulate.axes_catch.Children])

% Delete existing checkboxes from CHECKBOX PANEL
delete(handles.tab_simulate.uipanel_biomassplots.Children)
handles.tab_simulate.plotCheckboxes = [];

% Initialize plots
set(handles.tab_simulate.axes_biomass,'nextplot','add','xlim',[0 handles.minaxeswidth])
set(handles.tab_simulate.axes_catch,'nextplot','add','xlim',[0 handles.minaxeswidth])

% Initialize guild LISTBOX and CHECKBOX PANEL
guildLabels = {Data.Guilds.label};
positions = repmat([10 10 50 15],GI.nFishGuilds,1);
positions(:,2) = positions(:,2) + (0:20:20*(GI.nFishGuilds-1))';

fishgls = {Data.Guilds(GI.iFishGuilds).label};
S.subs = {1,1:3}; S.type = '()';
fslabels = unique(cellfun(@(x)subsref(x,S),fishgls,'uniformoutput',false),'stable');

% Biomass plots for all fish guilds
for i = 1:GI.nFishGuilds
    I = GI.iFishGuilds(i);
    g = Data.Guilds(I);
    li = g.age+1;
    IS = find(strcmpi(g.label(1:3),fslabels));
 
    handles.plots.BiomassFishGuild(i) = plot(handles.tab_simulate.axes_biomass, ...
        0,Data.Guilds(I).binit,'marker',handles.Options.Plots.markers{li}, ...
        'color',handles.Options.Plots.linecolors(IS,:),'linewidth',handles.Options.Plots.linewidths(li), ...
        'linestyle',handles.Options.Plots.linestyles{li}); %#ok<FNDSB>
    handles.tab_simulate.all(end+1) = handles.plots.BiomassFishGuild(i);
    
    handles.tab_simulate.plotCheckboxes(i) = uicontrol( ...
        'Parent', handles.tab_simulate.uipanel_biomassplots, ...
        'Style', 'checkbox', ...
        'String', guildLabels{I}, ...
        'Callback', @(hObj,ed)ATN_gui('checkbox_biomassplot_Callback',hObj,ed,guidata(hObj)), ...
        'Value', 1, ...
        'Position', positions(i,:), ...
        'BackgroundColor', handles.plots.BiomassFishGuild(i).Color);
    
end
if GI.nFishGuilds > 0
    handles.tab_simulate.uipanel_biomassplots.Units = 'pixels';
    handles.tab_simulate.uipanel_biomassplots.Position(4) = ...
        2*positions(1,2) + positions(end,2) + positions(end,4);
    handles.tab_simulate.uipanel_biomassplots.Position(3) = ...
        2*positions(1,1) + positions(1,3);
    handles.tab_simulate.uipanel_biomassplots.Parent = handles.tab_simulate.uipanel_tab_simulate;
end
% Catch plots for all adult fish guilds
for i = 1:GI.nAdultFishGuilds
    I = GI.iAdultFishGuilds(i);
    g = Data.Guilds(I);
    li = g.age+1;
    IS = find(strcmpi(g.label(1:3),fslabels));
    
    handles.plots.CatchFishGuildYearly(i) = plot(handles.tab_simulate.axes_catch, ...
        0, 0, ...
        'marker', handles.Options.Plots.markers{li}, ...
        'color', handles.Options.Plots.linecolors(IS,:), ...
        'linewidth', handles.Options.Plots.linewidths(li), ...
        'linestyle', handles.Options.Plots.linestyles{li});
    handles.tab_simulate.all(end+1) = handles.plots.CatchFishGuildYearly(i);
    
    handles.plots.CatchFishGuildCumulative(i) = plot(handles.tab_simulate.axes_catch, ...
        0, 0, ...
        'marker', handles.Options.Plots.markers{li}, ...
        'color', handles.Options.Plots.linecolors(IS,:), ...
        'linewidth', handles.Options.Plots.linewidths(li), ...
        'linestyle', handles.Options.Plots.linestyles{li});
    handles.tab_simulate.all(end+1) = handles.plots.CatchFishGuildCumulative(i);
end

% Catch plots for all fish species
for i = 1:GI.nFishSpecies
    handles.plots.BiomassFishGuildPerSpecies(i) = plot(handles.tab_simulate.axes_biomass, ...
        0, 0, ...
        'marker', '.', ...
        'linestyle', '-', ...
        'color', handles.Options.Plots.linecolors(i,:));
    handles.tab_simulate.all(end+1) = handles.plots.BiomassFishGuildPerSpecies(i);
    
    handles.plots.CatchFishGuildYearlyPerSpecies(i) = plot(handles.tab_simulate.axes_catch, ...
        0, 0, ...
        'marker', '.', ...
        'linestyle', '-', ...
        'color', handles.Options.Plots.linecolors(i,:));
    handles.tab_simulate.all(end+1) = handles.plots.CatchFishGuildYearlyPerSpecies(i);
    
    handles.plots.CatchFishGuildCumulativePerSpecies(i) = plot(handles.tab_simulate.axes_catch, ...
        0, 0, ...
        'marker', '.', ...
        'linestyle', '-', ...
        'color', handles.Options.Plots.linecolors(i,:));
    handles.tab_simulate.all(end+1) = handles.plots.CatchFishGuildCumulativePerSpecies(i);
end

% Show/hide plots based on the biomasstype popumenu value
switch handles.tab_simulate.popupmenu_biomasstype.Value
    case 1
        set(handles.plots.BiomassFishGuild,'Visible','on')
        set(handles.plots.BiomassFishGuildPerSpecies,'Visible','off')
    case 2
        set(handles.plots.BiomassFishGuild,'Visible','off')
        set(handles.plots.BiomassFishGuildPerSpecies,'Visible','on')
end

% Show/hide plots based on the catchtype popumenu value
switch handles.tab_simulate.popupmenu_catchtype.Value
    case 1
        set(handles.plots.CatchFishGuildYearly,'Visible','on')
        set(handles.plots.CatchFishGuildCumulative,'Visible','off')
        set(handles.plots.CatchFishGuildYearlyPerSpecies,'Visible','off')
        set(handles.plots.CatchFishGuildCumulativePerSpecies,'Visible','off')
    case 2
        set(handles.plots.CatchFishGuildYearly,'Visible','off')
        set(handles.plots.CatchFishGuildCumulative,'Visible','on')
        set(handles.plots.CatchFishGuildYearlyPerSpecies,'Visible','off')
        set(handles.plots.CatchFishGuildCumulativePerSpecies,'Visible','off')
    case 3
        set(handles.plots.CatchFishGuildYearly,'Visible','off')
        set(handles.plots.CatchFishGuildCumulative,'Visible','off')
        set(handles.plots.CatchFishGuildYearlyPerSpecies,'Visible','on')
        set(handles.plots.CatchFishGuildCumulativePerSpecies,'Visible','off')
    case 4
        set(handles.plots.CatchFishGuildYearly,'Visible','off')
        set(handles.plots.CatchFishGuildCumulative,'Visible','off')
        set(handles.plots.CatchFishGuildYearlyPerSpecies,'Visible','off')
        set(handles.plots.CatchFishGuildCumulativePerSpecies,'Visible','on')
end
