classdef SEIntermediate < SEReference
properties
    % SEIntermediate can be anything
    % reference to an already defined parameter
    % reference to an already defined dynamic
    % reference to an already defined indexed parameter
    % reference to an already defined indexed dynamic
    % reference to an already defined indexed parameter at new (i.e. without _i)
    % reference to an already defined indexed dynamic at new (i.e. without _i)
end
   methods
        function str = repr(this)
            str = ['intermediate ' this.symbol ];
        end
        
       function resolve_context(obj, super_context, compiler)
       end
       
       function byte_compile_assign_to(this, compiler, params)
           if strcmp(params,'add')
               add = 1;
           else
               add = 0;
           end
           if isempty(this.info)
               this.error_me(sprintf('Unknown symbol %s',this.symbol));
           end
           table_id = this.info{1};
           idx = this.info{2};
           if ~add 
            if strcmp(table_id,'P') % TODO: Let compiler handle this
                   compiler.STORE_PARAMETER_OPCODE(idx);
           elseif strcmp(table_id,'B')
               compiler.STORE_DYNAMIC_OPCODE(idx);
           elseif strcmp(table_id,'P_i')
               compiler.STORE_INDEXED_PARAMETER_OPCODE(idx);
           elseif strcmp(table_id,'B_i')
               compiler.STORE_INDEXED_DYNAMIC_OPCODE(idx);
           elseif strcmp(table_id,'P_ij')
               compiler.STORE_LINK_INDEXED_PARAMETER_OPCODE(idx);
           elseif strcmp(table_id,'1P_i')
               compiler.STORE_PARAMETER_BY_IDX_OPCODE(1, idx);
           elseif strcmp(table_id,'2P_i')
               compiler.STORE_PARAMETER_BY_IDX_OPCODE(2, idx);
           elseif strcmp(table_id,'3P_i')
               compiler.STORE_PARAMETER_BY_IDX_OPCODE(3, idx);
            else
               this.info
               error('internal error.');
           end
           else
                compiler.ADD_REFERENCE_BY_INFO(this.info);
           end
        end
        
   end
end
