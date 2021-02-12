classdef SEDynamic < SEReference
properties
   dynamic_table_id
end
   methods
       function str = repr(obj)
           str = [ 'dynamic ' obj.symbol ];
       end
       
       function add_to_model(obj, rhs, model)
           model.add_dynamic(obj.symbol, rhs);
       end
      
       function value = is_dynamic(obj)
           value = 1;
       end
       
       function byte_compile_assign_to(obj, compiler, params)
            if ~isempty(params)
                error('Dynamic assign accepts no add-qualifiers');
            end
            if obj.parameter_type == 0
                compiler.STORE_DYNAMIC_OPCODE(obj.dynamic_table_id);
            elseif obj.parameter_type == 1
                compiler.STORE_INDEXED_DYNAMIC_OPCODE(obj.dynamic_table_id);
            else
                error('internal error');
            end           
       end

       function byte_compile_init(obj, compiler)
           % SEAssign will write the assignment code to init
       end
       
       function byte_compile_epoch(this, compiler)
       end        

       function byte_compile_update(obj, compiler)
           % SEAssign will write the assignment code to init
       end

       function byte_compile_gradient(this, compiler)
       end     

        function associate_references(this, super_context, compiler)
            if this.parameter_type == 0
                this.dynamic_table_id = super_context.get_dynamic_id_by_name(this.symbol);
            elseif this.parameter_type == 1
                this.dynamic_table_id = super_context.get_indexed_dynamic_id_by_name(this.symbol);
            else
                this.parameter_type
                error('internal error');
            end    
        end
       
       function resolve_context(obj, super_context, compiler)
            if numel(obj.indices)>0
                super_context.verify_indices(obj.indices);
            end           
            if obj.parameter_type == 0
                super_context.add_dynamic(obj);
            elseif obj.parameter_type == 1
                super_context.add_indexed_dynamic(obj.symbol);
            else
                obj.parameter_type
                error('internal error');
            end                       
       end

   end
end
