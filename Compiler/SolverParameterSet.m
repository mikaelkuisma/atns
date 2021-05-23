classdef SolverParameterSet < handle
    properties (Constant)
        OPTIONAL_PARAMETERS = {'steps_per_day', 'day_length', ...
                               'days_per_year', 'years', ...
                               'day_name','year_name'};
%        OPTIONAL_DEFAULT_VALUES = { 3, 1.0, 20, 3, 'day','year'};
        OPTIONAL_DEFAULT_VALUES = { 10, 1.0, 90, 3, 'day','year'};
        COMPULSORY_PARAMETERS = {};
    end        
    properties
        steps_per_minor_epoch
        minor_epoch_length
        minor_epochs_per_major_epoch
        major_epochs
        minor_epoch_name
        major_epoch_name
    end
    methods
        function obj = SolverParameterSet(varargin)
           [steps_per_minor_epoch, ...
            minor_epoch_length, ...
            minor_epochs_per_major_epoch, ...
            major_epochs, ...
            minor_epoch_name, ...
            major_epoch_name ] = ... 
              resolve_compulsory_and_optional_parameters(varargin, ...
              class(obj), ...
              obj.COMPULSORY_PARAMETERS, ...
              obj.OPTIONAL_PARAMETERS,...
              obj.OPTIONAL_DEFAULT_VALUES);                       
            
            obj.steps_per_minor_epoch = steps_per_minor_epoch;
            obj.minor_epoch_length = minor_epoch_length;
            obj.minor_epochs_per_major_epoch = minor_epochs_per_major_epoch;
            obj.major_epochs = major_epochs;
            obj.minor_epoch_name = minor_epoch_name;
            obj.major_epoch_name = major_epoch_name;
        end
        
        function value = get_steps_per_minor_epoch(obj)
            value = obj.steps_per_minor_epoch;
        end
        
        function value = get_minor_epoch_length(obj)
            value = obj.minor_epoch_length;
        end
        
        function value = get_minor_epochs_per_major_epoch(obj)
            value = obj.minor_epochs_per_major_epoch;
        end
        
        function value = get_major_epochs(obj)
            value = obj.major_epochs;
        end
        
        function value = get_total_minor_epochs(obj)
            value = obj.get_minor_epochs_per_major_epoch() * obj.get_major_epochs();
        end
        
        function value = get_minor_epoch_name(obj)
            value = obj.minor_epoch_name;
        end
        
        function value = get_major_epoch_name(obj)
            value = obj.major_epoch_name;
        end
    end
end