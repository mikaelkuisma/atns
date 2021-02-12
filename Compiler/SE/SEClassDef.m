classdef SEClassDef < SEExpression & Context
    properties (Constant) 
        DYNAMIC_TABLE = 1;
        PARAMETER_TABLE = 2;
    end
    properties
        class_id 
        
        my_module

        name

        statements
        ptr
        end_ptr
        
        entry_backfill_ids
        entry_names
        entry_infos

        symboltable
        gradients
        dynamics
        parameters
        
        namespace
    end
   methods (Access = protected)
      %function displayScalarObject(obj)
      %    for i=1:numel(obj.statements)
      %        disp(obj.statements{i}.repr());
      %    end
      %    %obj.display_symbols();
      %    %obj.display_gradients();
      %end
      
      %function display_symbols(obj)
      %    k = keys(obj.symbols);
      %    vals = values(obj.symbols);
      %    tbl = {};
      %    for i=1:numel(k)
      %       tbl{i,1} = k{i};
      %       tbl{i,2} = vals{i}.repr();
      %    end
      %    disp(cell2table(tbl));%,'VariableNames',{'Symbol','Expression'}));
      %end
      
      %function display_gradients(obj)
      %    k = keys(obj.gradients);
      %    vals = values(obj.gradients);
      %    tbl = {};
      %    for i=1:numel(k)
      %       tbl{i,1} = [ 'd' k{i} '/dt' ];
      %       tbl{i,2} = vals{i}.repr();
      %    end
      %    disp(cell2table(tbl,'VariableNames',{'Derivative','Expression'}));
      %end
   
    end    
    
    methods
        function obj = SEClassDef(name, statements)
            if ~isa(statements, 'SEExpressionList')
               statements = SEExpressionList([statements]);
            end
            obj.name = name;
            obj.statements = statements;

            obj.ptr = 1;
            obj.end_ptr = 1;
            obj.namespace = Namespace();
            obj.symboltable = SymbolTable();
            obj.parameters = containers.Map;
            obj.dynamics = containers.Map;
            obj.gradients = containers.Map;
        end
        
        function str = repr(obj)
            str = [ 'class ' obj.name ' { ' newline obj.statements.repr() ' };'];
        end

        function add_entry(obj, name)
            obj.entry_names{end+1} = name;
        end
        
        function optimize(obj, super_context, compiler)
            obj.statements.evaluate_if_possible(struct());
        end

        function resolve_context(obj, super_context, compiler)
            resolve_context@Context(obj, super_context, compiler);
            obj.my_module = super_context;
            obj.class_id = super_context.add_class(obj);
            
            
            obj.statements.resolve_context(obj, compiler); % Class is now new context for its statements
        end

        function index = add_constant(obj, constant)
           % Constants are taken care at module level
           index = obj.my_module.add_constant(constant);
        end

        function new_entry(obj, entry_name)
           %obj.entry_infos{end+1} = entry_info;
           obj.entry_names{end+1} = entry_name;
        end

        function result = evaluate(this, namespace)
            xxx
        end

        function count = get_dynamic_count(obj)
            count = obj.symboltable.get_size(SEGeneralModel.DYNAMIC_TABLE);
        end
        
        function count = get_indexed_dynamic_count(obj)
            count = obj.symboltable.get_size(SEGeneralModel.INDEXED_DYNAMIC_TABLE);
        end
        
        function count = get_indexed_parameter_count(obj)
            count = obj.symboltable.get_size(SEGeneralModel.INDEXED_PARAMETER_TABLE);
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
        
        function name = get_indexed_dynamic_name_by_id(obj, id)
            name = obj.symboltable.get_name_by_id(SEGeneralModel.INDEXED_DYNAMIC_TABLE, id);
        end
        
        function name = get_indexed_parameter_name_by_id(obj, id)
            name = obj.symboltable.get_name_by_id(SEGeneralModel.INDEXED_PARAMETER_TABLE, id);
        end
        
        %function result = lookup(obj, symbol)
        %    if obj.parameters.isKey(symbol)
        %        result = obj.parameters(symbol)
        %        return
        %   end
        %    xxx
        %end

        function add_dynamic(obj, lhs)
            if ~obj.symboltable.has_symbol(lhs.symbol)
                obj.symboltable.push(lhs.symbol, SEGeneralModel.DYNAMIC_TABLE, 1); % By default, for now, size is always 1
            else
                lhs.error_me(sprintf('Symbol already defined: %s.', lhs.symbol));
            end
            %TODO: Make sure the previous symbol is also dynamic. Warn if
            %symbols are defined in same class.
            %obj.parameters(lhs) = rhs;
        end
        
        %function add_gradient(obj, lhs, rhs)
        %    obj.gradients(lhs) = rhs;
        %end

        %function add_intermediate(obj, lhs, rhs)
        %    obj.symboltable.push(lhs, SEGeneralModel.PARAMETER_TABLE, 1); % By default, for now, size is always 1
        %    obj.parameters(lhs) = rhs;
        %end

        function id = get_parameter_id_by_name(obj, symbol)
             info = obj.symboltable.get_info(symbol);
             if isempty(info)
               error(sprintf('Symbol %s not found in context %s.', symbol, obj.name));
             end
             assert(strcmp(info{1},'P'));
             id = info{2};
        end
        

        function id = get_indexed_parameter_id_by_name(obj, symbol)
             info = obj.symboltable.get_info(symbol);
             if isempty(info)
               error(sprintf('Symbol %s not found in context %s.', symbol, obj.name));
             end
             if ~strcmp(info{1},'P_i')
                 error(sprintf('Expected P_i, got %s table.', info{1}));
             end
             id = info{2};
        end        

        function id = get_dynamic_id_by_name(obj, symbol)
             info = obj.symboltable.get_info(symbol);
             if isempty(info)
                 xxx
                 error(['Cannot locate symbol' symbol]);
             end
             if ~strcmp(info{1},'B')
                 error(sprintf('Expected dynamic variable for symbol %s.',symbol));
             end
             id = info{2};
        end
        
        function id = get_indexed_dynamic_id_by_name(obj, symbol)
             info = obj.symboltable.get_info(symbol);
             if isempty(info)
                 xxx
                 error(['Cannot locate symbol' symbol]);
             end
             if ~strcmp(info{1},'B_i')
                 error(sprintf('Expected indexed dynamic variable for symbol %s.',symbol));
             end
             id = info{2};
        end        

        function info = get_info_by_name(obj, symbol)
             info = obj.symboltable.get_info(symbol);
             if isempty(info) % Try adding index
                 if numel(find(symbol =='_'))==0
                     info = obj.symboltable.get_info([ symbol '_i']); % TODO: _i hardcoded here.
                 end
             end
        end

        function add_parameter(obj, lhs)
            if ~obj.symboltable.has_symbol(lhs.symbol)
                obj.symboltable.push(lhs.symbol, SEGeneralModel.PARAMETER_TABLE, 1); % By default, for now, size is always 1
            else
                lhs.error_me(sprintf('Symbol already defined: %s.', lhs.symbol));
            end
            
            % TODO: Check that is paramter, warn if duplicate definitions
            %obj.parameters(lhs) = rhs;
            %if isa(lhs, 'SEGradientReference')
            %    obj.gradients(lhs.symbol) = rhs;
            %elseif isa(lhs, 'SEReference')
            %    obj.symbols(lhs.symbol) = rhs;
            %else
            %    error('Internal error.');
            %end
            %obj.symbols(lhs
        end
        
        %function statement = next(obj)
        %    statement = obj.statements(obj.ptr);
        %    obj.ptr = obj.ptr + 1;
        %end
        
        %function value = is_eof(obj)
        %    value = (obj.ptr >= obj.end_ptr);
        %end
        
        %function add(obj, statement)
        %    statement.compile(obj);
        %    obj.statements{end+1} = statement;
        %    obj.end_ptr = numel(obj.statements)+1;
        %end
        
        %function evaluate_parameters(obj)
        %    k = keys(obj.parameters);
        %    vals = values(obj.parameters);
        %    for i=1:numel(k)
        %        obj.namespace.(k{i}) = vals{i}.evaluate(obj.namespace);
        %    end
        %end

        %function evaluate_dynamics(obj)
        %    k = keys(obj.dynamics);
        %    vals = values(obj.dynamics);
        %    for i=1:numel(k)
        %        obj.namespace.(k{i}) = vals{i}.evaluate(obj.namespace);
        %    end
        %end
        
        %function evaluate_gradients(obj, dt)
        %    k = keys(obj.gradients);
        %    vals = values(obj.gradients);
        %    for i=1:numel(k)
        %        obj.namespace.(k{i}) = obj.namespace.(k{i}) + vals{i}.evaluate(obj.namespace) * dt;
        %    end
        %end
        
        function show_namespace(obj, ns)
            obj.symboltable.show_namespace(ns);
        end

        function start_entry(obj, entry_name, compiler)
             entry_id=-1;
             for i=1:numel(obj.entry_names)
               if strcmp(entry_name, obj.entry_names{i})
                   entry_id = i;
               end
             end
             if entry_id==-1
                 %entry_name
                 %obj.entry_names
             end
             compiler.INFO_OPCODE(Compiler.INFO_BACKFILL_CURRENT_PTR, obj.entry_backfill_ids(entry_id));
        end

       function associate_references(obj, super_context, compiler)
           % Class definition replaces super_context (module) with its own
           % context.
           obj.statements.associate_references(obj, compiler);
       end
        
        function byte_compile_entry_code(obj, compiler)
            % Define the 'constructor' for module
            %obj.new_entry(compiler.get_entry_placeholder(), '.init');
            obj.start_entry(['.' obj.name '_init'], compiler);
            obj.statements.byte_compile_init(compiler);
            compiler.RET_OPCODE();
            % Define parameter update for module
            %obj.new_entry(compiler.get_entry_placeholder(), '.update');
            obj.start_entry(['.' obj.name '_update'], compiler);
            obj.statements.byte_compile_update(compiler);
            compiler.RET_OPCODE();
            % Define gradient update for module
            obj.start_entry(['.' obj.name '_gradient'], compiler);
            obj.statements.byte_compile_gradient(compiler);
            compiler.RET_OPCODE();
            
            obj.start_entry(['.' obj.name '_epoch'], compiler);
            obj.statements.byte_compile_epoch(compiler);
            compiler.RET_OPCODE();
            
        end

        function byte_compile_load(obj, compiler)
            obj.new_entry(['.' obj.name '_init']);
            obj.new_entry(['.' obj.name '_update']);
            obj.new_entry(['.' obj.name '_gradient']);
            obj.new_entry(['.' obj.name '_epoch']);
            compiler.push_STREAM(Compiler.encode_STRING(obj.name));
            obj.byte_compile_parameters(compiler);
            obj.byte_compile_dynamic(compiler);
            obj.byte_compile_entries(compiler);
            compiler.CREATE_CLASS_OPCODE();
        end

        

        function byte_compile_dynamic(obj, compiler)
            count = obj.get_dynamic_count();
            compiler.DYNAMIC_COUNT_OPCODE(count);
            for i=1:count
                compiler.push_STREAM(Compiler.encode_STRING(obj.get_dynamic_name_by_id(i)));
            end
        end

        function byte_compile_entries(obj, compiler)
            count = numel(obj.entry_names);
            compiler.ENTRY_COUNT_OPCODE(count);
            for i=1:count
                obj.entry_backfill_ids(i) = compiler.push_PTR_TO_BE_BACKFILLED();
                compiler.push_STREAM(uint8( [0 0 0 0])); % To be backfilled with address
                compiler.push_STREAM(Compiler.encode_STRING(obj.entry_names{i}));
            end
        end

        
        function byte_compile_parameters(obj, compiler)
            count = obj.get_parameter_count();
            compiler.PARAMETER_COUNT_OPCODE(count);
            for i=1:count
                compiler.push_STREAM(Compiler.encode_STRING(obj.get_parameter_name_by_id(i)));
            end
        end
          
            %code(ptr) = Compiler.DOUBLE_CONSTANT_COUNT; ptr = ptr + 1;
            %code(ptr:ptr+3) = typecast(cast(numel(obj.constants),'uint32'),'uint8'); ptr = ptr + 4;
            %for i=1:numel(obj.constants)
            %   code(ptr:ptr+7) = typecast(cast(obj.constants(i),'double'), 'uint8'); ptr = ptr + 8;
            %end
            %
            %code(ptr) = Compiler.ENTRY_COUNT; ptr = ptr + 1;
            %code(ptr:ptr+1) = typecast(cast(numel(obj.entries),'uint16'),'uint8'); ptr = ptr + 2;
            %entry_lookup = zeros(1,numel(obj.entries),'uint32');
            %for i=1:numel(obj.entries)
            %    % Store the address to backfill the entry pointer
            %    entry_lookup_address(i) = ptr;
            %    code(ptr:ptr+3) = typecast(uint32(0), 'uint8'); ptr = ptr + 4; % Placeholder for entry offset
            %    code(ptr) = Compiler.ENCODE_STRING; ptr = ptr + 1;
            %    entry_name = obj.entry_names{i};
            %    code(ptr) = cast(uint8(numel(entry_name)),'uint8'); ptr = ptr + 1;
            %    code(ptr:ptr+numel(entry_name)-1) = cast(entry_name,'uint8'); ptr = ptr + numel(entry_name);
            %end
            
            %count = obj.model.get_dynamic_count();
            %code(ptr) = Compiler.DOUBLE_DYNAMIC_COUNT; ptr = ptr + 1;
            %code(ptr:ptr+3) = typecast(cast(count,'uint32'),'uint8'); ptr = ptr + 4;
            %for i=1:count
            %    dynamic_name = obj.model.get_dynamic_name_by_id(i);
            %    code(ptr) = Compiler.ENCODE_STRING; ptr = ptr + 1;
            %    code(ptr) = cast(uint8(numel(dynamic_name)),'uint8'); ptr = ptr + 1;
            %    code(ptr:ptr+numel(dynamic_name)-1) = cast(dynamic_name,'uint8'); ptr = ptr + numel(dynamic_name);
            %end

            %count = obj.model.get_parameter_count();
            %code(ptr) = Compiler.DOUBLE_PARAMETER_COUNT; ptr = ptr + 1;
            %code(ptr:ptr+3) = typecast(cast(count,'uint32'),'uint8'); ptr = ptr + 4;
            %for i=1:count
            %    parameter_name = obj.model.get_parameter_name_by_id(i);
            %    code(ptr) = Compiler.ENCODE_STRING; ptr = ptr + 1;
            %    code(ptr) = cast(uint8(numel(parameter_name)),'uint8'); ptr = ptr + 1;
            %    code(ptr:ptr+numel(parameter_name)-1) = cast(parameter_name,'uint8'); ptr = ptr + numel(parameter_name);
            %end

        function byte_compile_init(obj, compiler)
            % Classdef's are not compiled
        end

        function byte_compile_update(obj, compiler)
            % Classdef's are not compiled
            % obj.statements.byte_compile_update(compiler);
        end
        
        function byte_compile_epoch(obj, compiler)
            % Classdef's are not compiled
            % obj.statements.byte_compile_update(compiler);
        end

        function byte_compile_gradient(obj, compiler)
            % Classdef's are not compiled
            % obj.statements.byte_compile_gradient(compiler);
        end


%        function byte_compile_load(obj, compiler)
%xxx
%        end 
%
%        function byte_compile_init(obj, compiler)
%xxx
%            for i=1:numel(obj.statements)
%               statement = obj.statements{i};
%               statement.byte_compile_init(compiler);
%            end
%        end
%       
%        function byte_compile_update(obj, compiler)
%            for i=1:numel(obj.statements)
%               statement = obj.statements{i};
%               statement.byte_compile_update(compiler);
%            end
%        end

%        function byte_compile_gradient(obj, compiler)
%            for i=1:numel(obj.statements)
%               statement = obj.statements{i};
%               statement.byte_compile_gradient(compiler);
%            end
%        end

    end

end
