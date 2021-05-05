classdef Compiler < handle
    properties (Constant)
        NO_OPERATION = 0x00;
        LOAD_CONSTANT_8 = 0x01; % int8 parameter
        ADD_OPERATOR = 0x02;
        SUB_OPERATOR = 0x03;
        MUL_OPERATOR = 0x04;
        DIV_OPERATOR = 0x05;
        POW_OPERATOR = 0x06;
        UNARY_MINUS = 0x07;
        LOAD_DYNAMIC = 0x12; % int16 parameter
        LOAD_PARAMETER = 0x13; % int16 parameter
        
        LOAD_CONSTANT_16 = 0x20; % int16 parameter
        STORE_DYNAMIC = 0x22; % int16 parameter
        STORE_PARAMETER = 0x23; % int16 parameter
        STORE_GRADIENT = 0x24; % int16 parameter

        LOAD_CONSTANT_32 = 0x40; % int32 parameter
        BUILTIN_LOGNORMAL=0x44;
        BUILTIN_RAND=0x45;
        BUILTIN_SWITCH=0x46;
        BUILTIN_EXP=0x47;
        BUILTIN_LN=0x48;
        BUILTIN_WT=0x49;
        BUILTIN_T=0x50;
        BUILTIN_t=0x51;
        
        BUILD_ARRAY = 0x50; % int16 parameter
        VECTOR_SUM = 0x51;
        PRINT = 0x70;
        HORZCAT = 0x71;
        BUILTIN_FUNCTION = 0x80;
        DUPLICATE_STACK = 0x81;
        
        DOUBLE_LINK_INDEXED_DYNAMIC_COUNT = 0x82; % int32 parameter
        STORE_LINK_INDEXED_GRADIENT = 0x83; % int32 parameter
        
        
        ENCODE_STRING = 0x9F;

        STORE_GRADIENT_BY_IDX_1 = 0xC0;
        STORE_GRADIENT_BY_IDX_2 = 0xC1;
        STORE_GRADIENT_BY_IDX_3 = 0xC2;

        LOAD_PARAMETER_BY_IDX_1 = 0xC3;
        LOAD_PARAMETER_BY_IDX_2 = 0xC4;
        LOAD_PARAMETER_BY_IDX_3 = 0xC5;
        
        ADD_INDEXED_PARAMETER = 0xC6;

        ADD_PARAMETER_BY_IDX_1 = 0xC7;
        ADD_PARAMETER_BY_IDX_2 = 0xC8;
        ADD_PARAMETER_BY_IDX_3 = 0xC9;

        STORE_PARAMETER_BY_IDX_1 = 0xCA;
        STORE_PARAMETER_BY_IDX_2 = 0xCB;
        STORE_PARAMETER_BY_IDX_3 = 0xCC;
        
        DISPLAY = 0xCD;
        
        TAG_COUNT = 0xCE;
        
        LOAD_DYNAMIC_BY_IDX_1 = 0xD0;
        LOAD_DYNAMIC_BY_IDX_2 = 0xD1;
        LOAD_DYNAMIC_BY_IDX_3 = 0xD2;
        LINK_JUMP = 0xD3;
        STORE_LINK_INDEXED_PARAMETER = 0xD4; % int32
        LOAD_LINK_INDEXED_PARAMETER = 0xD5; % int32
        LINK_LOOP = 0xD6;
        STORE_LINK_INDEXED_DYNAMIC = 0xD7; % int32
        NEW_LINK_INDEXED = 0xD8; % no immediate parameters (they are larger after opcode)

        DOUBLE_LINK_INDEXED_PARAMETER_COUNT = 0xD9; % int32 parameter
        SUM_LOOP = 0xDA; % int8 parameter
        SUM_JUMP = 0xDB; % int32 parameter
        INDEX_JUMP = 0xDC; % int32 parameter
        LOAD_INDEXED_PARAMETER = 0xDD; % int32 parameter
        LOAD_INDEXED_DYNAMIC = 0xDE; % int32 parameter
      
        INDEX_LOOP = 0xDF; % int8
        DOUBLE_CONSTANT_COUNT = 0xE0; % int32 parameter
        ENTRY_COUNT = 0xE1; % int16 parameter
        DOUBLE_DYNAMIC_COUNT = 0xE2; % int32 parameter
        DOUBLE_PARAMETER_COUNT = 0xE3; % int32 parameter
        CLASS_COUNT = 0xE4; % int16 parameter (Total number of classes)
        CREATE_CLASS = 0xE5;
        NODEDEF_COUNT = 0xE6; % int16 parameter (Total number of nodes)
        INDEX_AS = 0xE7; % int8 parameter
        DOUBLE_INDEX_DYNAMIC_COUNT = 0xE8; % int32 parameter
        DOUBLE_INDEX_PARAMETER_COUNT = 0xE9; % int32 parameter
        CREATE_NODEDEF = 0xEA; % int32 parameter
        DEPLOY = 0xEB; % int16 parameter
        NEW_INDEXED = 0xEC; % int8 paramter
        STORE_INDEXED_PARAMETER = 0xED; % int32 parameter
        STORE_INDEXED_DYNAMIC = 0xEE; % int32 parameter
        STORE_INDEXED_GRADIENT = 0xEF; % int32 parameter


        NEW_INSTANCE = 0xF0; % int16 paramter
        ENTER_LAMBDA = 0xF1;
        EXIT_LAMBDA = 0xF2;
        CALL_ENTRY = 0xF3;
        
        END_DEPLOY = 0xFE;
        RET = 0xFF;

        INFO_NEW_ENTRY = 0x100;
        INFO_PUSH_STREAM = 0x101;
        INFO_PTR_TO_BE_BACKFILLED = 0x102;
        INFO_BACKFILL_CURRENT_PTR = 0x103;
        INFO_PUSH_PTR = 0x104;
        
 
        %              0 1 2 3 4 5 6 7 8 9 A B C D E F
        PAR_COUNTS = [ 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ... % 00..0F  
                       0 0 2 2 0 0 0 0 0 0 0 0 0 0 0 0 ... % 10..1F
                       2 0 2 2 2 0 0 0 0 0 0 0 0 0 0 0 ... % 20..2F
                       0 0 2 2 0 0 0 0 0 0 0 0 0 0 0 0 ... % 30..3F
                       4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ... % 40..4F
                       2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ... % 50..5F
                       0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ... % 60..6F
                       1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ... % 70..7F
                       2 2 4 4 0 0 0 0 0 0 0 0 0 0 0 0 ... % 80..8F
                       0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ... % 90..9F
                       0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ... % A0..AF
                       0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ... % B0..BF
                       4 4 4 4 4 4 4 4 4 4 4 4 4 0 4 0 ... % C0..CF
                       4 4 4 4 4 4 0 4 0 4 1 4 4 4 4 1 ... % D0..DF
                       4 2 4 4 2 0 2 1 4 4 0 2 4 4 4 4 ... % E0..EF
                       2 0 0 2 0 0 0 0 0 0 0 0 0 0 0 0 ];  % F0..FF
                   
    end
    
    properties
        parser
        model
        
        
        opcodes 
        opdata
        optarget
        
        entries
        entry_names

        backfills
        
        forwardfills %  INFO_STORE_CURRENT_PTR = 0x104;  INFO_PUSH_STORED_PTR = 0x105;
        
        target
        header % Bytecode array
        definitions % Bytecode array
    end
    methods(Static)
        function stream = encode_STRING(s)
            if iscell(s)
                stream = cellfun(@(x) Compiler.encode_STRING(x), s, 'UniformOutput',false);
                stream = [ stream{:} ];
                return
            end
            stream = [ Compiler.ENCODE_STRING cast(numel(s),'uint8') uint8(s) ];
        end

        function str = encode_NEW_LINK_INDEXED(cls1, idx1, cls2, idx2, cls3, idx3)
            str = [ uint8(Compiler.NEW_LINK_INDEXED) uint8(cls1) uint8(idx1) uint8(cls2) uint8(idx2) uint8(cls3) uint8(idx3) ]; 
        end
        
        
        function stream = encode_OPCODE(op, parameter)
            stream = zeros(0,0,'uint8');
            stream = [stream cast(op,'uint8') ];
            parameter_size = Compiler.PAR_COUNTS(op+1);
            % Cast the parameter data to uint8 array
            if nargin < 2
                return
            end
            if numel(parameter)>=0
                casted_data = typecast(cast(parameter,'uint32'), 'uint8');
                % Make sure there is no truncation of bytes
                assert(all(casted_data(parameter_size+1:end)==0));
               
                % Push the parameter
                stream = [ stream casted_data(1:parameter_size); ];
            end
        end
        
        function stream = encode_DOUBLE(value)
            value = double(value);
            stream = typecast(value, 'uint8');
        end
                
                
        
        function name = get_name_by_opcode(op)
                switch op
                    case Compiler.DOUBLE_CONSTANT_COUNT
                        name = 'DOUBLE_CONSTANT_COUNT';
                    case Compiler.DOUBLE_DYNAMIC_COUNT
                        name = 'DOUBLE_DYNAMIC_COUNT';
                    case Compiler.DOUBLE_PARAMETER_COUNT
                        name = 'DOUBLE_PARAMETER_COUNT';
                    case Compiler.ENTRY_COUNT
                        name = 'ENTRY_COUNT';
                    case Compiler.TAG_COUNT
                        name = 'TAG_COUNT';
                    case Compiler.LOAD_CONSTANT_8
                        name = 'LOAD_CONSTANT_8';
                    case Compiler.LOAD_DYNAMIC
                        name = 'LOAD_DYNAMIC';
                    case Compiler.LOAD_PARAMETER
                        name = 'LOAD_PARAMETER';
                    case Compiler.STORE_PARAMETER
                        name = 'STORE_PARAMETER';
                    case Compiler.STORE_DYNAMIC
                        name = 'STORE_DYNAMIC';
                    case Compiler.STORE_GRADIENT
                        name = 'STORE_GRADIENT';
                    case Compiler.ADD_OPERATOR
                        name = 'ADD_OPERATOR';
                    case Compiler.SUB_OPERATOR
                        name = 'SUB_OPERATOR';
                    case Compiler.MUL_OPERATOR
                        name = 'MUL_OPERATOR';
                    case Compiler.DIV_OPERATOR
                        name = 'DIV_OPERATOR';
                    case Compiler.POW_OPERATOR
                        name = 'POW_OPERATOR';
                    case Compiler.UNARY_MINUS
                        name = 'UNARY_MINUS';
                    case Compiler.BUILD_ARRAY
                        name = 'BUILD_ARRAY';
                    case Compiler.VECTOR_SUM
                        name = 'VECTOR_SUM';
                    case Compiler.PRINT
                        name = 'PRINT';
                    case Compiler.HORZCAT
                        name = 'HORZCAT';
                    case Compiler.RET
                        name = 'RET';
                    case Compiler.CLASS_COUNT
                        name = 'CLASS_COUNT';
                    case Compiler.CREATE_CLASS
                        name = 'CREATE_CLASS';
                    case Compiler.NEW_INSTANCE
                        name = 'NEW_INSTANCE';
                    case Compiler.ENTER_LAMBDA
                        name = 'ENTER_LAMBDA';
                    case Compiler.EXIT_LAMBDA
                        name = 'EXIT_LAMBDA';
                    case Compiler.CALL_ENTRY
                        name = 'CALL_ENTRY';
                    case Compiler.BUILTIN_FUNCTION
                        name = 'BUILTIN_FUNCTION';
                    case Compiler.DUPLICATE_STACK
                        name = 'DUPLICATE_STACK';
                    case Compiler.ENCODE_STRING
                        name = 'ENCODE_STRING';
                    case Compiler.NODEDEF_COUNT
                        name = 'NODEDEF_COUNT';
                    case Compiler.INDEX_AS
                        name = 'INDEX_AS';
                    case Compiler.DOUBLE_INDEX_DYNAMIC_COUNT 
                        name = 'DOUBLE_INDEX_DYNAMIC_COUNT';
                    case Compiler.DOUBLE_INDEX_PARAMETER_COUNT
                        name = 'DOUBLE_INDEX_PARAMETER_COUNT';
                    case Compiler.DOUBLE_INDEX_DYNAMIC_COUNT
                        name = 'DOUBLE_INDEX_DYNAMIC_COUNT';
                    case Compiler.CREATE_NODEDEF
                        name = 'CREATE_NODEDEF';
                    case Compiler.DEPLOY
                        name = 'DEPLOY';
                    case Compiler.NEW_INDEXED
                        name = 'NEW_INDEXED';
                    case Compiler.NEW_LINK_INDEXED
                        name = 'NEW_LINK_INDEXED';
                    case Compiler.STORE_INDEXED_PARAMETER
                        name = 'STORE_INDEXED_PARAMETER';
                    case Compiler.ADD_INDEXED_PARAMETER
                        name = 'ADD_INDEXED_PARAMETER';
                    case Compiler.STORE_INDEXED_DYNAMIC
                        name = 'STORE_INDEXED_DYNAMIC';
                    case Compiler.STORE_INDEXED_GRADIENT
                        name = 'STORE_INDEXED_GRADIENT';
                    case Compiler.STORE_LINK_INDEXED_GRADIENT
                        name = 'STORE_LINK_INDEXED_GRADIENT';
                    case Compiler.END_DEPLOY
                        name = 'END_DEPLOY';
                    case Compiler.INDEX_LOOP
                        name = 'INDEX_LOOP';
                    case Compiler.LOAD_INDEXED_PARAMETER
                        name = 'LOAD_INDEXED_PARAMETER';
                    case Compiler.LOAD_INDEXED_DYNAMIC
                        name = 'LOAD_INDEXED_DYNAMIC';
                    case Compiler.INDEX_JUMP
                        name = 'INDEX_JUMP';
                    case Compiler.SUM_JUMP
                        name = 'SUM_JUMP';
                    case Compiler.SUM_LOOP
                        name = 'SUM_LOOP';
                    case Compiler.DOUBLE_LINK_INDEXED_PARAMETER_COUNT
                        name = 'DOUBLE_LINK_INDEXED_PARAMETER_COUNT';
                    case Compiler.DOUBLE_LINK_INDEXED_DYNAMIC_COUNT
                        name = 'DOUBLE_LINK_INDEXED_DYNAMIC_COUNT';
                    case Compiler.STORE_GRADIENT_BY_IDX_1
                        name = 'STORE_GRADIENT_BY_IDX_1';
                    case Compiler.STORE_GRADIENT_BY_IDX_2
                        name = 'STORE_GRADIENT_BY_IDX_2';
                    case Compiler.STORE_GRADIENT_BY_IDX_3
                        name = 'STORE_GRADIENT_BY_IDX_3';
                    case Compiler.LOAD_DYNAMIC_BY_IDX_1
                        name = 'LOAD_DYNAMIC_BY_IDX_1';
                    case Compiler.LOAD_DYNAMIC_BY_IDX_2
                        name = 'LOAD_DYNAMIC_BY_IDX_2';
                    case Compiler.LOAD_DYNAMIC_BY_IDX_3
                        name = 'LOAD_DYNAMIC_BY_IDX_3';
                    case Compiler.LOAD_PARAMETER_BY_IDX_1
                        name = 'LOAD_PARAMETER_BY_IDX_1';
                    case Compiler.LOAD_PARAMETER_BY_IDX_2
                        name = 'LOAD_PARAMETER_BY_IDX_2';
                    case Compiler.LOAD_PARAMETER_BY_IDX_3
                        name = 'LOAD_PARAMETER_BY_IDX_3';
                    case Compiler.STORE_PARAMETER_BY_IDX_1
                        name = 'STORE_PARAMETER_BY_IDX_1';
                    case Compiler.STORE_PARAMETER_BY_IDX_2
                        name = 'STORE_PARAMETER_BY_IDX_2';
                    case Compiler.STORE_PARAMETER_BY_IDX_3
                        name = 'STORE_PARAMETER_BY_IDX_3';
                    case Compiler.DISPLAY
                        name = 'DISPLAY';
                    case Compiler.ADD_PARAMETER_BY_IDX_1
                        name = 'ADD_PARAMETER_BY_IDX_1';
                    case Compiler.ADD_PARAMETER_BY_IDX_2
                        name = 'ADD_PARAMETER_BY_IDX_2';
                    case Compiler.ADD_PARAMETER_BY_IDX_3
                        name = 'ADD_PARAMETER_BY_IDX_3';
                    case Compiler.LINK_JUMP
                        name = 'LINK_JUMP';
                    case Compiler.STORE_LINK_INDEXED_PARAMETER
                        name = 'STORE_LINK_INDEXED_PARAMETER';
                    case Compiler.LINK_LOOP
                        name = 'LINK_LOOP';
                    case Compiler.STORE_LINK_INDEXED_DYNAMIC
                        name = 'STORE_LINK_INDEXED_DYNAMIC';
                     otherwise
                        name = sprintf('UNKNOWN_OPCODE_%x', op);
                end
            end
        
        function disassembler(code, model, error_address, error_message)
            if nargin<=1
                model=[];
            end
            fprintf('.load\n');
            ptr = uint32(1);
            class_names = {};
            class_names_remaining = 0;
            entry_names = {};
            dynamic_names = {};
            dynamic_names_remaining = 0;
            entry_points = zeros(0,0,'uint32');
            parameter_names = {};
            parameter_names_remaining = 0;
            tags_remaining = 0;
            tag_names = {};
            while 1
                ip_start = ptr;
                entry_idx = find(entry_points == ptr);
                if ~isempty(entry_idx)
                    fprintf('%s:\n', entry_names{entry_idx});
                end
                fprintf('    %04x ', ptr);
                if (ptr > numel(code))
                    fprintf('    <EOF>\n');
                    break;
                end
                    
                op = code(ptr); ptr = ptr + 1;
                parameter_size = Compiler.PAR_COUNTS(op+1);
                opname = Compiler.get_name_by_opcode(op);
                if parameter_size == 0
                    data = [];
                elseif parameter_size == 1
                    data = code(ptr); ptr = ptr + 1;
                elseif parameter_size == 2
                    data = typecast(code(ptr:ptr+1),'uint16'); ptr = ptr + 2;
                elseif parameter_size == 4
                    data = typecast(code(ptr:ptr+3),'uint32'); ptr = ptr + 4;
                else
                    error('Internal error.');
                end
                  
                switch op
                    case Compiler.DOUBLE_CONSTANT_COUNT
                        count = data;
                        fprintf('%s: %d\n', opname, data);
                        constants = zeros(1, count);
                        for i=1:count
                            constants(i) = typecast(code(ptr:ptr+7),'double'); ptr = ptr + 8;
                            fprintf('     %%%d = %.15g', i,constants(i)); 
                            if i<count
                                fprintf('\n');
                            end
                        end
                    case Compiler.DOUBLE_DYNAMIC_COUNT
                        fprintf('%s: %d', opname, data);
                        dynamic_names_remaining = data;
                        %for i=1:data
                        %    strlen = cast(code(ptr),'uint32'); ptr = ptr + 1;
                        %    dynamic_names{i} = code(ptr:ptr+strlen-1);
                        %    fprintf('     @%d = %s\n', i, dynamic_names{i}); ptr = ptr + strlen;
                        %end
                        
                    case Compiler.DOUBLE_PARAMETER_COUNT
                        fprintf('%s: %d', opname, data);
                        parameter_names_remaining = data;
                        %for i=1:data
                        %    strlen = cast(code(ptr),'uint32'); ptr = ptr + 1;
                        %    parameter_names{i} = code(ptr:ptr+strlen-1);
                        %    fprintf('     #%d = %s\n', i, parameter_names{i}); ptr = ptr + strlen;
                        %end
                    case Compiler.TAG_COUNT
                        fprintf('%s: %d', opname, data);
                        tags_remaining = data;
                        
                    case Compiler.ENTRY_COUNT
                        fprintf('%s: %d\n', opname, data);
                        for i=1:data
                            entry_points(end+1) = typecast(code(ptr:ptr+3),'uint32');
                            fprintf('     %04x:', entry_points(end)); ptr = ptr + 4;
                            assert(code(ptr)==Compiler.ENCODE_STRING); ptr = ptr +1;
                            strlen = cast(code(ptr),'uint32'); ptr = ptr + 1;
                            entry_names{end+1} = code(ptr:ptr+strlen-1);
                            fprintf('%s', entry_names{end}); ptr = ptr + strlen;
                            if i<data
                                fprintf('\n');
                            end
                        end
                    case Compiler.LOAD_CONSTANT_8
                        if numel(constants)>=data
                            fprintf('  %s: %%%x (=%g)', opname, data, constants(data));
                        else
                            fprintf('  %s: %%%x (=%s)', opname, data, 'OUT OF RANGE');
                        end
                            
                    case Compiler.LOAD_DYNAMIC
                        if numel(dynamic_names)>=data
                           fprintf('  %s: @%d (=%s)', opname, data, dynamic_names{data});
                        else
                           fprintf('  %s: @%d (=%s)', opname, data, 'OUT OF RANGE');
                        end
                            
                    case Compiler.LOAD_PARAMETER
                        fprintf('  %s: #%x (=%s)', opname, data, parameter_names{data});
                    case Compiler.STORE_PARAMETER
                        if numel(parameter_names)>=data
                           fprintf('  %s: @%d (=%s)', opname, data, parameter_names{data});
                        else
                           fprintf('  %s: @%d (=%s)', opname, data, 'OUT OF RANGE');
                        end
                    case Compiler.STORE_DYNAMIC
                        fprintf('  %s: @%d (=%s)', opname, data, dynamic_names{data});
                    case Compiler.STORE_GRADIENT
                        fprintf('  %s: @%d (=%s)', opname, data, dynamic_names{data});
                    case Compiler.BUILD_ARRAY
                        fprintf('  BUILD_ARRAY: %d', data);
                    case Compiler.VECTOR_SUM
                        fprintf('  VECTOR_SUM');
                    case Compiler.PRINT
                        fprintf('  PRINT: %d', data);
                    case Compiler.HORZCAT
                        fprintf('  HORZCAT: %d', data);
                    case Compiler.RET
                        fprintf('  RET');
                    case Compiler.ENCODE_STRING
                        strlen = cast(data,'uint32');
                        s = code(ptr:ptr+strlen-1); ptr = ptr + strlen;
                        fprintf('    "%s"',s);
                        if parameter_names_remaining > 0
                            parameter_names{end+1} = s;
                            parameter_names_remaining = parameter_names_remaining-1;
                        elseif dynamic_names_remaining > 0
                            dynamic_names{end+1} = s;
                            dynamic_names_remaining = dynamic_names_remaining-1;
                        elseif class_names_remaining > 0
                            class_names{end+1} = s;
                            class_names_remaining = class_names_remaining-1;
                        elseif tags_remaining > 0
                            tag_names{end+1} = s;
                            tags_remaining = tags_remaining-1;
                        else
                            fprintf('   !UNEXPECTED');
                        end
                    case Compiler.CLASS_COUNT
                        fprintf('  CLASS_COUNT: %d', data);
                        class_names_remaining = data;
                    case Compiler.CREATE_CLASS
                        fprintf('  CREATE_CLASS');
                    case Compiler.NEW_INSTANCE
                        fprintf('  NEW_INSTANCE: %d', data);
                    case Compiler.CALL_ENTRY
                        fprintf('  CALL_ENTRY: %d', data);
                    case Compiler.BUILTIN_FUNCTION
                        fprintf('  BUILTIN_FUNCTION: %d', data);
                    case Compiler.DUPLICATE_STACK
                        fprintf('  DUPLICATE_STACK: %d', data);
                    case Compiler.NEW_LINK_INDEXED
                        fprintf('  NEW_LINK_INDEXED:');
                        bytes = code(ptr:ptr+5);
                        ptr = ptr + 6;
                        fprintf('%02x ', bytes);
                        fprintf('\n');
                    otherwise
                        fprintf('  %s', opname);
                        if parameter_size > 0
                            fprintf(' %02x (?)', data);
                        end
                end
                if nargin > 2
                   if ip_start == error_address
                       fprintf('<-- %s', error_message);
                   end
                end
                fprintf('\n');
            end
        end
    end

    methods
        function obj = Compiler(parser)
            if nargin<1
               parser = [];
            end
            if isa(parser,'Parser')
                try
                    obj.model = parser.parse_MODULE();
                catch e
                    if e.message(1) == '@'
                        %rethrow(e);
                        token_ptr = str2num(e.message(2:7));
                        parser.tokenizer.error_at_token(token_ptr, e.message(9:end));
                    else
                       rethrow(e);
                    end
                end
            elseif startsWith(class(parser), 'SE')
               obj.model = parser;
            elseif isempty(parser)
            else
               error(sprintf('Invalid input to parser. class type %s.',class(parser)));
            end
            obj.parser = parser;
            obj.opcodes =[];
            obj.opdata ={};
            obj.entry_names = {};
            obj.backfills = 0;
        end
        
        function error(obj, message, token_ptr)
            obj.parser.error(message, token_ptr);
        end

        function ptr = get_entry_placeholder(obj)
             ptr = uint32(0);
        end
        
        function push_reference_lookup(obj, symbol)
            info = obj.model.symboltable.get_info(symbol);
            if isempty(info)
                obj.parser.tokenizer.buffer.error(obj.parser.tokenizer.peek_position(), sprintf('Undefined symbol ''%s''.', symbol));
            end
            [symbol_tbl, start_idx, end_idx] = info{:};
            if symbol_tbl == 'P'
                obj.LOAD_PARAMETER_OPCODE(start_idx);
            elseif symbol_tbl == 'B'
                obj.LOAD_DYNAMIC_OPCODE(start_idx);
            else
                error('Internal error.');
            end
        end
        
        function OPCODE(obj, opcode, opdata)
            obj.opcodes(end+1)=opcode;
            obj.opdata{end+1}=uint64(opdata);
        end

        function backfill_id = push_PTR_TO_BE_BACKFILLED(obj)
            obj.backfills = obj.backfills+1;
            backfill_id = obj.backfills;
            obj.INFO_OPCODE(Compiler.INFO_PTR_TO_BE_BACKFILLED, backfill_id);
        end

        function INFO_OPCODE(obj, opcode, opdata)
            obj.opcodes(end+1)=opcode;
            obj.opdata{end+1}=opdata;
        end
        
        
        function code = get_byte_code(obj)
            code = zeros(1, 10000, 'uint8');
            ptr = 1;
            %obj.model.byte_compile(obj);
            opcodes = obj.opcodes;
            opdata = obj.opdata;
            backfill_addresses=zeros(0,0,'uint32');
            for i=1:numel(obj.opcodes)
                op = obj.opcodes(i);
                data = obj.opdata{i};
                switch op
                    case Compiler.INDEX_JUMP
                        data = backfill_addresses(data);
                    case Compiler.SUM_JUMP
                        data = backfill_addresses(data);
                    case Compiler.LINK_JUMP
                        data = backfill_addresses(data);
                end
                if op >= 0x100 % INFO
                    switch op
                        case Compiler.INFO_NEW_ENTRY
                            xxx % obsolete
                            entry_ptr = entry_lookup_address(data);
                            % Backfill current entry-point to entry lookup table
                            code(entry_ptr:entry_ptr+3) = typecast(uint32(ptr), 'uint8');
                        case Compiler.INFO_PUSH_STREAM
                           code(ptr:ptr+numel(data)-1) = data;
                           ptr = ptr + numel(data);
                        case Compiler.INFO_PTR_TO_BE_BACKFILLED
                           %fprintf('INFO_PTR_TO_BE_BACKFILLED %d %04x', data, ptr);
                           backfill_addresses(data)=uint32(ptr);
                        case Compiler.INFO_BACKFILL_CURRENT_PTR
                           address = backfill_addresses(data);
                           %fprintf('INFO_BACKFILL_CURRENT_PTR code(%04x)=%04x', address, ptr);
                           code(address:address+3) = typecast(uint32(ptr),'uint8');
                        case Compiler.INFO_PUSH_PTR
                            code(ptr:ptr+3) = typecast(uint32(backfill_addresses(data)),'uint8'); ptr = ptr +4;
                    otherwise
                            error('Internal error.');
                    end
                else
                % Push the opcode
                code(ptr) = uint8(op); ptr = ptr + 1;
                
                % Determine the size of the parameter
                parameter_size = Compiler.PAR_COUNTS(op+1);
                % Cast the parameter data to uint8 array
                if numel(data)>=0
                casted_data = typecast(data, 'uint8');
                % Make sure there is no truncation of bytes
                assert(all(casted_data(parameter_size+1:end)==0));
                
                % Push the parameter
                code(ptr:ptr+parameter_size-1) = casted_data(1:parameter_size); ptr = ptr + parameter_size;
                end
                end
            end
            code = code(1:ptr-1);
        end
        
       function compile(obj)
           fprintf('Compiling..');
           try
              obj.model.byte_compile(obj);
           catch e
               if e.message(1) == '@'
                   rethrow(e);
                   token_ptr = str2num(e.message(2:7));
                   obj.parser.tokenizer.error_at_token(token_ptr, e.message(9:end));
               else
                   rethrow(e);
               end
           end
       end
        
       function NEW_ENTRY_OPINFO(obj, name)
           obj.entries(end+1)= 0; % Backfilled later
           obj.entry_names{end+1} = name;
           obj.OPCODE(Compiler.INFO_NEW_ENTRY,numel(obj.entry_names));
       end

        % Add arbitrary uint8 stream to code
        function push_STREAM(obj, stream)
           obj.INFO_OPCODE(Compiler.INFO_PUSH_STREAM, stream);
        end
       
        function UNARY_MINUS_OPCODE(obj)
            obj.OPCODE(Compiler.UNARY_MINUS, 0);
        end
        
        function RET_OPCODE(obj)
            obj.OPCODE(Compiler.RET, 0);
        end

        function ENTER_LAMBDA_OPCODE(obj)
            obj.OPCODE(Compiler.ENTER_LAMBDA, 0);
        end

        function EXIT_LAMBDA_OPCODE(obj)
            obj.OPCODE(Compiler.EXIT_LAMBDA, 0);
        end

        function LOAD_PARAMETER_OPCODE(obj, idx)
            obj.OPCODE(Compiler.LOAD_PARAMETER, idx);
        end
        
        function LOAD_INDEXED_PARAMETER_OPCODE(obj, idx)
            obj.OPCODE(Compiler.LOAD_INDEXED_PARAMETER, idx);
        end

        function NEW_INSTANCE_OPCODE(obj, idx)
            obj.OPCODE(Compiler.NEW_INSTANCE, idx);
        end
        
        function STORE_PARAMETER_OPCODE(obj, idx)
            obj.OPCODE(Compiler.STORE_PARAMETER, uint32(idx));
        end

        function STORE_INDEXED_PARAMETER_OPCODE(obj, idx)
            obj.OPCODE(Compiler.STORE_INDEXED_PARAMETER, uint32(idx));
        end
        
       function ADD_INDEXED_PARAMETER_OPCODE(obj, idx)
            obj.OPCODE(Compiler.ADD_INDEXED_PARAMETER, uint32(idx));
        end        
        
        function STORE_INDEXED_DYNAMIC_OPCODE(obj, idx)
            obj.OPCODE(Compiler.STORE_INDEXED_DYNAMIC, uint32(idx));
        end        
        
        function STORE_LINK_INDEXED_DYNAMIC_OPCODE(obj, idx)
            obj.OPCODE(Compiler.STORE_LINK_INDEXED_DYNAMIC, uint32(idx));
        end           
        
        function CALL_ENTRY_OPCODE(obj, idx)
            obj.OPCODE(Compiler.CALL_ENTRY, uint32(idx));
        end
        
        function NEW_INDEXED_OPCODE(obj)
            obj.OPCODE(Compiler.NEW_INDEXED, 1); % TODO;: There could be more indices at some point
        end
        
        function NEW_LINK_INDEXED_OPCODE(obj)
            obj.OPCODE(Compiler.NEW_LINK_INDEXED,0); 
        end

        function STORE_DYNAMIC_OPCODE(obj, dynamic_table_id)
            obj.OPCODE(Compiler.STORE_DYNAMIC, uint32(dynamic_table_id));
        end

        function LOAD_REFERENCE_BY_INFO(obj, info)
            if isempty(info)
                error('Unkown reference');
            end
            [ name, idx, ~ ] = info{:};
            if strcmp(name, 'B')
                obj.LOAD_DYNAMIC_OPCODE(idx);
            elseif strcmp(name,'P')
                obj.LOAD_PARAMETER_OPCODE(idx);
            elseif strcmp(name, 'B_i')
                obj.LOAD_INDEXED_DYNAMIC_OPCODE(idx);
            elseif strcmp(name,'P_i')
                obj.LOAD_INDEXED_PARAMETER_OPCODE(idx);
            elseif strcmp(name, '1B_i')
                obj.LOAD_DYNAMIC_BY_IDX_OPCODE(1, idx);
            elseif strcmp(name, '2B_i')
                obj.LOAD_DYNAMIC_BY_IDX_OPCODE(2, idx);
            elseif strcmp(name, '3B_i')
                obj.LOAD_DYNAMIC_BY_IDX_OPCODE(3, idx);
            elseif strcmp(name, '1P_i')
                obj.LOAD_PARAMETER_BY_IDX_OPCODE(1, idx);
            elseif strcmp(name, '2P_i')
                obj.LOAD_PARAMETER_BY_IDX_OPCODE(2, idx);
            elseif strcmp(name, '3P_i')
                obj.LOAD_PARAMETER_BY_IDX_OPCODE(3, idx);
            elseif strcmp(name, 'P_ij')
                obj.LOAD_LINK_INDEXED_PARAMETER_OPCODE(idx);
            elseif strcmp(name, 'B_ij')
                obj.LOAD_LINK_INDEXED_DYNAMIC_OPCODE(idx);
                
            else
                  error(sprintf('Invalid array name %s.', name));
            end
        end

        function ADD_REFERENCE_BY_INFO(obj, info)
            [ name, idx, ~ ] = info{:};
            if strcmp(name, 'B')
                xxx
                obj.LOAD_DYNAMIC_OPCODE(idx);
            elseif strcmp(name,'P')
                xxx
                obj.LOAD_PARAMETER_OPCODE(idx);
            elseif strcmp(name, 'B_i')
                xxxx
                obj.LOAD_INDEXED_DYNAMIC_OPCODE(idx);
            elseif strcmp(name,'P_i')
                xxx
                obj.LOAD_INDEXED_PARAMETER_OPCODE(idx);
            elseif strcmp(name, '1B_i')
                xxx
                obj.LOAD_DYNAMIC_BY_IDX_OPCODE(1, idx);
            elseif strcmp(name, '2B_i')
                %xxx
                obj.LOAD_DYNAMIC_BY_IDX_OPCODE(2, idx);
            elseif strcmp(name, '3B_i')
                xxx
                obj.LOAD_DYNAMIC_BY_IDX_OPCODE(3, idx);
            elseif strcmp(name, '1P_i')
                obj.ADD_PARAMETER_BY_IDX_OPCODE(1, idx);
            elseif strcmp(name, '2P_i')
                obj.ADD_PARAMETER_BY_IDX_OPCODE(2, idx);
            elseif strcmp(name, '3P_i')
                xxx
                obj.LOAD_PARAMETER_BY_IDX_OPCODE(3, idx);
            elseif strcmp(name, 'P_ij')
                xxx
                obj.LOAD_LINK_INDEXED_PARAMETER_OPCODE(idx);
            elseif strcmp(name, 'B_ij')
                xxx
                obj.LOAD_LINK_INDEXED_DYNAMIC_OPCODE(idx);
            else
                  error(sprintf('Invalid array name %s.', name));
            end
        end
        
        
        function LOAD_LINK_INDEXED_PARAMETER_OPCODE(obj, index)
             obj.OPCODE(Compiler.LOAD_LINK_INDEXED_PARAMETER, uint32(index));
        end
        
        function STORE_LINK_INDEXED_PARAMETER_OPCODE(obj, index)
             obj.OPCODE(Compiler.STORE_LINK_INDEXED_PARAMETER, uint32(index));
        end
        
        function LOAD_LINK_INDEXED_DYNAMIC_OPCODE(obj, index)
             obj.OPCODE(Compiler.LOAD_LINK_INDEXED_DYNAMIC, uint32(index));
        end
        
        
        function LOAD_DYNAMIC_BY_IDX_OPCODE(obj, idx, index)
             obj.OPCODE(Compiler.LOAD_DYNAMIC_BY_IDX_1+idx-1, uint32(index));
        end
        
        function STORE_GRADIENT_BY_IDX_OPCODE(obj, idx, index)
             obj.OPCODE(Compiler.STORE_GRADIENT_BY_IDX_1+idx-1, uint32(index));
        end
        
        function LOAD_PARAMETER_BY_IDX_OPCODE(obj, idx, index)
             obj.OPCODE(Compiler.LOAD_PARAMETER_BY_IDX_1+idx-1, uint32(index));
        end

        function ADD_PARAMETER_BY_IDX_OPCODE(obj, idx, index)
             obj.OPCODE(Compiler.ADD_PARAMETER_BY_IDX_1+idx-1, uint32(index));
        end
        
        function STORE_PARAMETER_BY_IDX_OPCODE(obj, idx, index)
             obj.OPCODE(Compiler.STORE_PARAMETER_BY_IDX_1+idx-1, uint32(index));
        end
        
        function DISPLAY_OPCODE(obj)
             obj.OPCODE(Compiler.DISPLAY, 0);
        end
        
        function STORE_GRADIENT_OPCODE(obj, idx)
            %info = obj.model.symboltable.get_info(symbol);
            %[ name, idx, ~ ] = info{:};
            %assert(strcmp(name,'B'));
            obj.OPCODE(Compiler.STORE_GRADIENT, uint32(idx));
        end
        
        function STORE_INDEXED_GRADIENT_OPCODE(obj, idx)
            obj.OPCODE(Compiler.STORE_INDEXED_GRADIENT, uint32(idx));
        end
        
        function STORE_LINK_INDEXED_GRADIENT_OPCODE(obj, idx)
            obj.OPCODE(Compiler.STORE_LINK_INDEXED_GRADIENT, uint32(idx));
        end
        
        function LOAD_DYNAMIC_OPCODE(obj, idx)
            obj.OPCODE(Compiler.LOAD_DYNAMIC, idx);
        end
        
        function LOAD_INDEXED_DYNAMIC_OPCODE(obj, idx)
            obj.OPCODE(Compiler.LOAD_INDEXED_DYNAMIC, idx);
        end

        function CREATE_CLASS_OPCODE(obj)
            obj.OPCODE(Compiler.CREATE_CLASS, 0);
        end

        function BUILD_ARRAY_OPCODE(obj, length)
            obj.OPCODE(Compiler.BUILD_ARRAY, length);
        end
        
        function BUILTIN_FUNCTION_OPCODE(obj, id)
            obj.OPCODE(Compiler.BUILTIN_FUNCTION, id);
        end

        function CLASS_COUNT_OPCODE(obj, length)
            obj.OPCODE(Compiler.CLASS_COUNT, length);
        end

        function PARAMETER_COUNT_OPCODE(obj, length)
            obj.OPCODE(Compiler.DOUBLE_PARAMETER_COUNT, length);
        end

        function TAG_COUNT_OPCODE(obj, length)
            obj.OPCODE(Compiler.TAG_COUNT, length);
        end
        
        function DOUBLE_INDEX_PARAMETER_COUNT_OPCODE(obj, length)
            obj.OPCODE(Compiler.DOUBLE_INDEX_PARAMETER_COUNT, length);
        end        

        function DUPLICATE_STACK_OPCODE(obj, length)
            obj.OPCODE(Compiler.DUPLICATE_STACK, length);
        end

        function DYNAMIC_COUNT_OPCODE(obj, length)
            obj.OPCODE(Compiler.DOUBLE_DYNAMIC_COUNT, length);
        end
        
        function INDEXED_DYNAMIC_COUNT_OPCODE(obj, length)
            obj.OPCODE(Compiler.DOUBLE_INDEX_DYNAMIC_COUNT, length); % TODO: Names not matching
        end
        
        function LINK_INDEXED_PARAMETER_COUNT_OPCODE(obj, length)
            obj.OPCODE(Compiler.DOUBLE_LINK_INDEXED_PARAMETER_COUNT, length); % TODO: Names not matching
        end
        
        function LINK_INDEXED_DYNAMIC_COUNT_OPCODE(obj, length)
            obj.OPCODE(Compiler.DOUBLE_LINK_INDEXED_DYNAMIC_COUNT, length); % TODO: Names not matching
        end

        function ENTRY_COUNT_OPCODE(obj, length)
            obj.OPCODE(Compiler.ENTRY_COUNT, length);
        end

        function DOUBLE_CONSTANT_COUNT_OPCODE(obj, length)
            obj.OPCODE(Compiler.DOUBLE_CONSTANT_COUNT, length);
        end
        
        function VECTOR_SUM_OPCODE(obj)
            obj.OPCODE(Compiler.VECTOR_SUM, 0);
        end
        
        function END_DEPLOY_OPCODE(obj)
            obj.OPCODE(Compiler.END_DEPLOY, 0);
        end
        
        function DEPLOY_OPCODE(obj, data)
            obj.OPCODE(Compiler.DEPLOY, data);
        end        

        function NODEDEF_COUNT_OPCODE(obj, data)
            obj.OPCODE(Compiler.NODEDEF_COUNT, data);
        end
           
        
        function PRINT_OPCODE(obj, length)
            obj.OPCODE(Compiler.PRINT, length);
        end
        
        function INDEX_LOOP_OPCODE(obj, idx)
            obj.OPCODE(Compiler.INDEX_LOOP, idx);
        end
        
        function SUM_LOOP_OPCODE(obj, idx)
            obj.OPCODE(Compiler.SUM_LOOP, idx);
        end
        
        function LINK_LOOP_OPCODE(obj)
            obj.OPCODE(Compiler.LINK_LOOP,0);
        end            
        
        function LINK_JUMP_OPCODE(obj, idx)
            obj.OPCODE(Compiler.LINK_JUMP,idx);
        end            
        
        function INDEX_JUMP_OPCODE(obj, idx)
            obj.OPCODE(Compiler.INDEX_JUMP, idx); % Note, this is not the final data, but the index for backfill ptrs
        end
        
        function SUM_JUMP_OPCODE(obj, idx)
            obj.OPCODE(Compiler.SUM_JUMP, idx); % Note, this is not the final data, but the index for backfill ptrs
        end

        function HORZCAT_OPCODE(obj, length)
            obj.OPCODE(Compiler.HORZCAT, length);
        end         
        
        %function LOAD_CONSTANT_OPCODE(obj, constant)
        %    index = obj.add_constant(constant);
        %    if index <= 0xFF
        %       obj.OPCODE(Compiler.LOAD_CONSTANT_8, index); 
        %    elseif index <= 0xFFFF
        %        obj.OPCODE(Compiler.LOAD_CONSTANT_16, index); 
        %    else
        %        obj.OPCODE(Compiler.LOAD_CONSTANT_32, index); 
        %    end
        %end
        function LOAD_CONSTANT_OPCODE(obj, index)
            if index < 1
                 xxx
            end
            if index <= 0xFF
               obj.OPCODE(Compiler.LOAD_CONSTANT_8, index); 
            elseif index <= 0xFFFF
                obj.OPCODE(Compiler.LOAD_CONSTANT_16, index); 
            else
                obj.OPCODE(Compiler.LOAD_CONSTANT_32, index); 
            end
        end
        
        function BINARY_OPERATOR_OPCODE(obj, op)
            switch op
                case '+'
                    op = Compiler.ADD_OPERATOR;
                case '-'
                    op = Compiler.SUB_OPERATOR;
                case '*'
                    op = Compiler.MUL_OPERATOR;
                case '/'
                    op = Compiler.DIV_OPERATOR;
                case '^'
                    op = Compiler.POW_OPERATOR;
            end
            obj.OPCODE(op, []);
        end


    end
end