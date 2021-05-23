function varargout = ATN_gui(varargin)
% ATN_GUI MATLAB code for ATN_gui.fig
%      ATN_GUI, by itself, creates a new ATN_GUI or raises the existing
%      singleton*.
%
%      H = ATN_GUI returns the handle to a new ATN_GUI or the handle to
%      the existing singleton*.
%
%      ATN_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ATN_GUI.M with the given input arguments.
%
%      ATN_GUI('Property','Value',...) creates a new ATN_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ATN_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ATN_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ATN_gui_OpeningFcn, ...
    'gui_OutputFcn',  @ATN_gui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

function ATN_gui_OpeningFcn(hObject, ~, handles, varargin)
handles.output = hObject;
% Save UIControl default values to handles-struct

% handles = addTextObjects(handles);
handles = groupHandles(handles);
handles = updateEcosystemPopupmenu(handles,[]);
handles.tab_simulate.pushbutton_stop.UserData.simulationStopped = false;

set(handles.tab_guilds.all,'Visible','off')
set(handles.tab_simulate.all,'Visible','on')

handles = saveUIControlValues(handles);

ecosyses = handles.tab_simulate.popupmenu_ecosystem.String;
if ~isempty(ecosyses)
    ecosys = feval(@(h)h.String{h.Value},handles.tab_simulate.popupmenu_ecosystem);
    load(['Data/' ecosys '.mat'],'Data')
    handles.Data = Data;
    handles.Data = updateGuildInfo(handles.Data);
    
    handles.minaxeswidth = 5;   % TODO: gather all gui parameters in one place

    % Define line properties
    handles.Options.Plots.linecolors = [0 1 0
        0.0345 0.7931 1
        0.3103 0.9655 1
        1 0.8621 0.4138
        0 0 0
        0 0 0
        0 0 0
        0 0 0
        0 0 0
        ];
    handles.Options.Plots.linestyles = {'--','--','-','-','-','-','-'};
    handles.Options.Plots.markers = {'.','.','.','.','.','.','.'};
    handles.Options.Plots.linewidths = [1 2 1 2 3 4 5];
    
    handles.Options.Axes_1.Title.String = 'Biomass';
    handles.Options.Axes_1.Title.FontSize = 14;
    handles.Options.Axes_2.Title.String = 'Catch';
    handles.Options.Axes_2.Title.FontSize = 14;

    handles.Options.Defaults.nGrowthDays = 90;
    handles.Options.Defaults.numberOfYears = 100;
    
    handles.Options.Outputs.Biomass = true; % can't imagine why this could be false though
    handles.Options.Outputs.GainFish = true; % this is essential for fish reproduction
    % Set these to false if they are not needed to speed up computation
    handles.Options.Outputs.AllBiomasses = true;
    handles.Options.Outputs.Catch = true;
    handles.Options.Outputs.Gain = false;
    handles.Options.Outputs.GainDaily = false;
    handles.Options.Outputs.Loss = false;
    handles.Options.Outputs.SSB = true;
    handles.Options.Outputs.JB = true;
    handles.Options.Outputs.Productivity = false;
    handles.Options.Outputs.ProductivityDaily = false;
    
    %%% Fish reproduction model
    % 1 = original surplus gain based version
    % 2 = smoothed version of the original version
    % 3 = latest version based on the ratio of gains and losses
    %handles.Options.Model.FishReproduction.Version = 1;
    %handles.Options.Model.FishReproduction.Version = 2;
    %handles.Options.Model.FishReproduction.Params = 0.2;
    handles.Options.Model.FishReproduction.Version = 3;
    handles.Options.Model.FishReproduction.Params = 0.5;
    
    %%% Producer growth model within growth season
    % 1 = original constant K model
    % 2 = first half of sinusoidal wave K model
    handles.Options.Model.GrowthSeason.K.Version = 1;
    %handles.Options.Model.GrowthSeason.K.Version = 2;
    %handles.Options.Model.GrowthSeason.K.Params = 0.25;
    
    handles = resetSimulation(handles);
    handles = initializeGuildTab(handles);
    handles.isGuildChange = false;
    handles.isSimulationStarted = false;
    handles.isNotSaved = false;   
    
    handles.altPressed = false;
    
    % Update handles structure
    guidata(hObject, handles)
else
    herror = errordlg('No mat-files found under Data/.');
    uiwait(herror)
    handles.output = [];
    guidata(hObject, handles)
    delete(handles.atn_gui)
end


function varargout = ATN_gui_OutputFcn(~, ~, ~)
% varargout{1} = handles.output;
varargout{1} = [];

% ----------------------------------------------------------------------- %
% ------------------------------ Callbacks ------------------------------ %
% ----------------------------------------------------------------------- %

% ------ MENU
function menu_view_Callback(hObject, ~, handles)
if strcmpi(handles.tab_simulate.uipanel_tab_simulate.Visible,'on')
    handles.tab_simulate.visibleStatus = get(handles.tab_simulate.all,'visible');
end
guidata(hObject, handles)
function menu_simulate_tab_Callback(hObject, ~, handles)
set(handles.tab_guilds.all,'Visible','off')
if handles.isGuildChange
    handles = resetSimulation(handles);
    for i = 1:length(handles.tab_simulate.all)
        if strcmpi(handles.tab_simulate.all(i).Type,'line')
            if any(handles.tab_simulate.all(i) == handles.plots.BiomassFishGuild)
                set(handles.tab_simulate.all(i),'visible','on')
                handles.tab_simulate.visibleStatus{i} = 'on';
            elseif any(handles.tab_simulate.all(i) == handles.plots.CatchFishGuildYearly)
                set(handles.tab_simulate.all(i),'visible','on')
                handles.tab_simulate.visibleStatus{i} = 'on';
            else
                set(handles.tab_simulate.all(i),'visible','off')
                handles.tab_simulate.visibleStatus{i} = 'off';
            end
        else
            set(handles.tab_simulate.all(i),'visible',handles.tab_simulate.visibleStatus{i})
        end
    end
else
    for i = 1:length(handles.tab_simulate.all)
        set(handles.tab_simulate.all(i),'visible',handles.tab_simulate.visibleStatus{i})
    end
end
str_sel = feval(@(h)h.String{h.Value},handles.tab_simulate.popupmenu_ecosystem);
handles = updateEcosystemPopupmenu(handles,str_sel);
handles = saveParameterValues(handles);
guidata(hObject, handles)
function menu_guilds_tab_Callback(~, ~, handles)
set(handles.tab_guilds.all,'Visible','on')
set(handles.tab_simulate.all,'Visible','off')
ecoStr = handles.tab_simulate.popupmenu_ecosystem.String{handles.tab_simulate.popupmenu_ecosystem.Value};
handles.tab_guilds.uipanel_tab_guilds.Title = ['Guilds (' ecoStr '.mat)'];
h = handles.tab_guilds.listbox_guild_list;
h.Value = 1;
h.Callback(h, handles)
function uidebug_ClickedCallback(hObject, eventdata, handles)
handles = ATN_gui_debugger(hObject, eventdata, handles);
guidata(hObject, handles)


% ------ SIMULATE TAB UICONTROLS
function pushbutton_gofishing_Callback(hObject, ~, handles)
enableUIControls(hObject, handles, 'off');

handles.Data.F = str2double(handles.uicontrolvalues.edit_fishingmortality);
handles.Data.nGrowthDays = str2double(handles.uicontrolvalues.edit_length_season);
handles.Data.hmax = handles.Data.F/handles.Data.nGrowthDays;
gearStr = handles.tab_simulate.uibuttongroup_gear.SelectedObject.String;
gear = Gear(gearStr, str2double(handles.tab_simulate.edit_releaseproportion.String));
E = handles.Data.hmax*gear.selectivity(handles.Data.Guilds(handles.Data.GuildInfo.iFishGuilds));

% S = selective_fishery(handles.Data, gearStr);
% E = S;
% 
% if handles.tab_simulate.radiobutton_gear_3.Value == 1 % Fyke net selected
%     propRelease = str2double(handles.tab_simulate.edit_releaseproportion.String);
%     oldFishInds = find([handles.Data.Guilds(handles.Data.GuildInfo.iAdultFishGuilds).age] == 4);
%     E(oldFishInds) = E(oldFishInds)*(1-propRelease);
% end

handles.Data.E = E;
% handles.Data.P_mat = proba_mature(0);

handles = simulateForward(handles);
enableUIControls(hObject, handles, 'on');
handles.isSimulationStarted = true;
guidata(hObject, handles)
function pushbutton_nofishing_Callback(hObject, ~, handles)
enableUIControls(hObject, handles, 'off');
handles.Data.nGrowthDays = str2double(handles.uicontrolvalues.edit_length_season);
handles.Data.E = zeros(handles.Data.GuildInfo.nFishGuilds,1);
% handles.Data.P_mat = proba_mature(0);
handles = simulateForward(handles);
enableUIControls(hObject, handles, 'on');
handles.isSimulationStarted = true;
guidata(hObject, handles)
function pushbutton_reset_Callback(hObject, ~, handles)
handles = resetSimulation(handles);
enableUIControls(hObject, handles, 'on');
handles.isSimulationStarted = false;
guidata(hObject, handles)
function pushbutton_save_results_Callback(~, ~, handles)
[filename, dirname] = uiputfile('*.mat');
Results = handles.Results;
save([dirname filename],'Results')
function pushbutton_rewind_Callback(hObject, ~, handles)

handles.Results.B(:,end) = [];
handles.Results.C(:,end) = [];
handles.Results.GF(:,end) = [];
handles.Results.G(:,:,end) = [];
handles.Results.L(:,:,end) = [];

if size(handles.Results.B,2) > 0
    handles.Simulation.Binit = handles.Results.B(:,end);
else
    handles.Simulation.Binit = vertcat(handles.Data.Guilds.binit);
end
handles = refreshAxes(handles); % Refresh plots at each time step

handles.Results.SSB(:,end) = [];
handles.Results.JB(:,end) = [];

handles.Results.allbiomasses(:,end-handles.Data.nGrowthDays:end) = [];

enableUIControls(hObject, handles, 'on');
guidata(hObject, handles)
function pushbutton_stop_Callback(hObject, ~, handles)
hObject.UserData.simulationStopped = true;
guidata(hObject, handles)
function pushbutton_planktonfigure_Callback(~, ~, handles)
Guilds = handles.Data.Guilds;
GI = handles.Data.GuildInfo;

f = findobj(get(0,'Children'),'name','Biomasses by type');
if isempty(f)
    f = figure('name','Biomasses by type');
    set(f,'paperpositionmode','auto')
    %set(f,'units','normalized','outerposition',[0.1 0.1 0.8 0.8])
    set(f,'units','normalized','outerposition',[0 0 0.5 0.5])
else
    figure(f)
end
    
