classdef SEModule < SEClassDef
    properties
        classes

        tags_lookup
        constants
        constants_lookup % Do not duplicate constants
        
        deploy_count
        deployed_nodes
        
        tag_list
    end
    methods
        function obj = SEModule(expression_list)
             obj@SEClassDef('', expression_list);
             obj.classes={};
             obj.tag_list = {};
             obj.tags_lookup=containers.Map('ValueType','uint16','KeyType','char');
             obj.constants_lookup = containers.Map('ValueType','uint32','KeyType','uint64');
             obj.deploy_count = 0;
        end
        
        function str = repr(obj)
            str = [' module ' newline '  {' newline ];
            %for i=1:numel(obj.classes)
            %    str = [ str obj.classes{i}.repr() ];
            %end
            str = [ str obj.statements.repr() ];
            str = [ str newline '};'];
        end
        
        function code = resolve_tags(obj, tag)
            if ~isKey(obj.tags_lookup, tag)
                error(sprintf('Tag %s not found.', tag));
            end
            code = obj.tags_lookup(tag);
        end
        
        function count = get_tags_count(obj)
            count = numel(obj.tag_list);
        end
        
        function tag = get_tag_by_id(obj, id)
            tag = obj.tag_list{id};
        end
        
        function index = add_constant(obj, constant)
            constant_key = typecast(cast(constant,'double'), 'uint64');
            if obj.constants_lookup.isKey(constant_key)
                index = obj.constants_lookup(constant_key);
            else
                % Add new constant to constants table
                obj.constants(end+1) = constant;
                index = uint32(numel(obj.constants));
                obj.constants_lookup(constant_key) = index;
            end
        end

        function add_tag(obj, deploy_id, index_id, tag)
            obj.tags_lookup(tag) = typecast(uint8([deploy_id index_id]), 'uint16'); % TODO: Need also instance index (?)
            obj.tag_list{end+1} = tag;
        end
        
        function deploy_id= get_new_deploy_id(obj, deploy)
            obj.deploy_count = obj.deploy_count + 1;
            obj.deployed_nodes{end+1} = deploy;
            deploy_id = obj.deploy_count;
        end
            
        
        function code = resolve_tag(obj, tag)
            if ~isKey(obj.tags_lookup, tag)
                error(sprintf('Tag not found: %s.',tag));
            end
            code = typecast(obj.tags_lookup(tag),'uint8');
        end


        function class_id = add_class(obj, class)
           obj.classes{end+1} = class;
           class_id = numel(obj.classes);
        end

        function byte_compile_constants(obj, compiler)
            compiler.DOUBLE_CONSTANT_COUNT_OPCODE(numel(obj.constants));
            for i=1:numel(obj.constants)
                compiler.push_STREAM(Compiler.encode_DOUBLE(obj.constants(i)));
            end
        end

        function byte_compile_tags(obj, compiler)
            count = obj.get_tags_count();
            compiler.TAG_COUNT_OPCODE(count);
            for i=1:count
                compiler.push_STREAM(Compiler.encode_STRING(obj.get_tag_by_id(i)));
            end
        end        
        
        function byte_compile_load(obj, compiler)
            obj.byte_compile_constants(compiler);
            obj.byte_compile_classes(compiler);
            obj.byte_compile_parameters(compiler);
            obj.byte_compile_dynamic(compiler);
            obj.byte_compile_tags(compiler);
            obj.byte_compile_entries(compiler);
            compiler.RET_OPCODE();
        end

        function byte_compile_classes(obj, compiler)
            compiler.NODEDEF_COUNT_OPCODE(numel(obj.classes));
            for i=1:numel(obj.classes)
                obj.classes{i}.byte_compile_load(compiler);
            end
        end

        function byte_compile_entry_code(obj, compiler)
            for i=1:numel(obj.classes)
                obj.classes{i}.byte_compile_entry_code(compiler);
            end
            byte_compile_entry_code@SEClassDef(obj, compiler);
        end

        function id = get_class_id_by_name(obj, symbol)
             id = -1;
             for i=1:numel(obj.classes)
                if strcmp(obj.classes{i}.name, symbol)
                   id = i;
                end
             end
             if id==-1
                error(sprintf('Class not found: %s.', symbol));
             end
        end

        function byte_compile(obj, compiler)
            % Push all definitions (parameter, dynamic, gradient, entry) to
            % module object.
            obj.statements.resolve_context(obj, compiler);

            % The symbol table is now ready, now one may associate all
            % references with their index.
            obj.statements.associate_references(obj, compiler);

            obj.new_entry(['.' obj.name '_init']);
            obj.new_entry(['.' obj.name '_update']);
            obj.new_entry(['.' obj.name '_gradient']);
            obj.new_entry(['.' obj.name '_epoch']);

            obj.byte_compile_load(compiler);
            obj.byte_compile_entry_code(compiler);
            %obj.new_entry(compiler.get_entry_placeholder(), '.gradient');
            %obj.byte_compile_gradient(obj);
            %compiler.RET_OPCODE();
        end

    end
end
