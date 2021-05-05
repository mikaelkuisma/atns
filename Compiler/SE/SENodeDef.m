classdef SENodeDef < SEClassDef
    properties (Constant) 
    end
    properties
        inherits
        super_class
        
        indexed_parameters
        indexed_dynamics
        indexing
        link_indexing
        link_classes % Contexts for resolving link indices
        
        link_indexed_parameter_names
        link_indexed_dynamic_names
        
        index_to_id
    end
    methods (Access = protected)
    end    
    methods
        function obj = SENodeDef(name, indexing, statements, inherits)
            obj@SEClassDef(name, statements);
            obj.inherits = inherits;
            obj.indexing = indexing;
            obj.link_indexed_parameter_names = {};
            obj.index_to_id = containers.Map;
            if strcmp(class(obj.indexing),'SEReference')
                obj.link_indexing = 0;
                obj.index_to_id(obj.indexing.symbol)=1;
            elseif iscell(obj.indexing)
                obj.link_indexing = 1;
                for c=1:3
                   obj.index_to_id(obj.indexing{c}{2})=c;
                end
            elseif isempty(obj.indexing)
            else
                error('Internal error');
            end

            obj.indexed_dynamics = containers.Map;
            obj.indexed_parameters = containers.Map;
        end
        
        function verify_indices(obj, indices)
            for i=1:numel(indices)
                index = indices(i);
                if ~isKey(obj.index_to_id, index)
                    error(sprintf('Undefined index %s.', index));
                end
            end
        end
        
        function str = repr(obj)
            str = [ 'NodeDef ' obj.name obj.link_indexing_repr() newline ' { ' newline obj.statements.repr() newline ' };'];
        end
        
        function plus_equals_opcheck(obj, ref)
            % TODO
        end
        
        function verify_pairdef(obj, pairdef)
            if obj.link_indexing == 0
                if ~isempty(pairdef)
                    error('Unexpected link definition.');
                end
            else
            for i=1:3
                link_class_id = obj.link_classes{i};
                %obj.super_context
                %link_class = obj.super_context.classes{link_class_id};
                %link_class.name
                %pairdef
                %pairdef(1+(i-1)*2)
                pair_class = obj.super_context.classes{obj.super_context.deployed_nodes{pairdef(1+(i-1)*2)}.class_table_id};
                pair_class.require_classtype(link_class_id);
            end
            end
        end
        
        function str = link_indexing_repr(obj)
            if iscell(obj.indexing)
                a = obj.indexing;
                str = sprintf(' <%s as %s, %s as %s, %s as %s> ', a{1}{1},a{1}{2}, a{2}{1}, a{2}{2}, a{3}{1}, a{3}{2});
                return
            end
                
            str = ['index as ' obj.indexing.symbol'];
        end
        
        function add_indexed_parameter(obj, lhs)
            if ~obj.symboltable.has_symbol(lhs)
                obj.symboltable.push(lhs, SEGeneralModel.INDEXED_PARAMETER_TABLE, 1); % By default, for now, size is always 1
            end
        end

        function add_link_indexed_parameter(obj, lhs)
            obj.link_indexed_parameter_names{end+1} = lhs;
            if ~obj.symboltable.has_symbol(lhs)
                obj.symboltable.push(lhs, SEGeneralModel.LINK_INDEXED_PARAMETER_TABLE, 1); % By default, for now, size is always 1
            end
        end
        
        function add_link_indexed_dynamic(obj, lhs)
            obj.link_indexed_dynamic_names{end+1} = lhs;
            if ~obj.symboltable.has_symbol(lhs)
                obj.symboltable.push(lhs, SEGeneralModel.LINK_INDEXED_DYNAMIC_TABLE, 1); % By default, for now, size is always 1
            end
        end
        
        function add_indexed_dynamic(obj, lhs)
            if ~obj.symboltable.has_symbol(lhs)
                obj.symboltable.push(lhs, SEGeneralModel.INDEXED_DYNAMIC_TABLE, 1); % By default, for now, size is always 1
            end
        end
        
        function byte_compile_dynamic(obj, compiler)
            byte_compile_dynamic@SEClassDef(obj, compiler); % Call superclass
            count = obj.get_indexed_dynamic_count();
            compiler.INDEXED_DYNAMIC_COUNT_OPCODE(count);
            for i=1:count
                compiler.push_STREAM(Compiler.encode_STRING(obj.get_indexed_dynamic_name_by_id(i)));
            end
        end
        
        function byte_compile_init_link_indexed(obj, compiler)
            if ~isempty(obj.super_class)
               obj.super_class.byte_compile_init_link_indexed(compiler);
            end
            obj.statements.byte_compile_init_link_indexed(compiler);
        end
        
        function byte_compile_init_indexed(obj, compiler)
            if ~isempty(obj.super_class)
               obj.super_class.byte_compile_init_indexed(compiler);
            end
            obj.statements.byte_compile_init_indexed(compiler);
        end
        
        function byte_compile_entry_code(obj, compiler)
            % Define the 'constructor' for module
            %obj.new_entry(compiler.get_entry_placeholder(), '.init');
            obj.start_entry(['.' obj.name '_init'], compiler);
            if ~isempty(obj.super_class)
               obj.super_class.statements.byte_compile_init(compiler);
            end
            obj.statements.byte_compile_init(compiler);
            compiler.RET_OPCODE();
            % Define parameter update for module
            %obj.new_entry(compiler.get_entry_placeholder(), '.update');
            obj.start_entry(['.' obj.name '_update'], compiler);
            if ~isempty(obj.super_class)
               obj.super_class.statements.byte_compile_update(compiler);
            end
            obj.statements.byte_compile_update(compiler);
            compiler.RET_OPCODE();
            
            % Define gradient update for module
            obj.start_entry(['.' obj.name '_gradient'], compiler);
            if ~isempty(obj.super_class)
               obj.super_class.statements.byte_compile_gradient(compiler);
            end
            obj.statements.byte_compile_gradient(compiler);
            compiler.RET_OPCODE();

            obj.start_entry(['.' obj.name '_epoch'], compiler);
            if ~isempty(obj.super_class)
               obj.super_class.statements.byte_compile_epoch(compiler);
            end
            obj.statements.byte_compile_epoch(compiler);
            compiler.RET_OPCODE();
        
        end
        
        
        function add_tag(obj, deploy_id, index_id, tag)
            obj.my_module.add_tag(deploy_id, index_id, tag);
        end        
        
        function resolve_context(obj, super_context, compiler)
            if ~isempty(obj.inherits)
               super_class_id = super_context.get_class_id_by_name(obj.inherits.symbol);
               class = super_context.classes{super_class_id};
               obj.super_class = class;
               if numel(class.indexed_parameters.keys) > 0
                    obj.indexed_parameters = containers.Map(class.indexed_parameters.keys, class.indexed_parameters.values);
               end
               if numel(class.indexed_dynamics.keys) > 0
               obj.indexed_dynamics = containers.Map(class.indexed_dynamics.keys, class.indexed_dynamics.values);
               end
               if numel(class.parameters.keys) > 0
               obj.parameters = containers.Map(class.parameters.keys,class.parameters.values);
               end
               if numel(class.dynamics.keys) > 0
               obj.dynamics = containers.Map(class.dynamics.keys,class.dynamics.values);
               end
               if numel(class.gradients.keys) > 0
               obj.gradients = containers.Map(class.gradients.keys,class.gradients.values);
               end
               obj.symboltable = class.symboltable.deepcopy();
            end
            
            resolve_context@SEClassDef(obj, super_context, compiler);
            
            if obj.link_indexing
                for c=1:3
                   obj.link_classes{c} = obj.my_module.get_class_id_by_name(obj.indexing{c}{1});
                end
            end
        end

        function require_classtype(obj, class_id)
            if class_id ~= obj.class_id
                if ~isempty(obj.super_class)
                    obj.super_class.require_classtype(class_id);
                else
                    error(sprintf('Class id mismatch. Required %s, found %s.', obj.super_context.classes{obj.class_id}.name,obj.super_context.classes{class_id}.name));
                end
            end
        end
        
        function byte_compile_parameters(obj, compiler)
            byte_compile_parameters@SEClassDef(obj, compiler); % Call superclass
            count = obj.get_indexed_parameter_count();
            compiler.DOUBLE_INDEX_PARAMETER_COUNT_OPCODE(count);
            for i=1:count
                compiler.push_STREAM(Compiler.encode_STRING(obj.get_indexed_parameter_name_by_id(i)));
            end
            
            count = numel(obj.link_indexed_parameter_names);
            compiler.LINK_INDEXED_PARAMETER_COUNT_OPCODE(count);
            for i=1:count
                compiler.push_STREAM(Compiler.encode_STRING(obj.link_indexed_parameter_names{i}));
            end

            count = numel(obj.link_indexed_dynamic_names);
            compiler.LINK_INDEXED_DYNAMIC_COUNT_OPCODE(count);
            for i=1:count
                compiler.push_STREAM(Compiler.encode_STRING(obj.link_indexed_dynamic_names{i}));
            end

        end
        
        function info = get_info_by_name(obj, symbol)
            info = get_info_by_name@SEClassDef(obj, symbol);
            if ~isempty(info)
                return
            end

            if obj.link_indexing
                parts = split(symbol,'_');
                if numel(parts) == 1
                    % Are we in deploy. If yes, we could try
                    
                    full_symbol = [ symbol '_' obj.indexing{1}{2} obj.indexing{2}{2} ];
                    info = get_info_by_name@SEClassDef(obj, full_symbol);
                    if ~isempty(info)
                        return
                    end
                    
                    error(sprintf('Symbol not found %s.',symbol));
                end
                if numel(parts) > 2
                    error('Too many _''s in a symbol');
                end
                 basename = parts{1};
                 indices = parts{2};
                 index_ids = [];
                 for c=1:numel(indices)
                     index_ids(c) = obj.index_to_id(indices(c));
                 end
                 if numel(index_ids) == 1
                    class_id = obj.link_classes{index_ids};
                    class = obj.my_module.classes{class_id};
                    info = class.get_info_by_name(basename);
                    if isempty(info)
                    %class
                    %basename
                    %info
                    %symbol
                    %obj.name
                    %class.symboltable
                    error(sprintf('Cannot find symbol %s.', symbol));
                    end
                    info{1} = [ num2str(index_ids) info{1} ];
                    return
                 else
                     xxx
                     error(sprintf('Cannot handle symbol %s.', symbol));
                 end

                 index_ids
                 xxx
                 
                xxx
               disp('Resolving context at LinkDef. Must be really smart here at get_info_by_name.');
               
               return
            end
            info = get_info_by_name@SEClassDef(obj, symbol);
        end
        
        function id = get_link_indexed_parameter_id_by_name(obj, symbol)
             info = obj.get_info_by_name(symbol);
             if ~strcmp(info{1},'P_ij')
                 error('link index paramter expected');
             end
             id = info{2};
        end
        
        function value = is_link(obj)
            value = obj.link_indexing;
        end
            
        
        function id = get_indexed_dynamic_id_by_name(obj, symbol)
            if obj.link_indexing
                info = obj.get_info_by_name(symbol);
                if isempty(info)
                    xxx
                    error(['Cannot locate symbol' symbol]);
                end
                if isstrprop(info{1}(1),'digit') % We have link_index lookup
                    id{1} = info{1}(1)-'0';
                    id{2} = info{2};
                    return
                end
                if ~strcmp(info{1},'B_i')
                    error(sprintf('Expected indexed dynamic variable for symbol %s.',symbol));
                end
                id = info{2};
                return
            end       
            id = get_indexed_dynamic_id_by_name@SEClassDef(obj, symbol);
        end


        function id = get_link_indexed_dynamic_id_by_name(obj, symbol)
            if obj.link_indexing
                info = obj.get_info_by_name(symbol);
                if isempty(info)
                    xxx
                    error(['Cannot locate symbol' symbol]);
                end
                if isstrprop(info{1}(1),'digit') % We have link_index lookup
                    id{1} = info{1}(1)-'0';
                    id{2} = info{2};
                    return
                end
                if ~strcmp(info{1},'B_ij')
                    error(sprintf('Expected link indexed dynamic variable for symbol %s.',symbol));
                end
                id = info{2};
                return
            end       
            error('internal error');%id = get_link_indexed_dynamic_id_by_name@SEClassDef(obj, symbol);
        end

    end

end
