classdef SESumExpression < SEExpression
    properties
        indices
        expression
    end
    methods
        function obj = SESumExpression(indices, expression)
            obj.indices = indices;
            obj.expression = expression;
        end
       
       function str = repr(obj)
           str = ['sum_i ' obj.expression.repr() ];
       end
       
       function value = is_expression(obj)
           value = true;
       end

       function resolve_context(obj, super_context, compiler)
           obj.expression.resolve_context(super_context, compiler);
       end
       
       function value = is_constant(obj)
           value = false;
       end

       function associate_references(obj, super_context, compiler)
           obj.expression.associate_references(super_context, compiler);
       end
       
       function byte_compile(obj, compiler)
           compiler.SUM_LOOP_OPCODE(1);
           loop_ptr = compiler.push_PTR_TO_BE_BACKFILLED();
           obj.expression.byte_compile(compiler);
           compiler.SUM_JUMP_OPCODE(loop_ptr);
       end

       function byte_compile_init(obj, compiler)
       end

       function byte_compile_update(obj, compiler)
       end
              
       function byte_compile_gradient(obj, compiler)
       end
       
        function result = evaluate(obj, namespace)
            xxx
           result = obj.rhs.evaluate(namespace);
           namespace.(obj.lhs.symbol) = result;
        end            
   end
end
