classdef SEArray < SEExpression
    properties
        expression_list
    end
   methods
       function obj = SEArray(expression_list)
           obj.expression_list = expression_list;
       end
       
       function value = identify(this)
           value = 'array';
       end
       
       function str = repr(this)
           str = ['[ ' this.expression_list.repr() ' ]'];
       end
       
       function value = is_constant(obj)
           value = obj.expression_list.is_constant();
       end
       
       function result = evaluate(obj, namespace)
           result = obj.expression_list.evaluate(namespace);
       end       

       function resolve_context(obj, super_context, compiler)
           obj.expression_list.resolve_context(super_context, compiler)
       end

       function associate_references(obj, super_context, compiler)
           obj.expression_list.associate_references(super_context, compiler)
       end
       
       function byte_compile(obj, compiler)
           obj.expression_list.byte_compile(compiler);
           compiler.BUILD_ARRAY_OPCODE(obj.expression_list.get_length());
       end
       
   end

end