subplot(2,2,1)
B = [[Guilds(GI.iDetritusGuilds).binit] ; handles.Results.B(GI.iDetritusGuilds,:)'];
plot(0:size(B,1)-1,sum(B,2))
title('Detritus')
set(gca,'tickdir','out')
box off

subplot(2,2,2)
B = [[Guilds(GI.iProducerGuilds).binit] ; handles.Results.B(GI.iProducerGuilds,:)'];
plot(0:size(B,1)-1,sum(B,2))
title('Producers')
set(gca,'tickdir','out')
box off

subplot(2,2,3)
B = [[Guilds(GI.iConsumerGuilds).binit] ; handles.Results.B(GI.iConsumerGuilds,:)'];
plot(0:size(B,1)-1,sum(B,2))
title('Consumers')
set(gca,'tickdir','out')
box off

subplot(2,2,4)
if GI.nFishGuilds > 0
    B = [[Guilds(GI.iFishGuilds).binit] ; handles.Results.B(GI.iFishGuilds,:)'];
    plot(0:size(B,1)-1,sum(B,2))
    title('Fish')
    set(gca,'tickdir','out')
    box off
end
function pushbutton_planktonfigure_old_Callback(~, ~, handles)

Guilds = handles.Data.Guilds;
gls = {Guilds.label};

iAlg = find(1-cellfun(@isempty,cellfun(@(x)strfind(x,'Alg'),gls,'uniformoutput',false)));
iBac = find(1-cellfun(@isempty,cellfun(@(x)strfind(x,'Bac'),gls,'uniformoutput',false)));
iCil = find(1-cellfun(@isempty,cellfun(@(x)strfind(x,'Cil'),gls,'uniformoutput',false)));
iRot = find(1-(cellfun(@isempty,cellfun(@(x)strfind(x,'Rot'),gls,'uniformoutput',false)) & ...
    cellfun(@isempty,cellfun(@(x)strfind(x,'Asp'),gls,'uniformoutput',false))));
iHCr = find(1-cellfun(@isempty,cellfun(@(x)strfind(x,'Cru'),gls,'uniformoutput',false)));
iCcr = find(1-(cellfun(@isempty,cellfun(@(x)strfind(x,'Cyc'),gls,'uniformoutput',false)) & ...
    cellfun(@isempty,cellfun(@(x)strfind(x,'Lep'),gls,'uniformoutput',false))));

panelwidth = 0.28*ones(1,6);
panelheight = 0.4*ones(1,6);
panelvertoffset = 0.07;
panelhorzoffset = 0.05;
panelbottom0 = 0.08;
panelleft0 = 0.04;
panelbottom = ones(1,6)*panelbottom0 + [1 1 1 0 0 0].*(panelheight+panelvertoffset);
panelleft = ones(1,6)*panelleft0 + [0 1 2 0 1 2].*(panelwidth+panelhorzoffset);

f = findobj(get(0,'Children'),'name','Plankton');
if isempty(f)
    f = figure('name','Plankton');
    set(f,'paperpositionmode','auto')
    %set(f,'units','normalized','outerposition',[0.1 0.1 0.8 0.8])
    set(f,'units','normalized','outerposition',[0 0 0.5 0.5])
else
    figure(f)
end
    
subplot(2,3,1)
B = [[Guilds(iAlg).binit] ; handles.Results.B(iAlg,:)'];
plot(0:size(handles.Results.B,2),B)
set(gca,'tickdir','out')
box off
title('Algae')
set(gca,'position',[panelleft(1) panelbottom(1) panelwidth(1) panelheight(1)])

subplot(2,3,2)
B = [[Guilds(iBac).binit] ; handles.Results.B(iBac,:)'];
plot(0:size(handles.Results.B,2),B)
set(gca,'tickdir','out')
box off
title('Bacteria')
set(gca,'position',[panelleft(2) panelbottom(2) panelwidth(2) panelheight(2)])

subplot(2,3,3)
B = [[Guilds(iCil).binit] ; handles.Results.B(iCil,:)'];
plot(0:size(handles.Results.B,2),B)
set(gca,'tickdir','out')
box off
title('Ciliates')
set(gca,'position',[panelleft(3) panelbottom(3) panelwidth(3) panelheight(3)])

subplot(2,3,4)
B = [[Guilds(iRot).binit] ; handles.Results.B(iRot,:)'];
plot(0:size(handles.Results.B,2),B)
set(gca,'tickdir','out')
box off
title('Rotifiers')
set(gca,'position',[panelleft(4) panelbottom(4) panelwidth(4) panelheight(4)])

subplot(2,3,5)
B = [[Guilds(iHCr).binit] ; handles.Results.B(iHCr,:)'];
plot(0:size(handles.Results.B,2),B)
set(gca,'tickdir','out')
box off
title('Herbivorous crustacean')
set(gca,'position',[panelleft(5) panelbottom(5) panelwidth(5) panelheight(5)])

subplot(2,3,6)
B = [[Guilds(iCcr).binit] ; handles.Results.B(iCcr,:)'];
plot(0:size(handles.Results.B,2),B)
set(gca,'tickdir','out')
box off
title('Carnivorous crustacean')
set(gca,'position',[panelleft(6) panelbottom(6) panelwidth(6) panelheight(6)])
function updatePlanktonFigure(f,handles)
Guilds = handles.Data.Guilds;
GI = handles.Data.GuildInfo;
%
axs = findobj(get(f,'children'),'type','axes');
tit = get(axs,'title');
tit = [tit{:}];
tit = {tit.String};

str = 'Detritus';
ax = axs(strcmp(tit,str));
h = ax.Children;
B = fliplr([[Guilds(GI.iDetritusGuilds).binit] ; handles.Results.B(GI.iDetritusGuilds,:)']);
h.XData = 0:size(handles.Results.B,2);
h.YData = sum(B,2);

str = 'Producers';
ax = axs(strcmp(tit,str));
h = ax.Children;
B = fliplr([[Guilds(GI.iProducerGuilds).binit] ; handles.Results.B(GI.iProducerGuilds,:)']);
h.XData = 0:size(handles.Results.B,2);
h.YData = sum(B,2);

str = 'Consumers';
ax = axs(strcmp(tit,str));
h = ax.Children;
B = fliplr([[Guilds(GI.iConsumerGuilds).binit] ; handles.Results.B(GI.iConsumerGuilds,:)']);
h.XData = 0:size(handles.Results.B,2);
h.YData = sum(B,2);

if GI.nFishGuilds > 0
    str = 'Fish';
    ax = axs(strcmp(tit,str));
    h = ax.Children;
    B = fliplr([[Guilds(GI.iFishGuilds).binit] ; handles.Results.B(GI.iFishGuilds,:)']);
    h.XData = 0:size(handles.Results.B,2);
    h.YData = sum(B,2);
end
function updatePlanktonFigure_old(f,handles)

Guilds = handles.Data.Guilds;
gls = {Guilds.label};

iAlg = find(1-cellfun(@isempty,cellfun(@(x)strfind(x,'Alg'),gls,'uniformoutput',false)));
iBac = find(1-cellfun(@isempty,cellfun(@(x)strfind(x,'Bac'),gls,'uniformoutput',false)));
iCil = find(1-cellfun(@isempty,cellfun(@(x)strfind(x,'Cil'),gls,'uniformoutput',false)));
iRot = find(1-(cellfun(@isempty,cellfun(@(x)strfind(x,'Rot'),gls,'uniformoutput',false)) & ...
    cellfun(@isempty,cellfun(@(x)strfind(x,'Asp'),gls,'uniformoutput',false))));
iHCr = find(1-cellfun(@isempty,cellfun(@(x)strfind(x,'Cru'),gls,'uniformoutput',false)));
iCcr = find(1-(cellfun(@isempty,cellfun(@(x)strfind(x,'Cyc'),gls,'uniformoutput',false)) & ...
    cellfun(@isempty,cellfun(@(x)strfind(x,'Lep'),gls,'uniformoutput',false))));

%
axs = findobj(get(f,'children'),'type','axes');
tit = get(axs,'title');
tit = [tit{:}];
tit = {tit.String};

str = 'Algae';
ax = axs(strcmp(tit,str));
h = ax.Children;
B = fliplr([[Guilds(iAlg).binit] ; handles.Results.B(iAlg,:)']);
for i = 1:length(h)
    h(i).XData = 0:size(handles.Results.B,2);
    h(i).YData = B(:,i);
end

str = 'Bacteria';
ax = axs(strcmp(tit,str));
h = ax.Children;
B = fliplr([[Guilds(iBac).binit] ; handles.Results.B(iBac,:)']);
for i = 1:length(h)
    h(i).XData = 0:size(handles.Results.B,2);
    h(i).YData = B(:,i);
end

str = 'Ciliates';
ax = axs(strcmp(tit,str));
h = ax.Children;
B = fliplr([[Guilds(iCil).binit] ; handles.Results.B(iCil,:)']);
for i = 1:length(h)
    h(i).XData = 0:size(handles.Results.B,2);
    h(i).YData = B(:,i);
end

str = 'Rotifiers';
ax = axs(strcmp(tit,str));
h = ax.Children;
B = fliplr([[Guilds(iRot).binit] ; handles.Results.B(iRot,:)']);
for i = 1:length(h)
    h(i).XData = 0:size(handles.Results.B,2);
    h(i).YData = B(:,i);
end

str = 'Herbivorous crustacean';
ax = axs(strcmp(tit,str));
h = ax.Children;
B = fliplr([[Guilds(iHCr).binit] ; handles.Results.B(iHCr,:)']);
for i = 1:length(h)
    h(i).XData = 0:size(handles.Results.B,2);
    h(i).YData = B(:,i);
end

str = 'Carnivorous crustacean';
ax = axs(strcmp(tit,str));
h = ax.Children;
B = fliplr([[Guilds(iCcr).binit] ; handles.Results.B(iCcr,:)']);
for i = 1:length(h)
    h(i).XData = 0:size(handles.Results.B,2);
    h(i).YData = B(:,i);
end
function pushbutton_totalbiomassfigure_Callback(~, ~, handles)

f = findobj(get(0,'Children'),'name','Total Biomass');
if isempty(f)
    f = figure('name','Total Biomass');
    set(f,'paperpositionmode','auto')
    set(f,'units','normalized','outerposition',[0 0.5 0.5 0.5])
else
    figure(f)
end

GI = handles.Data.GuildInfo;
Guilds = handles.Data.Guilds;
Iall = 1:GI.nGuilds;
I = setdiff(Iall,GI.iDetritusGuilds);

subplot(2,2,1)
plot(0:size(handles.Results.B,2),sum([[handles.Data.Guilds(I).binit]' handles.Results.B(I,:)]))
set(gca,'xtick',unique(round(get(gca,'xtick'))))
title('Ecosystem biomass (no detritus)')

subplot(2,2,2)
legends = cell(1,GI.nFishSpecies);
for i = 1:GI.nFishSpecies
    fishgls = {Guilds(GI.iFishGuilds).label};
    S.subs = {1,1:3};
    S.type = '()';
    fslabels = unique(cellfun(@(x)subsref(x,S),fishgls,'uniformoutput',false),'stable');
    fishgls = cellfun(@(x)subsref(x,S),fishgls,'uniformoutput',false); 
    fsinds = find(strcmpi(fslabels{i},fishgls));
    xdata = 0:size(handles.Results.GF,2);
    ydata = [0 sum(handles.Results.GF(fsinds,:))];
    plot(xdata,ydata)
    hold on
    legends{i} = fslabels{i};
end
hold off
title('Fish larvae production')
legend(legends)

subplot(2,2,3)
plot(0:size(handles.Results.B,2),[handles.Data.Guilds(GI.iPOC).binit handles.Results.B(GI.iPOC,:)])
title('Undissolved detritus')

subplot(2,2,4)
plot(0:size(handles.Results.B,2),[handles.Data.Guilds(GI.iDOC).binit handles.Results.B(GI.iDOC,:)])
title('Dissolved detritus')
function updateTotalBiomassFigure(f,handles)

GI = handles.Data.GuildInfo;
Guilds = handles.Data.Guilds;
Iall = 1:GI.nGuilds;
I = setdiff(Iall,GI.iDetritusGuilds);

axs = findobj(get(f,'children'),'type','axes');
tit = get(axs,'title');
tit = [tit{:}];
tit = {tit.String};

str = 'Ecosystem biomass (no detritus)';
ax = axs(strcmp(tit,str));
h = ax.Children;
Becosys = sum([[handles.Data.Guilds(I).binit]' handles.Results.B(I,:)]);
set(h,'xdata',0:size(handles.Results.B,2),'ydata',Becosys)
ax.XTickMode = 'auto';
set(ax,'xtick',unique(round(get(ax,'xtick'))))

str = 'Fish larvae production';
ax = axs(strcmp(tit,str));
h = ax.Children;
fishgls = {Guilds(GI.iFishGuilds).label};
S.subs = {1,1:3};
S.type = '()';
fslabels = unique(cellfun(@(x)subsref(x,S),fishgls,'uniformoutput',false),'stable');
fishgls = cellfun(@(x)subsref(x,S),fishgls,'uniformoutput',false); 
% afishgls = {Guilds(GI.iAdultFishGuilds).label};
% afishgls = cellfun(@(x)subsref(x,S),afishgls,'uniformoutput',false);

for i = 1:length(h)
    I = strcmp(h(i).DisplayName,fslabels);
%     afsinds = strcmpi(fslabels{I},afishgls);
    fsinds = find(strcmpi(fslabels{I},fishgls));
%     set(h(i),'xdata',0:size(handles.Results.GF,2),'ydata',[0 sum(handles.Results.GF(afsinds,:))])
    set(h(i),'xdata',0:size(handles.Results.GF,2),'ydata',[0 sum(handles.Results.GF(fsinds,:))])
end
ax.XTickMode = 'auto';
set(ax,'xtick',unique(round(get(ax,'xtick'))))

str = 'Undissolved detritus';
ax = axs(strcmp(tit,str));
h = ax.Children;
BPOC = [handles.Data.Guilds(GI.iPOC).binit handles.Results.B(GI.iPOC,:)];
set(h,'xdata',0:size(handles.Results.B,2),'ydata',BPOC)
ax.XTickMode = 'auto';
set(ax,'xtick',unique(round(get(ax,'xtick'))))

str = 'Dissolved detritus';
ax = axs(strcmp(tit,str));
h = ax.Children;
BDOC = [handles.Data.Guilds(GI.iDOC).binit handles.Results.B(GI.iDOC,:)];
set(h,'xdata',0:size(handles.Results.B,2),'ydata',BDOC)
ax.XTickMode = 'auto';
set(ax,'xtick',unique(round(get(ax,'xtick'))))
function pushbutton_subnetfigure_Callback(~, ~, handles)

% TODO: Create axes and plots here

f = findobj(get(0,'children'),'name','Subnet Figure');
if isempty(f)
    f = figure('Name','Subnet Figure');
    set(f,'units','normalized','position',[0.5 0 0.5 0.5])
    gnames = {handles.Data.Guilds.name}';
    h=uicontrol(f,'style','popupmenu','String',gnames,'units','normalized', ...
        'Position', [0 0.99 0.1 0.01], ...
        'Callback',@(h,e)updateSubnetFigure(h,e,handles));
else
    figure(f)
    h = findobj(get(f,'children'),'style','popupmenu');
end
updateSubnetFigure(h,[],handles);
function updateSubnetFigure(h, ~, handles)

% TODO: only update axes, do not delete and create new ones, unless popup
% selection has changed

showAllBiomasses = false;
% showAllBiomasses = true;

f = get(h,'parent');
delete(findobj(get(f,'children'),'type','axes'))
I = h.Value;
Guilds = handles.Data.Guilds;
Results = handles.Results;

Cmtx = handles.Data.adjacencyMatrix;
If = find(Cmtx(I,:));
Ip = find(Cmtx(:,I));

Nf = length(If);
Np = length(Ip);

oPadX = 0.05;
oPadY = 0.02;

ah = 0.25;
aph = ah;
ash = ah;
afh = ah;

aPadY = (1-3*ah-2*oPadY)/6;
apPadY = aPadY;
asPadY = aPadY;
afPadY = aPadY;

apPadX = 0.01;
afPadX = 0.01;

Y0f = oPadY+afPadY;
Y0s = oPadY+2*afPadY+asPadY+afh;
Y0p = oPadY+2*afPadY+2*asPadY+apPadY+afh+ash;

asw = 0.3;
apw = (1-2*oPadX)/Np-2*apPadX;
afw = (1-2*oPadX)/Nf-2*afPadX;
apwTot = apw+2*apPadX;
afwTot = afw+2*afPadX;

X0s = (1-asw)/2;
X0p = oPadX+apPadX;
X0f = oPadX+afPadX;

ftsize = 8;

axP = [];
tP = [];
for i = 1:Np
    axP(i) = axes(f,'units','normalized', ...
        'position',[X0p+(i-1)*apwTot Y0p apw aph]); %#ok<AGROW>

    if showAllBiomasses
        B = [[Guilds(Ip(i)).binit] Results.allbiomasses(Ip(i),:)];
        t = linspace(0,size(Results.B,2),length(B));
    else
        B = [[Guilds(Ip(i)).binit] Results.B(Ip(i),:)];
        t = 0:length(B)-1;
    end
    
    plot(axP(i),t,B,'-k')    
    tP(i) = title(axP(i),Guilds(Ip(i)).name); %#ok<AGROW>
end

axS = axes(f,'units','normalized', ...
    'position',[X0s Y0s asw ash], ...
    'fontsize',ftsize);

if showAllBiomasses
    B = [[Guilds(I).binit] Results.allbiomasses(I,:)];
    t = linspace(0,size(Results.B,2),length(B));
else
    B = [[Guilds(I).binit] Results.B(I,:)];
    t = 0:length(B)-1;
end

plot(axS,t,B,'-k')
tS = title(axS,Guilds(I).name);

axF = [];
tF = [];
for i = 1:Nf
    axF(i) = axes(f,'units','normalized', ...
        'position',[X0f+(i-1)*afwTot Y0f afw afh], ...
        'fontsize',ftsize); %#ok<AGROW>

    if showAllBiomasses
        B = [[Guilds(If(i)).binit] Results.allbiomasses(If(i),:)];
        t = linspace(0,size(Results.B,2),length(B));
    else
        B = [[Guilds(If(i)).binit] Results.B(If(i),:)];
        t = 0:length(B)-1;
    end
    
    plot(axF(i),t,B,'-k')        
    tF(i) = title(axF(i),Guilds(If(i)).name); %#ok<AGROW>
end

set(axP,'fontsize',ftsize)
set(axS,'fontsize',ftsize)
set(axF,'fontsize',ftsize)
set(tP,'fontsize',ftsize)
set(tS,'fontsize',ftsize)
set(tF,'fontsize',ftsize)

function edit_numberofyears_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'int',0,999)
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function edit_fishingmortality_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'real',0,91)
    set(handles.tab_simulate.slider_F,'Value',str2double(hObject.String))
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function edit_axeswidth_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'int',0,999)
    handles = saveUIControlValues(handles);
end
handles = refreshAxes(handles);
guidata(hObject, handles)
function edit_length_season_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'int',0,365)
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function edit_releaseproportion_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'real',0,1)
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)

function checkbox_biomassplot_Callback(hObject, ~, handles)
gls = {handles.Data.Guilds(handles.Data.GuildInfo.iFishGuilds).label};
I = find(strcmpi(gls,hObject.String));
J = find(I==handles.Data.GuildInfo.iAdultFishGuildsInFish);
%J = I - (handles.Data.GuildInfo.nLarvaeFishGuilds+handles.Data.GuildInfo.nJuvenileFishGuilds);
if J < 1
    J = [];
end
switch hObject.Value
    case 0
        set(handles.plots.BiomassFishGuild(I),'Visible','off')
        switch handles.tab_simulate.popupmenu_catchtype.Value
            case 1
                set(handles.plots.CatchFishGuildYearly(J),'Visible','off')
                set(handles.plots.CatchFishGuildCumulative,'Visible','off')
                set(handles.plots.CatchFishGuildYearlyPerSpecies,'Visible','off')
                set(handles.plots.CatchFishGuildCumulativePerSpecies,'Visible','off')
            case 2
                set(handles.plots.CatchFishGuildYearly,'Visible','off')
                set(handles.plots.CatchFishGuildCumulative(J),'Visible','off')
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
    case 1
        set(handles.plots.BiomassFishGuild(I),'Visible','on')
        switch handles.tab_simulate.popupmenu_catchtype.Value
            case 1
                set(handles.plots.CatchFishGuildYearly(J),'Visible','on')
                set(handles.plots.CatchFishGuildCumulative,'Visible','off')
                set(handles.plots.CatchFishGuildYearlyPerSpecies,'Visible','off')
                set(handles.plots.CatchFishGuildCumulativePerSpecies,'Visible','off')
            case 2
                set(handles.plots.CatchFishGuildYearly,'Visible','off')
                set(handles.plots.CatchFishGuildCumulative(J),'Visible','on')
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
end
guidata(hObject, handles)
function checkbox_catchable_Callback(~, ~, ~)

function popupmenu_catchtype_Callback(hObject, ~, handles)

visPlotInds = find([handles.tab_simulate.uipanel_biomassplots.Children.Value]);
afishgls = {handles.Data.Guilds(handles.Data.GuildInfo.iAdultFishGuilds).label};
visInds = [];
for i = 1:length(visPlotInds)
    child = handles.tab_simulate.uipanel_biomassplots.Children(visPlotInds(i));
    visInds = [visInds find(strcmpi(child.String,afishgls))]; %#ok<AGROW>
end

switch hObject.Value
    case 1
        set(handles.plots.CatchFishGuildYearly(visInds),'Visible','on')
        set(handles.plots.CatchFishGuildCumulative,'Visible','off')
        set(handles.plots.CatchFishGuildYearlyPerSpecies,'Visible','off')
        set(handles.plots.CatchFishGuildCumulativePerSpecies,'Visible','off')
    case 2
        set(handles.plots.CatchFishGuildYearly,'Visible','off')
        set(handles.plots.CatchFishGuildCumulative(visInds),'Visible','on')
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
function popupmenu_ecosystem_Callback(hObject, ~, handles)

if handles.isSimulationStarted
    answer = questdlg('This will reset simulation, and all progress will be lost. Do you want to continue?', ...
        'Confirm simulation reset','Yes','No','No');
end
if ~handles.isSimulationStarted || strcmpi(answer,'yes')
    load(['Data\' hObject.String{hObject.Value} '.mat'],'Data')
    handles.Data = Data;
    handles.Data = updateGuildInfo(handles.Data);
    handles.minaxeswidth = 5;   % TODO: gather all gui parameters in one place
    handles = resetSimulation(handles);
    handles = initializeGuildTab(handles);
    handles = saveUIControlValues(handles);
    handles.isGuildChange = false;
    handles.isSimulationStarted = false;
    clearFigures;
    guidata(hObject, handles)
else
    hObject.Value = handles.uicontrolvalues.(hObject.Tag);
end
function popupmenu_biomasstype_Callback(hObject, ~, handles)

visPlotInds = find([handles.tab_simulate.uipanel_biomassplots.Children.Value]);
fishgls = {handles.Data.Guilds(handles.Data.GuildInfo.iFishGuilds).label};
visInds = [];
for i = 1:length(visPlotInds)
    child = handles.tab_simulate.uipanel_biomassplots.Children(visPlotInds(i));
    visInds = [visInds find(strcmpi(child.String,fishgls))]; %#ok<AGROW>
end

switch hObject.Value
    case 1
        set(handles.plots.BiomassFishGuild(visInds),'Visible','on')
        set(handles.plots.BiomassFishGuildPerSpecies,'Visible','off')
    case 2
        set(handles.plots.BiomassFishGuild,'Visible','off')
        set(handles.plots.BiomassFishGuildPerSpecies,'Visible','on')
end
function uibuttongroup_gear_SelectionChangedFcn(hObject, ~, handles)
if strcmpi(hObject.String,'Fyke net')
    handles.tab_simulate.edit_releaseproportion.Enable = 'on';
else
    handles.tab_simulate.edit_releaseproportion.Enable = 'off';
end

function slider_F_Callback(hObject, ~, handles)
set(handles.tab_simulate.edit_fishingmortality,'String',num2str(hObject.Value))
handles = saveUIControlValues(handles);
guidata(hObject, handles)


% ------ GUILDS TAB UICONTROLS
function pushbutton_import_Callback(hObject, ~, handles)
answer1 = 'no';
answer2 = 'yes';
if handles.isNotSaved
    answer1 = questdlg('You have unsaved changes in the current ecosystem definitions. Do you want to save changes first?', ...
        'Confirm save changes','Yes','No','No');
end
if strcmpi(answer1,'yes')
    pushbutton_export_Callback(handles.tab_guilds.pushbutton_export, [], handles)
    answer2 = questdlg('Do you want to proceed to importing ecosystem definitions?', ...
        'Confirm save changes','Yes','No','No');
end
if strcmpi(answer2,'yes')
    if handles.isSimulationStarted
        answer3 = questdlg('This will reset simulation, and all progress will be lost. Do you want to continue?', ...
            'Confirm simulation reset','Yes','No','No');
    end
    if ~handles.isSimulationStarted || strcmpi(answer3,'yes')
        [filename, dirname] = uigetfile('*.mat');
        if ischar(filename) && ischar(dirname)
            load([dirname filename])
            if ~exist('Data', 'var')
                errordlg('Data file corrupted.')
            else
                handles.Data = Data;
                handles.Data = updateGuildInfo(handles.Data);
                handles = resetSimulation(handles); %%%
                handles = initializeGuildTab(handles);
                
                % Set ecosystem popupmenu selection to imported datafile
                str_sel = filename(1:end-4);
                handles = updateEcosystemPopupmenu(handles,str_sel);
                ecoStr = handles.tab_simulate.popupmenu_ecosystem.String{handles.tab_simulate.popupmenu_ecosystem.Value};
                handles.tab_guilds.uipanel_tab_guilds.Title = ['Guilds (' ecoStr '.mat)'];
                
                handles.isGuildChange = true;
                handles.isSimulationStarted = false;
                guidata(hObject, handles)
            end
        end
    end
end
function pushbutton_export_Callback(hObject, ~, handles)
handles = saveParameterValues(handles);
[filename, dirname] = uiputfile('*.mat');
if ischar(filename) && ischar(dirname)
    Data = handles.Data;
%     Data = rmfield(Data,{'omega','GuildInfo'}); %#ok<NASGU>
    save([dirname filename],'Data')
    
    % Set ecosystem popupmenu selection to exported datafile
    str_sel = filename(1:end-4);
    handles = updateEcosystemPopupmenu(handles,str_sel);
end
handles.isNotSaved = false;
guidata(hObject, handles)
function pushbutton_add_guild_Callback(hObject, ~, handles)
if handles.isSimulationStarted
    answer = questdlg('This will reset simulation, and all progress will be lost. Do you want to continue?', ...
        'Confirm simulation reset','Yes','No','No');
end
if ~handles.isSimulationStarted || strcmpi(answer,'yes')
    glabel = handles.tab_guilds.edit_label.String;
    if isempty(glabel)
        herror = errordlg('Guild label cannot be empty.');
        uiwait(herror)
        uicontrol(handles.tab_guilds.edit_label)
        return
    end
    if ismember(glabel,{handles.Data.Guilds.label})
        errordlg('Guild label exists already. Choose another label.')
    else
        gtype = handles.tab_guilds.uibuttongroup_type.SelectedObject.String;
        gname = handles.tab_guilds.edit_name.String;
        if isempty(gname)
            herror = errordlg('Guild name cannot be empty.');
            uiwait(herror)
            uicontrol(handles.tab_guilds.edit_name)
            return
        end
        gbinit = str2double(handles.tab_guilds.edit_initial_biomass.String);
        if isnan(gbinit)
            herror = errordlg('Initial biomass cannot be empty.');
            uiwait(herror)
            uicontrol(handles.tab_guilds.edit_initial_biomass)
            return
        end
        
        gigr = str2double(handles.tab_guilds.edit_intrinsic_growth_rate.String);
        gmbr = str2double(handles.tab_guilds.edit_metabolic_rate.String);
        gavgl = str2double(handles.tab_guilds.edit_average_length.String);
        glw_a = str2double(handles.tab_guilds.edit_lw_a.String);
        glw_b = str2double(handles.tab_guilds.edit_lw_b.String);
        gf_m = str2double(handles.tab_guilds.edit_basal_respiration.String);
        gc = str2double(handles.tab_guilds.edit_producer_competition.String);
        gs = str2double(handles.tab_guilds.edit_fraction_of_exudation.String);
        gdiss_rate = str2double(handles.tab_guilds.edit_dissolution_rate.String);
        ghatchery = str2double(handles.tab_guilds.edit_hatchery.String);
        gf_a = str2double(handles.tab_guilds.edit_activity_respiration_coefficient.String);
        ginvest = str2double(handles.tab_guilds.edit_invest.String);
        gcatchable = handles.tab_guilds.checkbox_catchable.Value;
        gPmat = str2double(handles.tab_guilds.edit_Pmat.String);
        gisRef = handles.tab_guilds.checkbox_referenceguild.Value;
        gbodymass = str2double(handles.tab_guilds.edit_bodymass.String);
        genable = handles.tab_guilds.checkbox_enable.Value;
        
        switch lower(gtype)
            case 'fish'
                if length(glabel)~=4 || isnan(str2double(glabel(4)))
                    herror = errordlg(['Label must be four characters long where the ' ...
                        'last character is a number denoting the age of the guild.']);
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_basal_respiration)
                    return
                end
                gigr = [];
                gc = [];
                gage = str2double(glabel(4));
                gs = [];
                gdiss_rate = [];
                
                if isnan(gf_m)
                    herror = errordlg('Basal respiration cannot be empty.');
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_basal_respiration)
                    return
                end
                if isnan(gavgl)
                    herror = errordlg('Average length of individuals cannot be empty.');
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_average_length)
                    return
                end
                if isnan(glw_a)
                    herror = errordlg('Length-weight parameter ''a'' cannot be empty.');
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_lw_a)
                    return
                end
                if isnan(glw_b)
                    herror = errordlg('Length-weight parameter ''b'' cannot be empty.');
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_lw_b)
                    return
                end
                
                Iref = [];
                if isfield(handles.Data.Guilds, 'isRefGuild')
                    Iref = find([handles.Data.Guilds.isRefGuild]);
                end                    
                aRef = 1; % assuming the reference guild is a producer for all of which a=1
                Mref = 6.4e-5; % If no reference guild body mass. Use this default from LC

                if ~isempty(Iref)
                    grefBM = handles.Data.Guilds(Iref).bodymass;
                    if ~isnan(grefBM) && isnumeric(grefBM) && grefBM > 0
                        Mref = grefBM;
                    end
                end
                gmbr = metabolicRate(gavgl,glw_a,glw_b,gtype,Mref,aRef);
                
                if isnan(ghatchery)
                    hwarn = warndlg('Hatchery was left empty. Using default value of 0.');
                    uiwait(hwarn)
                    handles.tab_guilds.edit_hatchery.String = num2str(0);
                    ghatchery = 0;
                end
                if isnan(gf_a)
                    herror = errordlg('Activity respiration coefficient cannot be empty.');
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_activity_respiration_coefficient)
                    return
                end
                if isnan(ginvest)
                    hwarn = warndlg(['Surplus invested to reproduction was left empty. ' ...
                        'Using default value of 0.']);
                    uiwait(hwarn)
                    handles.tab_guilds.edit_invest.String = num2str(0);
                    ginvest = 0;
                end
                if isnan(gPmat)
                    hwarn = warndlg(['Proportion of mature individuals was left empty. ' ...
                        'Using default value of 0.']);
                    uiwait(hwarn)
                    handles.tab_guilds.edit_Pmat.String = num2str(0);
                    gPmat = 0;
                end
                
            case 'consumer'
                gage = [];
                gigr = [];
                gc = [];
                gavgl = [];
                glw_a = [];
                glw_b = [];
                gs = [];
                gdiss_rate = [];
                ghatchery = [];
                ginvest = [];
                gPmat = [];
                
                if isnan(gf_m)
                    herror = errordlg('Basal respiration cannot be empty.');
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_basal_respiration)
                    return
                end
                if isnan(gmbr)
                    herror = errordlg('Metabolic rate cannot be empty.');
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_metabolic_rate)
                    return
                end
                if isnan(gf_a)
                    herror = errordlg('Activity respiration coefficient cannot be empty.');
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_activity_respiration_coefficient)
                    return
                end
            case 'producer'
                gage = [];
                gf_m = [];
                gmbr = [];
                gavgl = [];
                glw_a = [];
                glw_b = [];
                gdiss_rate = [];
                ghatchery = [];
                gf_a = [];
                ginvest = [];
                gPmat = [];
                
                if isnan(gigr)
                    herror = errordlg('Intrinsic growth rate cannot be empty.');
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_intrinsic_growth_rate)
                    return
                end
                if isnan(gc)
                    herror = errordlg('Producer competition cannot be empty.');
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_producer_competition)
                    return
                end
                if isnan(gs)
                    herror = errordlg('Fraction of exudation cannot be empty.');
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_fraction_of_exudation)
                    return
                end
            case 'detritus'
                gage = [];
                gigr = [];
                gmbr = [];
                gf_m = [];
                gc = [];
                gavgl = [];
                glw_a = [];
                glw_b = [];
                gs = [];
                ghatchery = [];
                gf_a = [];
                ginvest = [];
                gPmat = [];
                if isnan(gdiss_rate)
                    hwarn = errordlg(['Dissolution rate was left empty. Using default ' ...
                        'value of 0. If this is particulate organic carbon, ' ...
                        'you must change the rate later.']);
                    uiwait(hwarn)
                    handles.tab_guilds.edit_dissolution_rate.String = num2str(0);
                    gdiss_rate = 0;
                end
        end
        
        newguild = struct( ...
            'label', glabel, 'name', gname, 'type', gtype, 'igr', ...
            gigr, 'mbr', gmbr, 'avgl', gavgl, 'lw_a', glw_a, ...
            'lw_b', glw_b, 'binit', gbinit, 'age', gage, 'f_m', gf_m, ...
            'c', gc, 's', gs, 'diss_rate', gdiss_rate, ...
            'hatchery', ghatchery, 'f_a', gf_a, 'invest', ginvest,  ...
            'catchable', gcatchable, 'Pmat', gPmat, 'isRefGuild', gisRef, ...
            'bodymass', gbodymass, 'enable', genable);

        if gisRef
            J = 1:length(handles.Data.Guilds);
            for j = J
                handles.Data.Guilds(j).isRefGuild = false;
            end
        end
        
        if isempty(handles.Data.Guilds)
            handles.Data.Guilds = newguild;
        else
            if ~isfield(handles.Data.Guilds, 'isRefGuild')
                for i = 1:length(handles.Data.Guilds)
                    handles.Data.Guilds(i).isRefGuild = false;
                end
            end

            if ~isfield(handles.Data.Guilds, 'bodymass')
                for i = 1:length(handles.Data.Guilds)
                    handles.Data.Guilds(i).bodymass = NaN;
                end
            end

            if ~isfield(handles.Data.Guilds, 'enable')
                for i = 1:length(handles.Data.Guilds)
                    handles.Data.Guilds(i).enable = true;
                end
            end
            handles.Data.Guilds(end+1) = newguild;
        end
        
        if isempty(handles.Data.adjacencyMatrix)
            handles.Data.adjacencyMatrix(1,1) = 0;
            handles.Data.B0(1,1) = 0;
            handles.Data.d(1,1) = 0;
            handles.Data.q(1,1) = 0;
            handles.Data.e(1,1) = 0;
            handles.Data.y(1,1) = 0;
        else
            handles.Data.adjacencyMatrix(end+1,:) = 0;
            handles.Data.adjacencyMatrix(:,end+1) = 0;
            handles.Data.B0(end+1,:) = 0;
            handles.Data.B0(:,end+1) = 0;
            handles.Data.d(end+1,:) = 0;
            handles.Data.d(:,end+1) = 0;
            handles.Data.q(end+1,:) = 0;
            handles.Data.q(:,end+1) = 0;
            handles.Data.e(end+1,:) = 0;
            handles.Data.e(:,end+1) = 0;
            handles.Data.y(end+1,:) = 0;
            handles.Data.y(:,end+1) = 0;
        end
        
        value = length(handles.Data.Guilds);
        handles = updateGuildListbox(handles, value);
        handles = updatePreyListbox(handles);
        handles = updateAvailablePreyListbox(handles);
        handles.Data = updateGuildInfo(handles.Data);
        handles = updateEdits(handles);
        handles.isGuildChange = true;
        handles.isNotSaved = true;
        handles.isSimulationStarted = false;
        
        guidata(hObject, handles)
    end
end
function pushbutton_clear_Callback(hObject, ~, handles)
set(findobj(handles.tab_guilds.uipanel_add_guild.Children,'Style','edit'),'String','')
handles.isNotSaved = true;
guidata(hObject, handles)
function pushbutton_delete_Callback(hObject, ~, handles)
if handles.isSimulationStarted
    answer = questdlg('This will reset simulation, and all progress will be lost. Do you want to continue?', ...
        'Confirm simulation reset','Yes','No','No');
end
if ~handles.isSimulationStarted || strcmpi(answer,'yes')
    lvalue = handles.tab_guilds.listbox_guild_list.Value;
    lstrings = handles.tab_guilds.listbox_guild_list.String;
    if ~isempty(lstrings)
        slabel = lstrings{lvalue};
        lvalue = max([lvalue-1 1]);
        
        di = strcmp(slabel,{handles.Data.Guilds.label});
        
        handles.Data.Guilds(di) = [];
        handles.Data.adjacencyMatrix(di,:) = [];
        handles.Data.adjacencyMatrix(:,di) = [];
        handles.Data.B0(di,:) = [];
        handles.Data.B0(:,di) = [];
        handles.Data.d(di,:) = [];
        handles.Data.d(:,di) = [];
        handles.Data.q(di,:) = [];
        handles.Data.q(:,di) = [];
        handles.Data.e(di,:) = [];
        handles.Data.e(:,di) = [];
        handles.Data.y(di,:) = [];
        handles.Data.y(:,di) = [];
        
        handles.Data = updateGuildInfo(handles.Data);
        handles = updateGuildListbox(handles, lvalue);
        handles = updatePreyListbox(handles);
        handles = updateAvailablePreyListbox(handles);
        handles = updateEdits(handles);
        %pushbutton_clear_Callback(handles.tab_guilds.pushbutton_clear, [], handles);
        handles.isGuildChange = true;
        handles.isNotSaved = true;
        handles.isSimulationStarted = false;
        
        uicontrol(handles.tab_guilds.listbox_guild_list)
        
        guidata(hObject, handles)
    end
end
function pushbutton_save_changes_Callback(hObject, ~, handles)
if handles.isSimulationStarted
    answer = questdlg('This will reset simulation, and all progress will be lost. Do you want to continue?', ...
        'Confirm simulation reset','Yes','No','No');
end
if ~handles.isSimulationStarted || strcmpi(answer,'yes')
    handles.Data = updateGuildInfo(handles.Data);
    glabel = handles.tab_guilds.edit_label.String;
    if isempty(glabel)
        herror = errordlg('Guild label cannot be empty.');
        uiwait(herror)
        uicontrol(handles.tab_guilds.edit_label)
        return
    end
    i = handles.tab_guilds.listbox_guild_list.Value;
    noti = setdiff(1:handles.Data.GuildInfo.nGuilds,i);
    if ismember(glabel,{handles.Data.Guilds(noti).label})
        errordlg('Guild label exists already. Choose another label.')
    else
        gtype = handles.tab_guilds.uibuttongroup_type.SelectedObject.String;
        gname = handles.tab_guilds.edit_name.String;
        if isempty(gname)
            herror = errordlg('Guild name cannot be empty.');
            uiwait(herror)
            uicontrol(handles.tab_guilds.edit_name)
            return
        end
        gbinit = str2double(handles.tab_guilds.edit_initial_biomass.String);
        if isnan(gbinit)
            herror = errordlg('Initial biomass cannot be empty.');
            uiwait(herror)
            uicontrol(handles.tab_guilds.edit_initial_biomass)
            return
        end
        
        gigr = str2double(handles.tab_guilds.edit_intrinsic_growth_rate.String);
        gmbr = str2double(handles.tab_guilds.edit_metabolic_rate.String);
        gavgl = str2double(handles.tab_guilds.edit_average_length.String);
        glw_a = str2double(handles.tab_guilds.edit_lw_a.String);
        glw_b = str2double(handles.tab_guilds.edit_lw_b.String);
        gf_m = str2double(handles.tab_guilds.edit_basal_respiration.String);
        gc = str2double(handles.tab_guilds.edit_producer_competition.String);
        gs = str2double(handles.tab_guilds.edit_fraction_of_exudation.String);
        gdiss_rate = str2double(handles.tab_guilds.edit_dissolution_rate.String);
        ghatchery = str2double(handles.tab_guilds.edit_hatchery.String);
        gf_a = str2double(handles.tab_guilds.edit_activity_respiration_coefficient.String);
        ginvest = str2double(handles.tab_guilds.edit_invest.String);
        gcatchable = handles.tab_guilds.checkbox_catchable.Value;
        gPmat = str2double(handles.tab_guilds.edit_Pmat.String);
        gisRef = handles.tab_guilds.checkbox_referenceguild.Value;
        gbodymass = str2double(handles.tab_guilds.edit_bodymass.String);
        genable = handles.tab_guilds.checkbox_enable.Value;
        
        switch lower(gtype)
            case 'fish'
                if length(glabel)~=4 || isnan(str2double(glabel(4)))
                    herror = errordlg(['Label must be four characters long where the ' ...
                        'last character is a number denoting the age of the guild.']);
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_basal_respiration)
                    return
                end
                gigr = [];
                gc = [];
                gage = str2double(glabel(4));
                gs = [];
                gdiss_rate = [];
                
                if isnan(gf_m)
                    herror = errordlg('Basal respiration cannot be empty.');
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_basal_respiration)
                    return
                end
                if isnan(gavgl)
                    herror = errordlg('Average length of individuals cannot be empty.');
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_average_length)
                    return
                end
                if isnan(glw_a)
                    herror = errordlg('Length-weight parameter ''a'' cannot be empty.');
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_lw_a)
                    return
                end
                if isnan(glw_b)
                    herror = errordlg('Length-weight parameter ''b'' cannot be empty.');
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_lw_b)
                    return
                end
                
%                 gmbr = metabolicRate(gavgl,glw_a,glw_b);
                Iref = find([handles.Data.Guilds.isRefGuild]);
                aRef = 1; % assuming the reference guild is a producer for all of which a=1
                Mref = 6.4e-5; % If no reference guild body mass. Use this default from LC
                if ~isempty(Iref)
                    grefBM = handles.Data.Guilds(Iref).bodymass;
                    if ~isnan(grefBM) && isnumeric(grefBM) && grefBM > 0
                        Mref = grefBM;
                    end
                end
                gmbr = metabolicRate(gavgl,glw_a,glw_b,gtype,Mref,aRef);

                if isnan(ghatchery)
                    hwarn = warndlg('Hatchery was left empty. Using default value of 0.');
                    uiwait(hwarn)
                    handles.tab_guilds.edit_hatchery.String = num2str(0);
                    ghatchery = 0;
                end
                if isnan(gf_a)
                    herror = errordlg('Activity respiration coefficient cannot be empty.');
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_activity_respiration_coefficient)
                    return
                end
                if isnan(ginvest)
                    hwarn = warndlg(['Surplus invested to reproduction was left empty. ' ...
                        'Using default value of 0.']);
                    uiwait(hwarn)
                    handles.tab_guilds.edit_invest.String = num2str(0);
                    ginvest = 0;
                end
                if isnan(gPmat)
                    hwarn = warndlg(['Proportion of mature individuals was left empty. ' ...
                        'Using default value of 0.']);
                    uiwait(hwarn)
                    handles.tab_guilds.edit_Pmat.String = num2str(0);
                    gPmat = 0;
                end
              
            case 'consumer'
                gigr = [];
                gc = [];
                gage = [];
                gavgl = [];
                glw_a = [];
                glw_b = [];
                gs = [];
                gdiss_rate = [];
                ghatchery = [];
                ginvest = [];
                gPmat = [];
                
                if isnan(gf_m)
                    herror = errordlg('Basal respiration cannot be empty.');
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_basal_respiration)
                    return
                end
                if isnan(gmbr)
                    herror = errordlg('Metabolic rate cannot be empty.');
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_metabolic_rate)
                    return
                end
                if isnan(gf_a)
                    herror = errordlg('Activity respiration coefficient cannot be empty.');
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_activity_respiration_coefficient)
                    return
                end
            case 'producer'
                gage = [];
                gf_m = [];
                gmbr = [];
                gavgl = [];
                glw_a = [];
                glw_b = [];
                gdiss_rate = [];
                ghatchery = [];
                gf_a = [];
                ginvest = [];
                gPmat = [];
                
                if isnan(gigr)
                    herror = errordlg('Intrinsic growth rate cannot be empty.');
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_intrinsic_growth_rate)
                    return
                end
                if isnan(gc)
                    herror = errordlg('Producer competition cannot be empty.');
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_producer_competition)
                    return
                end
                if isnan(gs)
                    herror = errordlg('Fraction of exudation cannot be empty.');
                    uiwait(herror)
                    uicontrol(handles.tab_guilds.edit_fraction_of_exudation)
                    return
                end
            case 'detritus'
                gage = [];
                gigr = [];
                gmbr = [];
                gf_m = [];
                gc = [];
                gavgl = [];
                glw_a = [];
                glw_b = [];
                gs = [];
                ghatchery = [];
                gf_a = [];
                ginvest = [];
                gPmat = [];
                if isnan(gdiss_rate)
                    hwarn = errordlg(['Dissolution rate was left empty. Using default ' ...
                        'value of 0. If this is the pool of undissolved detritus, ' ...
                        'you must change the rate later.']);
                    uiwait(hwarn)
                    handles.tab_guilds.edit_dissolution_rate.String = num2str(0);
                    gdiss_rate = 0;
                end
        end
        
        handles.Data.Guilds(i).name = gname;
        handles.Data.Guilds(i).label = glabel;
        handles.Data.Guilds(i).age = gage;
        handles.Data.Guilds(i).type = gtype;
        handles.Data.Guilds(i).igr = gigr;
        handles.Data.Guilds(i).mbr = gmbr;
        handles.Data.Guilds(i).avgl = gavgl;
        handles.Data.Guilds(i).lw_a = glw_a;
        handles.Data.Guilds(i).lw_b = glw_b;
        handles.Data.Guilds(i).binit = gbinit;
        handles.Data.Guilds(i).f_m = gf_m;
        handles.Data.Guilds(i).c = gc;
        handles.Data.Guilds(i).s = gs;
        handles.Data.Guilds(i).diss_rate = gdiss_rate;
        handles.Data.Guilds(i).hatchery = ghatchery;
        handles.Data.Guilds(i).f_a = gf_a;
        handles.Data.Guilds(i).invest = ginvest;
        handles.Data.Guilds(i).catchable = gcatchable;
        handles.Data.Guilds(i).Pmat = gPmat;
        handles.Data.Guilds(i).isRefGuild = gisRef;
        handles.Data.Guilds(i).bodymass = gbodymass;
        handles.Data.Guilds(i).enable = genable;
        if gisRef
            J = setdiff(1:length(handles.Data.Guilds),i);
            for j = J
                handles.Data.Guilds(j).isRefGuild = false;
            end
        end
        
        handles = updateGuildListbox(handles, handles.tab_guilds.listbox_guild_list.Value);
        handles.Data = updateGuildInfo(handles.Data);
        handles = updateEdits(handles);
        handles.isGuildChange = true;
        handles.isNotSaved = true;
        handles.isSimulationStarted = false;
        guidata(hObject, handles)
    end
end
function pushbutton_add_food_item_Callback(hObject, ~, handles)
if handles.isSimulationStarted
    answer = questdlg('This will reset simulation, and all progress will be lost. Do you want to continue?', ...
        'Confirm simulation reset','Yes','No','No');
end
if ~handles.isSimulationStarted || strcmpi(answer,'yes')
    i = handles.tab_guilds.listbox_guild_list.Value;
    jj = handles.tab_guilds.listbox_available_prey.Value;
    if jj <= length(handles.tab_guilds.listbox_available_prey.String)
        preyLabel = handles.tab_guilds.listbox_available_prey.String{jj};
        j = find(strcmp({handles.Data.Guilds.label},preyLabel));
        
        handles = setDefaultFParams(handles, i, j);
        
        handles.Data.adjacencyMatrix(i,j) = 1;
        handles = updateAvailablePreyListbox(handles);
        handles = updatePreyListbox(handles);
        
        handles.Data = updateGuildInfo(handles.Data);
        handles.isGuildChange = true;
        handles.isNotSaved = true;
        handles.isSimulationStarted = false;
        guidata(hObject, handles)
    end
end
function pushbutton_remove_food_item_Callback(hObject, ~, handles)
if handles.isSimulationStarted
    answer = questdlg('This will reset simulation, and all progress will be lost. Do you want to continue?', ...
        'Confirm simulation reset','Yes','No','No');
end
if ~handles.isSimulationStarted || strcmpi(answer,'yes')
    i = handles.tab_guilds.listbox_guild_list.Value;
    jj = handles.tab_guilds.listbox_prey.Value;
    if jj <= length(handles.tab_guilds.listbox_prey.String)
        removedpreylabel = handles.tab_guilds.listbox_prey.String{jj};
        %handles.tab_guilds.listbox_prey.String = ...
        %    setdiff(handles.tab_guilds.listbox_prey.String,removedpreylabel);
        %handles.tab_guilds.listbox_prey.Value = max([1 jj-1]);
        % update edits based on new selection
        %listbox_prey_Callback(handles.tab_guilds.listbox_prey, [], handles);
        %handles.tab_guilds.listbox_available_prey.String = ...
        %    union(handles.tab_guilds.listbox_available_prey.String,removedpreylabel);
        %handles.tab_guilds.listbox_available_prey.Value = ...
        %    find(strcmp(handles.tab_guilds.listbox_available_prey.String,removedpreylabel));
        j = find(strcmp({handles.Data.Guilds.label},removedpreylabel));
        handles.Data.adjacencyMatrix(i,j) = 0;
        handles.Data.B0(i,j) = 0;
        handles.Data.d(i,j) = 0;
        handles.Data.y(i,j) = 0;
        handles.Data.q(i,j) = 0;
        handles.Data.e(i,j) = 0;
        handles = updateAvailablePreyListbox(handles);
        handles = updatePreyListbox(handles);
        
        handles.Data = updateGuildInfo(handles.Data);
        handles.isGuildChange = true;
        handles.isNotSaved = true;
        handles.isSimulationStarted = false;
        guidata(hObject, handles)
    end
end
function pushbutton_copydiet_Callback(hObject, ~, handles)
if handles.isSimulationStarted
    answer = questdlg('This will reset simulation, and all progress will be lost. Do you want to continue?', ...
        'Confirm simulation reset','Yes','No','No');
end
if ~handles.isSimulationStarted || strcmpi(answer,'yes')
    i = handles.tab_guilds.listbox_guild_list.Value;
    if i > 1
        handles.Data.adjacencyMatrix(i,:) = handles.Data.adjacencyMatrix(i-1,:);
        handles = updateAvailablePreyListbox(handles);
        handles = updatePreyListbox(handles);
        
        J = find(full(handles.Data.adjacencyMatrix(i,:)));
        if ~isempty(J)
            for j = J
                handles = setDefaultFParams(handles, i, j);
            end
            
            handles.tab_guilds.edit_half_saturation_constant.String = num2str(handles.Data.B0(i,J(1)));
            handles.tab_guilds.edit_feeding_interference_coefficient.String = num2str(handles.Data.d(i,J(1)));
            handles.tab_guilds.edit_F_q.String = num2str(handles.Data.q(i,J(1)));
            handles.tab_guilds.edit_assimilation_efficiency.String = num2str(handles.Data.e(i,J(1)));
            handles.tab_guilds.edit_maximum_consumption_rate.String = num2str(handles.Data.y(i,J(1)));
            
            handles.tab_guilds.listbox_prey.Value = length(handles.tab_guilds.listbox_prey.String);
        end
        
        handles.Data = updateGuildInfo(handles.Data);
        handles.isGuildChange = true;
        handles.isNotSaved = true;
        handles.isSimulationStarted = false;
        guidata(hObject, handles)
    end
end
function pushbutton_clearall_Callback(hObject, ~, handles)
if handles.isSimulationStarted
    answer = questdlg('This will reset simulation, and all progress will be lost. Do you want to continue?', ...
        'Confirm simulation reset','Yes','No','No');
end
if ~handles.isSimulationStarted || strcmpi(answer,'yes')
    handles.Data.Guilds(1:end) = [];
    handles.Data.adjacencyMatrix = sparse([]);
    handles.Data.B0 = sparse([]);
    handles.Data.d = sparse([]);
    handles.Data.q = sparse([]);
    handles.Data.e = sparse([]);
    handles.Data.y = sparse([]);
    if isfield(handles.Data,'omega')
        handles.Data = rmfield(handles.Data,'omega');
    end
    if isfield(handles.Data,'GuildInfo')
        handles.Data = rmfield(handles.Data,'GuildInfo');
    end
    %%%% TODO: clear all other related variables! %%%%
    handles = updateGuildListbox(handles, 1);
    handles = updatePreyListbox(handles);
    handles = updateAvailablePreyListbox(handles);
    handles = updateEdits(handles);
    handles.isGuildChange = true;
    handles.isNotSaved = true;
    handles.isSimulationStarted = false;
    guidata(hObject, handles)
end
function pushbutton_movedown_Callback(hObject, ~, handles)
if handles.isSimulationStarted
    answer = questdlg('This will reset simulation, and all progress will be lost. Do you want to continue?', ...
        'Confirm simulation reset','Yes','No','No');
end
if ~handles.isSimulationStarted || strcmpi(answer,'yes')
    N = length(handles.tab_guilds.listbox_guild_list.String);
    lbtop = handles.tab_guilds.listbox_guild_list.ListboxTop;
    i1 = handles.tab_guilds.listbox_guild_list.Value;
    if i1 < N
        i2 = i1+1;
        handles = swapGuildPositions(handles,i1,i2);
        handles.tab_guilds.listbox_guild_list.ListboxTop = i2-(i1-lbtop);
        handles.isGuildChange = true;
        handles.isNotSaved = true;
        handles.isSimulationStarted = false;
    end
    guidata(hObject, handles)
end
function pushbutton_moveup_Callback(hObject, ~, handles)
if handles.isSimulationStarted
    answer = questdlg('This will reset simulation, and all progress will be lost. Do you want to continue?', ...
        'Confirm simulation reset','Yes','No','No');
end
if ~handles.isSimulationStarted || strcmpi(answer,'yes')
    lbtop = handles.tab_guilds.listbox_guild_list.ListboxTop;
    i1 = handles.tab_guilds.listbox_guild_list.Value;
    if i1 > 1
        i2 = i1-1;
        handles = swapGuildPositions(handles,i1,i2);
        handles.tab_guilds.listbox_guild_list.ListboxTop = max(i2-(i1-lbtop),1);
        handles.isGuildChange = true;
        handles.isNotSaved = true;
        handles.isSimulationStarted = false;
    end
    guidata(hObject, handles)
end
function pushbutton_generateRandomWeb_Callback(hObject, ~, handles)
answer1 = 'no';
answer2 = 'yes';
if handles.isNotSaved
    answer1 = questdlg('You have unsaved changes in the current ecosystem definitions. Do you want to save changes first?', ...
        'Confirm save changes','Yes','No','No');
end
if strcmpi(answer1,'yes')
    pushbutton_export_Callback(handles.tab_guilds.pushbutton_export, [], handles)
    answer2 = questdlg('Do you want to proceed to generating random ecosystem?', ...
        'Confirm discard changes','Yes','No','No');
end
if strcmpi(answer2,'yes')
    if handles.isSimulationStarted
        answer3 = questdlg('This will reset simulation, and all progress will be lost. Do you want to continue?', ...
            'Confirm simulation reset','Yes','No','No');
    end
    if ~handles.isSimulationStarted || strcmpi(answer3,'yes')
        nSpecies = str2double(handles.tab_guilds.edit_numberOfSpecies.String);
        
        handles.Data = generateRandomNetwork(nSpecies);
        handles = saveParameterValues(handles);
        handles.Data = updateGuildInfo(handles.Data);
        handles = resetSimulation(handles); %%%
        handles = initializeGuildTab(handles);
        
        % Save to file here ?
        
        % % Set ecosystem popupmenu selection to imported datafile
        % str_sel = filename(1:end-4);
        % handles = updateEcosystemPopupmenu(handles,str_sel);
        
        handles.isGuildChange = true;
        handles.isSimulationStarted = false;
        guidata(hObject, handles)
    end
end
function pushbutton_test_Callback(~, ~, handles)
handles.Data.K.type = handles.tab_guilds.uibuttongroup_carrying_capacity.SelectedObject.String;
handles.Data.K.mean = str2double(handles.tab_guilds.edit_K_mean.String);
handles.Data.K.standard_deviation = str2double(handles.tab_guilds.edit_K_standard_deviation.String);
handles.Data.K.autocorrelation = str2double(handles.tab_guilds.edit_K_autocorrelation.String);
handles.Data.Cii = str2double(handles.tab_guilds.edit_intraspecificCompetitionCoefficient.String);
handles.Data.nGrowthDays = str2double(handles.tab_guilds.edit_length_season.String);
handles.Data.numberOfYears = str2double(handles.tab_guilds.edit_numberOfYears.String);

if ~isempty(handles.Data.Guilds)
    testweb(handles.Data)
end
function pushbutton_defaults_Callback(hObject, ~, handles)
if handles.isSimulationStarted
    answer = questdlg('This will reset simulation, and all progress will be lost. Do you want to continue?', ...
        'Confirm simulation reset','Yes','No','No');
end
if ~handles.isSimulationStarted || strcmpi(answer,'yes')
    i = handles.tab_guilds.listbox_guild_list.Value;
    jj = handles.tab_guilds.listbox_prey.Value;
    preyLabel = handles.tab_guilds.listbox_prey.String{jj};
    j = find(strcmp({handles.Data.Guilds.label},preyLabel));
    
    handles = setDefaultFParams(handles, i, j);
    
    handles.isGuildChange = true;
    handles.isNotSaved = true;
    handles.isSimulationStarted = false;
    guidata(hObject, handles)
end
function pushbutton_defaultsAll_Callback(hObject, ~, handles)
if handles.isSimulationStarted
    answer = questdlg('This will reset simulation, and all progress will be lost. Do you want to continue?', ...
        'Confirm simulation reset','Yes','No','No');
end
if ~handles.isSimulationStarted || strcmpi(answer,'yes')
    for i = 1:length(handles.tab_guilds.listbox_guild_list.String)
        for jj = 1:length(handles.tab_guilds.listbox_prey.String)
            preyLabel = handles.tab_guilds.listbox_prey.String{jj};
            j = find(strcmp({handles.Data.Guilds.label},preyLabel));
            handles = setDefaultFParams(handles, i, j);
        end
    end
    
    handles.isGuildChange = true;
    handles.isNotSaved = true;
    handles.isSimulationStarted = false;
    guidata(hObject, handles)
end

function edit_name_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'string',[],[])
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function edit_label_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'labelstring',[],[])
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function edit_intrinsic_growth_rate_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'real',0,10)
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function edit_metabolic_rate_Callback(hObject, ~, handles) % POISTA
if isValidInput(hObject,handles,'real',0,1)
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function edit_average_length_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'real',0,1e99)
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function edit_lw_a_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'real',0,1)
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function edit_lw_b_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'real',0,10)
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function edit_initial_biomass_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'real',0,Inf)
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function edit_half_saturation_constant_Callback(hObject, ~, handles)
if handles.isSimulationStarted
    answer = questdlg('This will reset simulation, and all progress will be lost. Do you want to continue?', ...
        'Confirm simulation reset','Yes','No','No');
end
if ~handles.isSimulationStarted || strcmpi(answer,'yes')
    preystrcell = handles.tab_guilds.listbox_prey.String;
    if ~isempty(preystrcell)
        if isValidInput(hObject,handles,'real',0,Inf)
            handles = saveUIControlValues(handles);
            
            selected_prey_label =  preystrcell{handles.tab_guilds.listbox_prey.Value};
            selected_predator_label = handles.tab_guilds.listbox_guild_list.String{ ...
                handles.tab_guilds.listbox_guild_list.Value};
            allguildlabels = {handles.Data.Guilds.label};
            ipredator = strcmpi(allguildlabels,selected_predator_label);
            iprey = strcmpi(allguildlabels,selected_prey_label);
            handles.Data.B0(ipredator,iprey) = ...
                str2double(handles.tab_guilds.edit_half_saturation_constant.String);
            handles.isGuildChange = true;
            handles.isNotSaved = true;
            handles.isSimulationStarted = false;
        end
    else
        warndlg('No prey selected for this guild. Discarding parameter change.', ...
            'No prey selected')
        hObject.String = '';
    end
    guidata(hObject, handles)
end
function edit_feeding_interference_coefficient_Callback(hObject, ~, handles)
if handles.isSimulationStarted
    answer = questdlg('This will reset simulation, and all progress will be lost. Do you want to continue?', ...
        'Confirm simulation reset','Yes','No','No');
end
if ~handles.isSimulationStarted || strcmpi(answer,'yes')
    preystrcell = handles.tab_guilds.listbox_prey.String;
    if ~isempty(preystrcell)
        if isValidInput(hObject,handles,'real',0,1)
            handles = saveUIControlValues(handles);
            
            selected_prey_label = preystrcell{handles.tab_guilds.listbox_prey.Value};
            selected_predator_label = handles.tab_guilds.listbox_guild_list.String{ ...
                handles.tab_guilds.listbox_guild_list.Value};
            allguildlabels = {handles.Data.Guilds.label};
            ipredator = strcmpi(allguildlabels,selected_predator_label);
            iprey = strcmpi(allguildlabels,selected_prey_label);
            handles.Data.d(ipredator,iprey) = ...
                str2double(handles.tab_guilds.edit_feeding_interference_coefficient.String);
            handles.isGuildChange = true;
            handles.isNotSaved = true;
            handles.isSimulationStarted = false;
        end
    else
        warndlg('No prey selected for this guild. Discarding parameter change.', ...
            'No prey selected')
        hObject.String = '';
    end
    guidata(hObject, handles)
end
function edit_basal_respiration_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'real',0,1)
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function edit_producer_competition_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'real',0,2)
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function edit_K_mean_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'real',0,Inf)
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function edit_K_standard_deviation_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'real',0,Inf)
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function edit_K_autocorrelation_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'real',-1,1)
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function edit_F_q_Callback(hObject, ~, handles)
if handles.isSimulationStarted
    answer = questdlg('This will reset simulation, and all progress will be lost. Do you want to continue?', ...
        'Confirm simulation reset','Yes','No','No');
