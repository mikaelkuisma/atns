classdef SEGradient < SEExpression
    properties
        lhs
        rhs
    end
    methods
        function obj = SEGradient(lhs, rhs)
            obj.lhs = lhs;
            obj.rhs = rhs;
        end
       
        function result = evaluate(obj, namespace)
           result =  obj.rhs.evaluate(namespace);
           namespace.([ 'd' obj.lhs.symbol 'dt']) = result;
        end            
   end
end
