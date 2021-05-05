classdef SEExpressionList < SEExpression
properties
    exprs
end
   methods
       function this = SEExpressionList(exprs)
           if ~iscell(exprs)
               exprs = num2cell(exprs);
           end
           this.exprs = exprs;
       end
       
       function str = repr(obj)
           str = 'SEExpressionList(';
           for i=1:numel(obj.exprs)
               str = [ str obj.exprs{i}.repr ];
               if i < numel(obj.exprs)
                   str = [ str newline ];
               end
           end
           %str = [ obj.left.repr() ', ' obj.right.repr() ];
       end
       
       function value = is_constant(obj)
           value = true;
           for i = 1:numel(obj.exprs)
               value = value && obj.exprs{i}.is_constant();
           end            
       end

       function resolve_context(obj, super_context, compiler)
           for i = 1:numel(obj.exprs)
               obj.exprs{i}.resolve_context(super_context, compiler);
           end 
       end

       function associate_references(obj, super_context, compiler)
           for i = 1:numel(obj.exprs)
               obj.exprs{i}.associate_references(super_context, compiler);
           end 
       end
       
       function len = get_length(obj)
           len = numel(obj.exprs);
       end
       
       function value = identify(obj)
           value = 'expression list';
       end
       
       function value = is_expression(obj)
           value = false;
       end
       
       function byte_compile(obj, compiler)
           % Pushes values to stack, it is left for parent expression to
           % deal with the data
           for i = 1:numel(obj.exprs)
               obj.exprs{i}.byte_compile(compiler);
           end
       end

       function byte_compile_init(obj, compiler)
           for i = 1:numel(obj.exprs)
               obj.exprs{i}.byte_compile_init(compiler);
           end
       end

       function byte_compile_init_indexed(obj, compiler)
           for i = 1:numel(obj.exprs)
               obj.exprs{i}.byte_compile_init_indexed(compiler);
           end
       end
       
       function byte_compile_init_link_indexed(obj, compiler)
           for i = 1:numel(obj.exprs)
               obj.exprs{i}.byte_compile_init_link_indexed(compiler);
           end
       end       
       
       
       function byte_compile_update(obj, compiler)
           for i = 1:numel(obj.exprs)
               obj.exprs{i}.byte_compile_update(compiler);
           end
       end

       function byte_compile_epoch(obj, compiler)
           for i = 1:numel(obj.exprs)
               obj.exprs{i}.byte_compile_epoch(compiler);
           end
       end
       
       function byte_compile_gradient(obj, compiler)
           for i = 1:numel(obj.exprs)
               obj.exprs{i}.byte_compile_gradient(compiler);
           end
       end
       
        function result = evaluate(obj, namespace)
            result = [];
            for i = 1:numel(obj.exprs)
               result(end+1) = obj.exprs{i}.evaluate(namespace);
            end
        end
   end
end
