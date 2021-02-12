classdef ResultDatabase < handle & matlab.mixin.CustomDisplay
    properties
        % Name of the result file
        filename
        
        % File handle to the (possible open) result file
        filehandle
        
        % Parameterset received from ModelSolver
        parameterset
        
        % Cell array with length of rowsize. 
        % Contains names of result rows.
        names
        
        tags
        
        classes
        
        % Lookup table from name to column index
        name_lookup
       
        rowsize
        total_minor_epochs
        total_major_epochs
        
        % These arrays contain all the data
        Bmajor
        Bminor
        
        major_index
        minor_index
        
        verbose
    end
    
methods (Access = protected)
   function displayScalarObject(obj)
       if isempty(obj.names)
           fprintf('No results found.\n\n');
           return
       end
       fprintf('This result object contains data for\n');
       fprintf('   %d %ss in total \n', obj.total_minor_epochs, obj.parameterset.minor_epoch_name);
       fprintf('   in %d %ss\n', obj.total_major_epochs, obj.parameterset.major_epoch_name);
       maxyear = min(10, obj.total_major_epochs);
       fprintf('\nDisplaying data for %d first %ss.\n', maxyear, obj.parameterset.major_epoch_name);
       fprintf(' %-10s ', obj.parameterset.major_epoch_name);
       for col=1:size(obj.Bmajor, 1)
           fprintf('%-10s ', obj.names{col});
       end
       fprintf('\n');
       for row = 1:maxyear
           rowtxt = [];
           for col = 1:size(obj.Bmajor, 1)
               rowtxt = [rowtxt sprintf('%10.2f ', obj.Bmajor(col, row)) ];
           end
           fprintf('%5d %s\n', row-1, rowtxt);
       end
       fprintf('...\n\n');
   end
