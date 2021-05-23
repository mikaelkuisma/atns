function handles = setUIControlPositions(handles)

h_text = 1.0;
h_edit = 1.3;
w_edit = 10.2;
py_t_e = 0.3;
oy_t_e = -(h_text+py_t_e);

tab_simulate_positions = [ ...
    0 0 204.2 47.7692;          % (uipanel_tab_simulate)
    27.4 17.5 80.4 26.3077;     % (axes_biomass)
    117.6 17.5 80.4 26.3077;    % (axes_catch)
    45.8 3.0769 24.2 6.2308;    % (uibuttongroup_gear)
    0.8 3.3077 21.2 1.7692;     % (radiobutton_gear_1)
    0.8 1.9231 20.6 1.7692;     % (radiobutton_gear_2)
    0.8 0.4615 16.2 1.7692;     % (radiobutton_gear_3)
    71.6 3.0769 66.4 6.2308;    % (uipanel_fishingpressure)
    18.4 3.0769 6.4 h_edit;     % (edit_fishingmortality)
    1.1 3.3846 16 h_text;       % (text_fishingmortality)
    139.8 2.7 44 8.3;           % (uipanel_simulate)
    31.4 5.07 10.4 h_edit;      % (edit_numberofyears)
    2.2 5.4 28.2 h_text;        % (text_numberofyears)
    2 2.6 20 1.7;               % (pushbutton_gofishing)
    21.8 2.6 20 1.7;            % (pushbutton_nofishing)
%     58 45.3 0 NaN;            % (text_axes_biomass)
%     151 45.3 0 NaN;           % (text_axes_catch)
    141.8 1 40.2 h_text;        % (text_simulationstatus)
    186 5.9 13.8 2.462;         % (pushbutton_reset)
    170 13 30 1.6154;           % (popupmenu_catchtype)
    27.8 13 32.2 h_text;        % (text_axeswidth)
    61.6 13 6.2 h_edit;         % (edit_axeswidth)
    1.8 10.4615 18.2 14.6154;   % (uipanel_biomassplots)
    186 3.354 13.8 2.462;       % (pushbutton_save_results)
    1.1 1.231 39.2 h_text;      % (text_releaseproportion)
    40.8 0.846 6.4 h_edit;      % (edit_releaseproportion)
    54 1 17.4 1.7;              % (pushbutton_planktonfigure)
%     0 0 1 1;                  % (axes_bgimage_simulate)
    1.8 7.5 40 1.6              % (popupmenu_ecosystem)
    2 0.8 20 1.7;               % (pushbutton_rewind)
    21.8 0.8 20 1.7;            % (pushbutton_stop)
    72 1 22.8 1.7;              % (pushbutton_totalbiomassfigure)
    78 13 30 1.6154;            % (popupmenu_biomasstype)
    26 3.2 36.4 1.3;            % (slider_F)
    95 1 17.4 1.7;              % (pushbutton_subnetfigure)
    1.8 0.38 17.625 1.381;      % (checkbox_newVersion)
    ];

