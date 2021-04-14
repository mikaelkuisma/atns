classdef VM < handle & matlab.mixin.CustomDisplay
    properties
        code
        ptr

        % For debug information, model may be spesified
        model
        
        initialized
        
        year

        %entry_points
        %entry_names
        %parameter_names
        %dynamic_names
        classes

        deployed_nodes

        module % VMClass
        module_instance % VMInstance

        return_stack
        context_stack
        stack
        %dynamic
        %gradient
        %parameter


        constants
    end

    methods (Access = protected)
      function displayScalarObject(obj)
          obj.show_namespace(obj.module_instance.dynamic, obj.module_instance.parameter);
      end
   end

    methods
        function obj = VM(code, model)
            if nargin>1
                obj.model = model;
            end
            obj.year = 0;
            obj.code = code;
            obj.ptr = 1;
            %obj.entry_names = {};
            obj.stack = {};
            obj.deployed_nodes = {};
            %obj.parameter = {};
            obj.module = VMClass('MODULE');
            obj.module_instance = VMInstance(obj.module);
            obj.context_stack = { };
            obj.classes = { obj.module };
            obj.initialize();
        end
        
        function reset(obj)
            obj.ptr = 1;
            obj.stack = {};
            obj.deployed_nodes = {};
            obj.module = VMClass('MODULE');
            obj.module_instance = VMInstance(obj.module);
            obj.context_stack = { };
            obj.classes = { obj.module };
        end
        
        function show_namespace(obj, dynamic, params)
            ns{1} = dynamic;
            ns{2} = params;
            if ~isempty(obj.model)
                obj.model.show_namespace(ns);
            end
        end
        
        function dynsize = get_dynamical_size(obj)
            dynsize = numel(obj.get_dynamical_names());
        end
        
        function [names, tags, classes] = get_dynamical_names(obj)
            names = {};
            tags = {};
            classes = {};
            context = obj.module_instance;
            for d = 1:numel(context.vmclass.dynamic_names)
                names{end+1} = context.vmclass.dynamic_names{d};
                tags{end+1} = '';
                classes{end+1} = 'module';
            end
            for node = 1:numel(obj.deployed_nodes)
                   node = obj.deployed_nodes{node}; % TODO: Remove same variable name, bad style
                   for d=1:numel(node.dynamic)
                      names{end+1} = char(node.vmclass.dynamic_names{d});
                      tags{end+1} = '';
                      classes{end+1} = char(node.vmclass.name);
                   end
                   for x=1:size(node.index_dynamic,1)
                     for y=1:size(node.index_dynamic,2)
                        names{end+1} = char(node.vmclass.index_dynamic_names{y});
                        tags{end+1} = char(node.tags{x});
                        classes{end+1} = char(node.vmclass.name);
                     end
                   end
            end
        end

        function jit_zero_gradient(obj, fid)
            context = obj.module_instance;
            for d = 1:numel(context.vmclass.dynamic_names)
                fprintf(fid, 'd%s_%sdt = 0;\n', context.classname, context.vmclass.dynamic_names{d});
            end
            for node = 1:numel(obj.deployed_nodes)
                node = obj.deployed_nodes{node};
                for d=1:numel(node.dynamic)
                    fprintf(fid, 'd%s_%sdt = 0;\n', node.classname, node.vmclass.dynamic_names{d});
                end
                for x=1:size(node.index_dynamic,1)
                    for y=1:size(node.index_dynamic,2)
                        value = [ node.tags{x} '_' node.vmclass.index_dynamic_names{y} ];
                        fprintf(fid, 'd%sdt = 0;\n', value);
                    end
                end
            end
            
            
        end
        
        function jit_compile_step(obj, fid)
            context = obj.module_instance;
            for d = 1:numel(context.vmclass.dynamic_names)
                dname = sprintf('%s_%s', context.classname, context.vmclass.dynamic_names{d});
                fprintf(fid, '%s = %s + d%sdt * dt;\n', dname, dname, dname);
            end
        end

        function jit_compile_flatvector(obj, fid, target)
            context = obj.module_instance;
            fprintf(fid, '%s = [ ', target);
            for d = 1:numel(context.vmclass.dynamic_names)
                fprintf(fid, '%s_%s ', context.classname, context.vmclass.dynamic_names{d});
            end            
            
            for node = 1:numel(obj.deployed_nodes)
                node = obj.deployed_nodes{node};
                for d=1:numel(node.dynamic)
                    fprintf(fid, '%s_%s ', node.classname, node.vmclass.dynamic_names{d});
                end
                for x=1:size(node.index_dynamic,1)
                    for y=1:size(node.index_dynamic,2)
                        value = [ node.tags{x} '_' node.vmclass.index_dynamic_names{y} ];
                        fprintf(fid, '%s ', value);
                    end
                end
            end            
            
            fprintf(fid, '];\n');
        end

        function jit_fromarray(obj, fid, target)
            context = obj.module_instance;
            for d = 1:numel(context.vmclass.dynamic_names)
                fprintf(fid, '%s_%s = %s(%d);\n', context.classname, context.vmclass.dynamic_names{d}, target, d);
            end
            idx = numel(context.vmclass.dynamic_names)+1;
            for node = 1:numel(obj.deployed_nodes)
                node = obj.deployed_nodes{node};
                for d=1:numel(node.dynamic)
                    fprintf(fid, '%s_%s = %s(%d);\n', node.classname, node.vmclass.dynamic_names{d}, target, idx);
                    idx = idx + 1;
                end
                for x=1:size(node.index_dynamic,1)
                    for y=1:size(node.index_dynamic,2)
                        value = [ node.tags{x} '_' node.vmclass.index_dynamic_names{y} ];
                        fprintf(fid, '%s = %s(%d);\n', value, target, idx);
                        idx = idx + 1;
                    end
                end
            end
            
        end
        
        
        function jit_compile_flatgrad(obj, fid, target)
            context = obj.module_instance;
            fprintf(fid, 'd%sdt = [ ', target);
            for d = 1:numel(context.vmclass.dynamic_names)
                fprintf(fid, 'd%s_%sdt ', context.classname, context.vmclass.dynamic_names{d});
            end            

            for node = 1:numel(obj.deployed_nodes)
                node = obj.deployed_nodes{node};
                for d=1:numel(node.dynamic)
                    fprintf(fid, 'd%s_%sdt ', node.classname, node.vmclass.dynamic_names{d});
                end
                for x=1:size(node.index_dynamic,1)
                    for y=1:size(node.index_dynamic,2)
                        value = [ node.tags{x} '_' node.vmclass.index_dynamic_names{y} ];
                        fprintf(fid, 'd%sdt ', value);
                    end
                end
            end
            fprintf(fid, '];\n');
        end
        
        function B=jit_gather_B(obj)
            B=[];
            context = obj.module_instance;
            for d = 1:numel(context.vmclass.dynamic_names)
                B(end+1) = context.dynamic{d};
            end
            for node = 1:numel(obj.deployed_nodes)
                node = obj.deployed_nodes{node};
                for d=1:numel(node.dynamic)
                    B(end+1) = node.dynamic{d};
                end
                for x=1:size(node.index_dynamic,1)
                    for y=1:size(node.index_dynamic,2)
                        B(end+1) = node.index_dynamic{x,y};
                    end
                end
            end
        end
        
        function jit_compile_init(obj, fid)
            context = obj.module_instance;
            for d = 1:numel(context.vmclass.dynamic_names)
                fprintf(fid, '%s_%s = %.16f;\n', context.classname, context.vmclass.dynamic_names{d}, context.dynamic{d});
            end
            for d = 1:numel(context.parameter)
                if ~isempty(context.parameter{d})
                fprintf(fid, '%s_%s = %.16f;\n', context.classname, context.vmclass.parameter_names{d}, context.parameter{d});
                end
            end            
            for node = 1:numel(obj.deployed_nodes)
                node = obj.deployed_nodes{node};
                for d=1:numel(node.dynamic)
                    fprintf(fid, '%s_%s = %.16f;\n', node.classname, node.vmclass.dynamic_names{d}, node.dynamic{d});
                end
                for d=1:numel(node.parameter)
                    if ~isempty(node.parameter{d})
                    fprintf(fid, '%s_%s = %.16f;\n', node.classname, node.vmclass.parameter_names{d}, node.parameter{d});
                    end
                end
                for x=1:size(node.index_dynamic,1)
                    for y=1:size(node.index_dynamic,2)
                        value = [ node.tags{x} '_' node.vmclass.index_dynamic_names{y} ];
                        fprintf(fid, '%s = %.16f;\n', value, node.index_dynamic{x,y});
                    end
                end
                for x=1:size(node.index_parameter,1)
                    for y=1:size(node.index_parameter,2)
                        value = [ node.tags{x} '_' node.vmclass.index_parameter_names{y} ];
                        fprintf(fid, '%s = %.16f;\n', value, node.index_parameter{x,y});
                    end
                end
                linkindexkeys = keys(node.link_index_parameter);
                for x = 1:numel(linkindexkeys);
                    key = linkindexkeys{x};
                    value = node.link_index_parameter(key);
                    for y = 1:numel(value)
                        varname = sprintf('%s_link%d_%s', node.classname, x, node.vmclass.link_indexed_parameter_names{y});
                        val = value{y};
                        fprintf(fid, '%s = %.16f;\n', varname, val);
                    end
                end
                %for x = 
                %    x
                %    pause
                %end
                
            end
            
        end
        
        function data = get_deploy_struct(obj)
            data{1} = obj.module_instance.get_deploy_struct();
            for i=1:numel(obj.deployed_nodes)
                node = obj.deployed_nodes{i};
                data{end+1} = node.get_deploy_struct();
            end
        end
        
        function gradfun = jit_gradient_function(obj)
            %obj.reset();
            %obj.context_stack{end+1} = obj.module_instance;
            %context = obj.module_instance;
            %obj.load(); % Deploys objects in module
            %obj.call_by_entry_id(1); % Call module .init
            fname = sprintf('temp_gradient_%d.m', floor(rand(1)*1000000));
            fid = fopen(fname,'w');
            fprintf(fid, 'function dBdt = temp_gradient(B)\n');
            obj.jit_compile_init(fid); % Just copy already set up values
            obj.jit_fromarray(fid,'B'); % Rewrite B here
            obj.jit_compile_update(fid);
            obj.jit_compile_update(fid);
            obj.jit_compile_flatgrad(fid,'B');
            fclose(fid);
            gradfun = str2func(fname(1:end-2));
        end
        
        function yearfun = jit_year_function(obj)
            fid = fopen('temp_year.m','w');
            fprintf(fid, 'function dBdt = temp_year(B)\n');
            obj.jit_compile_init(fid); % Just copy already set up values
            obj.jit_fromarray(fid, 'B');
            obj.jit_compile_update_yearly(fid);
            obj.jit_compile_flatgrad(fid,'B');
            fprintf(fid, 'end\n');
            fclose(fid);
            yearfun = @temp_year;
            
        end
        
        function initialize(obj)
            obj.reset();
            obj.context_stack{end+1} = obj.module_instance;
            obj.load(); % Deploys objects in module
            obj.call_by_entry_id(1); % Call module .init
            obj.initialized = 1;
        end
        
        function J = jacobian(obj, B, gradfun)
            J = [];
            dfdB0 = gradfun(B);
            dB = 1e-5;
            for i=1:numel(B)
                B1 = B;
                B1(i) = B1(i) + dB;
                dfdB1 = gradfun(B1);
                J = [ J ; (dfdB1-dfdB0)/dB ];
            end                
        end

        function J = jit_jacobian_simple(obj, parameterset)
            if ~obj.initialized
                obj.initialize();
            end
            gradfun = obj.jit_gradient_function();
            Bref = obj.jit_gather_B();
            gradfun(Bref)
            J = obj.jacobian(Bref, gradfun);
        end
        
        
        function results = jit_my(obj, parameterset, prefix)
            if nargin < 3
                prefix = '';
            end
            logplot=1;
            %parameterset = SolverParameterSet();
            %results = obj.jit_solve(parameterset);
            %results.plot();
            %[x,data] = results.get_daily_data();
            %Bref = data(:,end)';
            if ~obj.initialized
                obj.initialize();
            end

            context = obj.module_instance;
            
            results = ResultDatabase([]);
            if nargin<2 || isempty(parameterset)
                parameterset = SolverParameterSet(); % Default parameters
            end
            
            daylength = context.get_parameter_by_name('daylength');
            if ~isempty(daylength)
                parameterset.minor_epoch_length = daylength;
            end
            stepsperday = context.get_parameter_by_name('stepsperday');
            if ~isempty(stepsperday)
                parameterset.steps_per_minor_epoch = stepsperday;
            end
            daysperyear = context.get_parameter_by_name('daysperyear');
            if ~isempty(daysperyear)
                parameterset.minor_epochs_per_major_epoch = daysperyear;
            end
            years = context.get_parameter_by_name('years');
            if ~isempty(years)
                parameterset.major_epochs = years;
            end
            results.set_solver_parameters(obj, parameterset);
            
            Bref = obj.jit_gather_B();
            
 % Get parameters from parameter set
               minor_epoch_length = parameterset.minor_epoch_length;
               steps_per_minor_epoch = parameterset.steps_per_minor_epoch; 
               minor_epochs_per_major_epoch = parameterset.minor_epochs_per_major_epoch;
               major_epochs = parameterset.major_epochs;
            
               dt = minor_epoch_length / steps_per_minor_epoch;            
            gradfun = obj.jit_gradient_function();
            yearfun = obj.jit_year_function();
            if logplot
            t = logspace(log10(0.5), log10(90*20)-0.1,100);
            else
            t = 0:(major_epochs*minor_epochs_per_major_epoch-1);
            end
            
            
 
            Jstart = obj.jacobian(Bref, gradfun);
            g=3;
 greenColorMap = [zeros(1, 132), linspace(0, 1, 124).^(1/g)];
