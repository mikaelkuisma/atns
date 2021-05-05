classdef SENewExpression < SEExpression
properties
    super_context
    
    statements 
    pairdef
    tag_index 
    
    indexing_opcode
    
    mytag
end
   methods
       function obj = SENewExpression(statements, pairdef)
           obj.statements = statements;
           obj.pairdef = pairdef;
       end
       
       function pass_tag(obj, tag)
           obj.mytag = tag;
       end
       
       function str = repr(obj)
           pairdef_str = '';
           if ~isempty(obj.pairdef)
           pairdef_str = ['<' sprintf('%s, ', obj.pairdef{:}) '>'];
           end
           str = ['new ' pairdef_str '{ ' obj.statements.repr() ' }'];
       end
       
       function value = is_constant(obj)
           value = false;
       end
       
       function resolve_context(obj, super_context, compiler)
           obj.super_context = super_context;
           obj.statements.resolve_context(super_context, compiler);       
       end
       
       function associate_references(obj, super_context, compiler)
           %obj.tag_index = super_context.get_next_tag_index();
           % Resolve the indexing tags
           if iscell(obj.pairdef)
               obj.indexing_opcode = [];
               for i=1:3
                   obj.indexing_opcode = [obj.indexing_opcode uint8(super_context.resolve_tag(obj.pairdef{i})) ];
               end
               assert(numel(obj.indexing_opcode) == 6);
           else
               self.deploy_index = super_context.get_new_deploy_index();
           end
           super_context.verify_pairdef(obj.indexing_opcode);
           obj.statements.associate_references(super_context, compiler);
       end       
       
      
       function byte_compile(obj, compiler)
           obj.byte_compile_init(compiler);
           obj.byte_compile_update(compiler);
       end
       
       function byte_compile_update(obj, compiler)
       end
       
       function byte_compile_init(obj, compiler)
           if iscell(obj.pairdef)
              compiler.NEW_LINK_INDEXED_OPCODE();
              compiler.push_STREAM(obj.indexing_opcode);
              %obj.super_context.super_context.classes{obj.super_context.class_table_id}.byte_compile_init_indexed(compiler);
              obj.super_context.byte_compile_init_link_indexed(compiler); % Indexed initializers

           else
              compiler.NEW_INDEXED_OPCODE();
              compiler.push_STREAM(Compiler.encode_STRING(obj.mytag));
              
              % Compile static assignments at class level
              %obj.super_context.super_context.classes{obj.super_context.class_table_id}.byte_compile_init_indexed(compiler);
              
              obj.super_context.byte_compile_init_indexed(compiler); % Indexed initializers
           end
           
           obj.statements.byte_compile(compiler);
       end
       
        function result = evaluate(obj, namespace)
           asd
        end            
   end
end

