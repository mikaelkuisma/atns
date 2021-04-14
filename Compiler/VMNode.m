classdef VMNode < VMClass
    properties
        index_name
        
        index_parameter_names
        link_indexed_parameter_names        
        link_indexed_dynamic_names        
        index_dynamic_names
    end
    methods (Access = protected)
       function displayScalarObject(obj)
          displayScalarObject@VMClass(obj);
          fprintf('*****************************\n');
          fprintf('* %-26s*\n', obj.name);
          fprintf('*****************************\n');
          fprintf('*INDEX PARAMETERS           *\n');
          for i=1:numel(obj.index_parameter_names)
              fprintf('* %-26s*\n', obj.index_parameter_names{i});
          end
          if numel(obj.index_parameter_names) == 0
              fprintf('*  N/A                      *\n');
          end          
          fprintf('*****************************\n');
          fprintf('*INDEX DYNAMIC              *\n');
          for i=1:numel(obj.index_dynamic_names)
              fprintf('* %-26s*\n', obj.index_dynamic_names{i});
          end
          if numel(obj.index_dynamic_names) == 0
              fprintf('*  N/A                      *\n');
          end
          fprintf('*****************************\n');
      end        
    end    
    methods
        function obj = VMNode(name)
            obj@VMClass(name);
            obj.link_indexed_parameter_names = {};
            obj.link_indexed_dynamic_names = {};
            obj.index_parameter_names = {};
            obj.index_dynamic_names = {};
        end
        
        function index_as(obj, index_name)
            obj.index_name = index_name;
        end
        
        function push_index_parameter_name(obj, name)
            obj.index_parameter_names{end+1} = char(name);
        end
        
        function push_link_indexed_parameter_name(obj, name)
            obj.link_indexed_parameter_names{end+1} = char(name);
        end

        function push_link_indexed_dynamic_name(obj, name)
            obj.link_indexed_dynamic_names{end+1} = char(name);
        end

        
        function push_index_dynamic_name(obj, name)
            obj.index_dynamic_names{end+1} = char(name);
        end
    end
end