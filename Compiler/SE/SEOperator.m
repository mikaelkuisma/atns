classdef SEOperator < SEExpression
properties
    op
    left
    right
end
   methods
       function this = SEOperator(op, left, right)
           this.op = op;
           this.left = left;
           this.right = right;
       end
       
       function str = repr(obj)
           str = [ '(' obj.left.repr() ')' obj.op '(' obj.right.repr() ')'];
       end
       
       function byte_compile(obj, compiler)
           obj.left.byte_compile(compiler);
           obj.right.byte_compile(compiler);
           compiler.BINARY_OPERATOR_OPCODE(obj.op);
       end

       function resolve_context(this, super_context, compiler)
           this.left.resolve_context(super_context, compiler);
           this.right.resolve_context(super_context, compiler);
       end

       function associate_references(this, super_context, compiler)
           this.left.associate_references(super_context, compiler);
           this.right.associate_references(super_context, compiler);
       end
       
       function value = is_constant(this)
           value = this.left.is_constant() && this.right.is_constant();
       end
       
       function value = is_linked(this)
           value = this.left.is_linked() || this.right.is_linked();
       end
       
        function result = evaluate(this, namespace)
            value_left = this.left.evaluate(namespace);
            value_right = this.right.evaluate(namespace);
            if (this.op == '+')
                result = value_left + value_right;
            elseif (this.op == '-')
                result = value_left - value_right;
            elseif (this.op == '*')
                result = value_left * value_right;
            elseif (this.op == '/')
                result = value_left / value_right;
            elseif (this.op == '^')
                result = value_left ^ value_right;
            else
                error(sprintf('Unkown operator %s.', this.op));
            end
        end
   end
end
