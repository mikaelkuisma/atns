classdef SEUnaryMinus < SEExpression
properties
    arg
end
   methods
       function this = SEUnaryMinus(arg)
           this.arg = arg;
       end
       
       function resolve_context(obj, super_context, compiler)
           obj.arg.resolve_context(super_context, compiler)
       end

       function str = repr(obj)
           str = [ '-' repr(obj.arg) ];
       end
       
       function value = is_constant(obj)
           value = obj.arg.is_constant();
       end
       
       function value = is_linked(obj)
           value = obj.arg.is_linked();
       end
       
        function result = evaluate(this, namespace)
            result = -this.arg.evaluate(namespace);
        end

       function associate_references(this, super_context, compiler)
           this.arg.associate_references(super_context, compiler);
       end
        
        function byte_compile(this, compiler)
            this.arg.byte_compile(compiler);
            compiler.UNARY_MINUS_OPCODE();
        end
   end
end
