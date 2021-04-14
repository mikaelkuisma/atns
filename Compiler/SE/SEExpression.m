classdef (Abstract) SEExpression < matlab.mixin.Heterogeneous & handle
   methods (Abstract)
        result = evaluate(this, namespace)
   end
   
   properties
       token_ptr
   end

   methods
       function return_value = compile(this, model)
           % No need to compile expression, it does not do anything
       end
       
       function str = repr(this)         
           error(sprintf('Internal error. Class %s does not have repr method defined.', class(this)));
       end
       
       
       function value = is_expression(this)
           value = true;
       end
       
       function value = is_tag(this)
           value = 0;
       end
       
       function error_me(this, msg)
           if ~isempty(this.token_ptr)
              error(['@' sprintf('%06d', this.token_ptr) ':' msg]);
           else
              error(msg);
           end
       end
       
       function value = is_constant(this)
           error(sprintf('class %s should implement is_constant.', class(this)));
       end
       
       function resolve_context(this, super_context, compiler)
           error(sprintf('Not implemented in %s.', class(this)));
       end

       function value = get_length(this)
           value = 1;
       end
         
       
       function value = identify(this)
           value = 'TODO';
       end
       
       function byte_compile(this, compiler)
           %class(this)
           fprintf('TODO: %s\n', class(this));
           %error('Internal error.');
       end
       
       function byte_compile_init(this, compiler)
           error(sprintf('byte_compile_init not defined in %s.', class(this)));
       end
       
       function byte_compile_update(this, compiler)
           error(sprintf('byte_compile_update not defined in %s.', class(this)));
       end       

       function byte_compile_gradient(this, compiler)
           error(sprintf('byte_compile_gradient not defined in %s.', class(this)));
       end              

   end

end