end
if ~handles.isSimulationStarted || strcmpi(answer,'yes')
    preystrcell = handles.tab_guilds.listbox_prey.String;
    if ~isempty(preystrcell)
        if isValidInput(hObject,handles,'real',0,Inf)
            handles = saveUIControlValues(handles);
            
            selected_prey_label =  preystrcell{handles.tab_guilds.listbox_prey.Value};
            selected_predator_label = handles.tab_guilds.listbox_guild_list.String{ ...
                handles.tab_guilds.listbox_guild_list.Value};
            allguildlabels = {handles.Data.Guilds.label};
            ipredator = strcmpi(allguildlabels,selected_predator_label);
            iprey = strcmpi(allguildlabels,selected_prey_label);
            handles.Data.q(ipredator,iprey) = ...
                str2double(handles.tab_guilds.edit_F_q.String);
            handles.isGuildChange = true;
            handles.isNotSaved = true;
            handles.isSimulationStarted = false;
        end
    else
        warndlg('No prey selected for this guild. Discarding parameter change.', ...
            'No prey selected')
        hObject.String = '';
    end
    guidata(hObject, handles)
end
function edit_assimilation_efficiency_Callback(hObject, ~, handles)
if handles.isSimulationStarted
    answer = questdlg('This will reset simulation, and all progress will be lost. Do you want to continue?', ...
        'Confirm simulation reset','Yes','No','No');
