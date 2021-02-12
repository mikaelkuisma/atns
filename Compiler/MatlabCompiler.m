classdef MatlabCompiler < Compiler
    properties
    end
    methods
        function obj = MatlabCompiler(parser)
            obj@Compiler(parser);
            % ModelWrapper
            % ParameterSpaceSize
            %compiled_model = ModelWrapper();
            obj.display_expression_tree(obj.model.statements{1},0);
        end
        
        function display_expression_tree(obj, expression, indent)
            A=zeros(1,indent);
            A(:) = 32;
            A=char(A);
            cls = class(expression);
            tree = [ A cls ':' ];
            if isprop(expression,'value')
                tree = [ tree num2str(expression.value)];
            end
            if isprop(expression,'op')
                tree = [ tree expression.op ];
            end
            tree = [ tree newline ];
            fprintf(tree);
            if isprop(expression,'left')
                disp([ A '  left:']);
                obj.display_expression_tree(expression.left, indent+4);
            end
            if isprop(expression,'right')
                disp([ A '  right:']);
                obj.display_expression_tree(expression.right, indent+4);
            end
            if isprop(expression,'lhs')
                disp([ A '  lhs:']);
                obj.display_expression_tree(expression.lhs, indent+4);
            end
            if isprop(expression,'rhs')
                disp([ A '  rhs:']);
                obj.display_expression_tree(expression.rhs, indent+4);
            end
            if isprop(expression,'arg')
                disp([ A '  arg:']);
                obj.display_expression_tree(expression.arg, indent+4);
            end
           
        end
        
        function handle = get_model(obj, name)
            if strcmp(name, 'main')
               
            end
        end
        
        function str = repr(obj)
            str='';
            for i=1:numel(obj.model.statements)
                statement = obj.model.statements{i};
                str = [ str statement.repr() ];
            end            
        end
        
    end
end