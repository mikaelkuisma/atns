classdef SEDisplay < SEExpression
    properties
        label
        expression
    end
    methods
        function obj = SEDisplay(label, expression)
            obj.label = label;
            obj.expression = expression;
        end
       
        function result = evaluate(obj, namespace)
           result =  obj.expression.evaluate(namespace);
        end
        
       function resolve_context(obj, super_context, compiler)
           obj.expression.resolve_context(super_context, compiler);
       end
       
       function associate_references(obj, super_context, compiler)
           obj.expression.associate_references(super_context, compiler);
       end
       
       function byte_compile_init(obj, compiler)
       end
       
       function byte_compile_update(obj, compiler)
       end

       function byte_compile_epoch(obj, compiler)
       end
       
       function byte_compile_gradient(obj, compiler)
            obj.expression.byte_compile(compiler);
            compiler.DISPLAY_OPCODE();
       end
       
   end
end