tab_guilds_positions = [ ...
    0 0 204.2 47.7692;                  % (uipanel_tab_guilds)
    7.8 11.3 58.2 33;                   % (uipanel_add_guild)
    1.8 31 6.2 h_text;                  % (text_name)
    1.8 31+oy_t_e 34.4 h_edit;          % (edit_name)
    1.8 27.7 6.2 h_text;                % (text_label)
    1.8 17.4 20.2 h_text;               % (text_intrinsic_growth_rate)
    23.4 14.1 30.2 h_text;              % (text_metabolic_rate)
    1.8 27.7+oy_t_e w_edit h_edit;      % (edit_label)
    1.8 17.4+oy_t_e w_edit h_edit;      % (edit_intrinsic_growth_rate)
    23.4 14.1+oy_t_e w_edit h_edit;     % (edit_metabolic_rate)
    1.8 0.3 13.8 1.7;                   % (pushbutton_add_guild)
    16 0.3 17.2 1.7;                    % (pushbutton_save_changes)
    34 0.3 13.8 1.7;                    % (pushbutton_clear)
    1.8 18.385 20.2 7.154;              % (uibuttongroup_type)
    67.6 15.3077 134.4 29.3;            % (uipanel_guild_list)
    2 16.8462 33.8 11.23;               % (listbox_guild_list)
    2 12.1538 34 1.7;                   % (pushbutton_delete)
    136 13.6154 13.8 1.7;               % (pushbutton_import)
    154 13.6154 13.8 1.7;               % (pushbutton_export)
    1.8 1.6 13.2 1.8;                   % (radiobutton_consumer)
    1.8 3 14.4 1.8;                     % (radiobutton_producer)
    1.8 4.4 15.6 1.8;                   % (radiobutton_detritus)
    38 16.8462 33.8 11.23;              % (listbox_prey)
    98 16.8462 33.8 11.23;              % (listbox_available_prey)
    72.8 23 24.2 1.7;                   % (pushbutton_add_food_item)
    72.8 20.5385 24.2 1.7;              % (pushbutton_remove_food_item)
    72.8 17 24.2 1.7;                   % (pushbutton_copydiet)
    118 13.6154 13.8 1.7;               % (pushbutton_clearall)
    1.8 0.2 13.2 1.8;                   % (radiobutton_fish)
    1.8 10.8 24.3 h_text;               % (text_average_length)
    1.8 10.8+oy_t_e w_edit h_edit;      % (edit_average_length)
    27 10.8 26.8 h_text;                % (text_length_weight_parameters)
    27 10.8+oy_t_e w_edit h_edit;       % (edit_lw_a)
    43 10.8+oy_t_e w_edit h_edit;       % (edit_lw_b)
    24 10.8+oy_t_e 2 h_text;            % (text_lw_a)
    40 10.8+oy_t_e 2 h_text;            % (text_lw_b)
    23.4 24+oy_t_e w_edit h_edit;       % (edit_initial_biomass)
    23.4 24 14 h_text;                  % (text_initial_biomass)
    2 14.5 17 1.7;                      % (pushbutton_moveup)
    19 14.5 17 1.7;                     % (pushbutton_movedown)
    40 15 24 h_text;                    % (text_half_saturation_constant)
    40 15+oy_t_e w_edit h_edit;         % (edit_half_saturation_constant)
    40 11.15 32.2 h_text;               % (text_feeding_interference_coefficient)
    40 11.15+oy_t_e w_edit h_edit;      % (edit_feeding_interference_coefficient)
    7.6 9.5+oy_t_e w_edit h_edit;       % (edit_length_season)
    7.6 9.5 30.6 h_text;                % (text_length_season)
    23.4 20.7+oy_t_e w_edit h_edit;     % (edit_basal_respiration)
    23.4 20.7 30 h_text;                % (text_basal_respiration)
    23.4 17.4+oy_t_e w_edit h_edit      % (edit_producer_competition)
    23.4 17.4 32.4 h_text;              % (text_producer_competition)
    7.8 1 77.4 5.85;                    % (uibuttongroup_carrying_capacity)
    1.5 2.7 14.4 1.7692;                % (radiobutton_K_constant)
    19.4 2.7 17 1.7692;                 % (radiobutton_K_white_noise)
    49.6 2.7 11.4 1.7692;               % (radiobutton_K_AR1)
    1.5 1 6 h_text;                     % (text_K_mean)
    8.4 0.7 w_edit h_edit;              % (edit_K_mean)
    19.4 1 18.8 h_text;                 % (text_K_standard_deviation)
    38.4 0.7 w_edit h_edit;             % (edit_K_standard_deviation)
    49.6 1 15.4 h_text;                 % (text_K_autocorrelation)
    65.4 0.7 w_edit h_edit;             % (edit_K_autocorrelation)
    40 7.3 33.2 h_text;                 % (text_F_q)
    40 7.3+oy_t_e w_edit h_edit;        % (edit_F_q)
    75 15 22.6 h_text;                  % (text_assimilation_efficiency)
    75 15+oy_t_e w_edit h_edit;         % (edit_assimilation_efficiency)
    75 11.15 27.2 h_text;               % (text_maximum_consumption_rate)
    75 11.15+oy_t_e w_edit h_edit;      % (edit_maximum_consumption_rate)
    1.8 14.1 21 h_text;                 % (text_fraction_of_exudation)
    1.8 14.1+oy_t_e w_edit h_edit;      % (edit_fraction_of_exudation)
    1.8 7.5 15.4 h_text;                % (text_dissolution_rate)
    1.8 7.5+oy_t_e w_edit h_edit;       % (edit_dissolution_rate)
    1.8 4.2 9.2 h_text;                 % (text_hatchery)
    1.8 4.2+oy_t_e w_edit h_edit;       % (edit_hatchery)
    23.4 4.2 19.25 h_text;              % (text_invest)
    23.4 4.2+oy_t_e w_edit h_edit;      % (edit_invest)
    23.4 7.5 30.2 h_text;               % (text_activity_respiration_coefficient)
    23.4 7.5+oy_t_e w_edit h_edit;      % (edit_activity_respiration_coefficient)
    40 22 13.5 1.4;                     % (checkbox_catchable)
    43 4.2 11.75 h_text;                % (text_Pmat)
    43 4.2+oy_t_e w_edit h_edit;        % (edit_Pmat)
    172 13.6154 21.3 1.7;               % (pushbutton_generateRandomWeb)    
    172 11.61541 22.2 h_text;           % (text_numberOfSpecies)
    172 9.6154 w_edit h_edit;           % (edit_numberOfSpecies)    
    38 9.5 32 h_text;                   % (text_intraspecificCompetitionCoefficient)
    38 9.5+oy_t_e w_edit h_edit;        % (edit_intraspecificCompetitionCoefficient)
    43 27.7 10.2 h_text;                % (text_bodymass)
    43 27.7+oy_t_e w_edit h_edit;       % (edit_bodymass)
    20 27.7+oy_t_e 18.5 1.4;            % (checkbox_referenceguild)
    90 13.6154 13.8 1.7;                % (pushbutton_test)
    75 7.3+oy_t_e 13.8 1.7;             % (pushbutton_defaults)
    42 31 11 1.4;                       % (checkbox_enable)
    75 1.4 13.8 1.7;                    % (pushbutton_defaultsAll)
    74 9.5 32 h_text;                   % (text_numberOfYears)
    74 9.5+oy_t_e w_edit h_edit;        % (edit_numberOfYears)
    ];