end
if ~handles.isSimulationStarted || strcmpi(answer,'yes')
    preystrcell = handles.tab_guilds.listbox_prey.String;
    if ~isempty(preystrcell)
        if isValidInput(hObject,handles,'real',0,Inf)
            handles = saveUIControlValues(handles);
            
            selected_prey_label =  preystrcell{handles.tab_guilds.listbox_prey.Value};
            selected_predator_label = handles.tab_guilds.listbox_guild_list.String{ ...
                handles.tab_guilds.listbox_guild_list.Value};
            allguildlabels = {handles.Data.Guilds.label};
            ipredator = strcmpi(allguildlabels,selected_predator_label);
            iprey = strcmpi(allguildlabels,selected_prey_label);
            handles.Data.e(ipredator,iprey) = ...
                str2double(handles.tab_guilds.edit_assimilation_efficiency.String);
            handles.isGuildChange = true;
            handles.isNotSaved = true;
            handles.isSimulationStarted = false;
        end
    else
        warndlg('No prey selected for this guild. Discarding parameter change.', ...
            'No prey selected')
        hObject.String = '';
    end
    guidata(hObject, handles)
end
function edit_maximum_consumption_rate_Callback(hObject, ~, handles)
if handles.isSimulationStarted
    answer = questdlg('This will reset simulation, and all progress will be lost. Do you want to continue?', ...
        'Confirm simulation reset','Yes','No','No');