end    
    
    methods
        % ResultDatabase takes paramterset from solver, which accurately
        % configures the minor and major epochs and their lengths.
        function obj = ResultDatabase(filename)
            obj.filename = filename;
            obj.parameterset = [];
            obj.major_index = 0;
            obj.minor_index = 0;
            obj.name_lookup = containers.Map;
        end
        
        function structured_plot(obj)
            plotdata = obj.get_struct();
            for plotid = 1:numel(plotdata)
                figure(plotid);
                hold on
                names = {};
                traces = plotdata{plotid}.data;
                for trace = 1:numel(traces)
                    trace = traces{trace};
                    plot(trace.x, trace.y,'color', rand(3,1));
                    names{end+1} = trace.name;
                end
                legend(names);
                title(plotdata{plotid}.layout.title);
            end
        end
        
        function plotdata = get_struct(obj)
            plotdata = {};
            
            [x,y] = obj.get_daily_data();

            % For each node
            distinct_classes = unique(obj.classes);
            for i=1:numel(distinct_classes)
                idx = find(strcmp(obj.classes, distinct_classes{i}));
                
                names_local = obj.names(idx);
                %tags_local = obj.tags(idx);
                
                distinct_names = unique(obj.names(idx));
                
                for k=1:numel(distinct_names)
                    idx2 = find(strcmp(names_local, distinct_names{k}));
                    %tags_local2 = tags_local(idx2);
                    ids = idx(idx2);
                    traces = {};
                    for id = ids
                        trace.x = x;
                        trace.y = y(id,:);
                        trace.name = obj.tags{id};
                        traces{end+1} = trace;
                    end
                    subplotdata.data = traces;
                    subplotdata.layout = struct('title',distinct_names{k});
                    plotdata{end+1} = subplotdata;
                end
            end
        end
        
        function html = asjson(obj)
            data = obj.get_struct();
            html = jsonencode(data);
        end
        
        function [x,data] = get_daily_data(obj)
            x = 0:(size(obj.Bminor,2)-1);
            data = obj.Bminor;
        end
        
        function set_solver_parameters(obj, solver, parameterset)
            % Get size of each row (i.e. the number of columns)
            obj.rowsize = solver.get_dynamical_size();
            
            % Get column names from solver
            [obj.names, obj.tags, obj.classes] = solver.get_dynamical_names();
            % Set up containers.Map, which mappingn from name to its index
            for i=1:numel(obj.names)
                obj.name_lookup(obj.names{i})=i;
            end
            
            obj.parameterset = parameterset;
            
            % Estimate number of datapoints to come
            obj.total_minor_epochs = parameterset.get_total_minor_epochs();
            obj.total_major_epochs = parameterset.get_major_epochs();
            
            % Preallocate result arrays
            obj.Bminor = zeros(obj.rowsize, obj.total_minor_epochs);
            obj.Bmajor = zeros(obj.rowsize, obj.total_major_epochs);
        end
        
        function add_major_epoch(obj, Bdata)
            obj.major_index = obj.major_index + 1;
            obj.Bmajor(:, obj.major_index) = Bdata;
            if obj.major_index > 1
                fprintf('Log10 absolute biomass change from last year %.2f\n', log10(sum(abs(obj.Bmajor(:, obj.major_index)-obj.Bmajor(:,obj.major_index-1)))));
            end
        end
        
        function B = get_last_B(obj, Bdata)
            B = obj.Bmajor(:, end);
        end
        
        function add_minor_epoch(obj, Bdata)
            obj.minor_index = obj.minor_index + 1;
            obj.Bminor(:, obj.minor_index) = Bdata;
        end
        
        function export(obj, filename)
             N = size(obj.Bmajor,2);
             data = [ 0:(N-1) ; obj.Bmajor ];
             T = array2table(data','VariableNames',[ {'year'} obj.names ]);
             writetable(T, filename);
             [fPath, fName, fExt] = fileparts(filename);
             fName = [ fName '_daily' ];
             
             N = size(obj.Bminor,2);
             data = [ (0:(N-1))*obj.parameterset.minor_epoch_length ; obj.Bminor ];
             T = array2table(data','VariableNames',[ {'day'} obj.names ]);
             writetable(T, [fPath fName fExt]);
        end
        
        function assert_same(obj, others)
            size(obj.Bminor)
            size(others.Bminor)
            obj.names
            others.names
            daydiff = norm(obj.Bminor - others.Bminor);
            yeardiff = norm(obj.Bmajor - others.Bmajor);
            fprintf('Results differ by %.6f at day level\n', daydiff);
            fprintf('Results differ by %.6f at year level\n', yeardiff);
            if daydiff > 1e-7
                figure(1);
                obj.plot();
                figure(2);
                others.plot();
                assert(daydiff < 1e-7);
            end
            assert(yeardiff < 1e-7);
        end
        
        function plot(obj,varargin)
            params = struct(varargin{:});
            if isfield(params,'hold')
                hold_value = params.hold;
            else
                hold_value = 'off';
            end
            % Resolve the column index, if given a column name
            %if ischar(idx)
            %   idx = obj.name_lookup(idx);
            %end
            hold(hold_value);
            % Get full data for column
            data = obj.Bminor(:, :)';
            
            N = size(data,1);
            plot((0:(N-1))*obj.parameterset.minor_epoch_length,data');
            
            % Locate the maximum and minimum values of data
            data_min = min(data(:));
            data_max = max(data(:));
            
            % If there is no variation in data, set default ylim to +-1 of
            % the constant value.
            if data_max == data_min
                data_max = data_max +1;
                data_min = data_min -1;
                span = 2;
            else
                % Increase the upper and lower limit by 10% of the span of
                % the data. If the data was not negative, stop lowering the
                % ylim at 0.
                span = data_max - data_min;
                data_max = data_max + span*0.1;
                was_negative = data_min < 0;
                data_min = data_min - span*0.1;
                if ~was_negative && data_min <0
                    data_min = 0;
                end
            end
            ylim([data_min data_max]);
            
            legend(obj.names,'Fontsize',14);
            
            % Create vertical bars for major epochs
            spacing = obj.parameterset.minor_epoch_length*obj.parameterset.get_minor_epochs_per_major_epoch();
            for i=0:(obj.parameterset.get_major_epochs()-1)
                if i>0
                line([i*spacing i*spacing],[data_min data_max], ...
                    'color','black','linestyle','--','HandleVisibility','off');
                end
                text(i*spacing, data_max-0.1*span, ...
                    sprintf('\\leftarrow %s %d', ...
                    obj.parameterset.get_major_epoch_name(),i));
            end
            xlabel(obj.parameterset.get_minor_epoch_name());
            xlim([0 N-1]*obj.parameterset.minor_epoch_length);
            set(gca,'Fontsize',14);
        end
    end
end