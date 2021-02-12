classdef SEDeploy < SEExpression & Context
properties
    my_id
    
    symbol
    arguments
    class_table_id
    
    tag_count
    
    deploy_index
end
   methods
       function this = SEDeploy(symbol, arguments)
           this.symbol = symbol;
           this.arguments = arguments;
           this.deploy_index = 0;
       end
       
       function str = repr(obj)
           str = ['deploy ' obj.symbol ' { ' obj.arguments.repr() ' };'];
           %str = ['@' obj.ref.repr() '(' obj.arguments.repr() ')'];
       end

       function index = get_new_deploy_index(obj)
           obj.deploy_index = obj.deploy_index + 1;
           index = obj.deploy_index;
       end
       
       function verify_pairdef(obj, pairdef)
           my_class = obj.super_context.classes{obj.class_table_id};
           my_class.verify_pairdef(pairdef);
       end
       
       function byte_compile_init_indexed(obj, compiler)
           my_class = obj.super_context.classes{obj.class_table_id};
           my_class.byte_compile_init_indexed(compiler);
       end
       
       function deploy_tag(obj, tag)
           obj.super_context.add_tag(obj.my_id, obj.deploy_index, tag);
       end
       
       function resolve_context(obj, super_context, compiler)
           resolve_context@Context(obj, super_context, compiler);
           obj.my_id = obj.super_context.get_new_deploy_id(obj);
           obj.class_table_id = super_context.get_class_id_by_name(obj.symbol);
           
           % CHANGED 12/12/2020: Commented these two lines. Deploy itself
           % is a context. It knows then the its class_id.
           %context = super_context.classes{obj.class_table_id};
           %obj.arguments.resolve_context(context, compiler);
           obj.arguments.resolve_context(obj, compiler);
       end

       function info = get_info_by_name(obj, info)
           % Delegate info to class
           info = obj.super_context.classes{obj.class_table_id}.get_info_by_name(info);
       end
       
       function associate_references(obj, super_context, compiler)
           % context needs to implement get_info_by_name
           
           % One is at lambda constructor. The references should be
           % associated with the class being constructed.

           % TODO: Trying context is SEDeploy
           % 
           obj.tag_count = 0;
           obj.super_context = super_context;
           obj.arguments.associate_references(obj, compiler);
           % obj.arguments.associate_references(super_context, compiler);
       end
       
       function tagcode = resolve_tag(obj, tag)
           tagcode = obj.super_context.resolve_tag(tag);
       end
       
       function tag_index = get_next_tag_index(obj)
           obj.tag_count = obj.tag_count + 1;
           tag_index = obj.tag_count;
       end
       
       function byte_compile(obj, compiler)
           %compiler.NEW_INSTANCE_OPCODE(obj.class_table_id);
           %xxx % LAMBDA OPCODE USED FOR CLASS, NOT THIS
           %compiler.ENTER_LAMBDA_OPCODE(); 
           %obj.arguments.byte_compile(compiler);
           %compiler.EXIT_LAMBDA_OPCODE();
           %compiler.CALL_ENTRY_OPCODE(1);
           xxx
       end
       
       function byte_compile_init(obj, compiler)
           compiler.DEPLOY_OPCODE(obj.class_table_id);
           class = obj.super_context.classes{obj.class_table_id};
           obj.arguments.byte_compile_init(compiler);
           obj.arguments.byte_compile_update(compiler);
           compiler.END_DEPLOY_OPCODE();
       end
       
       function byte_compile_epoch(obj, compiler)
       end
       
       function byte_compile_update(this, compiler)
           %disp('TODO: Maybe call update code here!!');
       end
       
       function byte_compile_gradient(this, compiler)
           %disp('TODO: Maybe call gradient code here!!');
       end          
       
       function result = evaluate(this, namespace)
          error('Not implemented');
       end
   end
end