for i = 1:length(handles.tab_simulate.all)
    if strcmpi(handles.tab_simulate.all(i).Type,'text')
        handles.tab_simulate.all(i).Position = tab_simulate_positions(i,1:3);
    elseif strcmpi(handles.tab_simulate.all(i).Type,'uipanel')
        handles.tab_simulate.all(i).Position = tab_simulate_positions(i,:);
    elseif strcmpi(handles.tab_simulate.all(i).Type,'axes')
        handles.tab_simulate.all(i).Position = tab_simulate_positions(i,:);
    elseif strcmpi(handles.tab_simulate.all(i).Type,'uibuttongroup')
        handles.tab_simulate.all(i).Position = tab_simulate_positions(i,:);
    elseif strcmpi(handles.tab_simulate.all(i).Type,'uicontrol')
        handles.tab_simulate.all(i).Position = tab_simulate_positions(i,:);
    end
end

for i = 1:length(handles.tab_guilds.all)
    if strcmpi(handles.tab_guilds.all(i).Type,'uipanel')
        handles.tab_guilds.all(i).Position = tab_guilds_positions(i,:);
    elseif strcmpi(handles.tab_guilds.all(i).Type,'uibuttongroup')
        handles.tab_guilds.all(i).Position = tab_guilds_positions(i,:);
    elseif strcmpi(handles.tab_guilds.all(i).Type,'uicontrol')
        handles.tab_guilds.all(i).Position = tab_guilds_positions(i,:);
    else
        handles.tab_guilds.all(i).Type
        handles.tab_guilds.all(i).Type;
    end
end
