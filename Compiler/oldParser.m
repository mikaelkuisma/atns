% The structure of the parser class is as follows
% 
% 1. Inline implementation of character buffer
% 2. Inline implementation of token buffer (reading from character buffer)
classdef Parser < handle
    properties (Constant)
        TOKEN_NUMBER = 1;
        TOKEN_LITERAL = 2;
        TOKEN_STRING = 3;
        TOKEN_OPERATOR = 4;
        TOKEN_EOF = 5;
    end
    properties
        % ***********************************
        % * Properties for character buffer *
        % ***********************************
        
        % The buffer data is stored here
        buffer
        
        % Pointer to current (unread) position of the buffer
        ptr
        
        % There are methods push_ptr() and pop_ptr() which push and pop
        % buffer pointers to this stack. This is required for prereads.
        ptr_stack
        
        % End pointer (exclusive) for the buffer. numel(buffer)+1.
        end_ptr
        
        % The current line number for error messages
        linenumber
        
        % The start offset of current line for error messages
        linestart

        % ***********************************
        % * Properties for token buffer     *
        % ***********************************
        
        % Has one of following values 
        % 1 TOKEN_NUMBER 
        % 2 TOKEN_LITERAL
        % 3 TOKEN_STRING
        % 4 TOKEN_OPERATOR
        % 5 TOKEN_EOF
        token_type 
        
        % The data for current token.
        % Depending on token_type
        % TOKEN_NUMBER, has the number
        % TOKEN_LITERAL, has the character array
        % TOKEN_STRING, has the character array for "" separated string.
        % TOKEN_EOF, empty [].
        token_data
        
        % Starting point of current token at buffer
        token_ptr
        % End point of current token at buffer
        token_end_ptr

        % Starting point of next token at buffer
        next_token_ptr
        % End point of next token at buffer
        next_token_end_ptr
        
        % Next token is already prefecthed, for L1 predictive parsing
        next_token_type
        
        % The data corresponding to next_token_type, similarly as for
        % token_data
        next_token_data
        
        % Bytecode target object
        target
    end
    methods (Access=public)
        function obj = Parser(buffer)
            obj.buffer = buffer(:);
            obj.ptr = 1;
            obj.ptr_stack = [];
            obj.end_ptr = numel(obj.buffer)+1;
            obj.linenumber = 1;
            obj.linestart = 1;
        end
        
        function set_target(obj, target)
            this.target = target;
        end
        
        function parse(obj, target)
            obj.set_target(target);
            obj.parse_MASTER();
        end
    end
    
    methods (Access=protected)
        function log(obj, msg)
            disp(msg);
        end
        
        function log3(obj, msg)
            disp(msg);
        end
        
        
        
        function parse_WHITESPACE(obj)
            while (isspace(obj.peek()) && ~obj.is_eof()) 
                obj.get();
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