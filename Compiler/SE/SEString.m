classdef SEString < SEExpression
properties
    value
end
   methods
       function obj = SEString(value)
           obj.value = value;
       end
       
       function value = is_linked(obj)
           value = 0;
       end
       function result = evaluate(obj, namespace)
           result = obj.value;
       end
       
       function value = is_constant(obj)
           value = 1;
       end
       
       function resolve_context(obj, super_context, compiler)
       end

       function associate_references(obj, super_context, compiler)
       end

       function str = repr(obj)
           str = sprintf('"%s"', obj.value);
       end
       
       function byte_compile(obj, compiler)
       end

   end
end
