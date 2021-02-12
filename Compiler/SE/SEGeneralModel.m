classdef SEGeneralModel < handle & matlab.mixin.CustomDisplay
    properties (Constant)
        DYNAMIC_TABLE = 1;
        PARAMETER_TABLE = 2;
        INDEXED_DYNAMIC_TABLE = 3;
        INDEXED_PARAMETER_TABLE = 4;
        LINK_INDEXED_DYNAMIC_TABLE = 5;
        LINK_INDEXED_PARAMETER_TABLE = 6;
    end
    properties
        statements
        ptr
        end_ptr
        
        symboltable
        gradients
        dynamics
        parameters
        
        namespace
    end
   methods (Access = protected)
      function displayScalarObject(obj)
          for i=1:numel(obj.statements)
              disp(obj.statements{i}.repr());
          end
          %obj.display_symbols();
          %obj.display_gradients();
      end
      
      function display_symbols(obj)
          k = keys(obj.symbols);
          vals = values(obj.symbols);
          tbl = {};
          for i=1:numel(k)
             tbl{i,1} = k{i};
             tbl{i,2} = vals{i}.repr();
          end
          disp(cell2table(tbl));%,'VariableNames',{'Symbol','Expression'}));
      end
      
      function display_gradients(obj)
          k = keys(obj.gradients);
          vals = values(obj.gradients);
          tbl = {};
          for i=1:numel(k)
             tbl{i,1} = [ 'd' k{i} '/dt' ];
             tbl{i,2} = vals{i}.repr();
          end
          disp(cell2table(tbl,'VariableNames',{'Derivative','Expression'}));
      end
   
    end    
    
    methods
        function obj = SEGeneralModel()
            obj.statements = {};
            obj.ptr = 1;
            obj.end_ptr = 1;
            obj.namespace = Namespace();
            obj.symboltable = SymbolTable();
            obj.parameters = containers.Map;
            obj.dynamics = containers.Map;
            obj.gradients = containers.Map;
        end
        
        function count = get_dynamic_count(obj)
            count = obj.symboltable.get_size(SEGeneralModel.DYNAMIC_TABLE);
        end
        
        function count = get_parameter_count(obj)
            count = obj.symboltable.get_size(SEGeneralModel.PARAMETER_TABLE);
        end
        
        function name = get_parameter_name_by_id(obj, id)
            name = obj.symboltable.get_name_by_id(SEGeneralModel.PARAMETER_TABLE, id);
        end
        
        function name = get_dynamic_name_by_id(obj, id)
            name = obj.symboltable.get_name_by_id(SEGeneralModel.DYNAMIC_TABLE, id);
        end
        
        function result = lookup(obj, symbol)
            if obj.parameters.isKey(symbol)
                result = obj.parameters(symbol)
                return
            end
            xxx
        end

        function add_dynamic(obj, lhs, rhs)
            obj.symboltable.push(lhs, SEGeneralModel.DYNAMIC_TABLE, 1); % By default, for now, size is always 1
            obj.parameters(lhs) = rhs;
        end
        
        function add_gradient(obj, lhs, rhs)
            obj.gradients(lhs) = rhs;
        end

        function add_intermediate(obj, lhs, rhs)
            obj.symboltable.push(lhs, SEGeneralModel.PARAMETER_TABLE, 1); % By default, for now, size is always 1
            obj.parameters(lhs) = rhs;
        end
        
        function add_parameter(obj, lhs, rhs)
            obj.symboltable.push(lhs, SEGeneralModel.PARAMETER_TABLE, 1); % By default, for now, size is always 1
            obj.parameters(lhs) = rhs;
            %if isa(lhs, 'SEGradientReference')
            %    obj.gradients(lhs.symbol) = rhs;
            %elseif isa(lhs, 'SEReference')
            %    obj.symbols(lhs.symbol) = rhs;
            %else
            %    error('Internal error.');
            %end
            %obj.symbols(lhs
        end
        
        function statement = next(obj)
            statement = obj.statements(obj.ptr);
            obj.ptr = obj.ptr + 1;
        end
        
        function value = is_eof(obj)
            value = (obj.ptr >= obj.end_ptr);
        end
        
        function add(obj, statement)
            statement.compile(obj);
            obj.statements{end+1} = statement;
            obj.end_ptr = numel(obj.statements)+1;
        end
        
        function evaluate_parameters(obj)
            k = keys(obj.parameters);
            vals = values(obj.parameters);
            for i=1:numel(k)
                obj.namespace.(k{i}) = vals{i}.evaluate(obj.namespace);
            end
        end

        function evaluate_dynamics(obj)
            k = keys(obj.dynamics);
            vals = values(obj.dynamics);
            for i=1:numel(k)
                obj.namespace.(k{i}) = vals{i}.evaluate(obj.namespace);
            end
        end
        
        function evaluate_gradients(obj, dt)
            k = keys(obj.gradients);
            vals = values(obj.gradients);
            for i=1:numel(k)
                obj.namespace.(k{i}) = obj.namespace.(k{i}) + vals{i}.evaluate(obj.namespace) * dt;
            end
        end
        
        function show_namespace(obj, ns)
            obj.symboltable.show_namespace(ns);
        end
        
        function byte_compile_init(obj, compiler)
            for i=1:numel(obj.statements)
               statement = obj.statements{i};
               statement.byte_compile_init(compiler);
            end
        end
        
        function byte_compile_update(obj, compiler)
            for i=1:numel(obj.statements)
               statement = obj.statements{i};
               statement.byte_compile_update(compiler);
            end
        end

        function byte_compile_gradient(obj, compiler)
            for i=1:numel(obj.statements)
               statement = obj.statements{i};
               statement.byte_compile_gradient(compiler);
            end
        end

        function run(obj)
            % Initialization
            obj.evaluate_parameters();
            obj.evaluate_dynamics();
            obj.namespace
            % Loop over parameters and evaluate them
            % Loop over dynamics and evaluate them
            
            % In loop
            % Loop over parameters and evaluate them
            % Loop over gradients and evaluate them
            % Update dynamics with gradients
            
            % Simplest possible slow running of stuff
            dt = 0.01;
            B = zeros(2,1000);
            for i = 1:1000
                obj.evaluate_gradients(dt);
                B(1,i) = obj.namespace.B1;
                B(2,i) = obj.namespace.B2;
            end
            plot(B');
            %while (~obj.is_eof())
            %    statement = obj.next();
            %    statement.execute(obj);
            %end
        end
    end

end
