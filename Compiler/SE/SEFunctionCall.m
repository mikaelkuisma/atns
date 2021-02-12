classdef SEFunctionCall < SEExpression
properties
    ref
    arguments
end
   methods
       function this = SEFunctionCall(ref, arguments)
           this.ref = ref;
           this.arguments = arguments;
       end
       
       function str = repr(obj)
           if ischar(obj.ref)
               symbol = obj.ref;
           else
               symbol = obj.ref.symbol;
           end
           if ischar(obj.arguments) || isempty(obj.arguments)
               args = obj.arguments;
           else
               obj.arguments
               args = obj.arguments.repr();
           end
           str = ['@' symbol '(' args ')'];
       end
       
       function value = is_constant(obj)
           value = false;
       end

       function resolve_context(obj, super_context, compiler)
           if ~isempty(obj.arguments)
              obj.arguments.resolve_context(super_context, compiler);
           end
       end

       function associate_references(obj, super_context, compiler)
           if ~isempty(obj.arguments)
               obj.arguments.associate_references(super_context, compiler);
           end
       end
       
       function byte_compile_init(obj, compiler)
          obj.byte_compile(compiler);
       end

       function byte_compile_update(obj, compiler)
       end

       function byte_compile_gradient(this, compiler)
       end
       
       function byte_compile_epoch(this, compiler)
       end

       
       function byte_compile(obj, compiler)
           % Check for builtins
           if ~isempty(obj.arguments)
               obj.arguments.byte_compile(compiler);
           end
           if ischar(obj.ref)
               symbol = obj.ref;
           else
               symbol = obj.ref.symbol;
           end
           if strcmp(symbol, 'SUM')
               if obj.arguments.get_length()~=1
                   compiler.error('Function @SUM expects 1 argument.');
               end
               compiler.VECTOR_SUM_OPCODE();
               return
           elseif strcmp(symbol,'PRINT')
               compiler.DUPLICATE_STACK_OPCODE(obj.arguments.get_length());
               compiler.PRINT_OPCODE(obj.arguments.get_length());
               return
           elseif strcmp(symbol,'RAND')
               compiler.BUILTIN_FUNCTION_OPCODE(Compiler.BUILTIN_RAND);
               return
           elseif strcmp(symbol,'exp')
               compiler.BUILTIN_FUNCTION_OPCODE(Compiler.BUILTIN_EXP);
               return
           elseif strcmp(symbol,'lognormal')
               compiler.BUILTIN_FUNCTION_OPCODE(Compiler.BUILTIN_LOGNORMAL);
               return
           elseif strcmp(symbol,'SWITCH')
               compiler.BUILTIN_FUNCTION_OPCODE(Compiler.BUILTIN_SWITCH);
               return
           elseif strcmp(symbol,'ln')
               compiler.BUILTIN_FUNCTION_OPCODE(Compiler.BUILTIN_LN);
               return
           elseif strcmp(symbol,'HORZ')
               compiler.HORZCAT_OPCODE(obj.arguments.get_length());
               return
           elseif strcmp(symbol,'SOLVE')
               fprintf('NOT calling solve\n');
           elseif strcmp(symbol,'Wt')
               compiler.BUILTIN_FUNCTION_OPCODE(Compiler.BUILTIN_WT);
           elseif strcmp(symbol,'T')
               compiler.BUILTIN_FUNCTION_OPCODE(Compiler.BUILTIN_T);
           elseif strcmp(symbol,'t')
               compiler.BUILTIN_FUNCTION_OPCODE(Compiler.BUILTIN_t);
           else
               error(sprintf('Not implemented: %s.', symbol));
           end
       end
       
        function result = evaluate(this, namespace)
           error('Not implemented');
        end
   end
end
