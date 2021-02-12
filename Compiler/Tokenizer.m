% The structure of the parser class is as follows
% 
% 1. Inline implementation of character buffer
% 2. Inline implementation of token buffer (reading from character buffer)
classdef Tokenizer < handle
    properties (Constant)
        TOKEN_NUMBER = 1;
        TOKEN_LITERAL = 2;
        TOKEN_STRING = 3;
        TOKEN_OPERATOR = 4;
        TOKEN_EOF = 5;
        OPERATORS = '#<>@[],(){};+-*/^=.';
    end
    properties
        log_level
        
        buffer
        
        
        ptr_stack
        token_ptr
        token_end_ptr
        token_types
        token_datas
        token_files
        token_file_positions
    end
    methods (Access=public)
        function obj = Tokenizer(buffer)
            obj.log_level = 0;
            obj.buffer = buffer;
            obj.token_types = [];
            obj.token_datas = {};
            obj.token_files = {};
            obj.token_file_positions = {};
            obj.tokenize();
            obj.token_ptr = 1;
            obj.token_end_ptr = numel(obj.token_types)+1;
        end
        
        function nest(obj, tokenizer2)
            obj.token_types = [ obj.token_types(1:obj.token_ptr-1) tokenizer2.token_types obj.token_types(obj.token_ptr:end) ];
            obj.token_datas = [ obj.token_datas(1:obj.token_ptr-1) tokenizer2.token_datas obj.token_datas(obj.token_ptr:end) ];
            obj.token_files = [ obj.token_files(1:obj.token_ptr-1) tokenizer2.token_files obj.token_files(obj.token_ptr:end) ];
            obj.token_file_positions = [ obj.token_file_positions(1:obj.token_ptr-1) tokenizer2.token_file_positions obj.token_file_positions(obj.token_ptr:end) ];
            obj.token_end_ptr = numel(obj.token_types)+1;
        end
        
        function log3(obj, msg)
            if obj.log_level >= 3
                disp(msg);
            end
        end
        
        function push_ptr(obj)
            obj.ptr_stack = [ obj.ptr_stack obj.token_ptr ];
        end
        
        function pop_ptr(obj)
            obj.token_ptr = obj.ptr_stack(end);
            obj.ptr_stack = obj.ptr_stack(1:end-1);
        end        
        
        function stash_ptr(obj)
            obj.ptr_stack = obj.ptr_stack(1:end-1);
        end                
        
        function push_LITERAL(obj, literal, pos)
            obj.log3(sprintf('LITERAL: %s\n', literal));
            obj.token_types(end+1) = obj.TOKEN_LITERAL;
            obj.token_datas{end+1} = literal;
            obj.token_files{end+1} = obj.buffer.filename;
            obj.token_file_positions{end+1} = pos;
        end
        
        function push_STRING(obj, string, pos)
            obj.log3(sprintf('STRING: "%s"\n', string));
            obj.token_types(end+1) = obj.TOKEN_STRING;
            obj.token_datas{end+1} = string;
            obj.token_files{end+1} = obj.buffer.filename;
            obj.token_file_positions{end+1} = pos;
        end
        
        function push_NUMBER(obj, number, pos)
            obj.log3(sprintf('NUMBER: %f\n', number));
            obj.token_types(end+1) = obj.TOKEN_NUMBER;
            obj.token_datas{end+1} = number;
            obj.token_files{end+1} = obj.buffer.filename;
            obj.token_file_positions{end+1} = pos;
        end

        function push_OPERATOR(obj, operator, pos)
            obj.log3(sprintf('OPERATOR: %s\n', operator));
            obj.token_types(end+1) = obj.TOKEN_OPERATOR;
            obj.token_datas{end+1} = operator;
            obj.token_files{end+1} = obj.buffer.filename;
            obj.token_file_positions{end+1} = pos;
        end
        
        function type = peek_type(obj)
           if (obj.token_ptr >= obj.token_end_ptr)
               type = obj.TOKEN_EOF;
               return
           end
           type = obj.token_types(obj.token_ptr); 
        end
        
        function str = peek_as_str(obj)
            type = obj.peek_type();
            data = obj.peek_data();
            switch (type)
                case obj.TOKEN_LITERAL
                    str = sprintf('literal ''%s''', data);
                case obj.TOKEN_NUMBER
                    str = sprintf('number ''%f''', data);
                case obj.TOKEN_OPERATOR
                    str = sprintf('operator ''%s''', data);
                case obj.TOKEN_STRING
                    str = sprintf('"%s"', data);
                case obj.TOKEN_EOF
                    str = 'EOF';
                otherwise
                    error('Internal error: Unknown token.');
            end
        end
        
        function expected_error(obj, msg)
            obj.buffer.error(obj.peek_position(), sprintf('%s Found %s instead.', msg, obj.peek_as_str()), obj.token_files{obj.token_ptr+1});
        end
        
        function error(obj, msg, token_ptr)
            pos = obj.token_file_positions{token_ptr};
            obj.buffer.error(pos, sprintf('%s Found %s instead.', msg, obj.peek_as_str()), obj.token_files{token_ptr});
        end
        
        function data = get_data(obj)
            data = obj.token_datas{obj.token_ptr};
            obj.token_ptr = obj.token_ptr + 1;
        end
        
        function pos = peek_position(obj)
            if obj.token_ptr > numel(obj.token_datas) % End of file?
                if numel(obj.token_datas)>0
                   pos = obj.token_file_positions{end};
                else
                  pos = [1 1]; 
                end
            else
                pos = obj.token_file_positions{obj.token_ptr};
            end
        end
        
        function pos = get_position(obj)
            pos = obj.token_file_positions{obj.token_ptr-1};
        end
        
        function error_at_token(obj, token_ptr, msg)
            %token_ptr
            %obj.token_file_positions
            obj.buffer.error( obj.token_file_positions{token_ptr}, msg, obj.token_files{token_ptr});
        end
        
        function data = peek_data(obj)
            if obj.token_ptr > numel(obj.token_datas)
                data = 'EOF';
                return
            end
            data = obj.token_datas{obj.token_ptr};
        end        

        function tokenize(obj)
            fprintf('Tokenizing..\n');
            token_start = 1;
            obj.parse_WHITESPACE();
            while (~obj.buffer.is_eof())
                pos = obj.buffer.get_position();
                % Starting to load a token, first, clear all whitespace
                % TOKEN := number | operator | string | literal |
                [number, success] = obj.parse_NUMBER();
                if success
                    obj.push_NUMBER(number, pos);
                else
                    [operator, success] = obj.parse_OPERATOR();
                    if success
                        obj.push_OPERATOR(operator, pos);
                    else
                        [string, success] = obj.parse_STRING();
                        if success
                            obj.push_STRING(string, pos);
                        else
                            [literal, success] = obj.parse_LITERAL();
                            if success
                                obj.push_LITERAL(literal, pos);
                            else
                                obj.buffer.error(pos, 'Number, operator, string, or literal expected.');
                            end
                        end
                    end
                end
                obj.parse_WHITESPACE();
            end
        end
        
        function [literal, success] = parse_LITERAL(obj)
            literal = [];
            
            % Legitimate literal needs to start with alpha (not alphanum)
            success = isstrprop(obj.buffer.peek(),'alpha');
            if ~success
                return
            end
            while (isstrprop(obj.buffer.peek(),'alphanum') || obj.buffer.peek() == '.' || obj.buffer.peek() == '_')
                literal = [ literal obj.buffer.get() ];
            end
        end 
        
        
    end
    
    methods (Access=protected)
        
        function [number, success] = parse_NUMBER(obj)
            number = [];
            success = isstrprop(obj.buffer.peek(),'digit');
            if ~success
                return
            end
            while (isstrprop(obj.buffer.peek(),'digit') || obj.buffer.peek() =='.' || obj.buffer.peek() == 'e'|| obj.buffer.peek() =='E')
                number = [ number obj.buffer.get() ];
            end
            number = sscanf(number, '%f');
        end
        
        function [operator, success] = parse_OPERATOR(obj)
            operator = [];
            success = contains(obj.OPERATORS, obj.buffer.peek());
            if ~success
                return
            end
            operator = obj.buffer.get();
        end
        
        function [string, success] = parse_STRING(obj)
            string = [];
            success = false;
            if obj.buffer.peek() ~='"'
                return
            end
            obj.buffer.get();
            while (~obj.buffer.is_eof())
                string = [ string obj.buffer.get() ];
                if obj.buffer.peek() == '"'
                    obj.buffer.get();
                    success = true;
                    return
                end
            end
        end
        
        function parse_WHITESPACE(obj)
            while (isspace(obj.buffer.peek()) && ~obj.buffer.is_eof()) 
                obj.buffer.get();
            end
        end
        
        function c = parse_ALPHA(obj)
            c = obj.get();
            if ~isletter(c)
                obj.error(sprintf('Expected a valid name. Found %s instead.', c));
            end
        end
        
        function name = parse_VALIDNAME(obj)
            obj.parse_WHITESPACE();
            name = obj.parse_ALPHA();
            while (isstrprop(obj.peek(), 'alphanum'))
                name = [ name obj.get() ];
            end
            obj.log3(sprintf('Parsed VALIDNAME: %s.', name));
        end
            
        function parse_EXPECTED(obj, str)
            obj.parse_WHITESPACE();
            failed = false;
            got = [];
            for i=1:numel(str)
                if obj.is_eof()
                    failed = true;
                    break;
                end
                c = obj.get();
                got = [ got c ];
                if c ~= str(i)
                    failed = true;
                end
            end
            if failed
                obj.error(sprintf('Expected "%s", got "%s".',str, got));
            end
        end
        
        % FACTOR := NUMBER | VALIDREF | '(' EXPRESSION ')';
        function factor = parse_FACTOR(obj)
            % Try to parse parenthesis
            % Try to parse number
            % Try to parse valid ref
        end
        
        % TERM := FACTOR { MULOP FACTOR };
        function term = parse_TERM(obj)
            factor = parse_FACTOR();
            term = factor;
        end
        
        % EXPRESSION := TERM { ADDOP TERM };
        function expression = parse_EXPRESSION(obj)
            term = obj.parse_TERM();
            expression = [];
            %while (1)
            %    c = obj.peek();
            %    if c == ';';
            %        break
            %    end
            %    obj.get();
            %    expression = [ expression c];
            %end
            %obj.log3(sprintf('Parsed EXPRESSION:%s', expression));
        end
        
        function intermediate = parse_INTERMEDIATE(obj)
            symbol = obj.parse_VALIDNAME();
            expression = obj.parse_EXPRESSION();
            intermediate = [];
        end
        
        % OBJDEFINITION := 'obj' VALIDNAME '{' { STATEMENT } '};
        function objdef = parse_OBJDEFINITION(obj)
            obj.log3('Parsing OBJDEFINITION');
            obj.parse_EXPECTED('obj');
            
            symbol = obj.parse_VALIDNAME();
            
            obj.parse_EXPECTED('{');
            
            while (1)
               obj.parse_WHITESPACE();
               if obj.peek() == '}'
                   break
               end
               
               symbol = obj.parse_VALIDNAME();
               if strcmp(symbol,'intermediate')
                   obj.parse_INTERMEDIATE();
               end
               obj.parse_EXPECTED(';');
            end
            
            obj.parse_EXPECTED('}');
            obj.parse_EXPECTED(';');
            obj.log(sprintf('obj %s {};',symbol));
            objdef = [];
        end

        
        % MASTER := { OBJDEFINITION ';' }
        function parse_MASTER(obj)
            while 1
                obj.parse_WHITESPACE();
                if obj.is_eof()
                    return
                end
                objdef = obj.parse_OBJDEFINITION();
            end
        end
        
        
    end
end