end
if ~handles.isSimulationStarted || strcmpi(answer,'yes')
    preystrcell = handles.tab_guilds.listbox_prey.String;
    if ~isempty(preystrcell)
        if isValidInput(hObject,handles,'real',0,Inf)
            handles = saveUIControlValues(handles);
            
            selected_prey_label =  preystrcell{handles.tab_guilds.listbox_prey.Value};
            selected_predator_label = handles.tab_guilds.listbox_guild_list.String{ ...
                handles.tab_guilds.listbox_guild_list.Value};
            allguildlabels = {handles.Data.Guilds.label};
            ipredator = strcmpi(allguildlabels,selected_predator_label);
            iprey = strcmpi(allguildlabels,selected_prey_label);
            handles.Data.y(ipredator,iprey) = ...
                str2double(handles.tab_guilds.edit_maximum_consumption_rate.String);
            handles.isGuildChange = true;
            handles.isNotSaved = true;
            handles.isSimulationStarted = false;
        end
    else
        warndlg('No prey selected for this guild. Discarding parameter change.', ...
            'No prey selected')
        hObject.String = '';
    end
    guidata(hObject, handles)
end
function edit_invest_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'real',0,1)
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function edit_hatchery_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'real',0,Inf)
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function edit_dissolution_rate_Callback(hObject, ~, handles)
%if isValidInput(hObject,handles,'real',0,1)
    handles = saveUIControlValues(handles);
%end
guidata(hObject, handles)
function edit_fraction_of_exudation_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'real',0,1)
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function edit_activity_respiration_coefficient_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'real',0,1)
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function edit_Pmat_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'real',0,1)
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function edit_numberOfSpecies_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'int',0,999)
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function edit_intraspecificCompetitionCoefficient_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'real',0,999)
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function edit_bodymass_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'real',0,Inf)
    handles = saveUIControlValues(handles);
end

iRefGuild = find([handles.Data.Guilds.isRefGuild]);
if ~isempty(iRefGuild)
    if handles.tab_guilds.checkbox_referenceguild.Value == 1 % this is refGuild
        answer = questdlg(['Changing reference guild body mass. Do you want to ' ...
            'update allometric scaling for other guilds?'], ...
            'Confirm allometric scaling update','Yes','No','Yes');
        
        if strcmp(answer, 'Yes')
            MRef = str2double(handles.tab_guilds.edit_bodymass.String);
            handles = updateAllometricScalings(handles, MRef);
        end
    else
        MRef = handles.Data.Guilds(iRefGuild).bodymass;
        M = str2double(hObject.String);
        if strcmpi(handles.tab_guilds.uibuttongroup_type.SelectedObject.String, 'Producer')
            r = intrinsicGrowthRate(M, MRef);
            handles.tab_guilds.edit_intrinsic_growth_rate.String = num2str(r);
        elseif strcmpi(handles.tab_guilds.uibuttongroup_type.SelectedObject.String, 'Consumer')
            x = bodyMassToMetabolicRate(M, 'Consumer', MRef);
            handles.tab_guilds.edit_metabolic_rate.String = num2str(x);
        elseif strcmpi(handles.tab_guilds.uibuttongroup_type.SelectedObject.String, 'Fish')
            x = bodyMassToMetabolicRate(M, 'Fish', MRef);
            handles.tab_guilds.edit_metabolic_rate.String = num2str(x);
        end
    end
end

guidata(hObject, handles)
function edit_numberOfYears_Callback(hObject, ~, handles)
if isValidInput(hObject,handles,'int',0,99999)
    handles = saveUIControlValues(handles);
end
guidata(hObject, handles)
function listbox_guild_list_Callback(hObject, ~, handles)
handles = updatePreyListbox(handles);
handles = updateAvailablePreyListbox(handles);
handles = updateEdits(handles);
handles = setGuildEditStatus(handles);
%
preylabels = handles.tab_guilds.listbox_prey.String;
if ~isempty(preylabels)
    selected_prey_label = preylabels{ ...
        handles.tab_guilds.listbox_prey.Value};
    selected_predator_label = hObject.String{hObject.Value};
    allguildlabels = {handles.Data.Guilds.label};
    ipredator = strcmpi(allguildlabels,selected_predator_label);
    iprey = strcmpi(allguildlabels,selected_prey_label);
    dij = handles.Data.d(ipredator,iprey);
    B0ij = handles.Data.B0(ipredator,iprey);
    qij = handles.Data.q(ipredator,iprey);
    eij = handles.Data.e(ipredator,iprey);
    yij = handles.Data.y(ipredator,iprey);
else
    dij = [];
    B0ij = [];
    qij = [];
    eij = [];
    yij = [];
end
handles.tab_guilds.edit_half_saturation_constant.String = num2str(B0ij);
handles.tab_guilds.edit_feeding_interference_coefficient.String = num2str(dij);
handles.tab_guilds.edit_F_q.String = num2str(qij);
handles.tab_guilds.edit_assimilation_efficiency.String = num2str(eij);
handles.tab_guilds.edit_maximum_consumption_rate.String = num2str(yij);

%
guidata(hObject, handles)
function listbox_prey_Callback(hObject, ~, handles)
%
if isempty(hObject.String)
    handles.tab_guilds.edit_half_saturation_constant.String = '';
    handles.tab_guilds.edit_feeding_interference_coefficient.String = '';
    handles.tab_guilds.edit_F_q.String = '';
    handles.tab_guilds.edit_assimilation_efficiency.String = '';
    handles.tab_guilds.edit_maximum_consumption_rate.String = '';
else
    selected_prey_label = hObject.String{hObject.Value};
    selected_predator_label = handles.tab_guilds.listbox_guild_list.String{ ...
        handles.tab_guilds.listbox_guild_list.Value};
    allguildlabels = {handles.Data.Guilds.label};
    ipredator = strcmpi(allguildlabels,selected_predator_label);
    iprey = strcmpi(allguildlabels,selected_prey_label);
    dij = handles.Data.d(ipredator,iprey);
    B0ij = handles.Data.B0(ipredator,iprey);
    qij = handles.Data.q(ipredator,iprey);
    eij = handles.Data.e(ipredator,iprey);
    yij = handles.Data.y(ipredator,iprey);
    handles.tab_guilds.edit_half_saturation_constant.String = num2str(B0ij);
    handles.tab_guilds.edit_feeding_interference_coefficient.String = num2str(dij);
    handles.tab_guilds.edit_F_q.String = num2str(qij);
    handles.tab_guilds.edit_assimilation_efficiency.String = num2str(eij);
    handles.tab_guilds.edit_maximum_consumption_rate.String = num2str(yij);
end
%
guidata(hObject, handles)
function listbox_available_prey_Callback(~, ~, ~)

function uibuttongroup_type_SelectionChangedFcn(hObject, ~, handles)
handles = setGuildEditStatus(handles);
guidata(hObject, handles)
function uibuttongroup_carrying_capacity_SelectionChangedFcn(hObject, ~, handles)
switch hObject.Tag
    case 'radiobutton_K_constant'
        handles.tab_guilds.edit_K_mean.Enable = 'on';
        handles.tab_guilds.edit_K_standard_deviation.Enable = 'off';
        handles.tab_guilds.edit_K_autocorrelation.Enable = 'off';
    case 'radiobutton_K_white_noise'
        handles.tab_guilds.edit_K_mean.Enable = 'on';
        handles.tab_guilds.edit_K_standard_deviation.Enable = 'on';
        handles.tab_guilds.edit_K_autocorrelation.Enable = 'off';
        
        if isempty(handles.tab_guilds.edit_K_standard_deviation.String)
            defaultStd = 0.1*str2double(handles.tab_guilds.edit_K_mean.String);
            handles.tab_guilds.edit_K_standard_deviation.String = defaultStd;
        end
    case 'radiobutton_K_AR1'
        handles.tab_guilds.edit_K_mean.Enable = 'on';
        handles.tab_guilds.edit_K_standard_deviation.Enable = 'on';
        handles.tab_guilds.edit_K_autocorrelation.Enable = 'on';
        if isempty(handles.tab_guilds.edit_K_standard_deviation.String)
            defaultStd = 0.1*str2double(handles.tab_guilds.edit_K_mean.String);
            handles.tab_guilds.edit_K_standard_deviation.String = defaultStd;
        end
        if isempty(handles.tab_guilds.edit_K_autocorrelation.String)
            defaultCorr = 0.9;
            handles.tab_guilds.edit_K_autocorrelation.String = defaultCorr;
        end

end
guidata(hObject, handles)

function checkbox_referenceguild_Callback(hObject, ~, handles)
if hObject.Value
    handles = setAsReferenceGuild(handles);
    handles = updateEdits(handles);
end
guidata(hObject, handles)

% ----------------------------------------------------------------------- %
% ------------------------------ CreateFcns ----------------------------- %
% ----------------------------------------------------------------------- %

function atn_gui_CreateFcn(~, ~, ~)
function edit_fishingmortality_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_numberofyears_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu_catchtype_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_axeswidth_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_name_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_label_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_metabolic_rate_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_intrinsic_growth_rate_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function listbox_guild_list_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function listbox_prey_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function listbox_available_prey_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_average_length_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_lw_a_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_lw_b_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_initial_biomass_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_length_season_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_half_saturation_constant_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_feeding_interference_coefficient_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_releaseproportion_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_basal_respiration_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_producer_competition_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu_ecosystem_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_K_mean_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_K_standard_deviation_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_K_autocorrelation_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_F_q_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_assimilation_efficiency_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_maximum_consumption_rate_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_invest_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_hatchery_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_dissolution_rate_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_fraction_of_exudation_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_activity_respiration_coefficient_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu_biomasstype_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function slider_F_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function edit_Pmat_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_numberOfSpecies_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_intraspecificCompetitionCoefficient_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_bodymass_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_numberOfYears_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ----------------------------------------------------------------------- %
% -------------------------------- Tools -------------------------------- %
% ----------------------------------------------------------------------- %

function status = isValidInput(hObject,handles,type,low,up)
val = hObject.String;
status = true;
switch type
    case 'int'
        nVal = str2double(val);
        if isempty(nVal) || double(int16(nVal)) ~= nVal || nVal < low || nVal > up ||  isnan(nVal)
            status = false;
            hObject.String = handles.uicontrolvalues.(hObject.Tag);
            errordlg(['Invalid input. Must be integer, >= ' ...
                num2str(low) ' and <= ' num2str(up)])
        end
    case 'real'
        nVal = str2double(val);
        if isempty(nVal) || ~isreal(nVal) || nVal < low || nVal > up || isnan(nVal)
            status = false;
            hObject.String = handles.uicontrolvalues.(hObject.Tag);
            errordlg(['Invalid input. Must be real, >= ' ...
                num2str(low) ' and <= ' num2str(up)])
        end
    case 'labelstring'
        if isempty(val) || ~isvarname(['test_' val])
            status = false;
            hObject.String = handles.uicontrolvalues.(hObject.Tag);
            errordlg('Invalid input. Must be nonempty string containing letters, digits, or underscores')
        end
    case 'string'
        % no restrictions at the moment
    otherwise
        keyboard
end
function handles = saveUIControlValues(handles)
uicv.edit_fishingmortality = handles.tab_simulate.edit_fishingmortality.String;
uicv.edit_numberofyears = handles.tab_simulate.edit_numberofyears.String;
uicv.edit_axeswidth = handles.tab_simulate.edit_axeswidth.String;
uicv.popupmenu_catchtype = handles.tab_simulate.popupmenu_catchtype.Value;
uicv.edit_releaseproportion = handles.tab_simulate.edit_releaseproportion.String;
uicv.popupmenu_ecosystem = handles.tab_simulate.popupmenu_ecosystem.Value;

uicv.edit_name = handles.tab_guilds.edit_name.String;
uicv.edit_label = handles.tab_guilds.edit_label.String;
uicv.edit_intrinsic_growth_rate = handles.tab_guilds.edit_intrinsic_growth_rate.String;
uicv.edit_metabolic_rate = handles.tab_guilds.edit_metabolic_rate.String;
uicv.edit_average_length = handles.tab_guilds.edit_average_length.String;
uicv.edit_lw_a = handles.tab_guilds.edit_lw_a.String;
uicv.edit_lw_b = handles.tab_guilds.edit_lw_b.String;
uicv.edit_initial_biomass = handles.tab_guilds.edit_initial_biomass.String;
uicv.edit_basal_respiration = handles.tab_guilds.edit_basal_respiration.String;
uicv.edit_producer_competition = handles.tab_guilds.edit_producer_competition.String;
uicv.edit_half_saturation_constant = handles.tab_guilds.edit_half_saturation_constant.String;
uicv.edit_feeding_interference_coefficient = handles.tab_guilds.edit_feeding_interference_coefficient.String;
uicv.edit_F_q = handles.tab_guilds.edit_F_q.String;
uicv.edit_length_season = handles.tab_guilds.edit_length_season.String;
uicv.edit_K_mean = handles.tab_guilds.edit_K_mean.String;
uicv.edit_K_standard_deviation = handles.tab_guilds.edit_K_standard_deviation.String;
uicv.edit_K_autocorrelation = handles.tab_guilds.edit_K_autocorrelation.String;
uicv.edit_fraction_of_exudation = handles.tab_guilds.edit_fraction_of_exudation.String;
uicv.edit_dissolution_rate = handles.tab_guilds.edit_dissolution_rate.String;
uicv.edit_hatchery = handles.tab_guilds.edit_hatchery.String;
uicv.edit_activity_respiration_coefficient = handles.tab_guilds.edit_activity_respiration_coefficient.String;
uicv.edit_invest = handles.tab_guilds.edit_invest.String;
uicv.edit_Pmat = handles.tab_guilds.edit_Pmat.String;
uicv.edit_numberOfGuilds = handles.tab_guilds.edit_numberOfSpecies.String;
uicv.edit_numberOfSpecies = handles.tab_guilds.edit_numberOfSpecies.String;
uicv.edit_intraspecificCompetitionCoefficient = handles.tab_guilds.edit_intraspecificCompetitionCoefficient.String;
uicv.edit_bodymass = handles.tab_guilds.edit_bodymass.String;
uicv.edit_numberOfYears = handles.tab_guilds.edit_numberOfYears;

% TODO: add more if needed
handles.uicontrolvalues = uicv;
handles.isGuildChange = true;
handles.isNotSaved = true;

function enableUIControls(~, handles, status)
% enableUIControls - used to disable/enable UIControls during computation
handles.tab_simulate.radiobutton_gear_1.Enable = status;
handles.tab_simulate.radiobutton_gear_2.Enable = status;
handles.tab_simulate.radiobutton_gear_3.Enable = status;
handles.tab_simulate.edit_fishingmortality.Enable = status;
handles.tab_simulate.edit_numberofyears.Enable = status;
% if handles.Game.gameover
%     handles.tab_simulate.pushbutton_gofishing.Enable = 'off';
%     handles.tab_simulate.pushbutton_nofishing.Enable = 'off';
% else
    handles.tab_simulate.pushbutton_gofishing.Enable = status;
    handles.tab_simulate.pushbutton_nofishing.Enable = status;
% end
%handles.tab_simulate.pushbutton_reset.Enable = status;
% handles.tab_simulate.pushbutton_planktonfigure.Enable = status;
% handles.tab_simulate.pushbutton_totalbiomassfigure.Enable = status;
handles.tab_simulate.pushbutton_save_results.Enable = status;
handles.tab_simulate.pushbutton_rewind.Enable = status;
handles.tab_simulate.edit_numberofyears.Enable = status;
if handles.tab_simulate.radiobutton_gear_3.Value
    handles.tab_simulate.edit_releaseproportion.Enable = status;
else
    handles.tab_simulate.edit_releaseproportion.Enable = 'off';
end
handles.tab_simulate.popupmenu_ecosystem.Enable = status;
if strcmp(status,'on')
    handles.tab_simulate.pushbutton_stop.Enable = 'off';
else
    handles.tab_simulate.pushbutton_stop.Enable = 'on';
end
drawnow
function handles = simulateForward(handles)

nYearsFwd = str2double(handles.tab_simulate.edit_numberofyears.String);
handles.Data.nYearsFwd = nYearsFwd;
handles.Data.nGrowthDays = str2double(handles.tab_guilds.edit_length_season.String);
tspan = 0:handles.Data.nGrowthDays;
GI = handles.Data.GuildInfo;
% Guilds = handles.Data.Guilds;

Options = handles.Options;
Options.isNewVersion = handles.tab_simulate.checkbox_newVersion.Value;
Options.intraspecificProducerCompetitionCoefficient = str2double(handles.tab_guilds.edit_intraspecificCompetitionCoefficient.String);

handles.Data.K.type = handles.tab_guilds.uibuttongroup_carrying_capacity.SelectedObject.String;
handles.Data.K.mean = str2double(handles.tab_guilds.edit_K_mean.String);
handles.Data.K.standard_deviation = str2double(handles.tab_guilds.edit_K_standard_deviation.String);
handles.Data.K.autocorrelation = str2double(handles.tab_guilds.edit_K_autocorrelation.String);


