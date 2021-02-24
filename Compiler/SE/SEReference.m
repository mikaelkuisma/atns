classdef SEReference < SEExpression
properties
   
    symbol
    indices
    parameter_type % 0 = normal 1 = indexed 2 = linked
    info
end
   methods
       function this = SEReference(symbol, token_ptr)
           if nargin > 1
               this.token_ptr = token_ptr;
           end
           this.symbol = symbol;
           underscores = find(this.symbol == '_');
           if numel(underscores)>1
               this.error_me('Two underscores detected.');
           end
           if numel(underscores)>0
              parts = split(this.symbol,'_');
              this.indices = parts{2};
              this.parameter_type = numel(this.indices);
              if this.parameter_type > 2
                  this.indices
                  xxx
              end
           else
               this.parameter_type = 0;
           end
       end
       
        function value = is_linked(this)
            value = this.parameter_type == 2;
        end
        
        function value = is_tag(this)
            value = 0;
        end

       
        function result = evaluate(this, namespace)
            result = namespace.(this.symbol);
        end
        
        function str = repr(this)
            str = this.symbol;
        end
        
        function value = is_gradient(this)
            value = false;
        end
        
        function value = is_epoch(this)
            value = false;
        end
        
        function value = is_constant(this)
            value = 0; % TODO: Reference could be constant. This can be improved.
        end
        
        function value = is_dynamic(this)
            value = false;
        end

       function resolve_context(obj, super_context, compiler)
           if ~strcmp(class(obj), 'SEReference')
               obj.resolve_context@SEExpression(super_context, compiler);
           end 
       end

        function associate_references(this, super_context, compiler)
            this.info = super_context.get_info_by_name(this.symbol);
            if isempty(this.info)
                this.info = super_context.get_info_by_name(this.symbol);
            end
        end

        function byte_compile(this, compiler)
            if ~isempty(this.info)
               compiler.LOAD_REFERENCE_BY_INFO(this.info);
            else
                this.error_me(sprintf('Cannot find context for reference %s.', this.symbol));
            end
        end
   end
end
