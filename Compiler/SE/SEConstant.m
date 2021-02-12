classdef SEConstant < SEExpression
properties
    value
    constant_table_id
end
   methods
       function obj = SEConstant(value)
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
           obj.constant_table_id = super_context.add_constant(obj.value);
       end

       function associate_references(obj, super_context, compiler)
           % Technically, constant_table_id should be obtained here
       end

       function str = repr(obj)
           if isinteger(obj.value)
               str = sprintf('%d', obj.value);
           else
               str = sprintf('%f', obj.value);
           end
       end
       
       function byte_compile(obj, compiler)
           compiler.LOAD_CONSTANT_OPCODE(obj.constant_table_id);
       end

   end
end
