% SymbolTable is part of 'model' entity. It is related to the background
% framework used to run ATN Simulator, but does not directly reference the
% actual model being studied.
%
% SymbolTable is contains symbols for the model, their main storage 
% array index, their length and information about their location in the
% main storage arrays.
%
% Usage:
% > symbols = SymbolTable();
% > symbols.push('a', 1, 10);
% > symbols.push('b', 1, 20);
% > [array_idx, range] = symbols.get_range('b')
%   1 [11,12,13,14,15,16,17,18,19,20]
classdef SymbolTable < handle & matlab.mixin.CustomDisplay
    properties
        array_lengths % type: vector of integers
        array_names   % type: cell vector of strings

        lookup_map    % type: Containers.map Key: name, string Value: integer

        names         % type: cell vector of strings
        starts        % type: vector of integers
        ends          % type: vector of integers
        array_idx     % type: vector of integers
        
    end
    methods (Access = protected)
      function displayScalarObject(obj)
          tbl = {};
          for k=1:numel(obj.starts)
              tbl{k,1} = obj.array_names{obj.array_idx(k)};
              tbl{k,2} = obj.names{k};
              tbl{k,3} = obj.starts(k);
              tbl{k,4} = obj.ends(k);
          end
          cell2table(tbl,'VariableNames',{'Type','symbol','start_offset','end_offset'})
      end
   end
    methods
        function obj = SymbolTable()
           obj.array_lengths = [];
           obj.array_names = {'B','P','B_i','P_i','B_ij','P_ij'};

           obj.lookup_map = containers.Map;
           obj.names = {};
           obj.starts = [];
           obj.ends = [];
        end

        function A = deepcopy(obj)
            A = SymbolTable();
            A.array_lengths = obj.array_lengths;
            A.array_names = obj.array_names;
            A.lookup_map = containers.Map(obj.lookup_map.keys, obj.lookup_map.values);
            A.names = obj.names;
            A.starts = obj.starts;
            A.ends = obj.ends;
            A.array_idx = obj.array_idx;
        end
        
        function name = get_name_by_id(obj, array_index, id)
            for i=1:numel(obj.starts)
                if obj.array_idx(i) == array_index
                    id = id-1;
                end
                if id == 0
                    name = obj.names{i};
                    return
                end
            end
            name = 'N/A';
        end

        function value = has_symbol(obj, symbol)
            value = isKey(obj.lookup_map, symbol);
        end

        function start_idx = get_start_idx(obj, symbol)
            symbol_idx = obj.lookup_map(symbol);
            start_idx = obj.starts(symbol_idx);
        end
        
        function info = get_info(obj, symbol)
            if ~isKey(obj.lookup_map, symbol)
                info = [];
                return
            end
            idx = obj.lookup_map(symbol);
            info = [ obj.array_names(obj.array_idx(idx)) obj.starts(idx) obj.ends(idx) ];
        end
        
        function show_namespace(obj, ns)
            tbl={};
          for k=1:numel(obj.starts)
              arr_idx = obj.array_idx(k);
              tbl{k,1} = obj.array_names{arr_idx};
              tbl{k,2} = obj.names{k};
              tbl{k,3} = obj.starts(k);
              array = ns{arr_idx};
              if numel(array) >= obj.starts(k)
                  tbl{k,4} = sprintf('%g ', array{obj.starts(k)});
              else
                  tbl{k,4} = 'N/A';
              end
          end
          if ~isempty(tbl)
            cell2table(tbl,'VariableNames',{'Type','symbol','Offset','VALUE'})
          end
        end

        function symbol_info_list = resolve(obj, symbol_list)
            symbol_info_list={};
            for i=1:numel(symbol_list)
                symbol_info_list{i} = obj.get_info(symbol_list(i).symbol);
            end
        end
        
        function count = get_size(obj, array_index)
            if array_index > numel(obj.array_lengths)
                count = 0;
                return
            end
            count = obj.array_lengths(array_index);
        end

        function start_pos = push(obj, name, array_index, data_size)
            if strcmp(name,'feedingrate_ij')
                1
            end
            if numel(obj.array_lengths)<array_index
                assert(isnumeric(array_index));
                assert(array_index<100);
                obj.array_lengths(array_index) = 0;
            end
            idx = obj.array_lengths(array_index);
            pos = numel(obj.starts)+1;
            obj.lookup_map(name)=pos;
            obj.array_idx(pos) = array_index;
            obj.starts(pos) = idx+1; % Inclusive start
            obj.ends(pos) = idx+data_size; % Inclusive end
            obj.names{pos} = name;
            obj.array_lengths(array_index) = idx + data_size;
            start_pos = idx+1;
        end
        
    end
end