ODEData = compileOdeData(handles.Data,Options);
% Options.isNewVersion = boolean(handles.tab_simulate.checkbox_newVersion.Value);

ODEData = addIndices(ODEData,GI,Options);
ODEData.ltspan = length(tspan);

for i = 1:nYearsFwd
    
    if handles.tab_simulate.pushbutton_stop.UserData.simulationStopped
        handles.tab_simulate.text_simulationstatus.String = ...
            ['Status: simulation stopped (' num2str(i) '/' num2str(nYearsFwd) ')'];
        drawnow
        handles.tab_simulate.pushbutton_stop.UserData.simulationStopped = false;
        return
    end
    
    ODEData.year = i;
    
    handles.tab_simulate.text_simulationstatus.String = ...
        ['Status: running (' num2str(i) '/' num2str(nYearsFwd) ')'];
    drawnow
    
    %% One year at a time with catch
    Binit = handles.Simulation.Binit;
    
    Xinit = initialValueVector(Binit, GI, Options.Outputs);
    
    % Producer carrying capacity as a function of dissolved detritus biomass
    ODEData.K.values(ODEData.year) = basalProductionCarryingCapacity(Binit(GI.iDOC), ...
        ODEData.K.values(ODEData.year), Options.isNewVersion);
    
    % TODO: check which one is faster -->
    
    %[~,BC] = ode23(@(t,BC)atn_ode_biomass_catch_gainfish_gain_loss_fast(t,BC,Data), ...
    %    tspan,Xinit);

    
