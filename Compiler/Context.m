classdef Context < handle
    properties
        super_context
    end
    methods
        function resolve_context(obj, super_context, compiler)
            obj.super_context = super_context;
        end
        
        function constant_table_id = add_constant(obj, value)
            constant_table_id = obj.super_context.add_constant(value);
        end
        
        function add_indexed_parameter(obj, symbol)
            obj.super_context
            obj.super_context.add_indexed_parameter(symbol)
        end
        
        function associate_references(obj, super_context, compiler)
            obj.super_context = super_context;
        end
        

    end
end