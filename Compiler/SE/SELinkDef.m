classdef SELinkDef < SEClassDef
    properties (Constant) 
    end
    properties
        link_parameters
        link_dynamics
        linkindexing
        
        indexed_parameters
        indexed_dynamics
    end
    methods (Access = protected)
    end    
    methods
        function obj = SELinkDef(name, linkindexing, statements)
            xxx
            obj@SEClassDef(name, statements);
            obj.linkindexing = linkindexing;
            obj.link_parameters = containers.Map;
            obj.link_dynamics = containers.Map;
            
            obj.indexed_dynamics = containers.Map;
            obj.indexed_parameters = containers.Map;
        end
        
        function str = repr(obj)
            str = [ 'LinkDef ' obj.name ' <...> ' newline ' { ' newline obj.statements.repr() newline ' };'];
        end
        

        function add_indexed_parameter(obj, lhs)
            if ~obj.symboltable.has_symbol(lhs)
                obj.symboltable.push(lhs, SEGeneralModel.INDEXED_PARAMETER_TABLE, 1); % By default, for now, size is always 1
            end
        end
        
        function add_indexed_dynamic(obj, lhs)
            if ~obj.symboltable.has_symbol(lhs)
                obj.symboltable.push(lhs, SEGeneralModel.INDEXED_DYNAMIC_TABLE, 1); % By default, for now, size is always 1
            end
        end
        
        function info = get_info_by_name(obj, symbol)
            disp('Resolving context at LinkDef. Must be really smart here at get_info_by_name.');
            info = {'B',1,1};
            return
        end
        
        function id = get_indexed_dynamic_id_by_name(obj, symbol)
            disp('Resolving context at LinkDef. Must be really smart here at get_indexed_dynamic_id_by_name.');
            id = 0;
            return
             info = obj.symboltable.get_info(symbol);
             if isempty(info)
                 xxx
                 error(['Cannot locate symbol' symbol]);
             end
             if ~strcmp(info{1},'B_i')
                 error(sprintf('Expected indexed dynamic variable for symbol %s.',symbol));
             end
             id = info{2};
        end        

        
    end

end