redColorMap = [linspace(1, 0, 124).^(1/g), zeros(1, 132)];
colorMap = [redColorMap; greenColorMap; zeros(1, 256)]';
% Apply the colormap.            
               figure(1);
               alldata = zeros( [size(Jstart) numel(t) ]);
               for i=1:numel(t)
                   T = t(i);
            size(Jstart)
                   
                   alldata(:,:,i) = expm(Jstart*T);
               end
               %for dof=1:numel(Bref)
               %    subplot(5,5,dof);
               %    imagesc(squeeze(alldata(:,dof,:)));
               %    caxis([-0.1 0.1]);
               %    colormap(colorMap);
               %end
               figure(3);
               for dof=1:min(44,numel(Bref))
                   subplot(11,4,dof);
                   imagesc(squeeze(alldata(dof,:, :)));
                   caxis([-0.1 0.1]);
                   colormap(colorMap);
               end
               
               figure(2);                           
                           
            for dof = 1:min(44,numel(Bref))

               Bref2 = Bref;
               Bref2(dof) = Bref2(dof) + 1e-5;
               B = { Bref Bref2 };
            
            iteration = 1;
            data = zeros(numel(Bref), numel(B), years*minor_epochs_per_major_epoch);
            rows = 1;
           

            for major=1:major_epochs
                fprintf('year %d\n', major);
               for minor=1:minor_epochs_per_major_epoch
                  for iter=1:steps_per_minor_epoch
                     if iter==1 
                         %results.add_minor_epoch(B);
                             for i=1:numel(B)
                                 data(:, i, rows) = B{i};
                             end
                             rows = rows+1;
                         
                         if minor == 1
                             %results.add_major_epoch(B);
                         end
                     end
                     for i=1:numel(B)
                         dBdt = gradfun(B{i});
                         dBdt2 = gradfun(B{i} + dBdt*dt);
                         B{i} = B{i} + (dBdt+dBdt2)*dt/2;
                     end
                  end % intraday steps
               end % minor
               
               for i=1:numel(B)
               B{i} = B{i} + yearfun(B{i});
               end
               
               %obj.update_yearly();
               %fprintf('TODO: UPDATE YEARLY');
               %J=[];
               %for i=2:2:numel(B)
               %    J = [ J ; (B{i}-B{i+1})/(2*eps) ];
               %end
               %U = B{1+6*2}
               %D = B{1+6*2+1}
               %UD = U-D
               %save('J.mat','J','B');
               %figure(1);
               %imagesc(J);
               %colorbar
               %figure(2);
               %clf
               
               %[PSI,E] = eig(J); E=diag(E);
               %PSI
               %E
               %PSI(:,1)
               %pause(1)
            end % major
               figure(2);
               clf
               hold off
               %plot(squeeze(data(:, 1, :))','b');
               %hold on
               %plot(squeeze(data(:, 2, :))','k--');
               %subplot(11,4,dof);
               t0 = 0:(size(data,3)-1);
               for x=1:size(data,1)
                   for y=1:size(data,2)
                      logdata(x,y,:) = interp1(t0, squeeze(data(x,y,:)), t,'linear','extrap');
                   end
               end
               imagesc((1/1e-5*(squeeze(logdata(:, 2, :))-squeeze(logdata(:,1,:)))));
               if logplot
               tics = [ 1 7 30 90 5*90 20*90];
               ticknames = {'day','week','month','yr','5 yr','20 yr'};
               xlabel('time');
               tickpos=[];
               for i=2:numel(tics)
                  [minValue,closestIndex] = min(abs(t-tics(i)));
                  tickpos(i) = closestIndex;
               end
               
               else
                 tickpos = (1:20)*90;
                 ticknames={};
                 for i=1:20
                 ticknames{i} = sprintf('%d', tickpos(i)/90);
                 end
                 xlabel('year');
               end
               set(gca,'xtick',tickpos);
               set(gca,'xticklabel',ticknames);
               set(gca,'ytick',1:44);
               for i=1:numel(results.tags)
                   labels{i} = [ results.tags{i} '.' results.names{i} ];
               end
               set(gca,'yticklabel', labels);
               title([ results.tags{dof} '.' results.names{dof} ]);
               caxis([-0.05 0.05]);
              
               colormap(colorMap);
               set(gcf,'PaperUnits','inches','PaperPosition',[0 0 10 8])
               print('-dpng',sprintf('%s_dof_%03d_%s.png', prefix, dof, [ results.tags{dof} '.' results.names{dof} ]),'-r150');
            end
            
               end
        
        
        
        
        function results = jit_jacobian(obj, parameterset)
            %parameterset = SolverParameterSet();
            %results = obj.jit_solve(parameterset);
            %results.plot();
            %[x,data] = results.get_daily_data();
            %Bref = data(:,end)';
            if ~obj.initialized
                obj.initialize();
            end

            context = obj.module_instance;
            
            results = ResultDatabase([]);
            if nargin<2 || isempty(parameterset)
                parameterset = SolverParameterSet(); % Default parameters
            end
            
            daylength = context.get_parameter_by_name('daylength');
            if ~isempty(daylength)
                parameterset.minor_epoch_length = daylength;
            end
            stepsperday = context.get_parameter_by_name('stepsperday');
            if ~isempty(stepsperday)
                parameterset.steps_per_minor_epoch = stepsperday;
            end
            daysperyear = context.get_parameter_by_name('daysperyear');
            if ~isempty(daysperyear)
                parameterset.minor_epochs_per_major_epoch = daysperyear;
            end
            years = context.get_parameter_by_name('years');
            if ~isempty(years)
                parameterset.major_epochs = years;
            end
            results.set_solver_parameters(obj, parameterset);
            
            Bref = obj.jit_gather_B();
            
            B{1} = Bref;

            Bref = B{1};
            B = { Bref };
            eps = 1;
            for i=1:numel(Bref)
                Bjac = Bref;
                Bjac(i) = Bjac(i) + 2*eps;
                B{end+1} = Bjac;
                Bjac(i) = Bjac(i) - 2*eps;
                B{end+1} = Bjac;
            end                
            
            
            % Get parameters from parameter set
            minor_epoch_length = parameterset.minor_epoch_length;
            steps_per_minor_epoch = parameterset.steps_per_minor_epoch; 
            minor_epochs_per_major_epoch = parameterset.minor_epochs_per_major_epoch;
            major_epochs = parameterset.major_epochs;
            
            dt = minor_epoch_length / steps_per_minor_epoch;
            
            iteration = 1;
            gradfun = obj.jit_gradient_function();
            data = zeros(numel(Bref), numel(B), years*minor_epochs_per_major_epoch);
            rows = 1;
            for major=1:major_epochs
               for minor=1:minor_epochs_per_major_epoch
                  fprintf('year %d day %d \n', major, minor);
                  for iter=1:steps_per_minor_epoch
                     if iter==1 
                         %results.add_minor_epoch(B);
                             for i=1:numel(B)
                                 data(:, i, rows) = B{i}-B{1};
                             end
                             rows = rows+1;
                         
                         if minor == 1
                             %results.add_major_epoch(B);
                         end
                     end
                     for i=1:numel(B)
                         dBdt = gradfun(B{i});
                         dBdt2 = gradfun(B{i} + dBdt*dt);
                         B{i} = B{i} + (dBdt+dBdt2)*dt/2;
                     end
                  end % intraday steps
               end % minor
               %obj.update_yearly();
               fprintf('TODO: UPDATE YEARLY');
               J=[];
               for i=2:2:numel(B)
                   J = [ J ; (B{i}-B{i+1})/(2*eps) ];
               end
               %U = B{1+6*2}
               %D = B{1+6*2+1}
               %UD = U-D
               save('J.mat','J','B');
               figure(1);
               imagesc(J);
               colorbar
               figure(2);
               clf
               for i=1:numel(B)
                  plot(squeeze(data(:, i, :))');
                  hold on
               end
               
               [PSI,E] = eig(J); E=diag(E);
                pause(1);
            end % major
            dfssdf;
        end
        
        function results = jit_solve(obj, parameterset)
            %obj.reset();
            %obj.context_stack{end+1} = obj.module_instance;

            context = obj.module_instance;
            
            %obj.load(); % Deploys objects in module
            %obj.call_by_entry_id(1); % Call module .init
            if obj.initialized
                obj.initialize();
            end

            results = ResultDatabase([]);
            if nargin<2 || isempty(parameterset)
                parameterset = SolverParameterSet(); % Default parameters
            end
            
            daylength = context.get_parameter_by_name('daylength');
            if ~isempty(daylength)
                parameterset.minor_epoch_length = daylength;
            end
            stepsperday = context.get_parameter_by_name('stepsperday');
            if ~isempty(stepsperday)
                parameterset.steps_per_minor_epoch = stepsperday;
            end
            daysperyear = context.get_parameter_by_name('daysperyear');
            if ~isempty(daysperyear)
                parameterset.minor_epochs_per_major_epoch = daysperyear;
            end
            years = context.get_parameter_by_name('years');
            if ~isempty(years)
                parameterset.major_epochs = years;
            end
            
            results.set_solver_parameters(obj, parameterset);
            
            % Get parameters from parameter set
            lines = { 'minor_epoch_length = parameterset.minor_epoch_length;', ...
                      'steps_per_minor_epoch = parameterset.steps_per_minor_epoch;',...
                      'minor_epochs_per_major_epoch = parameterset.minor_epochs_per_major_epoch;',...
                      'major_epochs = parameterset.major_epochs;', ...
                      'dt = minor_epoch_length / steps_per_minor_epoch;'};
            fname = sprintf('temp_update_code_%d.m',floor(rand(1)*100000000));
            fid = fopen(fname, 'w');
            fprintf(fid, 'function results = temp_update_code(parameterset, results)\n');
            fprintf(fid, '%s\n', lines{:});
            obj.jit_compile_init(fid); % Just copy already set up values
            fprintf(fid, 'for major=1:major_epochs\n');
            fprintf(fid, '      fprintf(''year %%d\\n'', major);\n');
            fprintf(fid, '   for minor=1:minor_epochs_per_major_epoch\n');
            fprintf(fid, '      for iter=1:steps_per_minor_epoch\n');
            fprintf(fid, '       if iter==1\n');
            obj.jit_compile_flatvector(fid,'Bflat');
            fprintf(fid, '            results.add_minor_epoch(Bflat);\n');
            fprintf(fid, '            if minor == 1\n');
            fprintf(fid, '                results.add_major_epoch(Bflat);\n');
            fprintf(fid, '            end\n');
            fprintf(fid, '        end\n');
            obj.jit_compile_flatvector(fid,'Bflat');
            obj.jit_compile_update(fid);
            obj.jit_compile_flatgrad(fid,'Bflat');
            fprintf(fid, 'Bflat2 = Bflat;\n');
            fprintf(fid, 'Bflat = Bflat + dBflatdt*dt;\n');
            obj.jit_fromarray(fid, 'Bflat');
            obj.jit_compile_update(fid);
            obj.jit_compile_flatgrad(fid,'Bflat2');
            fprintf(fid, 'Bflat = Bflat2 + (dBflatdt+dBflat2dt)*dt/2;\n');
            obj.jit_fromarray(fid, 'Bflat');
            fprintf(fid, '      end\n');
            fprintf(fid, '   end\n');

            obj.jit_compile_flatvector(fid,'Bflat');
            obj.jit_compile_update_yearly(fid);
            obj.jit_compile_flatgrad(fid,'Bflat');
            fprintf(fid, 'Bflat = Bflat + dBflatdt;\n');
            obj.jit_fromarray(fid, 'Bflat');
            obj.jit_compile_update(fid);
            fprintf(fid, 'end\n');
            fclose(fid);
            calculation = str2func(fname(1:end-2));
            results = calculation(parameterset, results);
            B = results.get_last_B();
            ND = numel(context.dynamic);
            for d = 1:ND
                context.dynamic{d} = B(d);
            end
            idx = ND+1;
            for node = 1:numel(obj.deployed_nodes)
               node = obj.deployed_nodes{node};
               for d=1:numel(node.dynamic)
                   node.dynamic{d} = B(idx); idx = idx+1;
              end
                         for x=1:size(node.index_dynamic,1)
                             for y=1:size(node.index_dynamic,2)
                                 node.index_dynamic{x,y} = B(idx); idx = idx +1;
                             end
                         end
                     end
            return
            xxx
            B = {};            
            ND = numel(context.dynamic);
            NALL = numel([ context.dynamic{:}]);
            for node = 1:numel(obj.deployed_nodes)
               % TODO: static dynamics
               node = obj.deployed_nodes{node};
               for d=1:numel(node.dynamic)
                    NALL = NALL + numel(node.dynamic{d});
               end               
               for x=1:size(node.index_dynamic,1)
                     for y=1:size(node.index_dynamic,2)
                         NALL = NALL + numel(node.index_dynamic{x,y});
                     end
               end
            end
            N = major_epochs * minor_epochs_per_major_epoch * steps_per_minor_epoch;
            data = zeros(NALL, N);
            iteration = 1;
            for major=1:major_epochs
               for minor=1:minor_epochs_per_major_epoch
                  fprintf('year %d day %d \n', major, minor);
                  for iter=1:steps_per_minor_epoch
                     % OBTAIN B from context
                     for d = 1:ND
                        B{d} = context.dynamic{d};
                     end
                     idx = ND+1;
                     for node = 1:numel(obj.deployed_nodes)
                         node = obj.deployed_nodes{node};
                         for d=1:numel(node.dynamic)
                             B{idx} = node.dynamic{d}; idx = idx+1;
                         end
                         for x=1:size(node.index_dynamic,1)
                             for y=1:size(node.index_dynamic,2)
                                 B{idx} = node.index_dynamic{x,y}; idx = idx +1;
                             end
                         end
                     end
                     Bflat = cellfun( @(x) x(:), B, 'UniformOutput', false);
                     if iter==1 
                         results.add_minor_epoch(vertcat( Bflat{:} ));
                         if minor == 1
                             results.add_major_epoch(vertcat( Bflat{:} ));
                         end
                     end
                     data(:,iteration) = vertcat( Bflat{:} ); iteration = iteration + 1;

                     obj.update();
                     for d = 1:ND
                         B{d} = B{d} + 0.5*context.gradient{d}*dt;
                         context.dynamic{d} = B{d} + context.gradient{d}*dt;
                     end
                     idx = ND+1;
                     for node = 1:numel(obj.deployed_nodes)
                         % TODO: static dynamics
                         node = obj.deployed_nodes{node};
                         for d=1:numel(node.dynamic)
                             B{idx} = B{idx} + 0.5*context.gradient{d}*dt; idx = idx + 1;
                             node.dynamic{d} = node.dynamic{d} + context.gradient{d}*dt; 
                         end
                   
                         for x=1:size(node.index_dynamic,1)
                             for y=1:size(node.index_dynamic,2)
                                 node.index_dynamic{x,y} = B{idx} + node.index_gradient{x,y}*dt;
                                 B{idx} = B{idx} + 0.5*node.index_gradient{x,y}*dt; 
                                 idx = idx + 1;
                             end
                         end
                     end
               
                     obj.update();
                     for d = 1:ND
                         context.dynamic{d} = B{d} + 0.5*context.gradient{d}*dt;
                     end
                     idx = ND+1;
               
                     for node = 1:numel(obj.deployed_nodes)
                         node = obj.deployed_nodes{node}; % TODO: Remove same variable name, bad style
                         for d=1:numel(node.dynamic)
                            node.dynamic{d} = B{idx} + 0.5*node.gradient{d}*dt; idx = idx +1;
                         end
                         for x=1:size(node.index_dynamic,1)
                             for y=1:size(node.index_dynamic,2)
                                 node.index_dynamic{x,y} = B{idx} + 0.5*node.index_gradient{x,y}*dt;
                                 %fprintf('%f by %f\n', B{idx}, node.index_gradient{x,y});
                                 idx = idx + 1;
                             end
                         end
                     end
                     
                      
                  end % intraday steps
               end % minor
               obj.update_yearly();
               
               for d = 1:ND
                   context.dynamic{d} = context.dynamic{d} + context.gradient{d};
               end
               idx = ND+1;
               
               for node = 1:numel(obj.deployed_nodes)
                   node = obj.deployed_nodes{node}; % TODO: Remove same variable name, bad style
                   for d=1:numel(node.dynamic)
                       node.dynamic{d} = node.dynamic{d} + node.gradient{d};
                   end
                   for x=1:size(node.index_dynamic,1)
                       for y=1:size(node.index_dynamic,2)
                            node.index_dynamic{x,y} = node.index_dynamic{x,y} + node.index_gradient{x,y};
                            idx = idx + 1;
                       end
                    end
                end
               
            end % major
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            % FOR DEBUG PLOTTING     %
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            if 0 
            figure;
            hold off
            data
            t = (0:(N-1))*dt;

            for i=1:size(data,1)
            plot(t, data(i,:),'.-r');
            hold on
            end
            %plot(t,0.2*exp(t),'b');
            %plot(t,230*exp(-t),'b');
            results = [];
            for d = 1:ND
                result.x = t;
                result.y = data(d,:);
                result.name = context.vmclass.dynamic_names{d};
                results = [ results result ];
            end
            idx = ND+1;
            for node = 1:numel(obj.deployed_nodes)
                   node = obj.deployed_nodes{node}; % TODO: Remove same variable name, bad style
                   for d=1:numel(node.dynamic)
                      result.x = t;
                      result.y = data(idx,:);
                      result.name = node.vmclass.dynamic_names{d};
                      idx = idx+1;
                      results = [ results result ];
                   end            
                   for x=1:size(node.index_dynamic,1)
                     for y=1:size(node.index_dynamic,2)
                        result.x = t;
                        result.y = data(idx,:);
                        result.name = 'TODO:indexed_dynamic_name';
                        idx = idx+1;
                                        results = [ results result ];

                     end
                   end
                   
            end
            end
        end % solver
        
        function results = compare_solve(obj, parameterset)
            if nargin < 2
                parameterset = SolverParameterSet();
            end
            tic
            results2 = obj.jit_solve(parameterset);
            jittime = toc;
            tic
            results = obj.official_solve(parameterset);
            vmtime = toc;
            results.assert_same(results2);
            fprintf('Speedup %.2f %%\n', (vmtime/jittime-1)*100);

        end
        
        function results = official_solve(obj, parameterset)
            obj.reset();
            obj.context_stack{end+1} = obj.module_instance;

            context = obj.module_instance;
            
            obj.load(); % Deploys objects in module
            obj.call_by_entry_id(1); % Call module .init

            results = ResultDatabase([]);
            if nargin<2 || isempty(parameterset)
                parameterset = SolverParameterSet(); % Default parameters
            end
            
            daylength = context.get_parameter_by_name('daylength');
            if ~isempty(daylength)
                parameterset.minor_epoch_length = daylength;
            end
            stepsperday = context.get_parameter_by_name('stepsperday');
            if ~isempty(stepsperday)
                parameterset.steps_per_minor_epoch = stepsperday;
            end
            daysperyear = context.get_parameter_by_name('daysperyear');
            if ~isempty(daysperyear)
                parameterset.minor_epochs_per_major_epoch = daysperyear;
            end
            years = context.get_parameter_by_name('years');
            if ~isempty(years)
                parameterset.major_epochs = years;
            end
            
            results.set_solver_parameters(obj, parameterset);
            
            % Get parameters from parameter set
            minor_epoch_length = parameterset.minor_epoch_length;
            steps_per_minor_epoch = parameterset.steps_per_minor_epoch; 
            minor_epochs_per_major_epoch = parameterset.minor_epochs_per_major_epoch;
            major_epochs = parameterset.major_epochs;
            
            dt = minor_epoch_length / steps_per_minor_epoch;
            B = {};            
            ND = numel(context.dynamic);
            NALL = numel([ context.dynamic{:}]);
            for node = 1:numel(obj.deployed_nodes)
               % TODO: static dynamics
               node = obj.deployed_nodes{node};
               for d=1:numel(node.dynamic)
                    NALL = NALL + numel(node.dynamic{d});
               end               
               for x=1:size(node.index_dynamic,1)
                     for y=1:size(node.index_dynamic,2)
                         NALL = NALL + numel(node.index_dynamic{x,y});
                     end
               end
            end
            N = major_epochs * minor_epochs_per_major_epoch * steps_per_minor_epoch;
            data = zeros(NALL, N);
            iteration = 1;
            for major=1:major_epochs
               for minor=1:minor_epochs_per_major_epoch
                  fprintf('year %d day %d \n', major, minor);
                  for iter=1:steps_per_minor_epoch
                     % OBTAIN B from context
                     for d = 1:ND
                        B{d} = context.dynamic{d};
                     end
                     idx = ND+1;
                     for node = 1:numel(obj.deployed_nodes)
                         node = obj.deployed_nodes{node};
                         for d=1:numel(node.dynamic)
                             B{idx} = node.dynamic{d}; idx = idx+1;
                         end
                         for x=1:size(node.index_dynamic,1)
                             for y=1:size(node.index_dynamic,2)
                                 B{idx} = node.index_dynamic{x,y}; idx = idx +1;
                             end
                         end
                     end
                     Bflat = cellfun( @(x) x(:), B, 'UniformOutput', false);
                     if iter==1 
                         results.add_minor_epoch(vertcat( Bflat{:} ));
                         if minor == 1
                             results.add_major_epoch(vertcat( Bflat{:} ));
                         end
                     end
                     data(:,iteration) = vertcat( Bflat{:} ); iteration = iteration + 1;

                     obj.update();
                     for d = 1:ND
                         context.dynamic{d} = context.dynamic{d} + context.gradient{d}*dt;
                         B{d} = B{d} + 0.5*context.gradient{d}*dt;
                     end
                     idx = ND+1;
                     for node = 1:numel(obj.deployed_nodes)
                         % TODO: static dynamics
                         node = obj.deployed_nodes{node};
                         for d=1:numel(node.dynamic)
                             B{idx} = B{idx} + 0.5*context.gradient{d}*dt; idx = idx + 1;
                             node.dynamic{d} = node.dynamic{d} + context.gradient{d}*dt; 
                         end
                   
                         for x=1:size(node.index_dynamic,1)
                             for y=1:size(node.index_dynamic,2)
                                 node.index_dynamic{x,y} = B{idx} + node.index_gradient{x,y}*dt;
                                 B{idx} = B{idx} + 0.5*node.index_gradient{x,y}*dt; 
                                 idx = idx + 1;
                             end
                         end
                     end
               
                     obj.update();
                     for d = 1:ND
                         context.dynamic{d} = B{d} + 0.5*context.gradient{d}*dt;
                     end
                     idx = ND+1;
               
                     for node = 1:numel(obj.deployed_nodes)
                         node = obj.deployed_nodes{node}; % TODO: Remove same variable name, bad style
                         for d=1:numel(node.dynamic)
                            node.dynamic{d} = B{idx} + 0.5*node.gradient{d}*dt; idx = idx +1;
                         end
                         for x=1:size(node.index_dynamic,1)
                             for y=1:size(node.index_dynamic,2)
                                 node.index_dynamic{x,y} = B{idx} + 0.5*node.index_gradient{x,y}*dt;
                                 %fprintf('%f by %f\n', B{idx}, node.index_gradient{x,y});
                                 idx = idx + 1;
                             end
                         end
                     end
                     
                      
                  end % intraday steps
               end % minor
               obj.update_yearly();
               
               for d = 1:ND
                   context.dynamic{d} = context.dynamic{d} + context.gradient{d};
               end
               idx = ND+1;
               
               for node = 1:numel(obj.deployed_nodes)
                   node = obj.deployed_nodes{node}; % TODO: Remove same variable name, bad style
                   for d=1:numel(node.dynamic)
                       node.dynamic{d} = node.dynamic{d} + node.gradient{d};
                   end
                   for x=1:size(node.index_dynamic,1)
                       for y=1:size(node.index_dynamic,2)
                            node.index_dynamic{x,y} = node.index_dynamic{x,y} + node.index_gradient{x,y};
                            idx = idx + 1;
                       end
                    end
                end
               
            end % major
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            % FOR DEBUG PLOTTING     %
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            if 0 
            figure;
            hold off
            data
            t = (0:(N-1))*dt;

            for i=1:size(data,1)
            plot(t, data(i,:),'.-r');
            hold on
            end
            %plot(t,0.2*exp(t),'b');
            %plot(t,230*exp(-t),'b');
            results = [];
            for d = 1:ND
                result.x = t;
                result.y = data(d,:);
                result.name = context.vmclass.dynamic_names{d};
                results = [ results result ];
            end
            idx = ND+1;
            for node = 1:numel(obj.deployed_nodes)
                   node = obj.deployed_nodes{node}; % TODO: Remove same variable name, bad style
                   for d=1:numel(node.dynamic)
                      result.x = t;
                      result.y = data(idx,:);
                      result.name = node.vmclass.dynamic_names{d};
                      idx = idx+1;
                      results = [ results result ];
                   end            
                   for x=1:size(node.index_dynamic,1)
                     for y=1:size(node.index_dynamic,2)
                        result.x = t;
                        result.y = data(idx,:);
                        result.name = 'TODO:indexed_dynamic_name';
                        idx = idx+1;
                                        results = [ results result ];
                     end
                   end
                   
            end
            end
        end % solver
        
        
        function results = solve(obj, context, N,dt)
            obj.reset();

            if nargin < 2 || isempty(context)
               context = obj.module_instance;
            end
            obj.context_stack{end+1} = context;
            
            obj.load(); % Deploys objects
            obj.call_by_entry_id(1);
            if nargin < 3
                N=320;
            end
            if nargin<4
                dt=0.1;
            end

            ND = numel(context.dynamic);
            NALL = numel([ context.dynamic{:}]);
            for node = 1:numel(obj.deployed_nodes)
               % TODO: static dynamics
               node = obj.deployed_nodes{node};
               for d=1:numel(node.dynamic)
                    NALL = NALL + numel(node.dynamic{d});
               end               
               for x=1:size(node.index_dynamic,1)
                     for y=1:size(node.index_dynamic,2)
                         NALL = NALL + numel(node.index_dynamic{x,y});
                     end
               end
            end
            data = zeros(NALL, N);
            
            t = (0:(N-1))*dt;
            B={};
            for i=1:N
               % OBTAIN B from context
               for d = 1:ND
                   B{d} = context.dynamic{d};
               end
               idx = ND+1;
               for node = 1:numel(obj.deployed_nodes)
                   node = obj.deployed_nodes{node};
                   for d=1:numel(node.dynamic)
                       B{idx} = node.dynamic{d}; idx = idx+1;
                   end
                   for x=1:size(node.index_dynamic,1)
                     for y=1:size(node.index_dynamic,2)
                         B{idx} = node.index_dynamic{x,y}; idx = idx +1;
                     end
                   end
               end
               Bflat = cellfun( @(x) x(:), B, 'UniformOutput', false);
               data(:,i) = vertcat( Bflat{:} );
               obj.update();
               for d = 1:ND
                   context.dynamic{d} = B{d} + context.gradient{d}*dt;
                   B{d} = B{d} + 0.5*context.gradient{d}*dt;
               end
               idx = ND+1;
               for node = 1:numel(obj.deployed_nodes)
                   % TODO: static dynamics
                   node = obj.deployed_nodes{node};
                   for d=1:numel(node.dynamic)
                       B{idx} = B{idx} + 0.5*context.gradient{d}*dt; idx = idx + 1;
                       node.dynamic{d} = node.dynamic{d} + context.gradient{d}*dt; 
                   end
                   
                   for x=1:size(node.index_dynamic,1)
                     for y=1:size(node.index_dynamic,2)
                         node.index_dynamic{x,y} = B{idx} + node.index_gradient{x,y}*dt;
                         B{idx} = B{idx} + 0.5*node.index_gradient{x,y}*dt; 
                         idx = idx + 1;
                     end
                   end
               end
               
               obj.update();
               for d = 1:ND
                   context.dynamic{d} = B{d} + 0.5*context.gradient{d}*dt;
               end
               idx = ND+1;
               
               for node = 1:numel(obj.deployed_nodes)
                   node = obj.deployed_nodes{node}; % TODO: Remove same variable name, bad style
                   for d=1:numel(node.dynamic)
                      node.dynamic{d} = B{idx} + 0.5*node.gradient{d}*dt; idx = idx +1;
                   end
                   for x=1:size(node.index_dynamic,1)
                     for y=1:size(node.index_dynamic,2)
                         node.index_dynamic{x,y} = B{idx} + 0.5*node.index_gradient{x,y}*dt;
                         %fprintf('%f by %f\n', B{idx}, node.index_gradient{x,y});
                         idx = idx + 1;
                     end
                   end
               end
               
            end
            if 0
            figure;
            hold off
            data
            for i=1:size(data,1)
            plot(t, data(i,:),'.-r');
            hold on
            end
            end
            %plot(t,0.2*exp(t),'b');
            %plot(t,230*exp(-t),'b');
            if 1 % Writing the result array disabled for now
            results = [];
            for d = 1:ND
                result.x = t;
                result.y = data(d,:);
                result.name = context.vmclass.dynamic_names{d};
                results = [ results result ];
            end
            idx = ND+1;
            for node = 1:numel(obj.deployed_nodes)
                   node = obj.deployed_nodes{node}; % TODO: Remove same variable name, bad style
                   for d=1:numel(node.dynamic)
                      result.x = t;
                      result.y = data(idx,:);
                      result.name = node.vmclass.dynamic_names{d};
                      idx = idx+1;
                      results = [ results result ];

                   end            
                   for x=1:size(node.index_dynamic,1)
                     for y=1:size(node.index_dynamic,2)
                        result.x = t;
                        result.y = data(idx,:);
                        result.name = 'TODO:indexed_dynamic_name';
                        idx = idx+1;
                        results = [ results result ];
                     end
                   end
            end
            end
        end
        
        function return_value = jit_compile_update_yearly(obj, fid)
            obj.jit_compile_update(fid);
            obj.jit_zero_gradient(fid);

            obj.jit_by_entry_id(fid, 4);
                    
            for d=1:numel(obj.deployed_nodes)
                node = obj.deployed_nodes{d};
                obj.context_stack{end+1} = node;
                obj.jit_compile(fid, node.get_entry_by_id(4));
            end
        end        
        
        function asd = jit_compile_update(obj, fid)
            obj.jit_zero_gradient(fid);
            obj.jit_by_entry_id(fid, 2);
            obj.jit_by_entry_id(fid, 3);

            for d=1:numel(obj.deployed_nodes)
                node = obj.deployed_nodes{d};
                
                % Run at context of the node
                obj.context_stack{end+1} = node;
                obj.jit_compile(fid, node.get_entry_by_id(2));
                obj.context_stack{end+1} = node;
                obj.jit_compile(fid, node.get_entry_by_id(3));
            end
            
        end

      function return_value = update(obj)
            obj.update_params();
            
            ND = numel(obj.module_instance.dynamic);
            for d = 1:ND
                 obj.module_instance.gradient{d} = 0;
            end
            
            for d=1:numel(obj.deployed_nodes)
                node = obj.deployed_nodes{d};
                % Run at context of the node
                obj.context_stack{end+1} = node;
                obj.run(node.get_entry_by_id(2));
                node.zero_gradients();
            end

            obj.call_by_entry_id(3);
            for d=1:numel(obj.deployed_nodes)
                node = obj.deployed_nodes{d};
                % Run at context of the node
                obj.context_stack{end+1} = node;
                obj.run(node.get_entry_by_id(3));
            end
        end
        
        
        function return_value = update_yearly(obj)
            obj.update_params();
            
            ND = numel(obj.module_instance.dynamic);
            for d = 1:ND
                 obj.module_instance.gradient{d} = 0;
            end
            obj.call_by_entry_id(4);
                    
            for d=1:numel(obj.deployed_nodes)
                node = obj.deployed_nodes{d};
                
                % Run at context of the node
                obj.context_stack{end+1} = node;
                obj.run(node.get_entry_by_id(2));
                
                node.zero_gradients();

                % Run at context of the node
                obj.context_stack{end+1} = node;
                obj.run(node.get_entry_by_id(4)); % .update_yearly
            end
        end
        
        
        function return_value = load(obj)
            obj.run(1);
        end

        
        function return_value = update_params(obj)
            obj.call_by_entry_id(2);
        end
        
        function result = execute(obj)
            obj.context_stack{end+1} = obj.module_instance;
            result = obj.run(1);
        end
        
        function return_value = call_by_entry_id(obj, entry_id)
            obj.context_stack{end+1} = obj.module_instance;
            return_value = obj.run(obj.module.get_entry_by_id(entry_id));
        end

        function return_value = jit_by_entry_id(obj, fid, entry_id)
            obj.context_stack{end+1} = obj.module_instance;
            return_value = obj.jit_compile(fid, obj.module.get_entry_by_id(entry_id));
        end
        
        
        function print_stack(obj)
            for i=1:numel(obj.stack)
                disp(obj.stack{i});
            end
        end
        
        function return_value = jit_compile(obj, fid, entrypoint)
            obj.ptr = entrypoint;
            tempstack = {};
            for i=1:320
                freevars{i} = sprintf('temp%d', 320-i);
            end
            show_opcode=1;
            while 1
                ip_start = obj.ptr;
                op = obj.code(obj.ptr); obj.ptr = obj.ptr + 1;
                parameter_size = Compiler.PAR_COUNTS(op+1);
                if parameter_size == 0
                    data = [];
                elseif parameter_size == 1
                    data = obj.code(obj.ptr); obj.ptr = obj.ptr + 1;
                elseif parameter_size == 2
                    data = typecast(obj.code(obj.ptr:obj.ptr+1),'uint16'); obj.ptr = obj.ptr + 2;
                elseif parameter_size == 4
                    data = typecast(obj.code(obj.ptr:obj.ptr+3),'uint32'); obj.ptr = obj.ptr + 4;
                else
                    error('Internal error.');
                end
                if show_opcode
                    fprintf(fid, '%% %04x %s %d\n', obj.ptr, Compiler.get_name_by_opcode(op), data);
                end
                context = obj.context_stack{end};
                switch op
                    case Compiler.DOUBLE_CONSTANT_COUNT
                        error('Not allowed in JIT function.');
                    case Compiler.ENTRY_COUNT
                        error('Not allowed in JIT function.');
                    case Compiler.LOAD_CONSTANT_8
                        tempstack{end+1} = freevars{end}; freevars = freevars(1:end-1);
                        fprintf(fid, "%s = %.15f;\n", tempstack{end}, obj.constants(data));
                    case Compiler.ADD_OPERATOR
                        fprintf(fid, '%s = %s + %s;\n', tempstack{end-1}, tempstack{end-1}, tempstack{end});
                        freevars{end+1} = tempstack{end};
                        tempstack = tempstack(1:end-1);
                    case Compiler.SUB_OPERATOR
                        fprintf(fid, '%s = %s - %s;\n', tempstack{end-1}, tempstack{end-1}, tempstack{end});
                        freevars{end+1} = tempstack{end};
                        tempstack = tempstack(1:end-1);
                    case Compiler.MUL_OPERATOR
                        fprintf(fid, '%s = %s * %s;\n', tempstack{end-1}, tempstack{end-1}, tempstack{end});
                        freevars{end+1} = tempstack{end};
                        tempstack = tempstack(1:end-1);
                    case Compiler.DIV_OPERATOR
                        fprintf(fid, '%s = %s / %s;\n', tempstack{end-1}, tempstack{end-1}, tempstack{end});
                        freevars{end+1} = tempstack{end};
                        tempstack = tempstack(1:end-1);
                    case Compiler.POW_OPERATOR
                        fprintf(fid, '%s = %s ^ %s;\n', tempstack{end-1}, tempstack{end-1}, tempstack{end});
                        freevars{end+1} = tempstack{end};
                        tempstack = tempstack(1:end-1);
                    case Compiler.UNARY_MINUS
                        fprintf(fid, '%s = -%s;\n', tempstack{end}, tempstack{end});
                    case Compiler.LOAD_PARAMETER
                        paramname = sprintf('%s_%s', context.classname, context.vmclass.parameter_names{data});
                        tempstack{end+1} = freevars{end}; freevars = freevars(1:end-1);
                        fprintf(fid, '%s = %s;\n', tempstack{end}, paramname);
                    case Compiler.STORE_PARAMETER
                        %fprintf('storing to parameter %d of %s\n', data, context.classname);
                        fprintf(fid, '%s_%s = %s;\n', context.classname, context.vmclass.parameter_names{data}, tempstack{end});
                        freevars{end+1} = tempstack{end}; tempstack = tempstack(1:end-1); % Pop
                    case Compiler.LOAD_DYNAMIC
                        dynname = sprintf('%s_%s', context.classname, context.vmclass.dynamic_names{data});
                        tempstack{end+1} = freevars{end}; freevars = freevars(1:end-1);
                        fprintf(fid, '%s = %s;\n', tempstack{end}, dynname);
                    case Compiler.STORE_DYNAMIC
                        error('TODO');
                        %obj.flat_store_dynamic(data, obj.stack{end});
                        fprintf('storing to dynamic %d of %s with %f\n', data, context.classname, obj.stack{end});
                        context.dynamic{data} = obj.stack{end};
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.STORE_GRADIENT
                        gradname = sprintf('d%s_%sdt', context.classname, context.vmclass.dynamic_names{data});
                        fprintf(fid, '%s = %s + %s;\n', gradname, gradname, tempstack{end});
                        freevars{end+1} = tempstack{end}; tempstack = tempstack(1:end-1); % Pop
                    case Compiler.DOUBLE_DYNAMIC_COUNT                        
                        error('TODO');
                        %obj.dynamic = cell(1,data); % Allocate dynamic variables
                        %obj.gradient = cell(1,data); % Allocate gradient storage variables
                        %for i=1:data
                        %    strlen = cast(obj.code(obj.ptr),'uint32'); obj.ptr = obj.ptr + 1;
                        %    obj.dynamic_names{i} = char(obj.code(obj.ptr:obj.ptr+strlen-1)); obj.ptr = obj.ptr + strlen;
                        %end
                        dynamic_names_remaining = data;
                    case Compiler.DOUBLE_PARAMETER_COUNT
                        error('TODO');
                        %obj.parameter = cell(1,data);
                        parameter_names_remaining = data;
                        %for i=1:data
                        %    strlen = cast(obj.code(obj.ptr),'uint32'); obj.ptr = obj.ptr + 1;
                        %    obj.parameter_names{i} = char(obj.code(obj.ptr:obj.ptr+strlen-1)); obj.ptr = obj.ptr + strlen;
                        %end
                    case Compiler.BUILD_ARRAY
                        error('TODO');
                        if numel(obj.stack{end})==1
                           array = [ obj.stack{end-data+1:end} ];
                        else
                           %array = horzcat(obj.stack{end-data+1:end})
                           array = vertcat(obj.stack{end-data+1:end});
                        end

                        obj.stack = obj.stack(1:end-data);
                        obj.stack{end+1} = array;
                    case Compiler.VECTOR_SUM
                        error('TODO');
                        summands = obj.stack{end};
                        obj.stack{end} = sum(summands);
                    case Compiler.PRINT
                        error('TODO');
                        for i=1:data
                            argument = obj.stack{end-data+i};
                            %fprintf('%f ', argument);
                            disp(argument)
                        end
                        obj.stack = obj.stack(1:end-data);
                        fprintf('\n');
                    case Compiler.HORZCAT
                        error('TODO');
                        argument = horzcat(obj.stack(end-data+1:end));
                        obj.stack = obj.stack(1:end-data);
                        obj.stack{end+1} = horzcat(argument{:});
                    case Compiler.ENCODE_STRING
                        error('TODO');
                        strlen = cast(data,'uint32');
                        s = obj.code(obj.ptr:obj.ptr+strlen-1); obj.ptr = obj.ptr + strlen;
                        %fprintf('   FOUND "%s"',s);
                        if link_indexed_parameter_names_remaining > 0
                            if ~isempty(current_class)
                                current_class.push_link_indexed_parameter_name(s);
                            else
                                error('Expected to be within node definition.');
                            end
                            link_indexed_parameter_names_remaining = link_indexed_parameter_names_remaining-1;                            
                        elseif index_dynamic_names_remaining > 0
                            if ~isempty(current_class)
                                current_class.push_index_dynamic_name(s);
                            else
                                error('Expected to be within node definition.');
                            end
                            index_dynamic_names_remaining = index_dynamic_names_remaining-1;
                        elseif index_parameter_names_remaining > 0
                            if ~isempty(current_class)
                                current_class.push_index_parameter_name(s);
                            else
                                error('Expected to be within node definition.');
                            end
                            index_parameter_names_remaining = index_parameter_names_remaining-1;
                        elseif parameter_names_remaining > 0
                            %obj.parameter_names{end+1} = s;
                            if ~isempty(current_class)
                                current_class.push_parameter_name(s);
                            else
                                obj.module.push_parameter_name(s);
                            end
                            parameter_names_remaining = parameter_names_remaining-1;
                        elseif dynamic_names_remaining > 0
                            %obj.dynamic_names{end+1} = s;
                            if ~isempty(current_class)
                                current_class.push_dynamic_name(s);
                            else
                                obj.module.push_dynamic_name(s);
                            end
                            dynamic_names_remaining = dynamic_names_remaining-1;
                        elseif class_names_remaining > 0
                            if ~isempty(current_class)
                                error('Bytecode error: Unexpected classname.');
                            end
                            current_class = VMClass(s);
                            class_names_remaining = class_names_remaining-1;
                        elseif tags_remaining > 0
                            obj.module.push_tag(s);
                        elseif node_names_remaining > 0
                            if ~isempty(current_class)
                                error('Bytecode error: Unexpected nodename.');
                            end
                            current_class = VMNode(s);
                            node_names_remaining = node_names_remaining-1;
                        else
                            error('Unexpected string opcode.');
                        end
                    case Compiler.CLASS_COUNT
                        error('TODO');
                        class_names_remaining = data;
                    case Compiler.NEW_INSTANCE
                        error('TODO');
                        %fprintf('  NEW_INSTANCE: %d', data);
                        obj.stack{end+1} = VMInstance(obj.classes{data+1});
                    case Compiler.ENTER_LAMBDA
                        error('TODO');
                        %fprintf('  ENTER_LAMBDA');
                        obj.context_stack{end+1} = obj.stack{end};
                    case Compiler.EXIT_LAMBDA
                        error('TODO');
                        %fprintf('EXIT LAMBDA');
                        obj.context_stack = obj.context_stack(1:end-1);
                    %case Compiler.CALL_ENTRY (This was more like%CALL_MEMBER');
                    %    fprintf('  CALL_ENTRY: %d', data);
                    %    obj.return_stack = [ obj.return_stack obj.ptr ]; % Push return PTR
                    %    current_context = obj.context_stack{end};
                    %    obj.ptr = current_context.get_entry_by_id(data);
                    case Compiler.CALL_ENTRY 
                        error('TODO');
                        current_context = obj.stack{end}; %% CONTEXT STACK!
                        obj.context_stack{end+1} = current_context;
                        obj.return_stack = [ obj.return_stack obj.ptr ]; % Push return PTR
                        obj.ptr = current_context.get_entry_by_id(data);
                    case Compiler.BUILTIN_FUNCTION
                        switch data
                            case Compiler.BUILTIN_RAND
                                error('TODO');
                                obj.stack{end+1}=rand();
                            case Compiler.BUILTIN_EXP
                                fprintf(fid, '%s = exp(%s);\n', tempstack{end}, tempstack{end});
                            case Compiler.BUILTIN_LN
                                fprintf(fid, '%s = log(%s);\n', tempstack{end}, tempstack{end});                                
                            case Compiler.BUILTIN_SWITCH
                                fprintf(fid, 'if %s < 0\n', tempstack{end-2});
                                fprintf(fid, '  %s = %s;\n', freevars{end}, tempstack{end-1});
                                fprintf(fid, 'else\n');
                                fprintf(fid, '  %s = %s;\n', freevars{end}, tempstack{end});
                                fprintf(fid, 'end\n');
                                tempstack = tempstack(1:end-3);
                                tempstack{end+1} = freevars{end};
                                freevars = freevars(1:end-1);
                            case Compiler.BUILTIN_WT
                                tempstack{end+1} = freevars{end};
                                freevars = freevars(1:end-1);
                                fprintf(fid, '%s = randn()/sqrt(1/steps_per_minor_epoch);\n', tempstack{end});
                            case Compiler.BUILTIN_T
                                tempstack{end+1} = freevars{end};
                                freevars = freevars(1:end-1);
                                fprintf(fid, '%s = major;\n', tempstack{end});
                            case Compiler.BUILTIN_t
                                tempstack{end+1} = freevars{end};
                                freevars = freevars(1:end-1);
                                fprintf(fid, '%s = ((minor-1)+(iter-1)/steps_per_minor_epoch)/minor_epochs_per_major_epoch;\n', tempstack{end});
                            case Compiler.BUILTIN_LOGNORMAL
                                error('TODO');
                                parameters = obj.stack(end-2:end);
                                obj.stack = obj.stack(1:end-3);
                                m = parameters{2}; % mean
                                v = parameters{3}; % variance
                                N = parameters{1}; % Number              
                                mu = log((m^2)/sqrt(v+m^2));
                                sigma = sqrt(log(v/(m^2)+1));
                                obj.stack{end+1} = lognrnd(mu, sigma, 1, N);
                            otherwise
                                error(sprintf('Unknown builtin function id 0x%02x.', data));
                        end
                    case Compiler.DUPLICATE_STACK
                        error('TODO');
                        obj.stack = [ obj.stack obj.stack(end-data+1:end) ];
                    case Compiler.CREATE_CLASS
                        error('TODO');
                        obj.classes{end+1} = current_class;
                        current_class = [];
                    case Compiler.RET
                        obj.context_stack = obj.context_stack(1:end-1);
                        if numel(obj.return_stack)>0
                            obj.ptr = obj.return_stack(end);
                            obj.return_stack = obj.return_stack(1:end-1);
                        else
                             fprintf('% RET\n');
                             break
                        end
                    case Compiler.NODEDEF_COUNT
                        error('TODO');
                        node_names_remaining = data;
                    case Compiler.INDEX_AS
                        error('TODO');
                        if isempty(current_class)
                            error('Unexpected INDEX_AS opcode');
                        end

                        if obj.code(obj.ptr) ~= Compiler.ENCODE_STRING
                            error('Expected index name.');
                        end
                        obj.ptr = obj.ptr + 1;
                        
                        
                        strlen = cast(obj.code(obj.ptr),'uint32'); obj.ptr = obj.ptr + 1;
                        index_name = obj.code(obj.ptr:obj.ptr+strlen-1); obj.ptr = obj.ptr + strlen;
                        current_class.index_as(index_name);
                    case Compiler.DOUBLE_INDEX_DYNAMIC_COUNT 
                        error('TODO');
                        index_dynamic_names_remaining = data;
                    case Compiler.TAG_COUNT
                        error('TODO');
                        tags_remaining = data;
                    case Compiler.DOUBLE_INDEX_PARAMETER_COUNT
                        error('TODO');
                        index_parameter_names_remaining = data;
                    case Compiler.CREATE_NODEDEF
                        error('TODO');
                        obj.classes{end+1} = current_class;
                        current_class = [];
                    case Compiler.DEPLOY
                        error('TODO');
                        % Create instance, store it to deployed nodes, and
                        % to context stack and to current context.
                        node_instance = VMNodeInstance(obj.classes{data+1});
                        obj.deployed_nodes{end+1} = node_instance;
                        obj.context_stack{end+1} = node_instance;
                        
                        % Call constructor
                        % Add node instance as context one more time,
                        % because constructor ret will pop it from context
                        % stack.
                        obj.context_stack{end+1} = node_instance;
                        obj.return_stack = [ obj.return_stack obj.ptr ]; 
                        obj.ptr = node_instance.get_entry_by_id(1); % Entry id 1 for constructor
                    case Compiler.NEW_INDEXED
                        error('TODO');
                        assert(obj.code(obj.ptr) == Compiler.ENCODE_STRING); obj.ptr = obj.ptr + 1;
                        strlen = cast(obj.code(obj.ptr),'uint32'); obj.ptr = obj.ptr + 1;
                        tag = obj.code(obj.ptr:obj.ptr+strlen-1); obj.ptr = obj.ptr + strlen;
                        context.new_indexed(tag);
                    case Compiler.STORE_INDEXED_PARAMETER
                        fprintf(fid, "%s = %s;\n", context.load_indexed_parameter_ref(data), tempstack{end});
                        
                        % pop
                        freevars{end+1} = tempstack{end}; tempstack = tempstack(1:end-1);
                    case Compiler.ADD_INDEXED_PARAMETER
                        error('TODO');
                        context.add_indexed_parameter(data, obj.stack{end});
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.STORE_INDEXED_DYNAMIC
                        error('TODO');
                        context.store_indexed_dynamic(data, obj.stack{end});
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.STORE_INDEXED_GRADIENT
                        varname = context.load_indexed_dynamic_ref(data);
                        fprintf(fid, "d%sdt = d%sdt + %s;\n", varname, varname, tempstack{end});
                        freevars{end+1} = tempstack{end}; 
                        tempstack = tempstack(1:end-1);
                    case Compiler.END_DEPLOY
                        error('TODO');
                        obj.context_stack = obj.context_stack(1:end-1);
                    case Compiler.INDEX_LOOP
                        %error('TODO');
                        context.index_loop(); % Reset counter
                    case Compiler.LOAD_INDEXED_PARAMETER
                        tempstack{end+1} = freevars{end}; freevars = freevars(1:end-1); % push
                        fprintf(fid, '%s = %s;\n', tempstack{end}, context.load_indexed_parameter_ref(data));
                    case Compiler.LOAD_INDEXED_DYNAMIC
                        tempstack{end+1} = freevars{end}; freevars = freevars(1:end-1);
                        fprintf(fid, "%s = %s;\n", tempstack{end}, context.load_indexed_dynamic_ref(data));
                    case Compiler.INDEX_JUMP
                        if context.next_index()
                           obj.ptr = data; 
                        end
                    case Compiler.SUM_LOOP
                        context.index_loop(); % Reset counter
                        tempstack{end+1} = freevars{end}; freevars = freevars(1:end-1);
                        fprintf(fid, "%s = 0;\n", tempstack{end}); % Push accumulated value to stack
                    case Compiler.SUM_JUMP
                        fprintf(fid, '%s = %s + %s;\n', tempstack{end-1}, tempstack{end-1}, tempstack{end});
                        freevars{end+1} = tempstack{end};
                        tempstack = tempstack(1:end-1);
                        if context.next_index()
                           obj.ptr = data; 
                        end
                    case Compiler.DOUBLE_LINK_INDEXED_PARAMETER_COUNT
                        error('TODO');
                        link_indexed_parameter_names_remaining = data;
                    case Compiler.STORE_GRADIENT_BY_IDX_1
                        varname = context.dynamic_by_idx_ref(obj, 1,data);
                        fprintf(fid, 'd%sdt = d%sdt + %s;\n', varname, varname, tempstack{end});
                        freevars{end+1} = tempstack{end}; tempstack = tempstack(1:end-1); % pop
                    case Compiler.STORE_GRADIENT_BY_IDX_2
                        varname = context.dynamic_by_idx_ref(obj, 2,data);
                        fprintf(fid, 'd%sdt = d%sdt + %s;\n', varname, varname, tempstack{end});
                        freevars{end+1} = tempstack{end}; tempstack = tempstack(1:end-1); % pop
                    case Compiler.STORE_GRADIENT_BY_IDX_3
                        varname = context.dynamic_by_idx_ref(obj, 3,data);
                        fprintf(fid, 'd%sdt = d%sdt + %s;\n', varname, varname, tempstack{end});
                        freevars{end+1} = tempstack{end}; tempstack = tempstack(1:end-1); % pop
                    case Compiler.LOAD_DYNAMIC_BY_IDX_1
                        tempstack{end+1} = freevars{end}; freevars = freevars(1:end-1); % push
                        fprintf(fid, '%s = %s;\n', tempstack{end}, context.dynamic_by_idx_ref(obj, 1,data));
                    case Compiler.LOAD_DYNAMIC_BY_IDX_2
                        tempstack{end+1} = freevars{end}; freevars = freevars(1:end-1); % push
                        fprintf(fid, '%s = %s;\n', tempstack{end}, context.dynamic_by_idx_ref(obj, 2,data));
                    case Compiler.LOAD_DYNAMIC_BY_IDX_3
                        tempstack{end+1} = freevars{end}; freevars = freevars(1:end-1); % push
                        fprintf(fid, '%s = %s;\n', tempstack{end}, context.dynamic_by_idx_ref(obj, 3,data));
                    case Compiler.LOAD_PARAMETER_BY_IDX_1
                        tempstack{end+1} = freevars{end}; freevars = freevars(1:end-1); % push
                        fprintf(fid, '%s = %s;\n', tempstack{end}, context.parameter_by_idx_ref(obj, 1,data));
                    case Compiler.LOAD_PARAMETER_BY_IDX_2
                        tempstack{end+1} = freevars{end}; freevars = freevars(1:end-1); % push
                        fprintf(fid, '%s = %s;\n', tempstack{end}, context.parameter_by_idx_ref(obj, 2,data));
                    case Compiler.LOAD_PARAMETER_BY_IDX_3
                        tempstack{end+1} = freevars{end}; freevars = freevars(1:end-1); % push
                        fprintf(fid, '%s = %s;\n', tempstack{end}, context.parameter_by_idx_ref(obj, 3,data));
                    case Compiler.ADD_PARAMETER_BY_IDX_1
                        varname = context.parameter_by_idx_ref(obj, 1,data);
                        fprintf(fid, '%s = %s + %s;\n', varname, varname, tempstack{end});
                        % pop
                        freevars{end+1} = tempstack{end}; 
                        tempstack = tempstack(1:end-1);
                    case Compiler.ADD_PARAMETER_BY_IDX_2
                        varname = context.parameter_by_idx_ref(obj, 2,data);
                        fprintf(fid, '%s = %s + %s;\n', varname, varname, tempstack{end});
                        % pop
                        freevars{end+1} = tempstack{end}; 
                        tempstack = tempstack(1:end-1);
                    case Compiler.ADD_PARAMETER_BY_IDX_3
                        varname = context.parameter_by_idx_ref(obj, 1,data);
                        fprintf(fid, '%s = %s + %s;\n', varname, varname, tempstack{end});
                        % pop
                        freevars{end+1} = tempstack{end}; 
                        tempstack = tempstack(1:end-1);
                    case Compiler.STORE_PARAMETER_BY_IDX_1
                        fprintf(fid, '%s = %s;\n', context.parameter_by_idx_ref(obj, 1,data), tempstack{end});
                        % pop
                        freevars{end+1} = tempstack{end}; 
                        tempstack = tempstack(1:end-1);
                    case Compiler.STORE_PARAMETER_BY_IDX_2
                        fprintf(fid, '%s = %s;\n', context.parameter_by_idx_ref(obj, 2,data), tempstack{end});
                        % pop
                        freevars{end+1} = tempstack{end}; 
                        tempstack = tempstack(1:end-1);
                    case Compiler.STORE_PARAMETER_BY_IDX_3
                        error('TODO');
                        context.store_parameter_by_idx(obj, 3,data, obj.stack{end});
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.LINK_JUMP
                        if context.next_link()
                           obj.ptr = data; 
                        end
                    case Compiler.STORE_LINK_INDEXED_PARAMETER
                        fprintf(fid, '%s = %s;\n', context.link_indexed_parameter_ref(data), tempstack{end});
                        freevars{end+1} = tempstack{end}; tempstack = tempstack(1:end-1); 
                    case Compiler.LOAD_LINK_INDEXED_PARAMETER
                        tempstack{end+1} = freevars{end}; freevars = freevars(1:end-1);
                        fprintf(fid, '%s = %s;\n', tempstack{end}, context.link_indexed_parameter_ref(data));
                    case Compiler.LINK_LOOP
                        context.link_loop(obj);
                    case Compiler.DISPLAY
                        error('TODO');
                        disp(obj.stack(end))
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.STORE_LINK_INDEXED_DYNAMIC
                        error('TODO');
                        context.store_link_indexed_dynamic(data, obj.stack{end});
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.STORE_LINK_INDEXED_GRADIENT
                        fprintf(fid, '%s = %s;\n', context.link_indexed_gradient_ref(data), tempstack{end});
                        freevars{end+1} = tempstack{end}; tempstack = tempstack(1:end-1); 
                    case Compiler.NEW_LINK_INDEXED
                        error('TODO');
                        link = obj.code(obj.ptr:obj.ptr+5); obj.ptr = obj.ptr + 6; % 6 byte parameter string
                        context.link_index(link);
                        otherwise
                            error('Unkown opcode: 0x%x at %04x', op, obj.ptr);
                end
            end
            return_value = obj.stack;
            
        end
        
        function return_value = run(obj, entrypoint)
            obj.ptr = entrypoint;
            class_names_remaining = 0;
            class_definitions_remaining = 0;
            node_definitions_remaining = 0;
            parameter_names_remaining = 0;
            index_parameter_names_remaining = 0;
            index_dynamic_names_remaining = 0;
            dynamic_names_remaining = 0;
            link_indexed_parameter_names_remaining = 0;
            tags_remaining = 0;
            current_class = [];
            stepping = 0;
            show_stack = 0;
            show_opcode = 0;
            try
            while 1
                ip_start = obj.ptr;
                for i=1:numel(obj.stack)
                   if isnumeric(obj.stack{i}) && ~isreal(obj.stack{i})
                       error('Stack does not have a real number');
                   end
                end
                if show_stack
                    fprintf('STACK:\n');
                    if numel(obj.stack)==0
                       fprintf('empty');
                    end
                    for i=1:numel(obj.stack)
                       if isa(obj.stack{i}, 'VMInstance')
                           obj.stack{i}.display();
                       elseif isa(obj.stack{end}, 'VMClass')
                          obj.stack{i}.display();
                       else
                           obj.stack{i}
                           fprintf('%f', obj.stack{i});
                       end
                    end
                    fprintf('\n');
                end
                if stepping
                    
                    pause
                end
                if obj.ptr > numel(obj.code)
                    break
                end
                op = obj.code(obj.ptr); obj.ptr = obj.ptr + 1;
                parameter_size = Compiler.PAR_COUNTS(op+1);
                if parameter_size == 0
                    data = [];
                elseif parameter_size == 1
                    data = obj.code(obj.ptr); obj.ptr = obj.ptr + 1;
                elseif parameter_size == 2
                    data = typecast(obj.code(obj.ptr:obj.ptr+1),'uint16'); obj.ptr = obj.ptr + 2;
                elseif parameter_size == 4
                    data = typecast(obj.code(obj.ptr:obj.ptr+3),'uint32'); obj.ptr = obj.ptr + 4;
                else
                    error('Internal error.');
                end
                if show_opcode
                fprintf('%04x %s %d\n', obj.ptr, Compiler.get_name_by_opcode(op), data);
                end
                %%obj.print_stack();
                context = obj.context_stack{end};
                %obj.show_namespace(context.dynamic, context.parameter);
                switch op
                    case Compiler.DOUBLE_CONSTANT_COUNT
                        count = data;
                        obj.constants = zeros(1, count);
                        for i=1:count
                            obj.constants(i) = typecast(obj.code(obj.ptr:obj.ptr+7),'double'); obj.ptr = obj.ptr + 8;
                        end
                    case Compiler.ENTRY_COUNT
                        % Read each entry from stream
                        %obj.entry_points = zeros(1,data, 'uint32');
                        for i=1:data
                            entry_point = typecast(obj.code(obj.ptr:obj.ptr+3),'uint32'); obj.ptr = obj.ptr + 4;
                            assert(obj.code(obj.ptr) == Compiler.ENCODE_STRING); obj.ptr = obj.ptr + 1;
                            strlen = cast(obj.code(obj.ptr),'uint32'); obj.ptr = obj.ptr + 1;
                            entry_name = obj.code(obj.ptr:obj.ptr+strlen-1); obj.ptr = obj.ptr + strlen;
                            if ~isempty(current_class)
                                current_class.push_entry(entry_point, entry_name);
                            else
                                obj.module.push_entry(entry_point, entry_name);
                            end
                        end
                        %disp(['Entry count:' num2str(data)]);
                    case Compiler.LOAD_CONSTANT_8
                        obj.stack{end+1} = obj.constants(data);
                    case Compiler.ADD_OPERATOR
                        obj.stack{end-1} = obj.stack{end-1}+obj.stack{end};
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.SUB_OPERATOR
                        obj.stack{end-1} = obj.stack{end-1}-obj.stack{end};
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.MUL_OPERATOR
                        if numel(obj.stack{end-1}) == 1 || numel(obj.stack{end}) == 1
                            obj.stack{end-1} = obj.stack{end}*obj.stack{end-1};
                        elseif size(obj.stack{end-1}) == size(obj.stack{end})
                            obj.stack{end-1} = obj.stack{end-1}.*obj.stack{end};
                        else
                            obj.stack{end-1} = obj.stack{end}*obj.stack{end-1}';
                        end
                        obj.stack = obj.stack(1:end-1);
                        
                    case Compiler.DIV_OPERATOR
                        obj.stack{end-1} = obj.stack{end-1}./obj.stack{end};
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.POW_OPERATOR
                        a=obj.stack{end-1};
                        b = obj.stack{end};
                        obj.stack{end-1} = a.^b;
                        if ~isreal(obj.stack{end-1})
                            error(sprintf('Complex value obtained from %f^%f', a,b));
                        end
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.UNARY_MINUS
                        obj.stack{end} = -obj.stack{end};
                    case Compiler.LOAD_PARAMETER
                        if numel(context.parameter) < data
                            error(sprintf('Parameter %s not initialized.', context.vmclass.parameter_names{data}));
                        end
                        obj.stack{end+1} = context.parameter{data};
                    case Compiler.STORE_PARAMETER
                        %fprintf('storing to parameter %d of %s\n', data, context.classname);
                        context.parameter{data} = obj.stack{end};
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.LOAD_DYNAMIC
                        %fprintf('Loading dynamic %d %f\n', data, obj.dynamic(data));
                        obj.stack{end+1} = context.dynamic{data};
                    case Compiler.STORE_DYNAMIC
                        %obj.flat_store_dynamic(data, obj.stack{end});
                        %fprintf('storing to dynamic %d of %s with %f\n', data, context.classname, obj.stack{end});
                        context.dynamic{data} = obj.stack{end};
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.STORE_GRADIENT
                        if numel(context.gradient) >= data
                            addto = context.gradient{data};
                        else
                            addto = 0;
                        end
                        context.gradient{data} = addto + obj.stack{end};
                        %fprintf('storing to gradient %f\n', obj.stack(end));
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.DOUBLE_DYNAMIC_COUNT                        
                        %obj.dynamic = cell(1,data); % Allocate dynamic variables
                        %obj.gradient = cell(1,data); % Allocate gradient storage variables
                        %for i=1:data
                        %    strlen = cast(obj.code(obj.ptr),'uint32'); obj.ptr = obj.ptr + 1;
                        %    obj.dynamic_names{i} = char(obj.code(obj.ptr:obj.ptr+strlen-1)); obj.ptr = obj.ptr + strlen;
                        %end
                        dynamic_names_remaining = data;
                    case Compiler.DOUBLE_PARAMETER_COUNT
                        %obj.parameter = cell(1,data);
                        parameter_names_remaining = data;
                        %for i=1:data
                        %    strlen = cast(obj.code(obj.ptr),'uint32'); obj.ptr = obj.ptr + 1;
                        %    obj.parameter_names{i} = char(obj.code(obj.ptr:obj.ptr+strlen-1)); obj.ptr = obj.ptr + strlen;
                        %end
                    case Compiler.BUILD_ARRAY
                        if numel(obj.stack{end})==1
                           array = [ obj.stack{end-data+1:end} ];
                        else
                           %array = horzcat(obj.stack{end-data+1:end})
                           array = vertcat(obj.stack{end-data+1:end});
                        end

                        obj.stack = obj.stack(1:end-data);
                        obj.stack{end+1} = array;
                    case Compiler.VECTOR_SUM
                        summands = obj.stack{end};
                        obj.stack{end} = sum(summands);
                    case Compiler.PRINT
                        for i=1:data
                            argument = obj.stack{end-data+i};
                            %fprintf('%f ', argument);
                            disp(argument)
                        end
                        obj.stack = obj.stack(1:end-data);
                        fprintf('\n');
                    case Compiler.HORZCAT
                        argument = horzcat(obj.stack(end-data+1:end));
                        obj.stack = obj.stack(1:end-data);
                        obj.stack{end+1} = horzcat(argument{:});
                    case Compiler.ENCODE_STRING
                        strlen = cast(data,'uint32');
                        s = obj.code(obj.ptr:obj.ptr+strlen-1); obj.ptr = obj.ptr + strlen;
                        %fprintf('   FOUND "%s"',s);
                        if link_indexed_parameter_names_remaining > 0
                            if ~isempty(current_class)
                                current_class.push_link_indexed_parameter_name(s);
                            else
                                error('Expected to be within node definition.');
                            end
                            link_indexed_parameter_names_remaining = link_indexed_parameter_names_remaining-1;                            
                        elseif index_dynamic_names_remaining > 0
                            if ~isempty(current_class)
                                current_class.push_index_dynamic_name(s);
                            else
                                error('Expected to be within node definition.');
                            end
                            index_dynamic_names_remaining = index_dynamic_names_remaining-1;
                        elseif index_parameter_names_remaining > 0
                            if ~isempty(current_class)
                                current_class.push_index_parameter_name(s);
                            else
                                error('Expected to be within node definition.');
                            end
                            index_parameter_names_remaining = index_parameter_names_remaining-1;
                        elseif parameter_names_remaining > 0
                            %obj.parameter_names{end+1} = s;
                            if ~isempty(current_class)
                                current_class.push_parameter_name(s);
                            else
                                obj.module.push_parameter_name(s);
                            end
                            parameter_names_remaining = parameter_names_remaining-1;
                        elseif dynamic_names_remaining > 0
                            %obj.dynamic_names{end+1} = s;
                            if ~isempty(current_class)
                                current_class.push_dynamic_name(s);
                            else
                                obj.module.push_dynamic_name(s);
                            end
                            dynamic_names_remaining = dynamic_names_remaining-1;
                        elseif class_names_remaining > 0
                            if ~isempty(current_class)
                                error('Bytecode error: Unexpected classname.');
                            end
                            current_class = VMClass(s);
                            class_names_remaining = class_names_remaining-1;
                        elseif tags_remaining > 0
                            obj.module.push_tag(s);
                        elseif node_names_remaining > 0
                            if ~isempty(current_class)
                                error('Bytecode error: Unexpected nodename.');
                            end
                            current_class = VMNode(s);
                            node_names_remaining = node_names_remaining-1;
                        else
                            error('Unexpected string opcode.');
                        end
                    case Compiler.CLASS_COUNT
                        class_names_remaining = data;
                    case Compiler.NEW_INSTANCE
                        %fprintf('  NEW_INSTANCE: %d', data);
                        obj.stack{end+1} = VMInstance(obj.classes{data+1});
                    case Compiler.ENTER_LAMBDA
                        %fprintf('  ENTER_LAMBDA');
                        obj.context_stack{end+1} = obj.stack{end};
                    case Compiler.EXIT_LAMBDA
                        %fprintf('EXIT LAMBDA');
                        obj.context_stack = obj.context_stack(1:end-1);
                    %case Compiler.CALL_ENTRY (This was more like%CALL_MEMBER');
                    %    fprintf('  CALL_ENTRY: %d', data);
                    %    obj.return_stack = [ obj.return_stack obj.ptr ]; % Push return PTR
                    %    current_context = obj.context_stack{end};
                    %    obj.ptr = current_context.get_entry_by_id(data);
                    case Compiler.CALL_ENTRY 
                        current_context = obj.stack{end}; %% CONTEXT STACK!
                        obj.context_stack{end+1} = current_context;
                        obj.return_stack = [ obj.return_stack obj.ptr ]; % Push return PTR
                        obj.ptr = current_context.get_entry_by_id(data);
                    case Compiler.BUILTIN_FUNCTION
                        switch data
                            case Compiler.BUILTIN_RAND
                                obj.stack{end+1}=rand();
                            case Compiler.BUILTIN_EXP
                                %fprintf('EXP %.12f %.12f \n', obj.stack{end}, exp(obj.stack{end}));
                                %pause
                                obj.stack{end}=exp(obj.stack{end});
                            case Compiler.BUILTIN_LN
                                %fprintf('EXP %.12f %.12f \n', obj.stack{end}, exp(obj.stack{end}));
                                %pause
                                obj.stack{end}=log(obj.stack{end});
                            case Compiler.BUILTIN_SWITCH
                                parameters = obj.stack(end-2:end);
                                obj.stack = obj.stack(1:end-3);
                                if parameters{1}<0
                                    res = parameters{2};
                                else
                                    res = parameters{3};
                                end
                                obj.stack{end+1} = res;
                            case Compiler.BUILTIN_T
                                obj.stack{end+1} = obj.year;                                
                            case Compiler.BUILTIN_LOGNORMAL
                                parameters = obj.stack(end-2:end);
                                obj.stack = obj.stack(1:end-3);
                                m = parameters{2}; % mean
                                v = parameters{3}; % variance
                                N = parameters{1}; % Number              
                                mu = log((m^2)/sqrt(v+m^2));
                                sigma = sqrt(log(v/(m^2)+1));
                                obj.stack{end+1} = lognrnd(mu, sigma, 1, N);
                            otherwise
                                error(sprintf('Unknown builtin function id 0x%02x.', data));
                        end
                    case Compiler.DUPLICATE_STACK
                        obj.stack = [ obj.stack obj.stack(end-data+1:end) ];
                    case Compiler.CREATE_CLASS
                        obj.classes{end+1} = current_class;
                        current_class = [];
                    case Compiler.RET
                        obj.context_stack = obj.context_stack(1:end-1);
                        if numel(obj.return_stack)>0
                            obj.ptr = obj.return_stack(end);
                            obj.return_stack = obj.return_stack(1:end-1);
                        else
                             %fprintf('RET CALLED. EXITING\n');
                             break
                        end
                    case Compiler.NODEDEF_COUNT
                        node_names_remaining = data;
                    case Compiler.INDEX_AS
                        if isempty(current_class)
                            error('Unexpected INDEX_AS opcode');
                        end

                        if obj.code(obj.ptr) ~= Compiler.ENCODE_STRING
                            error('Expected index name.');
                        end
                        obj.ptr = obj.ptr + 1;
                        
                        
                        strlen = cast(obj.code(obj.ptr),'uint32'); obj.ptr = obj.ptr + 1;
                        index_name = obj.code(obj.ptr:obj.ptr+strlen-1); obj.ptr = obj.ptr + strlen;
                        current_class.index_as(index_name);
                    case Compiler.DOUBLE_INDEX_DYNAMIC_COUNT 
                        index_dynamic_names_remaining = data;
                    case Compiler.TAG_COUNT
                        tags_remaining = data;
                    case Compiler.DOUBLE_INDEX_PARAMETER_COUNT
                        index_parameter_names_remaining = data;
                    case Compiler.CREATE_NODEDEF
                        obj.classes{end+1} = current_class;
                        current_class = [];
                    case Compiler.DEPLOY
                        % Create instance, store it to deployed nodes, and
                        % to context stack and to current context.
                        node_instance = VMNodeInstance(obj.classes{data+1});
                        obj.deployed_nodes{end+1} = node_instance;
                        obj.context_stack{end+1} = node_instance;
                        
                        % Call constructor
                        % Add node instance as context one more time,
                        % because constructor ret will pop it from context
                        % stack.
                        obj.context_stack{end+1} = node_instance;
                        obj.return_stack = [ obj.return_stack obj.ptr ]; 
                        obj.ptr = node_instance.get_entry_by_id(1); % Entry id 1 for constructor
                    case Compiler.NEW_INDEXED
                        assert(obj.code(obj.ptr) == Compiler.ENCODE_STRING); obj.ptr = obj.ptr + 1;
                        strlen = cast(obj.code(obj.ptr),'uint32'); obj.ptr = obj.ptr + 1;
                        tag = obj.code(obj.ptr:obj.ptr+strlen-1); obj.ptr = obj.ptr + strlen;
                        context.new_indexed(tag);
                    case Compiler.STORE_INDEXED_PARAMETER
                        context.store_indexed_parameter(data, obj.stack{end});
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.ADD_INDEXED_PARAMETER
                        context.add_indexed_parameter(data, obj.stack{end});
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.STORE_INDEXED_DYNAMIC
                        context.store_indexed_dynamic(data, obj.stack{end});
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.STORE_INDEXED_GRADIENT
                        %fprintf('Storing gradient %f\n', obj.stack{end});
                        context.store_indexed_gradient(data, obj.stack{end});
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.END_DEPLOY
                        obj.context_stack = obj.context_stack(1:end-1);
                    case Compiler.INDEX_LOOP
                        context.index_loop(); % Reset counter
                    case Compiler.LOAD_INDEXED_PARAMETER
                        obj.stack{end+1} = context.load_indexed_parameter(data);
                    case Compiler.LOAD_INDEXED_DYNAMIC
                        obj.stack{end+1} = context.load_indexed_dynamic(data);
                    case Compiler.INDEX_JUMP
                        if context.next_index()
                           obj.ptr = data; 
                        end
                    case Compiler.SUM_LOOP
                        context.index_loop(); % Reset counter
                        obj.stack{end+1} = 0; % Push ACC to stack
                    case Compiler.SUM_JUMP
                        % Add value to acc
                        obj.stack{end-1} = obj.stack{end-1}+obj.stack{end};
                        obj.stack = obj.stack(1:end-1);
                        if context.next_index()
                           obj.ptr = data; 
                        end
                    case Compiler.DOUBLE_LINK_INDEXED_PARAMETER_COUNT
                        link_indexed_parameter_names_remaining = data;
                    case Compiler.STORE_GRADIENT_BY_IDX_1
                        context.store_gradient_by_idx(1,data,obj.stack{end});
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.STORE_GRADIENT_BY_IDX_2
                        context.store_gradient_by_idx(2,data,obj.stack{end});
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.STORE_GRADIENT_BY_IDX_3
                        context.store_gradient_by_idx(3,data, obj.stack{end});
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.LOAD_DYNAMIC_BY_IDX_1
                        obj.stack{end+1} = context.load_dynamic_by_idx(1,data);
                    case Compiler.LOAD_DYNAMIC_BY_IDX_2
                        obj.stack{end+1} = context.load_dynamic_by_idx(2,data);
                    case Compiler.LOAD_DYNAMIC_BY_IDX_3
                        obj.stack{end+1} = context.load_dynamic_by_idx(3,data);
                    case Compiler.LOAD_PARAMETER_BY_IDX_1
                        obj.stack{end+1} = context.load_parameter_by_idx(1,data);
                    case Compiler.LOAD_PARAMETER_BY_IDX_2
                        obj.stack{end+1} = context.load_parameter_by_idx(2,data);
                    case Compiler.LOAD_PARAMETER_BY_IDX_3
                        obj.stack{end+1} = context.load_parameter_by_idx(3,data);
                    case Compiler.ADD_PARAMETER_BY_IDX_1
                        context.add_parameter_by_idx(1,data, obj.stack{end});
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.ADD_PARAMETER_BY_IDX_2
                        context.add_parameter_by_idx(2,data, obj.stack{end});
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.ADD_PARAMETER_BY_IDX_3
                        context.add_parameter_by_idx(3,data, obj.stack{end});
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.STORE_PARAMETER_BY_IDX_1
                        context.store_parameter_by_idx(obj, 1,data, obj.stack{end});
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.STORE_PARAMETER_BY_IDX_2
                        context.store_parameter_by_idx(obj, 2,data, obj.stack{end});
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.STORE_PARAMETER_BY_IDX_3
                        context.store_parameter_by_idx(obj, 3,data, obj.stack{end});
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.LINK_JUMP
                        if context.next_link()
                           obj.ptr = data; 
                        end
                    case Compiler.STORE_LINK_INDEXED_PARAMETER
                        context.store_link_indexed_parameter(data, obj.stack{end});
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.LOAD_LINK_INDEXED_PARAMETER
                        obj.stack{end+1} = context.load_link_indexed_parameter(data);
                    case Compiler.LINK_LOOP
                        context.link_loop(obj);
                    case Compiler.DISPLAY
                        disp(obj.stack(end))
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.STORE_LINK_INDEXED_DYNAMIC
                        context.store_link_indexed_dynamic(data, obj.stack{end});
                        obj.stack = obj.stack(1:end-1);
                    case Compiler.NEW_LINK_INDEXED
                        link = obj.code(obj.ptr:obj.ptr+5); obj.ptr = obj.ptr + 6; % 6 byte parameter string
                        context.link_index(link);
                        otherwise
                            error('Unkown opcode: 0x%x at %04x', op, obj.ptr);
                end
            end
            catch e
                new_error = struct(e);
                new_error.message = sprintf('Exception at address %04x: %s', ip_start, e.message);
                Compiler.disassembler(obj.code, [], ip_start, new_error.message);
                rethrow(new_error);
            end
            
            return_value = obj.stack;
        end
    end
end
