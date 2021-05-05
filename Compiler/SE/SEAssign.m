classdef SEAssign < SEExpression & Context
    properties
        lhs
        rhs
        constant_table_id 
        
        params
        
        compiled_to_init
        
        zero_constant
    end
    methods
        function obj = SEAssign(lhs, rhs, params)
            obj.compiled_to_init = 0;
            obj.lhs = lhs;
            if nargin > 2
                obj.params = params;
            end
            if obj.lhs.parameter_type == 0
                %if isempty(rhs)
                %    obj.rhs = SEConstant(0);
                %else
                    obj.rhs = rhs;
                %end
            elseif obj.lhs.parameter_type == 1
                    obj.rhs = rhs;
            elseif obj.lhs.parameter_type == 2
                obj.rhs = rhs;
            else
                obj.lhs
                error(sprintf('Unknown lhs paramter type %d.', obj.lhs.parameter_type));
                %error('internal error.');
            end
                
        end
     
       %function return_value = compile(obj, model)
       %    obj.lhs.add_to_model(obj.rhs, model);
       %end
       
       function str = repr(obj)
           if ~isempty(obj.rhs)
            str = [obj.lhs.repr() ' = ' obj.rhs.repr() ';' ];
           else
            str = [obj.lhs.repr() ';' ];
           end
       end
       
       function value = is_expression(obj)
           value = false;
       end

       function resolve_context(obj, super_context, compiler)
           resolve_context@Context(obj, super_context, compiler);
           if strcmp(obj.params,'add')
               obj.zero_constant = SEConstant(0);
               obj.zero_constant.resolve_context(super_context, compiler);
           end
           if ~isempty(obj.rhs)
                obj.rhs.resolve_context(super_context, compiler);
                if obj.rhs.is_constant()
                    %obj.rhs.repr()
                    %disp('is constant')
                   value = obj.rhs.evaluate(struct());
                   
                   % We may add single double variables as constants to
                   % optimize
                   if numel(value) == 1
                       obj.rhs = SEConstant(value);
                       obj.rhs.resolve_context(super_context, compiler);
                   end
                end
           else
               obj.zero_constant = SEConstant(0);
               obj.zero_constant.resolve_context(super_context, compiler);
           end                
           obj.lhs.resolve_context(super_context, compiler);
       end

       function associate_references(obj, super_context, compiler)
           if ~isempty(obj.rhs)
                obj.rhs.associate_references(super_context, compiler);
                if obj.lhs.is_tag()
                    obj.rhs.pass_tag(obj.lhs.tag);
                end
           end

           obj.lhs.associate_references(super_context, compiler);
       end
       
       function byte_compile(obj, compiler)
           if obj.lhs.is_tag()
               xxx
           end
           obj.byte_compile_init(compiler);
           obj.byte_compile_update(compiler);
       end

       function byte_compile_init_indexed(obj, compiler)
            if obj.lhs.is_gradient()
                return
            end
            if ~isempty(obj.rhs) && ~obj.rhs.is_constant()
                return
            end
            if obj.lhs.parameter_type >= 1
                 if isempty(obj.rhs)
                      %compiler.LINK_LOOP_OPCODE();
                      %loop_ptr = compiler.push_PTR_TO_BE_BACKFILLED();
                      obj.zero_constant.byte_compile(compiler);
                      obj.lhs.byte_compile_assign_to(compiler,[]);
                      %compiler.LINK_JUMP_OPCODE(loop_ptr);   
                 else
                     %xxxx
                  end
            end
       end
       
       
       function byte_compile_init_link_indexed(obj, compiler)
            if obj.lhs.is_gradient()
                return
            end
            if ~isempty(obj.rhs) && ~obj.rhs.is_constant()
                return
            end
            if obj.lhs.parameter_type >= 1
                 if isempty(obj.rhs)
                      %compiler.LINK_LOOP_OPCODE();
                      %loop_ptr = compiler.push_PTR_TO_BE_BACKFILLED();
                      obj.zero_constant.byte_compile(compiler);
                      obj.lhs.byte_compile_assign_to(compiler,[]);
                      %compiler.LINK_JUMP_OPCODE(loop_ptr);   
                 else
                     obj.rhs.byte_compile(compiler);
                     obj.lhs.byte_compile_assign_to(compiler,[]);
                 end
            end
       end
       
       
       
       function byte_compile_init(obj, compiler)
           % If the right hand side is empty, there is nothing to compile.
           if isempty(obj.rhs) && ~obj.lhs.is_dynamic() && ~obj.lhs.is_epoch()
               return
           end
           % All assigns to dynamic variables are the initial values. Thus
           % they are byte compiled to .init. Also, all constants can be
           % byte compiled to init.
           obj.compiled_to_init = obj.lhs.is_dynamic() || (obj.rhs.is_constant() && ~(obj.lhs.is_gradient() || obj.lhs.is_epoch()));
           
           if obj.compiled_to_init
              if isempty(obj.rhs)
                  % Empty index and others are not initialized here
                  if obj.lhs.parameter_type < 1
                     obj.zero_constant.byte_compile(compiler);
                     obj.lhs.byte_compile_assign_to(compiler, obj.params);
                  end
              else
                  if obj.lhs.parameter_type < 1
                  obj.rhs.byte_compile(compiler);
                  obj.lhs.byte_compile_assign_to(compiler, obj.params);
                  else
                      % On purpose empty
                      %compiler.LINK_LOOP_OPCODE();
                      %loop_ptr = compiler.push_PTR_TO_BE_BACKFILLED();
                      %obj.rhs.byte_compile(compiler);
                      %obj.lhs.byte_compile_assign_to(compiler, obj.params);
                      %compiler.LINK_JUMP_OPCODE(loop_ptr);   
                  end
              end
           end
       end

       function byte_compile_update(obj, compiler)
           % If the expression is already compiled to .init, no longer need
           % to compile it to .update
           if obj.compiled_to_init
               return
           end
           
           % empty right hand side emits no code
           if isempty(obj.rhs)
               return
           end
           
           if ~(obj.lhs.is_gradient() || obj.lhs.is_epoch())
             if obj.lhs.parameter_type == 0
                obj.rhs.byte_compile(compiler);
                obj.lhs.byte_compile_assign_to(compiler, obj.params);
                if ~isempty(obj.params)
                    error('+= not suitable for non-indexed parameters');
                end
             elseif obj.lhs.parameter_type >= 1
                 % In case of += loop, TODO: If there are multiple +=
                 % ,this fails.
                 
                 % Set the parameter to zero in the beginning
                 add = strcmp(obj.params,'add');
                 %if strcmp(obj.lhs.symbol,'effectiveprey_i')
                 %    xxx
                 %end
                 %obj.lhs.symbol
                 %
                 
                 if obj.super_context.is_link()
                     if add
                         % TODO: This loops over all links in vain. The
                         % zeroing of these variables should be done
                         % differently.
                         obj.super_context.plus_equals_opcheck(obj.lhs);
                         compiler.LINK_LOOP_OPCODE();
                         loop_ptr = compiler.push_PTR_TO_BE_BACKFILLED();
                         obj.zero_constant.byte_compile(compiler);
                         obj.lhs.byte_compile_assign_to(compiler,[]);
                         compiler.LINK_JUMP_OPCODE(loop_ptr);        
                     end
                    compiler.LINK_LOOP_OPCODE();
                    loop_ptr = compiler.push_PTR_TO_BE_BACKFILLED();
                    obj.rhs.byte_compile(compiler);
                    obj.lhs.byte_compile_assign_to(compiler, obj.params);
                    compiler.LINK_JUMP_OPCODE(loop_ptr);        
                 else
                    compiler.INDEX_LOOP_OPCODE(1);
                    loop_ptr = compiler.push_PTR_TO_BE_BACKFILLED();
                    obj.rhs.byte_compile(compiler);
                    obj.lhs.byte_compile_assign_to(compiler, obj.params);
                    compiler.INDEX_JUMP_OPCODE(loop_ptr);
                 end
             else
                 error('internal error.');
             end
               
               if 0
             if obj.lhs.parameter_type == 0
                obj.rhs.byte_compile(compiler);
                obj.lhs.byte_compile_assign_to(compiler, obj.params);
             elseif obj.lhs.parameter_type == 1
                compiler.INDEX_LOOP_OPCODE(1);
                loop_ptr = compiler.push_PTR_TO_BE_BACKFILLED();
                obj.rhs.byte_compile(compiler);
                obj.lhs.byte_compile_assign_to(compiler, obj.params);
                compiler.INDEX_JUMP_OPCODE(loop_ptr);
            elseif obj.lhs.parameter_type == 2
                compiler.LINK_LOOP_OPCODE();
                loop_ptr = compiler.push_PTR_TO_BE_BACKFILLED();
                obj.rhs.byte_compile(compiler);
                obj.lhs.byte_compile_assign_to(compiler, obj.params);
                compiler.LINK_JUMP_OPCODE(loop_ptr);                
             else
                 error('internal error.');
             end               
               end
           end
       end
       
       function byte_compile_epoch(obj, compiler)
           if obj.lhs.is_epoch()
             if obj.lhs.parameter_type == 0
                obj.rhs.byte_compile(compiler);
                obj.lhs.byte_compile_assign_to(compiler, obj.params);
             elseif obj.lhs.parameter_type == 1
                 if obj.super_context.is_link()
                    compiler.LINK_LOOP_OPCODE();
                    loop_ptr = compiler.push_PTR_TO_BE_BACKFILLED();
                    obj.rhs.byte_compile(compiler);
                    obj.lhs.byte_compile_assign_to(compiler, obj.params);
                    compiler.LINK_JUMP_OPCODE(loop_ptr);        
                 else
                    compiler.INDEX_LOOP_OPCODE(1);
                    loop_ptr = compiler.push_PTR_TO_BE_BACKFILLED();
                    obj.rhs.byte_compile(compiler);
                    obj.lhs.byte_compile_assign_to(compiler, obj.params);
                    compiler.INDEX_JUMP_OPCODE(loop_ptr);
                 end
             elseif obj.lhs.parameter_type == 2
                error('Link epoch not supported.');
                %compiler.LINK_LOOP_OPCODE();
                %loop_ptr = compiler.push_PTR_TO_BE_BACKFILLED();
                %obj.rhs.byte_compile(compiler);
                %obj.lhs.byte_compile_assign_to(compiler);
                %compiler.LINK_JUMP_OPCODE(loop_ptr);        
             else
                 error('internal error.');
             end
           end
       end
       
       function byte_compile_gradient(obj, compiler)
           if isempty(obj.rhs)
               return
           end
           if obj.lhs.is_gradient()
             if obj.lhs.parameter_type == 0
                obj.rhs.byte_compile(compiler);
                obj.lhs.byte_compile_assign_to(compiler, obj.params);
             elseif obj.lhs.parameter_type == 1
                 if obj.super_context.is_link()
                    compiler.LINK_LOOP_OPCODE();
                    loop_ptr = compiler.push_PTR_TO_BE_BACKFILLED();
                    obj.rhs.byte_compile(compiler);
                    obj.lhs.byte_compile_assign_to(compiler, obj.params);
                    compiler.LINK_JUMP_OPCODE(loop_ptr);        
                 else
                    compiler.INDEX_LOOP_OPCODE(1);
                    loop_ptr = compiler.push_PTR_TO_BE_BACKFILLED();
                    obj.rhs.byte_compile(compiler);
                    obj.lhs.byte_compile_assign_to(compiler, obj.params);
                    compiler.INDEX_JUMP_OPCODE(loop_ptr);
                 end
             elseif obj.lhs.parameter_type == 2
                %error('Link gradients not supported.');
                compiler.LINK_LOOP_OPCODE();
                loop_ptr = compiler.push_PTR_TO_BE_BACKFILLED();
                obj.rhs.byte_compile(compiler);
                obj.lhs.byte_compile_assign_to(compiler,[]);
                compiler.LINK_JUMP_OPCODE(loop_ptr);        
             else
                 error('internal error.');
             end
           end
       end
       
        function result = evaluate(obj, namespace)
           if isnumeric(obj.rhs)
               result = obj.rhs;
           else
               result = obj.rhs.evaluate(namespace);
           end
           namespace.(obj.lhs.symbol) = result;
        end            
   end
end