%     odeopt = odeset('RelTol',1e-6,'AbsTol',1e-10,'NonNegative',1:GI.nGuilds);
    
    odeopt = odeset('NonNegative',1:GI.nGuilds);
    
    % We can restrict the solution to be non-negative to avoid errors.
    [~,X] = ode23(@(t,X)atn_ode(t,X,ODEData,Options), ...
        tspan,Xinit,odeopt);
    
    if ~isreal(X) || any(any(isnan(X)))
        herror = errordlg('Differential eqution solver returned non real biomasses. Check model parameters.');
        uiwait(herror)
        return
    end
    
    if ~Options.isNewVersion
        %%%%%% Fix for constraining the biomass of dissolved detritus %%%%%%%%
        bDOC_max = 1e6;
        X(end,GI.iDOC) = min([X(end,GI.iDOC) bDOC_max]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    Xend = X(end,:)';
    
    [handles.Simulation.Binit, OUT] = reproductionAndAging(Xend, ODEData.Inds, handles.Data.Guilds, GI, Options.Outputs);
%     Xend(Data.Inds.iB) = Binit;
    Xend(ODEData.Inds.iB) = handles.Simulation.Binit;
    
    resI = size(handles.Results.B,2)+1;
    handles.Results = updateResultsStruct(handles.Results,Xend,ODEData.Inds,OUT,X,resI,ODEData,GI,Options);    

    handles = refreshAxes(handles); % Refresh plots at each time step
    
end

%%
% if true
if false
    f=figure(101010);
    f.Name = 'Juveniles and spawners';
    
    subplot(211)
    for k = 1:GI.nFishSpecies
        SSB = [handles.Data.Guilds(GI.iFishGuilds(k)).binit handles.Results.SSB(k,1:end-1)];
        JB = handles.Results.JB(k,1:end);
        plot(SSB,JB,'.--','markersize',10,'color',handles.Options.Plots.linecolors(k,:))
        hold on
    end
    hold off
    xlabel('SSB'); ylabel('JB');
    
    subplot(212)
    for k = 1:GI.nFishSpecies
        SSB = [handles.Data.Guilds(GI.iFishGuilds(k)).binit handles.Results.SSB(k,1:end-1)];
        JB = handles.Results.JB(k,1:end);
        plot(JB./SSB,'color',handles.Options.Plots.linecolors(k,:))
        hold on
    end
    hold off
    xlabel('Year'); ylabel('JB/SSB')
end
%%

handles.tab_simulate.text_simulationstatus.String = 'Status: ready';
function handles = groupHandles(handles)

% ------ SIMULATE TAB UICONTROLS
tab_simulate.all(1) = handles.uipanel_tab_simulate;
tab_simulate.all(end+1) = handles.axes_biomass;
tab_simulate.all(end+1) = handles.axes_catch;
tab_simulate.all(end+1) = handles.uibuttongroup_gear;
tab_simulate.all(end+1) = handles.radiobutton_gear_1;
tab_simulate.all(end+1) = handles.radiobutton_gear_2;
tab_simulate.all(end+1) = handles.radiobutton_gear_3;
tab_simulate.all(end+1) = handles.uipanel_fishingpressure;
tab_simulate.all(end+1) = handles.edit_fishingmortality;
tab_simulate.all(end+1) = handles.text_fishingmortality;
tab_simulate.all(end+1) = handles.uipanel_simulate;
tab_simulate.all(end+1) = handles.edit_numberofyears;
tab_simulate.all(end+1) = handles.text_numberofyears;
tab_simulate.all(end+1) = handles.pushbutton_gofishing;
tab_simulate.all(end+1) = handles.pushbutton_nofishing;
tab_simulate.all(end+1) = handles.text_simulationstatus;
tab_simulate.all(end+1) = handles.pushbutton_reset;
tab_simulate.all(end+1) = handles.popupmenu_catchtype;
tab_simulate.all(end+1) = handles.text_axeswidth;
tab_simulate.all(end+1) = handles.edit_axeswidth;
tab_simulate.all(end+1) = handles.uipanel_biomassplots;
tab_simulate.all(end+1) = handles.pushbutton_save_results;
tab_simulate.all(end+1) = handles.text_releaseproportion;
tab_simulate.all(end+1) = handles.edit_releaseproportion;
tab_simulate.all(end+1) = handles.pushbutton_planktonfigure;
tab_simulate.all(end+1) = handles.popupmenu_ecosystem;
tab_simulate.all(end+1) = handles.pushbutton_rewind;
tab_simulate.all(end+1) = handles.pushbutton_stop;
tab_simulate.all(end+1) = handles.pushbutton_totalbiomassfigure;
tab_simulate.all(end+1) = handles.popupmenu_biomasstype;
tab_simulate.all(end+1) = handles.slider_F;
tab_simulate.all(end+1) = handles.pushbutton_subnetfigure;
tab_simulate.all(end+1) = handles.checkbox_newVersion;

tab_simulate.uipanel_tab_simulate = handles.uipanel_tab_simulate;
tab_simulate.axes_biomass = handles.axes_biomass;
tab_simulate.axes_catch = handles.axes_catch;
tab_simulate.uibuttongroup_gear = handles.uibuttongroup_gear;
tab_simulate.radiobutton_gear_1 = handles.radiobutton_gear_1;
tab_simulate.radiobutton_gear_2 = handles.radiobutton_gear_2;
tab_simulate.radiobutton_gear_3 = handles.radiobutton_gear_3;
tab_simulate.uipanel_fishingpressure = handles.uipanel_fishingpressure;
tab_simulate.edit_fishingmortality = handles.edit_fishingmortality;
tab_simulate.text_fishingmortality = handles.text_fishingmortality;
tab_simulate.uipanel_simulate = handles.uipanel_simulate;
tab_simulate.edit_numberofyears = handles.edit_numberofyears;
tab_simulate.text_numberofyears = handles.text_numberofyears;
tab_simulate.pushbutton_gofishing = handles.pushbutton_gofishing;
tab_simulate.pushbutton_nofishing = handles.pushbutton_nofishing;
tab_simulate.text_simulationstatus = handles.text_simulationstatus;
tab_simulate.pushbutton_reset = handles.pushbutton_reset;
tab_simulate.popupmenu_catchtype = handles.popupmenu_catchtype;
tab_simulate.text_axeswidth = handles.text_axeswidth;
tab_simulate.edit_axeswidth = handles.edit_axeswidth;
tab_simulate.pushbutton_save_results = handles.pushbutton_save_results;
tab_simulate.uipanel_biomassplots = handles.uipanel_biomassplots;
tab_simulate.text_releaseproportion = handles.text_releaseproportion;
tab_simulate.edit_releaseproportion = handles.edit_releaseproportion;
tab_simulate.pushbutton_planktonfigure = handles.pushbutton_planktonfigure;
tab_simulate.popupmenu_ecosystem = handles.popupmenu_ecosystem;
tab_simulate.pushbutton_rewind = handles.pushbutton_rewind;
tab_simulate.pushbutton_stop = handles.pushbutton_stop;
tab_simulate.pushbutton_totalbiomassfigure = handles.pushbutton_totalbiomassfigure;
tab_simulate.popupmenu_biomasstype = handles.popupmenu_biomasstype;
tab_simulate.slider_F = handles.slider_F;
tab_simulate.pushbutton_subnetfigure = handles.pushbutton_subnetfigure;
tab_simulate.checkbox_newVersion = handles.checkbox_newVersion;

handles = rmfield(handles,{'uipanel_tab_simulate','axes_biomass','axes_catch', ...
    'uibuttongroup_gear','radiobutton_gear_1','radiobutton_gear_2','radiobutton_gear_3', ...
    'uipanel_fishingpressure','edit_fishingmortality', ...
    'text_fishingmortality','uipanel_simulate','edit_numberofyears','pushbutton_gofishing', ...
    'pushbutton_nofishing', ...
    'text_simulationstatus', 'pushbutton_reset', 'popupmenu_catchtype', ...
    'text_axeswidth', 'edit_axeswidth', 'text_numberofyears', ...
    'uipanel_biomassplots','pushbutton_save_results', ...
    'text_releaseproportion', 'edit_releaseproportion','pushbutton_planktonfigure', ...
    'popupmenu_ecosystem','pushbutton_rewind', ...
    'pushbutton_stop','pushbutton_totalbiomassfigure', ...
    'popupmenu_biomasstype','slider_F','pushbutton_subnetfigure', ...
    'pushbutton_stop','pushbutton_totalbiomassfigure', ...
    'checkbox_newVersion'});

handles.tab_simulate = tab_simulate;


% ------ GUILDS TAB UICONTROLS
tab_guilds.all(1) = handles.uipanel_tab_guilds;
tab_guilds.all(end+1) = handles.uipanel_add_guild;
tab_guilds.all(end+1) = handles.text_name;
tab_guilds.all(end+1) = handles.edit_name;
tab_guilds.all(end+1) = handles.text_label;
tab_guilds.all(end+1) = handles.text_intrinsic_growth_rate;
tab_guilds.all(end+1) = handles.text_metabolic_rate;
tab_guilds.all(end+1) = handles.edit_label;
tab_guilds.all(end+1) = handles.edit_intrinsic_growth_rate;
tab_guilds.all(end+1) = handles.edit_metabolic_rate;
tab_guilds.all(end+1) = handles.pushbutton_add_guild;
tab_guilds.all(end+1) = handles.pushbutton_save_changes;
tab_guilds.all(end+1) = handles.pushbutton_clear;
tab_guilds.all(end+1) = handles.uibuttongroup_type;
tab_guilds.all(end+1) = handles.uipanel_guild_list;
tab_guilds.all(end+1) = handles.listbox_guild_list;
tab_guilds.all(end+1) = handles.pushbutton_delete;
tab_guilds.all(end+1) = handles.pushbutton_import;
tab_guilds.all(end+1) = handles.pushbutton_export;
tab_guilds.all(end+1) = handles.radiobutton_consumer;
tab_guilds.all(end+1) = handles.radiobutton_producer;
tab_guilds.all(end+1) = handles.radiobutton_detritus;
tab_guilds.all(end+1) = handles.listbox_prey;
tab_guilds.all(end+1) = handles.listbox_available_prey;
tab_guilds.all(end+1) = handles.pushbutton_add_food_item;
tab_guilds.all(end+1) = handles.pushbutton_remove_food_item;
tab_guilds.all(end+1) = handles.pushbutton_copydiet;
tab_guilds.all(end+1) = handles.pushbutton_clearall;
tab_guilds.all(end+1) = handles.radiobutton_fish;
tab_guilds.all(end+1) = handles.text_average_length;
tab_guilds.all(end+1) = handles.edit_average_length;
tab_guilds.all(end+1) = handles.text_length_weight_parameters;
tab_guilds.all(end+1) = handles.edit_lw_a;
tab_guilds.all(end+1) = handles.edit_lw_b;
tab_guilds.all(end+1) = handles.text_lw_a;
tab_guilds.all(end+1) = handles.text_lw_b;
tab_guilds.all(end+1) = handles.edit_initial_biomass;
tab_guilds.all(end+1) = handles.text_initial_biomass;
tab_guilds.all(end+1) = handles.pushbutton_moveup;
tab_guilds.all(end+1) = handles.pushbutton_movedown;
tab_guilds.all(end+1) = handles.text_half_saturation_constant;
tab_guilds.all(end+1) = handles.edit_half_saturation_constant;
tab_guilds.all(end+1) = handles.text_feeding_interference_coefficient;
tab_guilds.all(end+1) = handles.edit_feeding_interference_coefficient;
tab_guilds.all(end+1) = handles.edit_length_season;
tab_guilds.all(end+1) = handles.text_length_season;
tab_guilds.all(end+1) = handles.edit_basal_respiration;
tab_guilds.all(end+1) = handles.text_basal_respiration;
tab_guilds.all(end+1) = handles.edit_producer_competition;
tab_guilds.all(end+1) = handles.text_producer_competition;
tab_guilds.all(end+1) = handles.uibuttongroup_carrying_capacity;
tab_guilds.all(end+1) = handles.radiobutton_K_constant;
tab_guilds.all(end+1) = handles.radiobutton_K_white_noise;
tab_guilds.all(end+1) = handles.radiobutton_K_AR1;
tab_guilds.all(end+1) = handles.text_K_mean;
tab_guilds.all(end+1) = handles.edit_K_mean;
tab_guilds.all(end+1) = handles.text_K_standard_deviation;
tab_guilds.all(end+1) = handles.edit_K_standard_deviation;
tab_guilds.all(end+1) = handles.text_K_autocorrelation;
tab_guilds.all(end+1) = handles.edit_K_autocorrelation;
tab_guilds.all(end+1) = handles.text_F_q;
tab_guilds.all(end+1) = handles.edit_F_q;
tab_guilds.all(end+1) = handles.text_assimilation_efficiency;
tab_guilds.all(end+1) = handles.edit_assimilation_efficiency;
tab_guilds.all(end+1) = handles.text_maximum_consumption_rate;
tab_guilds.all(end+1) = handles.edit_maximum_consumption_rate;
tab_guilds.all(end+1) = handles.text_fraction_of_exudation;
tab_guilds.all(end+1) = handles.edit_fraction_of_exudation;
tab_guilds.all(end+1) = handles.text_dissolution_rate;
tab_guilds.all(end+1) = handles.edit_dissolution_rate;
tab_guilds.all(end+1) = handles.text_hatchery;
tab_guilds.all(end+1) = handles.edit_hatchery;
tab_guilds.all(end+1) = handles.text_invest;
tab_guilds.all(end+1) = handles.edit_invest;
tab_guilds.all(end+1) = handles.text_activity_respiration_coefficient;
tab_guilds.all(end+1) = handles.edit_activity_respiration_coefficient;
tab_guilds.all(end+1) = handles.checkbox_catchable;
tab_guilds.all(end+1) = handles.text_Pmat;
tab_guilds.all(end+1) = handles.edit_Pmat;
tab_guilds.all(end+1) = handles.pushbutton_generateRandomWeb;
tab_guilds.all(end+1) = handles.text_numberOfSpecies;
tab_guilds.all(end+1) = handles.edit_numberOfSpecies;
tab_guilds.all(end+1) = handles.text_intraspecificCompetitionCoefficient;
tab_guilds.all(end+1) = handles.edit_intraspecificCompetitionCoefficient;
tab_guilds.all(end+1) = handles.text_bodymass;
tab_guilds.all(end+1) = handles.edit_bodymass;
tab_guilds.all(end+1) = handles.checkbox_referenceguild;
tab_guilds.all(end+1) = handles.pushbutton_test;
tab_guilds.all(end+1) = handles.pushbutton_defaults;
tab_guilds.all(end+1) = handles.checkbox_enable;
tab_guilds.all(end+1) = handles.pushbutton_defaultsAll;
tab_guilds.all(end+1) = handles.text_numberOfYears;
tab_guilds.all(end+1) = handles.edit_numberOfYears;

tab_guilds.uipanel_tab_guilds = handles.uipanel_tab_guilds;
tab_guilds.uipanel_add_guild = handles.uipanel_add_guild;
tab_guilds.text_name = handles.text_name;
tab_guilds.text_label = handles.text_label;
tab_guilds.text_intrinsic_growth_rate = handles.text_intrinsic_growth_rate;
tab_guilds.text_metabolic_rate = handles.text_metabolic_rate;
tab_guilds.edit_name = handles.edit_name;
tab_guilds.edit_label = handles.edit_label;
tab_guilds.edit_intrinsic_growth_rate = handles.edit_intrinsic_growth_rate;
tab_guilds.edit_metabolic_rate = handles.edit_metabolic_rate;
tab_guilds.pushbutton_add_guild = handles.pushbutton_add_guild;
tab_guilds.pushbutton_save_changes = handles.pushbutton_save_changes;
tab_guilds.pushbutton_clear = handles.pushbutton_clear;
tab_guilds.uibuttongroup_type = handles.uibuttongroup_type;
tab_guilds.uipanel_guild_list = handles.uipanel_guild_list;
tab_guilds.listbox_guild_list = handles.listbox_guild_list;
tab_guilds.pushbutton_delete = handles.pushbutton_delete;
tab_guilds.pushbutton_import = handles.pushbutton_import;
tab_guilds.pushbutton_export = handles.pushbutton_export;
tab_guilds.radiobutton_consumer = handles.radiobutton_consumer;
tab_guilds.radiobutton_producer = handles.radiobutton_producer;
tab_guilds.radiobutton_detritus = handles.radiobutton_detritus;
tab_guilds.listbox_prey = handles.listbox_prey;
tab_guilds.listbox_available_prey = handles.listbox_available_prey;
tab_guilds.pushbutton_add_food_item = handles.pushbutton_add_food_item;
tab_guilds.pushbutton_remove_food_item = handles.pushbutton_remove_food_item;
tab_guilds.pushbutton_copydiet = handles.pushbutton_copydiet;
tab_guilds.pushbutton_clearall = handles.pushbutton_clearall;
tab_guilds.radiobutton_fish = handles.radiobutton_fish;
tab_guilds.text_average_length = handles.text_average_length;
tab_guilds.edit_average_length = handles.edit_average_length;
tab_guilds.text_length_weight_parameters = handles.text_length_weight_parameters;
tab_guilds.edit_lw_a = handles.edit_lw_a;
tab_guilds.edit_lw_b = handles.edit_lw_b;
tab_guilds.text_lw_a = handles.text_lw_a;
tab_guilds.text_lw_b = handles.text_lw_b;
tab_guilds.edit_initial_biomass = handles.edit_initial_biomass;
tab_guilds.text_initial_biomass = handles.text_initial_biomass;
tab_guilds.pushbutton_moveup = handles.pushbutton_moveup;
tab_guilds.pushbutton_movedown = handles.pushbutton_movedown;
tab_guilds.text_half_saturation_constant = handles.text_half_saturation_constant;
tab_guilds.edit_half_saturation_constant = handles.edit_half_saturation_constant;
tab_guilds.text_feeding_interference_coefficient = handles.text_feeding_interference_coefficient;
tab_guilds.edit_feeding_interference_coefficient = handles.edit_feeding_interference_coefficient;
tab_guilds.edit_length_season = handles.edit_length_season;
tab_guilds.text_length_season = handles.text_length_season;
tab_guilds.edit_basal_respiration = handles.edit_basal_respiration;
tab_guilds.text_basal_respiration = handles.text_basal_respiration;
tab_guilds.edit_producer_competition = handles.edit_producer_competition;
tab_guilds.text_producer_competition = handles.text_producer_competition;
tab_guilds.uibuttongroup_carrying_capacity = handles.uibuttongroup_carrying_capacity;
tab_guilds.radiobutton_K_constant = handles.radiobutton_K_constant;
tab_guilds.radiobutton_K_white_noise = handles.radiobutton_K_white_noise;
tab_guilds.radiobutton_K_AR1 = handles.radiobutton_K_AR1;
tab_guilds.text_K_mean = handles.text_K_mean;
tab_guilds.edit_K_mean = handles.edit_K_mean;
tab_guilds.text_K_standard_deviation = handles.text_K_standard_deviation;
tab_guilds.edit_K_standard_deviation = handles.edit_K_standard_deviation;
tab_guilds.text_K_autocorrelation = handles.text_K_autocorrelation;
tab_guilds.edit_K_autocorrelation = handles.edit_K_autocorrelation;
tab_guilds.text_F_q = handles.text_F_q;
tab_guilds.edit_F_q = handles.edit_F_q;
tab_guilds.text_assimilation_efficiency = handles.text_assimilation_efficiency;
tab_guilds.edit_assimilation_efficiency = handles.edit_assimilation_efficiency;
tab_guilds.text_maximum_consumption_rate = handles.text_maximum_consumption_rate;
tab_guilds.edit_maximum_consumption_rate = handles.edit_maximum_consumption_rate;
tab_guilds.text_fraction_of_exudation = handles.text_fraction_of_exudation;
tab_guilds.edit_fraction_of_exudation = handles.edit_fraction_of_exudation;
tab_guilds.text_dissolution_rate = handles.text_dissolution_rate;
tab_guilds.edit_dissolution_rate = handles.edit_dissolution_rate;
tab_guilds.text_hatchery = handles.text_hatchery;
tab_guilds.edit_hatchery = handles.edit_hatchery;
tab_guilds.text_invest = handles.text_invest;
tab_guilds.edit_invest = handles.edit_invest;
tab_guilds.text_activity_respiration_coefficient = handles.text_activity_respiration_coefficient;
tab_guilds.edit_activity_respiration_coefficient = handles.edit_activity_respiration_coefficient;
tab_guilds.checkbox_catchable = handles.checkbox_catchable;
tab_guilds.text_Pmat = handles.text_Pmat;
tab_guilds.edit_Pmat = handles.edit_Pmat;
tab_guilds.text_numberOfSpecies = handles.text_numberOfSpecies;
tab_guilds.edit_numberOfSpecies = handles.edit_numberOfSpecies;
tab_guilds.pushbutton_generateRandomWeb = handles.pushbutton_generateRandomWeb;
tab_guilds.text_intraspecificCompetitionCoefficient = handles.text_intraspecificCompetitionCoefficient;
tab_guilds.edit_intraspecificCompetitionCoefficient = handles.edit_intraspecificCompetitionCoefficient;
tab_guilds.text_bodymass = handles.text_bodymass;
tab_guilds.edit_bodymass = handles.edit_bodymass;
tab_guilds.checkbox_referenceguild = handles.checkbox_referenceguild;
tab_guilds.pushbutton_test = handles.pushbutton_test;
tab_guilds.pushbutton_defaults = handles.pushbutton_defaults;
tab_guilds.checkbox_enable = handles.checkbox_enable;
tab_guilds.pushbutton_defaultsAll = handles.pushbutton_defaultsAll;
tab_guilds.text_numberOfYears = handles.text_numberOfYears;
tab_guilds.edit_numberOfYears = handles.edit_numberOfYears;


handles = rmfield(handles,{'uipanel_tab_guilds','uipanel_add_guild','text_name', ...
    'text_label','text_intrinsic_growth_rate','text_metabolic_rate','edit_name', ...
    'edit_label','edit_intrinsic_growth_rate','edit_metabolic_rate','pushbutton_add_guild', ...
    'pushbutton_save_changes','pushbutton_clear','uibuttongroup_type', ...
    'uipanel_guild_list','listbox_guild_list','pushbutton_delete', ...
    'pushbutton_import','pushbutton_export','radiobutton_consumer', ...
    'radiobutton_producer','radiobutton_detritus','listbox_prey','listbox_available_prey', ...
    'pushbutton_add_food_item','pushbutton_remove_food_item', ...
    'pushbutton_copydiet','pushbutton_clearall', ...
    'radiobutton_fish','text_average_length','edit_average_length', ...
    'text_length_weight_parameters','edit_lw_a','edit_lw_b','text_lw_a','text_lw_b', ...
    'edit_initial_biomass','text_initial_biomass','pushbutton_moveup','pushbutton_movedown', ...
    'edit_half_saturation_constant','text_half_saturation_constant', ...
    'edit_feeding_interference_coefficient','text_feeding_interference_coefficient', ...
    'edit_length_season','text_length_season', ...
    'edit_basal_respiration','text_basal_respiration','edit_producer_competition', ...
    'text_producer_competition','uibuttongroup_carrying_capacity', ...
    'radiobutton_K_constant','radiobutton_K_white_noise','radiobutton_K_AR1', ...
    'text_K_mean','edit_K_mean','text_K_standard_deviation','edit_K_standard_deviation', ...
    'text_K_autocorrelation','edit_K_autocorrelation','text_F_q','edit_F_q', ...
    'text_assimilation_efficiency','edit_assimilation_efficiency', ...
    'text_maximum_consumption_rate','edit_maximum_consumption_rate', ...
    'text_fraction_of_exudation','edit_fraction_of_exudation', ...
    'text_dissolution_rate','edit_dissolution_rate','text_hatchery', ...
    'edit_hatchery','text_invest','edit_invest', ...
    'text_activity_respiration_coefficient','edit_activity_respiration_coefficient', ...
    'checkbox_catchable', 'text_Pmat', 'edit_Pmat', ...
    'pushbutton_generateRandomWeb', 'text_numberOfSpecies','edit_numberOfSpecies', ...
    'text_intraspecificCompetitionCoefficient', 'edit_intraspecificCompetitionCoefficient', ...
    'text_bodymass', 'edit_bodymass', 'checkbox_referenceguild', 'pushbutton_test', ...
    'pushbutton_defaults', 'checkbox_enable', 'pushbutton_defaultsAll', ...
    'text_numberOfYears', 'edit_numberOfYears'});

handles.tab_guilds = tab_guilds;

handles = setUIControlPositions(handles);

function handles = refreshAxes(handles)

GI = handles.Data.GuildInfo;
Guilds = handles.Data.Guilds;
for i = 1:GI.nFishGuilds
    h = handles.plots.BiomassFishGuild(i);
    IF = GI.iFishGuilds(i);
    xdata = 0:size(handles.Results.B,2);
    ydata = [Guilds(IF).binit handles.Results.B(IF,:)];
    set(h,'xdata',xdata,'ydata',ydata);
end
fishgls = {Guilds(GI.iFishGuilds).label};
S.subs = {1,1:3};
S.type = '()';
fslabels = unique(cellfun(@(x)subsref(x,S),fishgls,'uniformoutput',false),'stable');
fishgls = cellfun(@(x)subsref(x,S),fishgls,'uniformoutput',false);
% afishgls = {Guilds(GI.iAdultFishGuilds).label};
% afishgls = cellfun(@(x)subsref(x,S),afishgls,'uniformoutput',false);
for i = 1:GI.nFishSpecies
%     afsinds = find(strcmpi(fslabels{i},afishgls));
    fsinds = find(strcmpi(fslabels{i},fishgls));
    h1 = handles.plots.CatchFishGuildYearlyPerSpecies(i);
    h2 = handles.plots.CatchFishGuildCumulativePerSpecies(i);
    h3 = handles.plots.BiomassFishGuildPerSpecies(i);
    xdata = 0:size(handles.Results.C,2);
%     ydata1 = [0 sum(handles.Results.C(afsinds,:))]; %#ok<FNDSB>
    ydata1 = [0 sum(handles.Results.C(fsinds,:))];
    ydata2 = cumsum(ydata1);
    ydata3 = [sum([Guilds(GI.iFishGuilds(fsinds)).binit]) sum(handles.Results.B(GI.iFishGuilds(fsinds),:))];
    set(h1,'xdata',xdata,'ydata',ydata1);
    set(h2,'xdata',xdata,'ydata',ydata2);
    set(h3,'xdata',xdata,'ydata',ydata3);
end
for i = 1:GI.nAdultFishGuilds
    I = GI.iAdultFishGuildsInFish(i);
    h1 = handles.plots.CatchFishGuildYearly(i);
    h2 = handles.plots.CatchFishGuildCumulative(i);
    xdata = 0:size(handles.Results.C,2);
    ydata1 = [0 handles.Results.C(I,:)];
    ydata2 = cumsum(ydata1);
    set(h1,'xdata',xdata,'ydata',ydata1);
    set(h2,'xdata',xdata,'ydata',ydata2);
end
if GI.nFishSpecies > 0
    if xdata(end) < handles.minaxeswidth
        handles.tab_simulate.axes_biomass.XLim = [0 handles.minaxeswidth];
        handles.tab_simulate.axes_catch.XLim = [0 handles.minaxeswidth];
    else
        axeswidth = str2double(handles.tab_simulate.edit_axeswidth.String); % jne..
        handles.tab_simulate.axes_biomass.XLim = [max([0 xdata(end)-axeswidth]) xdata(end)];
        handles.tab_simulate.axes_catch.XLim = [max([0 xdata(end)-axeswidth]) xdata(end)];
    end
end
drawnow


f = findobj(get(0,'Children'),'name','Total Biomass');
if ~isempty(f)
    updateTotalBiomassFigure(f,handles);
end

% f = findobj(get(0,'Children'),'name','Plankton');
% if ~isempty(f)
%     updatePlanktonFigure(f,handles);
% end

f = findobj(get(0,'Children'),'name','Biomasses by type');
if ~isempty(f)
    updatePlanktonFigure(f,handles);
end

f = findobj(get(0,'Children'),'name','Subnet Figure');
if ~isempty(f)
    h = findobj(get(f,'children'),'style','popupmenu');
    updateSubnetFigure(h, [], handles);
end

function handles = initializeGuildTab(handles)
handles = updateGuildListbox(handles, 1);
handles = updatePreyListbox(handles);
handles = updateAvailablePreyListbox(handles);
handles = setGuildEditStatus(handles);
handles = setParameterEditValues(handles);
handles = updateEdits(handles);
function handles = updateGuildListbox(handles, value)
guild_labels = {handles.Data.Guilds.label}';
handles.tab_guilds.listbox_guild_list.String = guild_labels;
handles.tab_guilds.listbox_guild_list.Value = value;
function handles = updatePreyListbox(handles)
iPredator = [];
if ~isempty(handles.tab_guilds.listbox_guild_list.String)
    iPredator = handles.tab_guilds.listbox_guild_list.Value;
end
iPrey = find(full(handles.Data.adjacencyMatrix(iPredator,:)));
preyLabels = {handles.Data.Guilds(iPrey).label}';
handles.tab_guilds.listbox_prey.String = preyLabels;
value = min(handles.tab_guilds.listbox_prey.Value, ...
    length(handles.tab_guilds.listbox_prey.String));
value = max(1, value);
handles.tab_guilds.listbox_prey.Value = value;
%glabels = handles.tab_guilds.listbox_guild_list.String;
%gvalue = handles.tab_guilds.listbox_guild_list.Value;
%if ~isempty(glabels)
%    selectedGuildLabel = glabels{gvalue}; % TODO: FIX ERROR IF LIST GETS EMPTY
%    gind = find(strcmp(selectedGuildLabel,{handles.Data.Guilds.label}));
%    
%    % get feeding links for selected guild
%    preyinds = find(handles.Data.adjacencyMatrix(gind,:)); %#ok<FNDSB>
%    handles.tab_guilds.listbox_prey.String = glabels(preyinds); %#ok<FNDSB>
%    handles.tab_guilds.listbox_prey.Value = 1;
%else
%    handles.tab_guilds.listbox_prey.String = [];
%    handles.tab_guilds.listbox_prey.Value = 1;
%end
function handles = updateAvailablePreyListbox(handles)
iPredator = [];
if ~isempty(handles.tab_guilds.listbox_guild_list.String)
    iPredator = handles.tab_guilds.listbox_guild_list.Value;
end
iPrey = find(full(~handles.Data.adjacencyMatrix(iPredator,:)));
availablePreyLabels = {handles.Data.Guilds(iPrey).label}';
% preyitems = handles.tab_guilds.listbox_prey.String;
% availablepreyitems = setdiff({handles.Data.Guilds.label}',preyitems,'stable');
listboxTop = handles.tab_guilds.listbox_available_prey.ListboxTop;
handles.tab_guilds.listbox_available_prey.String = availablePreyLabels;
handles.tab_guilds.listbox_available_prey.ListboxTop = listboxTop;
value = min(length(availablePreyLabels), ...
    handles.tab_guilds.listbox_available_prey.Value);
value = max(1, value);
handles.tab_guilds.listbox_available_prey.Value = value;
function handles = updateEdits(handles)
ii = handles.tab_guilds.listbox_guild_list.Value;
if ~isempty(handles.tab_guilds.listbox_guild_list.String)
    glabel = handles.tab_guilds.listbox_guild_list.String{ii};
    i = find(strcmp({handles.Data.Guilds.label},glabel));
    g = handles.Data.Guilds(i);
    handles.tab_guilds.edit_name.String = g.name;
    handles.tab_guilds.edit_label.String = g.label;
    handles.tab_guilds.edit_intrinsic_growth_rate.String = num2str(g.igr);
    handles.tab_guilds.edit_metabolic_rate.String = num2str(g.mbr);
    handles.tab_guilds.edit_average_length.String = num2str(g.avgl);
    handles.tab_guilds.edit_lw_a.String = num2str(g.lw_a);
    handles.tab_guilds.edit_lw_b.String = num2str(g.lw_b);
    handles.tab_guilds.edit_initial_biomass.String = num2str(g.binit);
    handles.tab_guilds.edit_basal_respiration.String = num2str(g.f_m);
    handles.tab_guilds.edit_producer_competition.String = num2str(g.c);
    handles.tab_guilds.edit_fraction_of_exudation.String = num2str(g.s);
    handles.tab_guilds.edit_dissolution_rate.String = num2str(g.diss_rate);
    handles.tab_guilds.edit_hatchery.String = num2str(g.hatchery);
    handles.tab_guilds.edit_activity_respiration_coefficient.String = num2str(g.f_a);
    handles.tab_guilds.edit_invest.String = num2str(g.invest);

    gbodymass = NaN;
    if isfield(g,'bodymass') && ~isempty(g.bodymass)
        gbodymass = g.bodymass;
    end
    handles.tab_guilds.edit_bodymass.String = num2str(gbodymass);
    
    if ~isfield(g,'Pmat')
        if ~isempty(g.age)
            g.Pmat = proba_mature(0,g.age);
        else
            g.Pmat = [];
        end
    end
    handles.tab_guilds.edit_Pmat.String = num2str(g.Pmat);
    
    gcatchable = 0;
    if isfield(g,'catchable') && ~isempty(g.catchable)
    	gcatchable = g.catchable;
    end
    handles.tab_guilds.checkbox_catchable.Value = gcatchable;
    
    gisRef = false;
    if isfield(g,'isRefGuild') && ~isempty(g.isRefGuild)
    	gisRef = g.isRefGuild;
    end
    handles.tab_guilds.checkbox_referenceguild.Value = gisRef;

    genable = true;
    if isfield(g,'enable')
        if isempty(g.enable)
            genable = false;
        else
            genable = g.enable;
        end
    end
    handles.tab_guilds.checkbox_enable.Value = genable;
    
    
    set(findobj(handles.tab_guilds.uibuttongroup_type.Children, ...
        'String',g.type),'Value',1)
    handles = setGuildEditStatus(handles);
else
    handles.tab_guilds.edit_name.String = '';
    handles.tab_guilds.edit_label.String = '';
    handles.tab_guilds.edit_intrinsic_growth_rate.String = '';
    handles.tab_guilds.edit_metabolic_rate.String = '';
    handles.tab_guilds.edit_average_length.String = '';
    handles.tab_guilds.edit_lw_a.String = '';
    handles.tab_guilds.edit_lw_b.String = '';
    handles.tab_guilds.edit_initial_biomass.String = '';
    handles.tab_guilds.edit_basal_respiration.String = '';
    handles.tab_guilds.edit_producer_competition.String = '';
    handles.tab_guilds.edit_fraction_of_exudation.String = '';
    handles.tab_guilds.edit_dissolution_rate.String = '';
    handles.tab_guilds.edit_hatchery.String = '';
    handles.tab_guilds.edit_activity_respiration_coefficient.String = '';
    handles.tab_guilds.edit_invest.String = '';
    handles.tab_guilds.edit_Pmat.String = '';
    handles.tab_guilds.edit_bodymass.String = '';
    
    handles.tab_guilds.checkbox_referenceguild.Value = false;
    
    handles.tab_guilds.uibuttongroup_type.Children(4).Value = 1;
    uibuttongroup_type_SelectionChangedFcn(handles.tab_guilds.uibuttongroup_type, [], handles)
    
    handles.tab_guilds.edit_half_saturation_constant.String = '';
    handles.tab_guilds.edit_feeding_interference_coefficient.String = '';
    handles.tab_guilds.edit_F_q.String = '';
    handles.tab_guilds.edit_assimilation_efficiency.String = '';
    handles.tab_guilds.edit_maximum_consumption_rate.String = '';
end
function handles = setGuildEditStatus(handles)

switch handles.tab_guilds.uibuttongroup_type.SelectedObject.Tag
    case 'radiobutton_fish'
        toggleUIControls(handles, 'off', { ...
            'edit_intrinsic_growth_rate', ...
            'edit_producer_competition', ...
            'edit_fraction_of_exudation', ...
            'edit_dissolution_rate', ...
            'checkbox_referenceguild' ...
            });
        toggleUIControls(handles, 'on', { ...
            'edit_metabolic_rate', ...
            'edit_basal_respiration', ...
            'edit_average_length', ...
            'edit_lw_a', ...
            'edit_lw_b', ...
            'edit_hatchery', ...
            'edit_activity_respiration_coefficient', ...
            'edit_invest', ...
            'edit_Pmat', ...
            'edit_bodymass', ...
            'checkbox_catchable' ...
            });
    case 'radiobutton_consumer'
        toggleUIControls(handles, 'off', { ...
            'edit_intrinsic_growth_rate', ...
            'edit_producer_competition', ...
            'edit_average_length', ...
            'edit_lw_a', ...
            'edit_lw_b', ...
            'edit_fraction_of_exudation', ...
            'edit_dissolution_rate', ...
            'edit_hatchery', ...
            'edit_invest', ...
            'edit_Pmat', ...
            'checkbox_catchable', ...
            'checkbox_referenceguild' ...
            });
        toggleUIControls(handles, 'on', { ...
            'edit_metabolic_rate', ...
            'edit_basal_respiration', ...
            'edit_activity_respiration_coefficient', ...
            'edit_bodymass' ...
            });
    case 'radiobutton_producer'
        toggleUIControls(handles, 'off', { ...
            'edit_metabolic_rate', ...
            'edit_basal_respiration', ...
            'edit_average_length', ...
            'edit_lw_a', ...
            'edit_lw_b', ...
            'edit_dissolution_rate', ...
            'edit_hatchery', ...
            'edit_activity_respiration_coefficient', ...
            'edit_invest', ...
            'edit_Pmat', ...
            'checkbox_catchable' ...
            });
        toggleUIControls(handles, 'on', { ...
            'edit_intrinsic_growth_rate', ...
            'edit_producer_competition', ...
            'edit_fraction_of_exudation', ...
            'edit_bodymass', ...
            'checkbox_referenceguild' ...
            });
        
        % If the only producer make it the reference guild by default here
        if ~any(strcmp({handles.Data.Guilds.type}, 'Producer'))
            handles = setAsReferenceGuild(handles);
        end
    case 'radiobutton_detritus'
        toggleUIControls(handles, 'off', { ...
            'edit_intrinsic_growth_rate', ...
            'edit_metabolic_rate', ...
            'edit_basal_respiration', ...
            'edit_producer_competition', ...
            'edit_average_length', ...
            'edit_lw_a', ...
            'edit_lw_b', ...
            'edit_fraction_of_exudation', ...
            'edit_hatchery', ...            
            'edit_activity_respiration_coefficient', ...
            'edit_invest', ...
            'edit_Pmat', ...
            'edit_bodymass', ...
            'checkbox_referenceguild', ...
            'checkbox_catchable' ...
            });
        toggleUIControls(handles, 'on', { ...
            'edit_dissolution_rate' ...
            });
end
function toggleUIControls(handles, status, uinames)
for i = 1:length(uinames)
    if strcmp(status, 'off')
        if strcmp(handles.tab_guilds.(uinames{i}).Style, 'edit')
            handles.tab_guilds.(uinames{i}).String = '';
        elseif strcmp(handles.tab_guilds.(uinames{i}).Style, 'checkbox')
            handles.tab_guilds.(uinames{i}).Value = 0;
        end
        handles.tab_guilds.(uinames{i}).Enable = 'off';
    elseif strcmp(status, 'on')
        handles.tab_guilds.(uinames{i}).Enable = 'on';
    end
end
function handles = swapGuildPositions(handles,i1,i2)
g1 = handles.Data.Guilds(i1);
g2 = handles.Data.Guilds(i2);

Cmtx = handles.Data.adjacencyMatrix;
dmtx = handles.Data.d;
B0mtx = handles.Data.B0;
qmtx = handles.Data.q;
emtx = handles.Data.e;
ymtx = handles.Data.y;

Cmtx_new = Cmtx;
dmtx_new = dmtx;
B0mtx_new = B0mtx;
qmtx_new = qmtx;
emtx_new = emtx;
ymtx_new = ymtx;

Cmtx_new(i2,:) = Cmtx(i1,:);
Cmtx_new(i1,:) = Cmtx(i2,:);
Cmtx_new(:,i2) = Cmtx(:,i1);
Cmtx_new(:,i1) = Cmtx(:,i2);
dmtx_new(i2,:) = dmtx(i1,:);
dmtx_new(i1,:) = dmtx(i2,:);
dmtx_new(:,i2) = dmtx(:,i1);
dmtx_new(:,i1) = dmtx(:,i2);
B0mtx_new(i2,:) = B0mtx(i1,:);
B0mtx_new(i1,:) = B0mtx(i2,:);
B0mtx_new(:,i2) = B0mtx(:,i1);
B0mtx_new(:,i1) = B0mtx(:,i2);
qmtx_new(i2,:) = qmtx(i1,:);
qmtx_new(i1,:) = qmtx(i2,:);
qmtx_new(:,i2) = qmtx(:,i1);
qmtx_new(:,i1) = qmtx(:,i2);
emtx_new(i2,:) = emtx(i1,:);
emtx_new(i1,:) = emtx(i2,:);
emtx_new(:,i2) = emtx(:,i1);
emtx_new(:,i1) = emtx(:,i2);
ymtx_new(i2,:) = ymtx(i1,:);
ymtx_new(i1,:) = ymtx(i2,:);
ymtx_new(:,i2) = ymtx(:,i1);
ymtx_new(:,i1) = ymtx(:,i2);

if Cmtx(i1,i2) && ~Cmtx(i2,i1)
    Cmtx_new(i1,i1) = 0;
    Cmtx_new(i2,i1) = 1;
    dmtx_new(i1,i1) = 0;
    dmtx_new(i2,i1) = dmtx(i1,i2);
    B0mtx_new(i1,i1) = 0;
    B0mtx_new(i2,i1) = B0mtx(i1,i2);
    qmtx_new(i1,i1) = 0;
    qmtx_new(i2,i1) = qmtx(i1,i2);
    emtx_new(i1,i1) = 0;
    emtx_new(i2,i1) = emtx(i1,i2);
    ymtx_new(i1,i1) = 0;
    ymtx_new(i2,i1) = ymtx(i1,i2);
elseif ~Cmtx(i1,i2) && Cmtx(i2,i1)
    Cmtx_new(i1,i2) = 1;
    Cmtx_new(i2,i2) = 0;
    dmtx_new(i1,i2) = dmtx(i2,i1);
    dmtx_new(i2,i2) = 0;
    B0mtx_new(i1,i2) = B0mtx(i2,i1);
    B0mtx_new(i2,i2) = 0;
    qmtx_new(i1,i2) = qmtx(i2,i1);
    qmtx_new(i2,i2) = 0;
    emtx_new(i1,i2) = emtx(i2,i1);
    emtx_new(i2,i2) = 0;
    ymtx_new(i1,i2) = ymtx(i2,i1);
    ymtx_new(i2,i2) = 0;
elseif Cmtx(i1,i2) && Cmtx(i2,i1)
    Cmtx_new(i1,i1) = 0;
    Cmtx_new(i2,i1) = 1;
    Cmtx_new(i2,i2) = 0;
    Cmtx_new(i1,i2) = 1;
    dmtx_new(i1,i1) = 0;
    dmtx_new(i2,i1) = dmtx(i1,i2);
    dmtx_new(i2,i2) = 0;
    dmtx_new(i1,i2) = dmtx(i2,i1);
    B0mtx_new(i1,i1) = 0;
    B0mtx_new(i2,i1) = B0mtx(i1,i2);
    B0mtx_new(i2,i2) = 0;
    B0mtx_new(i1,i2) = B0mtx(i2,i1);
    qmtx_new(i1,i1) = 0;
    qmtx_new(i2,i1) = qmtx(i1,i2);
    qmtx_new(i2,i2) = 0;
    qmtx_new(i1,i2) = qmtx(i2,i1);
    emtx_new(i1,i1) = 0;
    emtx_new(i2,i1) = emtx(i1,i2);
    emtx_new(i2,i2) = 0;
    emtx_new(i1,i2) = emtx(i2,i1);
    ymtx_new(i1,i1) = 0;
    ymtx_new(i2,i1) = ymtx(i1,i2);
    ymtx_new(i2,i2) = 0;
    ymtx_new(i1,i2) = ymtx(i2,i1);
end

handles.Data.adjacencyMatrix = Cmtx_new;
handles.Data.d = dmtx_new;
handles.Data.B0 = B0mtx_new;
handles.Data.q = qmtx_new;
handles.Data.e = emtx_new;
handles.Data.y = ymtx_new;
handles.Data.Guilds(i1) = g2;
handles.Data.Guilds(i2) = g1;

handles.Data = updateGuildInfo(handles.Data);
handles = updateGuildListbox(handles,i2);

function handles = saveParameterValues(handles)
handles.Data.K.type = handles.tab_guilds.uibuttongroup_carrying_capacity.SelectedObject.String;

Ktype = handles.tab_guilds.uibuttongroup_carrying_capacity.SelectedObject.String;
Kmean = str2double(handles.tab_guilds.edit_K_mean.String);
Kstd = str2double(handles.tab_guilds.edit_K_standard_deviation.String);
Kacc = str2double(handles.tab_guilds.edit_K_autocorrelation.String);

handles.Data.K = basalProductionCarryingCapacityModel(Ktype,Kmean,Kstd,Kacc);

switch handles.Data.K.type
    case 'Constant'
        handles.Data.K.mean = str2double(handles.tab_guilds.edit_K_mean.String);
        handles.Data.K.standard_deviation = [];
        handles.Data.K.autocorrelation = [];
    case 'White noise'
        handles.Data.K.mean = str2double(handles.tab_guilds.edit_K_mean.String);
        handles.Data.K.standard_deviation = str2double(handles.tab_guilds.edit_K_standard_deviation.String);
        handles.Data.K.autocorrelation = [];
    case 'AR(1)'
        handles.Data.K.mean = str2double(handles.tab_guilds.edit_K_mean.String);
        handles.Data.K.standard_deviation = str2double(handles.tab_guilds.edit_K_standard_deviation.String);
        handles.Data.K.autocorrelation = str2double(handles.tab_guilds.edit_K_autocorrelation.String);
end
function handles = setParameterEditValues(handles)
handles.tab_guilds.edit_length_season.String = ...
    num2str(handles.Options.Defaults.nGrowthDays);
handles.tab_guilds.edit_numberOfYears.String = ...
    num2str(handles.Options.Defaults.numberOfYears);
if isfield(handles.Data,'K') && isfield(handles.Data.K,'type')
    switch handles.Data.K.type
        case 'Constant'
            handles.tab_guilds.radiobutton_K_constant.Value = 1;
            handles.tab_guilds.edit_K_mean.String = ...
                num2str(handles.Data.K.mean);
            uibuttongroup_carrying_capacity_SelectionChangedFcn( ...
                handles.tab_guilds.radiobutton_K_constant, [], handles)
        case 'White noise'
            handles.tab_guilds.radiobutton_K_white_noise.Value = 1;
            handles.tab_guilds.edit_K_mean.String = ...
                num2str(handles.Data.K.mean);
            handles.tab_guilds.edit_K_standard_deviation.String = ...
                num2str(handles.Data.K.standard_deviation);
            uibuttongroup_carrying_capacity_SelectionChangedFcn( ...
                handles.tab_guilds.radiobutton_K_white_noise, [], handles)
        case 'AR(1)'
            handles.tab_guilds.radiobutton_K_AR1.Value = 1;
            handles.tab_guilds.edit_K_mean.String = ...
                num2str(handles.Data.K.mean);
            handles.tab_guilds.edit_K_standard_deviation.String = ...
                num2str(handles.Data.K.standard_deviation);
            handles.tab_guilds.edit_K_autocorrelation.String = ...
                num2str(handles.Data.K.autocorrelation);
            uibuttongroup_carrying_capacity_SelectionChangedFcn( ...
                handles.tab_guilds.radiobutton_K_AR1, [], handles)
    end
else
    handles.tab_guilds.radiobutton_K_constant.Value = 1;
    handles.tab_guilds.edit_K_mean.String = 540000;
    uibuttongroup_carrying_capacity_SelectionChangedFcn( ...
        handles.tab_guilds.radiobutton_K_constant, [], handles)
end

function handles = updateEcosystemPopupmenu(handles,str_sel)
d = dir(fullfile('Data','*.mat'));
ecoStr = cellfun(@(x)x(1:strfind(x,'.mat')-1),{d.name},'uniformoutput',false);
set(handles.tab_simulate.popupmenu_ecosystem,'string',ecoStr)
value = find(strcmpi(ecoStr,str_sel));
if isempty(value) && ~isempty(ecoStr)
    value = 1;
elseif isempty(value) && isempty(ecoStr)
    value = 0;
end
set(handles.tab_simulate.popupmenu_ecosystem,'value',value);

function clearFigures
figs = findobj(get(0,'Children'),'type','figure');
fignames = {'Juveniles and spawners','Basal production carrying capacity', ...
    'Total Biomass','Plankton'};
for i = 1:length(figs)
    fig = figs(i);
    if any(strcmpi(fig.Name,fignames))
        delete(fig)
    end
end

function defaults = defaultFParams(predatorGuild, preyGuild, preyPreyTypes)

defaults.q = 1.2;

if strcmpi(predatorGuild.type, 'consumer') || ...
    (strcmpi(predatorGuild.type, 'fish') && predatorGuild.age == 0)
    defaults.y = 8;
    if strcmpi(preyGuild.type, 'consumer')
        defaults.e = 0.85;
        defaults.B0 = 1500;
        defaults.d = 0.01;
    elseif strcmpi(preyGuild.type, 'detritus')
        defaults.e = 0.45;
        defaults.B0 = 150000;
        defaults.d = 1;
    else
        defaults.e = 0.45;
        defaults.B0 = 1500;
        defaults.d = 0.01;
    end
elseif strcmpi(predatorGuild.type, 'fish')
    defaults.y = 4;
    if strcmpi(preyGuild.type, 'fish')
        defaults.e = 0.85;
        defaults.B0 = 15000;
        defaults.d = 3e-4;
    elseif strcmpi(preyGuild.type, 'consumer')
        defaults.e = 0.85;
        herbivority = sum(strcmpi(preyPreyTypes, 'producer'))/length(preyPreyTypes);
        if herbivority >= 0.7
            predatorBM = metabolicRateToBodyMass(predatorGuild.mbr, predatorGuild.type);
            preyBM = metabolicRateToBodyMass(preyGuild.mbr, preyGuild.type);
            if predatorBM/preyBM <= 50
                defaults.B0 = 15000;
                defaults.d = 1e-4;
            else
                defaults.B0 = 150000;
                defaults.d = 1;
            end
        else
            defaults.B0 = 50000;
            defaults.d = 1e-4;
        end
    elseif strcmpi(preyGuild.type,'producer')
        defaults.e = 0.45;
        defaults.B0 = 150000;
        defaults.d = 1;
    elseif strcmpi(preyGuild.type,'detritus')
        defaults.e = 0.45;
        defaults.B0 = 150000;
        defaults.d = 1;
    end
else
    defaults.y = 0;
    defaults.e = 0;
    defaults.B0 = 0;
    defaults.d = 0;
end

function handles = setDefaultFParams(handles, i, j)

predatorGuild = handles.Data.Guilds(i);
preyGuild = handles.Data.Guilds(j);

preyPreyTypes = {handles.Data.Guilds(find(handles.Data.adjacencyMatrix(j,:))).type};
defaults = defaultFParams(predatorGuild, preyGuild, preyPreyTypes);
handles.Data.B0(i,j) = defaults.B0;
handles.Data.d(i,j) = defaults.d;
handles.Data.q(i,j) = defaults.q;
handles.Data.e(i,j) = defaults.e;
handles.Data.y(i,j) = defaults.y;

handles.tab_guilds.edit_half_saturation_constant.String = num2str(defaults.B0);
handles.tab_guilds.edit_feeding_interference_coefficient.String = num2str(defaults.d);
handles.tab_guilds.edit_F_q.String = num2str(defaults.q);
handles.tab_guilds.edit_assimilation_efficiency.String = num2str(defaults.e);
handles.tab_guilds.edit_maximum_consumption_rate.String = num2str(defaults.y);

function handles = setAsReferenceGuild(handles)
handles.tab_guilds.checkbox_referenceguild.Value = 1;
iThis = handles.tab_guilds.listbox_guild_list.Value;
handles.Data.Guilds(iThis).isRefGuild = 1;
J = setdiff(1:length(handles.Data.Guilds),iThis);
for j = J
    handles.Data.Guilds(j).isRefGuild = false;
end

answer = questdlg(['Reference guild status assigned. Do you want to ' ... 
    'update allometric scaling for other guilds?'], ...
        'Confirm allometric scaling update','Yes','No','Yes');

if strcmp(answer, 'Yes')
    if isempty(handles.tab_guilds.edit_bodymass.String)
        errordlg('Reference guild bodymass must be defined.')
    else
        MRef = str2double(handles.tab_guilds.edit_bodymass.String);
        handles = updateAllometricScalings(handles, MRef);
    end
end

function handles = updateAllometricScalings(handles, MRef)

iThis = handles.tab_guilds.listbox_guild_list.Value;
iP = handles.Data.GuildInfo.iProducerGuilds;
for i = iP
    if iThis == i
        M = str2double(handles.tab_guilds.edit_bodymass.String);
    else
        M = handles.Data.Guilds(i).bodymass;
    end
    handles.Data.Guilds(i).igr = intrinsicGrowthRate(M, MRef);
end
iC = handles.Data.GuildInfo.iConsumerGuilds;
for i = iC
    M = handles.Data.Guilds(i).bodymass;
    handles.Data.Guilds(i).mbr = bodyMassToMetabolicRate(M, 'Consumer', MRef);
end
iF = handles.Data.GuildInfo.iFishGuilds;
for i = iF
    l = handles.Data.Guilds(i).avgl;
    lw_a = handles.Data.Guilds(i).lw_a;
    lw_b = handles.Data.Guilds(i).lw_b;
    handles.Data.Guilds(i).mbr = metabolicRate(l, lw_a, lw_b, 'Fish', MRef);
end

% --- Executes on key press with focus on atn_gui or any of its controls.
function atn_gui_WindowKeyPressFcn(hObject, eventdata, handles)

if strcmp(eventdata.Key, 'alt')
    handles.altPressed = ~handles.altPressed;
else
    if handles.altPressed
        if strcmp(eventdata.Key, 'd')
            pushbutton_defaults_Callback(hObject, [], handles)
        end
        handles = guidata(hObject);
    end
    handles.altPressed = false;
end

guidata(hObject, handles)
