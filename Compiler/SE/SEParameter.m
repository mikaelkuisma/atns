classdef SEParameter < SEReference
properties
    parameter_table_id
end
   methods
       %function this = SEReference(symbol)
       %    this.symbol = symbol;
       %end
        function result = evaluate(this, namespace)
            result = namespace.(this.symbol);
        end
        function str = repr(this)
            str = ['parameter ' this.symbol ];
        end
        
        function add_to_model(this, rhs, model)
            xxx % OBSOLETE FUNCTION?
            if this.parameter_type == 0
               this.symbol
               pause
               model.add_parameter(this.symbol, rhs);
            elseif this.parameter_type == 1
               model.add_indexed_parameter(this.symbol, rhs);
            else
                error('Unkown parameter type.');
            end
        end
       
        function byte_compile_assign_to(this, compiler, params)
            if strcmp(params, 'add')
                add = 1;
            else
                add = 0;
            end
            if this.parameter_type == 0 && add == 0
                compiler.STORE_PARAMETER_OPCODE(this.parameter_table_id);
            elseif this.parameter_type == 1 && add == 0
                compiler.STORE_INDEXED_PARAMETER_OPCODE(this.parameter_table_id);
            elseif this.parameter_type == 1 && add == 1
                compiler.ADD_INDEXED_PARAMETER_OPCODE(this.parameter_table_id);
            elseif this.parameter_type == 2 && add == 0
                compiler.STORE_LINK_INDEXED_PARAMETER_OPCODE(this.parameter_table_id);
            elseif this.parameter_type == 0 && add == 1
                this.error_me('Parameter += not allowed.');
            else
                
                error(sprintf('internal error: Not implemented parameter_assign_to %d %d', this.parameter_type, add));
            end
                
        end

        function resolve_context(this, super_context, compiler)
            if numel(this.indices)>0
                try
                   super_context.verify_indices(this.indices);
                catch e
                    this.error_me(e.message);
                end
            end
            if this.parameter_type == 0
                super_context.add_parameter(this);
            elseif this.parameter_type == 1
                super_context.add_indexed_parameter(this.symbol);
            elseif this.parameter_type == 2
                super_context.add_link_indexed_parameter(this.symbol);
            else
                this.parameter_type
                error('internal error');
            end            
        end

        function byte_compile_init(this, compiler)
        end

       function byte_compile_update(this, compiler)
       end     

       function byte_compile_gradient(this, compiler)
       end
       
       function byte_compile_epoch(this, compiler)
       end 

        function associate_references(this, super_context, compiler)
            if this.parameter_type == 0
                this.parameter_table_id = super_context.get_parameter_id_by_name(this.symbol);
            elseif this.parameter_type == 1
                this.parameter_table_id = super_context.get_indexed_parameter_id_by_name(this.symbol);
            elseif this.parameter_type == 2
                this.parameter_table_id = super_context.get_link_indexed_parameter_id_by_name(this.symbol);
            else
                this.parameter_type
                error('internal error');
            end                
        end
   end
end
