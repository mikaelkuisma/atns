classdef SENewInstance < SEExpression & Context
properties
    symbol
    arguments
    class_table_id
end
   methods
       function this = SENewInstance(symbol, arguments)
           this.symbol =symbol;
           this.arguments = arguments;
       end
       
       function str = repr(obj)
           str = ['@' obj.ref.repr() '(' obj.arguments.repr() ')'];
       end

       function resolve_context(obj, super_context, compiler)
           obj.class_table_id = super_context.get_class_id_by_name(obj.symbol);
           context = super_context.classes{obj.class_table_id};
           obj.arguments.resolve_context(context, compiler);
       end

       function associate_references(obj, super_context, compiler)
           % One is at lambda constructor. The references should be
           % associated with the class being constructed.
           context = super_context.classes{obj.class_table_id};
           obj.arguments.associate_references(context, compiler);
       end
       
       function byte_compile(obj, compiler)
           compiler.NEW_INSTANCE_OPCODE(obj.class_table_id);
           compiler.ENTER_LAMBDA_OPCODE(); 
           obj.arguments.byte_compile(compiler);
           compiler.EXIT_LAMBDA_OPCODE();
           compiler.CALL_ENTRY_OPCODE(1);
       end
       
       function result = evaluate(this, namespace)
          error('Not implemented');
       end
   end
end
