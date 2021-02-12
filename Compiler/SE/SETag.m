classdef SETag < SEExpression
properties
   tag
   parameter_type
end
   methods
       function obj = SETag(tag)
           obj.tag = tag;
           obj.parameter_type = 0;
       end
       
       function str = repr(obj)
           str = [ 'tag ' obj.tag ];
       end
       
       function value = is_dynamic(obj)
           value = 0;
       end
       
       function value = is_gradient(obj)
           value = 0;
       end
       
       function value = is_epoch(obj)
           value = 0;
       end
       
       function value = is_tag(obj)
           value = 1;
       end
       
       function byte_compile_assign_to(obj, compiler, params)
           % TAGS ARE NOT BYTE_COMPILED, THEY ARE COMPILATION TIME
           % REFERENCES
       end
       
       function associate_references(this, super_context, compiler)
           super_context.deploy_tag(this.tag);  
       end       
       
       function resolve_context(this, super_context, compiler)
           %super_context.add_tag(this.tag);
           % TODO: No not 
       end
       
       function value = evaluate(obj, namespace)
           value = [];
       end

   end
end
