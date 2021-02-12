classdef VMNodeInstance < VMInstance
    properties
        vm
        
        index_dynamic
        index_parameter
        index_gradient
        
        link_index_dynamic % TODO: NOT ALLOWED FOR NOW
        link_index_parameter
        link_index_gradient % TODO: NOT ALLOWED FOR NOW
        
        link_loop_index
        link_loop_keys

        current_index
        total_indexed
        
        current_link_index
        
        tags
    end
    methods (Access = protected)
      function displayScalarObject(obj)
          displayScalarObject@VMInstance(obj);
          for i=1:numel(obj.tags)
          fprintf('*****************************\n');
          fprintf('* TAG: %-21s*\n', obj.tags{i});
          fprintf('*****************************\n');
          fprintf('*****************************\n');

          end
      end
    end 
    
    methods
        function obj = VMNodeInstance(vmclass)
            obj@VMInstance(vmclass);
            obj.current_index = 0;
            obj.total_indexed = 0;
            
            obj.index_parameter = {};
            obj.index_dynamic = {};
            obj.index_gradient = {};
            obj.link_index_dynamic = containers.Map('KeyType','uint64','ValueType','any');
            obj.link_index_parameter = containers.Map('KeyType','uint64','ValueType','any');
            obj.link_index_gradient = containers.Map('KeyType','uint64','ValueType','any');
            obj.tags = {};
        end
        
        function data = get_deploy_struct(obj)
            data = get_deploy_struct@VMInstance(obj);
            data.index_names = {};
            data.index_types = {};
            for j=1:numel(obj.vmclass.index_dynamic_names)
                 data.index_names{end+1} = obj.vmclass.index_dynamic_names{j};
                 data.index_types{end+1} = 'dynamic';
            end
            for j=1:numel(obj.vmclass.index_parameter_names)
                 data.index_names{end+1} = obj.vmclass.index_parameter_names{j};
                 data.index_types{end+1} = 'parameter';
            end
            
            data.index_data = [ obj.index_dynamic  obj.index_parameter ];            
        end
        

        
        function new_indexed(obj, tag)
            obj.tags{end+1} = tag;
            N = obj.total_indexed;
            for i=1:numel(obj.vmclass.index_dynamic_names)
                obj.index_dynamic{N+1,i} = 0;
                obj.index_gradient{N+1,i} = 0;
            end
            for i=1:numel(obj.vmclass.index_parameter_names)
                obj.index_parameter{N+1,i} = 0;
            end
            obj.total_indexed = N + 1;
            obj.current_index = obj.total_indexed;
        end
        
        function link_index(obj, link)
            link = typecast([ link uint8(0) uint8(0) ], 'uint64');
            obj.current_link_index = link;

            if ~isKey(obj.link_index_dynamic, obj.current_link_index)
                obj.link_index_dynamic(link) = {};
                obj.link_index_parameter(link) = {};
                obj.link_index_gradient(link) = {};
            end
            
        end
        
        function index_loop(obj)
            obj.current_index = 1;
        end
        
        function was_more = next_index(obj)
            obj.current_index = obj.current_index + 1;
            was_more = obj.current_index <= size(obj.index_dynamic,1);
        end
        
        function was_more = next_link(obj)
            obj.link_loop_index = obj.link_loop_index + 1;
            was_more = obj.link_loop_index <= numel(obj.link_loop_keys);
            if was_more
               obj.current_link_index = obj.link_loop_keys{obj.link_loop_index};
            end
        end
        
        function value = load_indexed_parameter(obj, position)
            try
            value = obj.index_parameter{obj.current_index, position};
            catch e
                rethrow(e)
            end
                
                
        end
        
        function value = load_link_indexed_parameter(obj, position)
            parameters = obj.link_index_parameter(obj.current_link_index);
            value = parameters{position};
            if isempty(value)
                error('xxx');
            end
        end
        
        function value = load_indexed_dynamic(obj, position)
            value = obj.index_dynamic{obj.current_index, position};
        end
        
        function value = load_indexed_dynamic_ref(obj, position)
            value = [ obj.tags{obj.current_index} '_' obj.vmclass.index_dynamic_names{position} ];
        end

        function value = load_indexed_parameter_ref(obj, position)
            value = [ obj.tags{obj.current_index} '_' obj.vmclass.index_parameter_names{position} ];
        end
        
        
        function value = load_dynamic_by_idx(obj, idx, position)
            link_data = typecast(obj.current_link_index,'uint8');
            link_data = link_data(idx*2-1:idx*2);
            class_idx = link_data(1);
            dynamic_idx = link_data(2);
            instance = obj.vm.deployed_nodes{class_idx}; % TODO: Assumes same ordering as for classes(?)
            value = instance.index_dynamic{dynamic_idx, position};
            if isempty(value)
                xxx
            end
        end        

        function value = load_parameter_by_idx(obj, idx, position)
            link_data = typecast(obj.current_link_index,'uint8');
            link_data = link_data(idx*2-1:idx*2);
            class_idx = link_data(1);
            parameter_idx = link_data(2);
            instance = obj.vm.deployed_nodes{class_idx}; % TODO: Assumes same ordering as for classes(?)
            value = instance.index_parameter{parameter_idx, position};
            if isempty(value)  
                name = instance.vmclass.parameter_names{parameter_idx};
                error(sprintf('While at link, node parameter uninitialized %s at link index %d.', name, position));
            end
        end        
        
        
        function value = store_gradient_by_idx(obj, idx, position, value)
            link_data = typecast(obj.current_link_index,'uint8');
            link_data = link_data(idx*2-1:idx*2);
            class_idx = link_data(1);
            dynamic_idx = link_data(2);
            instance = obj.vm.deployed_nodes{class_idx}; % TODO: Assumes same ordering as for classes(?)
            instance.index_gradient{dynamic_idx, position} = instance.index_gradient{dynamic_idx, position} + value;
        end        

        function value = add_parameter_by_idx(obj, idx, position, value)
            link_data = typecast(obj.current_link_index,'uint8');
            link_data = link_data(idx*2-1:idx*2);
            class_idx = link_data(1);
            dynamic_idx = link_data(2);
            instance = obj.vm.deployed_nodes{class_idx}; % TODO: Assumes same ordering as for classes(?)
            instance.index_parameter{dynamic_idx, position} = instance.index_parameter{dynamic_idx, position} + value;
        end        

        
        function value = store_parameter_by_idx(obj, vm, idx, position, value)
            link_data = typecast(obj.current_link_index,'uint8');
            link_data = link_data(idx*2-1:idx*2);
            class_idx = link_data(1);
            dynamic_idx = link_data(2);
            instance = vm.deployed_nodes{class_idx}; % TODO: Assumes same ordering as for classes(?)
            instance.index_parameter{dynamic_idx, position} = value;
        end        
        
        function value = link_indexed_parameter_ref(obj, idx)
            value = sprintf('%s_link%d_%s', obj.classname, obj.link_loop_index, obj.vmclass.link_indexed_parameter_names{idx});
        end
        
        
        
       function value = parameter_by_idx_ref(obj, vm, idx, position)
            link_data = typecast(obj.current_link_index,'uint8');
            link_data = link_data(idx*2-1:idx*2);
            class_idx = link_data(1);
            dynamic_idx = link_data(2);
            instance = vm.deployed_nodes{class_idx}; % TODO: Assumes same ordering as for classes(?)
            %instance.index_parameter{dynamic_idx, position} = value;
            value = [ instance.tags{dynamic_idx} '_' instance.vmclass.index_parameter_names{position} ];
       end        
        
        function value = dynamic_by_idx_ref(obj, vm, idx, position)
            link_data = typecast(obj.current_link_index,'uint8');
            link_data = link_data(idx*2-1:idx*2);
            class_idx = link_data(1);
            dynamic_idx = link_data(2);
            instance = vm.deployed_nodes{class_idx}; % TODO: Assumes same ordering as for classes(?)
            %instance.index_parameter{dynamic_idx, position} = value;
            value = [ instance.tags{dynamic_idx} '_' instance.vmclass.index_dynamic_names{position} ];
        end        
       
        function link_loop(obj, vm)
            obj.link_loop_index = 1;
            obj.link_loop_keys = keys(obj.link_index_dynamic);
            obj.current_link_index = obj.link_loop_keys{obj.link_loop_index};
            obj.vm = vm;
        end
        
        function store_indexed_parameter(obj, position, value)
            obj.index_parameter{obj.current_index, position} = value;
        end

        function add_indexed_parameter(obj, position, value)
            xxx
            obj.index_parameter{obj.current_index, position} = obj.index_parameter{obj.current_index, position} + value;
        end
        
        function zero_gradients(obj)
            for i=1:numel(obj.gradient)
                obj.gradient{i} = 0.0;
            end
            
            for i=1:size(obj.index_gradient,1)
                for j=1:size(obj.index_gradient,2)
                    obj.index_gradient{i,j} = 0.0;
                end
            end
        end
        
        function store_indexed_dynamic(obj, position, value)
            try
            obj.index_dynamic{obj.current_index, position} = value;
            catch e
                pause
                rethrow(e);
            end
        end
        
        function store_link_indexed_dynamic(obj, position, value)
             data = obj.link_index_dynamic(obj.current_link_index);
             data{position} = value;
             obj.link_index_dynamic(obj.current_link_index) = data;
        end
        
        function store_link_indexed_parameter(obj, position, value)
             if isempty(obj.current_link_index)
                 error('Link index not set');
             end
             data = obj.link_index_parameter(obj.current_link_index);
             data{position} = value;
             if isempty(value)
                 xxx
             end
             obj.link_index_parameter(obj.current_link_index) = data;
        end        
        
        function store_indexed_gradient(obj, position, value)
            if ~all([obj.current_index position] <= size(obj.index_gradient))
                error('gradient index error');
            end
            obj.index_gradient{obj.current_index, position} = obj.index_gradient{obj.current_index, position} + value;
        end

    end
end