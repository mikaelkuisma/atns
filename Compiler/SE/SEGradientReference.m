classdef SEGradientReference < SEExpression
properties
    symbol
    dynamic_table_id
    parameter_type % 0 = normal 1 = indexed 2 = linked
    
    indices
end
   methods
       function this = SEGradientReference(symbol)
           this.symbol = symbol;
           
           % TODO: This is copy paste from SEReference
           underscores = find(this.symbol == '_');
           if numel(underscores)>1
               error('Two underscores detected.');
           end
           if numel(underscores)>0
              parts = split(this.symbol,'_');
              this.indices = parts{2};
              this.parameter_type = numel(this.indices);
           else
               this.parameter_type = 0;
           end
       end
       
       function result = evaluate(this, namespace)
           result = namespace.([ 'd' this.symbol 'dt']);
       end
       
       function str = repr(this)
           str = ['d' this.symbol '/dt'];
       end
       
       function value = is_gradient(this)
           value = true;
       end
       
       function value = is_epoch(this)
           value = false;
       end
       
       function value = is_dynamic(this)
           value = false;
       end
       
       function add_to_model(this, rhs, model)
           model.add_gradient(this.symbol, rhs);
       end

        function associate_references(this, super_context, compiler)
            try
            if this.parameter_type == 0
                this.dynamic_table_id = super_context.get_dynamic_id_by_name(this.symbol);
            elseif this.parameter_type == 1
                this.dynamic_table_id = super_context.get_indexed_dynamic_id_by_name(this.symbol);
                %this.dynamic_table_id
                %super_context
                %xxx TODO
            else
                this.dynamic_table_id = super_context.get_link_indexed_dynamic_id_by_name(this.symbol);
            end    
            catch e
                rethrow(e);
                this.error_me(e.message);
            end
        end
       
       function resolve_context(obj, super_context, compiler)
            if numel(obj.indices)>0
                super_context.verify_indices(obj.indices);
            end
           %super_context.add_gradient(obj.symbol);
       end

       function byte_compile_assign_to(this, compiler, params)
            if strcmp(params,'add')
                xxx
            end
            if iscell(this.dynamic_table_id) % LINK INDEX STORAGE
                compiler.STORE_GRADIENT_BY_IDX_OPCODE(this.dynamic_table_id{1}, this.dynamic_table_id{2});
                return
            end
           
            if this.parameter_type == 0
                compiler.STORE_GRADIENT_OPCODE(this.dynamic_table_id);
            elseif this.parameter_type == 1
                    compiler.STORE_INDEXED_GRADIENT_OPCODE(this.dynamic_table_id);
            else
                    compiler.STORE_LINK_INDEXED_GRADIENT_OPCODE(this.dynamic_table_id);
            end               
            
       end
   end
end
