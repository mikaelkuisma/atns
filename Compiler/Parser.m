%
%
% PARENTHESIS := '(' EXPRESSION_LIST ')';
% ARRAY := '[' EXPRESSION_LIST ']';
% FUNCTIONCALL := '@' VALIDREF PARENTHESIS
% FACTOR := NUMBER | STRING | NEW_OBJECT | VALIDREF | PARENTHESIS | ARRAY | FUNCTIONCALL 
% MASTER := { OBJDEFINITION ';' }
% POWER := FACTOR { POWOP FACTOR };
% POWOP := '^'
% ADDOP := '+' | '-'
% MULOP := '*' | '/'
% SUMEXPRESSION = 'sum_i' EXPRESSION;
% EXPRESSION := SUMEXPRESSION | NEWEXPRESSION | TERM { ADDOP TERM };
% NEWEXPRESSION := 'new' [ '<' LITERAL ',' LITERAL ',' LITERAL ',' '>' ] {' STATEMENTLIST '}'
% EXPRESSION_LIST := EXPRESSION { ',' EXPRESSION };
% VALIDLVALUE := [ 'parameter' | 'dynamic' | 'volatile' | 'intermediate' | 'tag' | 'global'] VALIDREF;
% VALIDGRADIENT := '.' VALIDREF;
% VALIDEPOCH := '#' VALIDREF;
% LHS := (VALIDLVALUE | VALIDGRADIENT | VALIDEPOCH);
% INDEXING = [ 'index' 'as' VALIDREF ];
% ASSIGNSTATEMENT := LHS '=' EXPRESSION_LIST
% PLUSASSIGNSTATEMENT := LHS '+=' EXPRESSION_LIST
% INHERITS = [ 'inherits' VALIDREF ];
% NODEDEF := NodeDef VALIDREF INDEXING INHERITS '{' NODEDEF '};'
% LINKDEF = VALIDNAME 'as' VALIDNAME;
% LINKINDEXING = '<' LINKDEF ',' LINKFED [ ',' LINKDEF ] '>'
% LINKDEF := NodeDef VALIDREF LINKINDEXING '{' NODEDEF '};'
% DEPLOY := deploy VALIDREF '{' { STATEMENT } ';';
% DISPLAYSTATEMENT := 'display' '"' LABEL '"' expression;
% INCLUDESTATEMENT := '#' 'include' STRING_LITERAL ';'
% STATEMENT := INCLUDESTATEMENT | [ 'disabled' ] class VALIDREF '{' CLASSDEF '};' | NODEDEF | LINKDEF | DEPLOY | ASSIGNSTATEMENT | DISPLAYSTATEMENT | PLUSASSIGNSTATEMENT | EXPRESSION_LIST ';';
% CLASSDEF := { STATEMENT };
 
classdef Parser < handle
    properties
        tokenizer    
        % Bytecode target object
        % target
    end

    properties (Constant)
        reserved_words = {'NodeDef','deploy','new','tag','parameter','dynamic','global','display','disabled'};
    end

    
    methods (Access=public)
        function obj = Parser(tokenizer)
            obj.tokenizer = tokenizer;
        end
        
        %function set_target(obj, target)
        %    this.target = target;
        %end

        function [ number, success ] = parse_NUMBER(obj)
            success = obj.tokenizer.peek_type() == Tokenizer.TOKEN_NUMBER;
            number = [];
            if ~success
                return
            end
            number = obj.tokenizer.get_data();
            number = SEConstant(number);
            number.token_ptr = obj.tokenizer.token_ptr;
        end
        
        function [ string, success ] = parse_STRING(obj)
            success = obj.tokenizer.peek_type() == Tokenizer.TOKEN_STRING;
            string = [];
            if ~success
                return
            end
            string = obj.tokenizer.get_data();
            string = SEString(string);
            string.token_ptr = obj.tokenizer.token_ptr;
        end
        

        function [operator, success] = parse_OPERATOR(obj, op)
            if (obj.tokenizer.peek_type() == Tokenizer.TOKEN_OPERATOR)
                operator = obj.tokenizer.peek_data();
                success = (operator == op);
                if (~success)
                    return
                end
                obj.tokenizer.get_data();
            else
                success = false;
                operator = [];
            end
        end
        
        % PARENTHESIS := '(' EXPRESSION ')';
        function [factor, success] = parse_PARENTHESIS(obj)
            factor = [];
            [ op, success ] = obj.parse_OPERATOR('(');
            if ~success
                return
            end
            obj.tokenizer.push_ptr();
            % Test if closes immediately
            [ op, success ] = obj.parse_OPERATOR(')');
            if success
                factor = [];
                obj.tokenizer.stash_ptr();
                return
            end
            obj.tokenizer.pop_ptr();
            
            [ factor, success ] = obj.parse_EXPRESSIONLIST();
            if ~success
                obj.tokenizer.buffer.error(obj.tokenizer.peek_position(), '''expression'' expected.');
            end
            [ op, success ] = obj.parse_OPERATOR(')');
            if ~success
                return
            end   
        end
        
       function factor = require_PARENTHESIS(obj)
           [factor, success] = obj.parse_PARENTHESIS();
           if ~success
               obj.tokenizer.buffer.error(obj.tokenizer.peek_position(), '() expected.');
           end
        end        

        % ARRAY := '[' EXPRESSIONLIST ']';
        function [factor, success] = parse_ARRAY(obj)
            factor = [];
            [ op, success ] = obj.parse_OPERATOR('[');
            if ~success
                return
            end
            [ factor, success ] = obj.parse_EXPRESSIONLIST();
            if ~success
                obj.tokenizer.buffer.error('Inside [], ''expression/expression list'' expected.');
            end
            factor = SEArray(factor);
            factor.token_ptr = obj.tokenizer.token_ptr;

            [ op, success ] = obj.parse_OPERATOR(']');
            if ~success
                return
            end   
        end
        
        function not_reserved(obj, literal)
            if sum(strcmp(literal, Parser.reserved_words))>0
                    obj.tokenizer.buffer.error(obj.tokenizer.get_position(), sprintf("%s is a reserved word, and cannot be used here.", literal));
            end
        end
                
        function [validref, success] = parse_VALIDREF(obj)
            if obj.tokenizer.peek_type() == Tokenizer.TOKEN_LITERAL
                % Reserved word cannot be a valid reference
                if sum(strcmp(obj.tokenizer.peek_data(), Parser.reserved_words))>0
                    validref = []; success = false;
                    return
                end
                validref = SEReference(obj.tokenizer.get_data(), obj.tokenizer.token_ptr);
                validref.token_ptr = obj.tokenizer.token_ptr;
                success = true;
            else
                validref = [];
                success = false;
            end
        end
        
        function validref = require_VALIDREF(obj)
            if obj.tokenizer.peek_type() == Tokenizer.TOKEN_LITERAL
                % Reserved word cannot be a valid reference
                if sum(strcmp(obj.tokenizer.peek_data(), Parser.reserved_words))>0
                    obj.tokenizer.expected_error(sprintf('Valid name expected instead of reserved word.'));
                end
                validref = SEReference(obj.tokenizer.get_data());
                validref.token_ptr = obj.tokenizer.token_ptr;
                success = true;
            else
                    obj.tokenizer.expected_error(sprintf('Valid name expected.'));
            end           
        end        
        
        function [functioncall, success] = parse_FUNCTIONCALL(obj)
            obj.tokenizer.push_ptr();
            [op, success] = obj.parse_FUNCOP();
            if ~success
                obj.tokenizer.pop_ptr();
                functioncall = [];
                return
            end
            % Point of no return
            ref = obj.require_VALIDREF();
            arguments = obj.require_PARENTHESIS();            
            functioncall = SEFunctionCall(ref, arguments);
            functioncall.token_ptr = obj.tokenizer.token_ptr;
        end
        
        function [validref, success] = parse_VALIDGRADIENT(obj)
            obj.tokenizer.push_ptr();
            validref = [];
            [ op, success ] = obj.parse_OPERATOR('.');
            if ~success
                obj.tokenizer.pop_ptr();
                return
            end
            if obj.tokenizer.peek_type() == Tokenizer.TOKEN_LITERAL
                validref = SEGradientReference(obj.tokenizer.get_data());
                validref.token_ptr = obj.tokenizer.token_ptr;
                success = true;
            else
                obj.pop_ptr();
                validref = [];
                success = false;
            end
            
        end

        function [validref, success] = parse_VALIDEPOCH(obj)
            obj.tokenizer.push_ptr();
            validref = [];
            [ op, success ] = obj.parse_OPERATOR('#');
            if ~success
                obj.tokenizer.pop_ptr();
                return
            end
            if obj.tokenizer.peek_type() == Tokenizer.TOKEN_LITERAL
                validref = SEEpochReference(obj.tokenizer.get_data());
                validref.token_ptr = obj.tokenizer.token_ptr;
                success = true;
            else
                obj.pop_ptr();
                validref = [];
                success = false;
            end
            
        end
        
        
        % FACTOR := NUMBER | VALIDREF | PARENTHESIS | FUNCTIONCALL;
        function [ factor, success ] = parse_FACTOR(obj)
            %[ op, unary_minus ] = parse_OPERATOR(obj, '-');
            [ factor, success ] = obj.parse_NUMBER();
            if ~success
                [ factor, success ] = obj.parse_STRING();
                if ~success
                [ factor, success ] = obj.parse_PARENTHESIS();
                if ~success
                  [ factor, success ] = parse_SUMEXPRESSION(obj);
                  if ~success
                    [factor, success] = obj.parse_NEWOBJECT();
                    if ~success
                    [factor, success ] = obj.parse_VALIDREF();
                    if ~success
                        [factor, success] = obj.parse_ARRAY();
                        if ~success
                            [factor, success] = obj.parse_FUNCTIONCALL();
                            if ~success
                                 return
                            end
                        end
                       end
                    end
                  end
                  end
                end
            end
            %if unary_minus
            %    factor = SEUnaryMinus(factor);
            %    factor.token_ptr = obj.tokenizer.token_ptr;
            %end
        end
        
        % POWER := FACTOR { POWOP FACTOR };
        function [ power, success ] = parse_POWER(obj)
            [ factor, success ] = obj.parse_FACTOR();
            power = factor;
            if ~success
                return
            end
            [ powop, next_success ] = parse_POWOP(obj);
            while (next_success)
                [ factor, next_success ] = obj.parse_FACTOR();
                if ~next_success
                    error('Expected factor.');
                end
                power = SEOperator(powop, power, factor);
                [ powop, next_success ] = parse_POWOP(obj);
            end
        end
        
        % TERM := POWER { MULOP POWER };
        function [ term, success ] = parse_TERM(obj)
            [ op, unary_minus ] = parse_OPERATOR(obj, '-');
            
            [ power, success ] = obj.parse_POWER();
            term = power;
            if ~success
                return
            end
            [ mulop, next_success ] = parse_MULOP(obj);
            while (next_success)
                [ power, next_success ] = obj.parse_POWER();
                if ~next_success
                    obj.tokenizer.expected_error('Factor expected.');
                end
                term = SEOperator(mulop, term, power);
                term.token_ptr = obj.tokenizer.token_ptr;

                [ mulop, next_success ] = parse_MULOP(obj);
            end
            if unary_minus
                term = SEUnaryMinus(term);
                term.token_ptr = obj.tokenizer.token_ptr;
            end            
        end

        % POWOP := '^'
        function [ powop, success ] = parse_POWOP(obj)
            if (obj.tokenizer.peek_type() == Tokenizer.TOKEN_OPERATOR)
                c = obj.tokenizer.peek_data();
                if (c == '^')
                    powop = obj.tokenizer.get_data();
                    success = true;
                    return
                end
            end
            powop = [];
            success = false;
        end        
        
        % FUNCOP := '@'
        function [ funcop, success ] = parse_FUNCOP(obj)
            if (obj.tokenizer.peek_type() == Tokenizer.TOKEN_OPERATOR)
                c = obj.tokenizer.peek_data();
                if (c == '@')
                    funcop = obj.tokenizer.get_data();
                    success = true;
                    return
                end
            end
            funcop = [];
            success = false;
        end        
        
        % ADDOP := '+' | '-'
        function [ addop, success ] = parse_ADDOP(obj)
            if (obj.tokenizer.peek_type() == Tokenizer.TOKEN_OPERATOR)
                c = obj.tokenizer.peek_data();
                if (c == '+' || c == '-')
                    addop = obj.tokenizer.get_data();
                    success = true;
                    return
                end
            end
            addop = [];
            success = false;
        end
        
        % COMMAOP := '+' | '-'
        function [ commaop, success ] = parse_COMMAOP(obj)
            if (obj.tokenizer.peek_type() == Tokenizer.TOKEN_OPERATOR)
                c = obj.tokenizer.peek_data();
                if (c == ',')
                    commaop = obj.tokenizer.get_data();
                    success = true;
                    return
                end
            end
            commaop = [];
            success = false;
        end        
        
        % MULOP := '*' | '/'
        function [ mulop, success ] = parse_MULOP(obj)
            if (obj.tokenizer.peek_type() == Tokenizer.TOKEN_OPERATOR)
                c = obj.tokenizer.peek_data();
                if (c == '*' || c == '/')
                    mulop = obj.tokenizer.get_data();
                    success = true;
                    return
                end
            end
            mulop = [];
            success = false;
        end        
        
        % EXPRESSION_LIST := EXPRESSION { ',' EXPRESSION }
        function [ expression_list, success ] = parse_EXPRESSIONLIST(obj)
            [ expression, success ] = parse_EXPRESSION(obj);
            if ~success
                expression_list = [];
                return
            end
            [ commaop, next_success ] = parse_COMMAOP(obj);
            if next_success
                expressions = {};
                expressions{1} = expression;
            else
                expression_list = expression; % Just a since expression (no comma)
                return
            end
            while (next_success)
                [ expression, next_success ] = obj.parse_EXPRESSION();
                if ~next_success
                    break % error('Expected term.'); Expression list may end in a comma. Thus, no error.
                end
                expressions{end+1} = expression;
                %expression_list = SEExpressionPair(commaop, expression_list, expression);
                [ commaop, next_success ] = parse_COMMAOP(obj);
            end
            expression_list = SEExpressionList(expressions);
            expression_list.token_ptr = obj.tokenizer.token_ptr;
            % TODO: Look for ',', loop.
        end
        
        % EXPRESSION := TERM { ADDOP TERM };            
        function [ expression, success ] = parse_EXPRESSION(obj)
            [ expression, success ] = parse_NEWEXPRESSION(obj);
            if success
                return
            end
            
            [ term, success ] = obj.parse_TERM();
            expression = term;
            if ~success
                return
            end
            [ addop, next_success ] = parse_ADDOP(obj);
            while (next_success)
                [ term, next_success ] = obj.parse_TERM();
                if ~next_success
                    error('Expected term.');
                end
                expression = SEOperator(addop, expression, term);
                expression.token_ptr = obj.tokenizer.token_ptr;
                [ addop, next_success ] = parse_ADDOP(obj);
            end
        end

        function expression = require_EXPRESSION(obj)
            [ expression, success ] = obj.parse_EXPRESSION();
            if ~success
                error('Expression expected.');
            end
        end
        
        
        function op = require_OPERATOR(obj, operator)
            [ op, success ] = obj.parse_OPERATOR(operator);
            if ~success
                obj.tokenizer.expected_error(sprintf('%s expected.', operator));
            end
        end
        
        function error(obj, msg, token_ptr)
            obj.tokenizer.error(msg, token_ptr);
        end
        
        function statement = require_STATEMENT(obj)
            [ statement, success ] = obj.parse_STATEMENT();
            if ~success
                obj.tokenizer.expected_error('Statement expected.');
            end
        end
        
        function text = require_STRING(obj)
            if (obj.tokenizer.peek_type() ~= Tokenizer.TOKEN_STRING)
                error('String expected.');
            end
            text = obj.tokenizer.get_data();
        end
        
        % VALIDLVALUE := [ parameter | dynamic | volatile | intermediate ] VALIDREF
        function [ lhs, success ] = parse_VALIDLVALUE(obj)
            try
            obj.tokenizer.push_ptr();
            
            if (obj.tokenizer.peek_type() ~= Tokenizer.TOKEN_LITERAL)
                lhs = [];
                success = false;
                obj.tokenizer.pop_ptr();
                return
            end
            literal = obj.tokenizer.get_data();
            lvalue_type = 'intermediate'; % Intermediate is the default type
            if strcmp(literal, 'parameter') || ...
                    strcmp(literal, 'dynamic') || ...
                    strcmp(literal, 'volatile') || ...
                    strcmp(literal, 'tag') || ...
                    strcmp(literal, 'global') || ...
                    strcmp(literal, 'intermediate')
                lvalue_type = literal;
                if (obj.tokenizer.peek_type() ~= Tokenizer.TOKEN_LITERAL)
                    lhs = [];
                    success = false;
                    obj.tokenizer.pop_ptr();
                    return
                end
                literal = obj.tokenizer.get_data();
                obj.not_reserved(literal);
            end
                if strcmp(literal, 'new') % FAIL, not allowed
                    success = false;
                    lhs = [];
                    obj.tokenizer.pop_ptr();
                    return
                end            
            success = true;
            if strcmp(lvalue_type, 'parameter')
                lhs = SEParameter(literal);
            elseif strcmp(lvalue_type, 'dynamic')
                lhs = SEDynamic(literal);
            elseif strcmp(lvalue_type, 'volatile')
                lhs = SEVolatile(literal);
            elseif strcmp(lvalue_type, 'tag')    
                lhs = SETag(literal);
            elseif strcmp(lvalue_type, 'global')
                lhs = SEGlobal(literal);
            elseif strcmp(lvalue_type, 'intermediate')
                lhs = SEIntermediate(literal);
            else
                error('Internal error.');
            end
            lhs.token_ptr = obj.tokenizer.token_ptr;

            catch e
                if contains(e.message,'col')
                    rethrow(e);
                end
                e.message
                obj.error(obj.tokenizer.token_ptr, e.message);
            end

         end
                
        % LHS := (VALIDLVALUE | VALIDGRADIENT)
        function [ lhs, success ] = parse_LHS(obj)
            obj.tokenizer.push_ptr();
            [lhs, success] = obj.parse_VALIDLVALUE();
            if ~success
                [lhs, success] = obj.parse_VALIDGRADIENT();
                if success
                    %disp('valid');
                else
                    [lhs, success] = obj.parse_VALIDEPOCH();
                    if ~success
                        obj.tokenizer.pop_ptr();
                        return
                    end
                end
            end
            obj.tokenizer.stash_ptr();
        end
        
        function [ expression, success ] = parse_SUMEXPRESSION(obj)
            expression = [];
            if obj.tokenizer.peek_type() ~= Tokenizer.TOKEN_LITERAL
                success = 0;
                return
            end
            if startsWith(obj.tokenizer.peek_data(),'sum_')
               sum_statement = split(obj.tokenizer.get_data(),'_');
               if numel(sum_statement) ~= 2
                   error(sprintf('Expected one _ in sum statement. Found %s instead.', sum_statement));
               end
               
               [expression, success] = obj.parse_EXPRESSION();
               if ~success
                   error('Expected expression after sum');
               end
               expression = SESumExpression(sum_statement{2}, expression);
               return
            end
            success = 0;
        end
        
        function [pairdef, success] = parse_PAIRDEF(obj)
             pairdef = [];
             [op, success] = obj.parse_OPERATOR('<');
             if ~success
                 return
             end
             pair1 = obj.parse_LITERAL();
             
             [op, success] = obj.parse_OPERATOR(',');
             if ~success
                 error(', expected.');
             end
             pair2 = obj.parse_LITERAL();
             [op, success] = obj.parse_OPERATOR(',');
             if ~success
                 error(', expected.');
             end
             pair3 = obj.parse_LITERAL();

             [op, success] = obj.parse_OPERATOR('>');
             if ~success
                 error('> expected.');
             end
             pairdef{1} = pair1;
             pairdef{2} = pair2;
             pairdef{3} = pair3;
        end
                
        
        function [ expression, success ] = parse_NEWEXPRESSION(obj)
            expression = [];
            if obj.tokenizer.peek_type() ~= Tokenizer.TOKEN_LITERAL
                success = 0;
                return
            end
            if strcmp(obj.tokenizer.peek_data(),'new')
               obj.tokenizer.get_data();
               
               [pairdef, success] = obj.parse_PAIRDEF();
               % We do not care if succesful or not, pairdef is [] if not
               % succesful.
               [op, success] = obj.parse_OPERATOR('{');
               if ~success
                   obj.tokenizer.buffer.error(obj.tokenizer.peek_position(), sprintf('''{'' expected after new-operator.'));
               end
               statements = obj.parse_STATEMENTLIST();
               [op, success] = obj.parse_OPERATOR('}');
               %disp('TODO NEWEXPRESSION');
               expression = SENewExpression(SEExpressionList(statements), pairdef);
               return
            end
            success = 0;
        end
        
        function [ lhs, rhs, success ] = parse_ASSIGNSTATEMENT(obj, add)
            obj.tokenizer.push_ptr();
            rhs = [];
            [lhs, success ] = obj.parse_LHS();
            if ~success
                obj.tokenizer.pop_ptr();
                return
            end
            if nargin>1 && add==1
                [op, success] = obj.parse_OPERATOR('+');
            end
            [op, success] = obj.parse_OPERATOR('=');
            if ~success
                obj.tokenizer.pop_ptr();
                return
            end
            [ rhs, success ] = obj.parse_EXPRESSIONLIST();
            if ~success
                obj.tokenizer.pop_ptr();
                return
            end
            obj.tokenizer.stash_ptr();
        end

        function [ display, success ] = parse_DISPLAYSTATEMENT(obj)
            display = [];
            obj.tokenizer.push_ptr();
            if (obj.tokenizer.peek_type() ~= Tokenizer.TOKEN_LITERAL)
                success = false;
                obj.tokenizer.pop_ptr();
                return
            end
            literal = obj.tokenizer.get_data();
            if ~strcmp(literal,'display')
                success = false;
                obj.tokenizer.pop_ptr();
                return
            end
            % Point of no return
            label = obj.require_STRING();
            expression = obj.require_EXPRESSION();
            obj.tokenizer.stash_ptr();
            display = SEDisplay(label, expression);
            success = true;
        end
        
        
        function [ object, success ] = parse_NEWOBJECT(obj)
            object=[];
            obj.tokenizer.push_ptr();
            if (obj.tokenizer.peek_type() ~= Tokenizer.TOKEN_LITERAL)
                class = [];
                success = false;
                obj.tokenizer.pop_ptr();
                return
            end
            literal = obj.tokenizer.get_data();
            if ~strcmp(literal,'new')
               success = false;
               obj.tokenizer.pop_ptr();
               return
            end
            if (obj.tokenizer.peek_type() ~= Tokenizer.TOKEN_LITERAL)
                success = false;
                obj.tokenizer.pop_ptr();
                return
            end
            class_name = obj.tokenizer.get_data();
            [op, success] = obj.parse_OPERATOR('{');
            if ~success
                obj.tokenizer.pop_ptr();
                obj.tokenizer.buffer.error(obj.tokenizer.peek_position(), sprintf('''{'' expected after ''class %s''', literal));
            end
            statements = obj.parse_STATEMENTLIST();
            [op, success] = obj.parse_OPERATOR('}');
            if ~success
                obj.tokenizer.pop_ptr();
                obj.tokenizer.buffer.error(obj.tokenizer.peek_position(), sprintf('''}'' expected'));
            end
            object = SENewInstance(class_name, SEExpressionList(statements));
        end

        function [ class, success ] = parse_CLASS(obj)
            class=[];
            obj.tokenizer.push_ptr();
            if (obj.tokenizer.peek_type() ~= Tokenizer.TOKEN_LITERAL)
                class = [];
                success = false;
                obj.tokenizer.pop_ptr();
                return
            end
            literal = obj.tokenizer.get_data();
            if ~strcmp(literal,'class')
               success = false;
               obj.tokenizer.pop_ptr();
               return
            end
            if (obj.tokenizer.peek_type() ~= Tokenizer.TOKEN_LITERAL)
                success = false;
                obj.tokenizer.pop_ptr();
                return
            end
            class_name = obj.tokenizer.get_data();
            [op, success] = obj.parse_OPERATOR('{');
            if ~success
                obj.tokenizer.pop_ptr();
                obj.tokenizer.buffer.error(obj.tokenizer.peek_position(), sprintf('''{'' expected after ''class %s''', literal));
            end
            statements = obj.parse_STATEMENTLIST();
            [op, success] = obj.parse_OPERATOR('}');
            if ~success
                obj.tokenizer.pop_ptr();
                obj.tokenizer.buffer.error(obj.tokenizer.peek_position(), sprintf('''}'' expected'));
            end
            [op, success] = obj.parse_OPERATOR(';');
            if ~success
                obj.tokenizer.pop_ptr();
                obj.tokenizer.buffer.error(obj.tokenizer.peek_position(), sprintf(''';'' expected'));
            end
            class = SEClassDef(class_name, statements);
        end
        
        function [literal, success ] = parse_LITERAL(obj)
            % TODO: literals are actually symbols, thorought the code
            literal = [];
            if (obj.tokenizer.peek_type() ~= Tokenizer.TOKEN_LITERAL)
                success = 0;
                return
            end
            literal = obj.tokenizer.get_data();
            success = 1;
        end
        
        function [ indexing, success ] = parse_INDEXING(obj)
            indexing = []; success=1; 
            if (obj.tokenizer.peek_type() == Tokenizer.TOKEN_LITERAL)
                if strcmp(obj.tokenizer.peek_data(), 'index')
                     obj.tokenizer.get_data();
                     if obj.tokenizer.peek_type() == Tokenizer.TOKEN_LITERAL && strcmp(obj.tokenizer.peek_data(),'as')
                         obj.tokenizer.get_data();
                         [ indexing, success ] = obj.parse_VALIDREF();
                         if ~success
                             error('Valid reference expected.');
                         end
                         return
                     else
                         error('as expected');
                     end
                end
            end
        end

        function [ indexing, success ] = parse_INHERITS(obj)
            indexing = []; success=1; 
            if (obj.tokenizer.peek_type() == Tokenizer.TOKEN_LITERAL)
                if strcmp(obj.tokenizer.peek_data(), 'inherits')
                     obj.tokenizer.get_data();
                     % Point of no return
                     [ indexing, success ] = obj.parse_VALIDREF();
                     if ~success
                         error('Valid reference expected.');
                     end
                end
            end
        end

        function [ token, success ] = parse_DISABLED(obj)
             token = '';
             if (obj.tokenizer.peek_type() ~= Tokenizer.TOKEN_LITERAL)
                 success = 0;
                 return
             end
             token = obj.tokenizer.peek_data();
             if strcmp(token,'disabled')
                 obj.tokenizer.get_data();
                 success = 1;
                 return
             end
            success = 0;
        end
        
        
        function [ class, success ] = parse_NODEDEF(obj)
            class=[];
            obj.tokenizer.push_ptr();
            if (obj.tokenizer.peek_type() ~= Tokenizer.TOKEN_LITERAL)
                class = [];
                success = false;
                obj.tokenizer.pop_ptr();
                return
            end
            literal = obj.tokenizer.get_data();
            if ~strcmp(literal,'NodeDef')
               success = false;
               obj.tokenizer.pop_ptr();
               return
            end
            % Point of no return, this needs to succees, or otherwise an
            % error must be thrown.
            if (obj.tokenizer.peek_type() ~= Tokenizer.TOKEN_LITERAL)
                success = false;
                obj.tokenizer.pop_ptr();
                error('Name for NodeDef expected. Instead: TODO');
                return
            end
            %class_name = obj.tokenizer.get_data();
            ref = obj.require_VALIDREF();
            class_name = ref.symbol;
            [index, success] = obj.parse_INDEXING();
            if ~success
                obj.tokenizer.pop_ptr();
                return
            end
            [inherits, success ] = obj.parse_INHERITS();
            if ~success
                error('Error in inherits definition.');
                return
            end
            [op, success] = obj.parse_OPERATOR('{');
            if ~success
                %obj.tokenizer.pop_ptr();
                obj.tokenizer.buffer.error(obj.tokenizer.peek_position(), sprintf('''{'' expected after ''class %s''', literal));
            end
            statements = obj.parse_STATEMENTLIST();
            [op, success] = obj.parse_OPERATOR('}');
            if ~success
                %obj.tokenizer.pop_ptr();
                obj.tokenizer.buffer.error(obj.tokenizer.get_position(), sprintf('''}'' expected'));
            end
            [op, success] = obj.parse_OPERATOR(';');
            if ~success
                %obj.tokenizer.pop_ptr();
                obj.tokenizer.buffer.error(obj.tokenizer.peek_position(), sprintf(''';'' expected'));
            end
            class = SENodeDef(class_name, index, statements, inherits);
        end
        
        function [linkas, success ] = parse_LINKAS(obj)
            [first, success] = obj.parse_LITERAL();
            if ~success
                error('Symbol expected.');
            end
            [as, success] = obj.parse_LITERAL();
            if ~success 
                error('''as'' expected.');
            end
            if ~strcmp(as,'as')
                error(sprintf('''as'' expected. Found %s instead.', as));
            end
            [first_index, success] = obj.parse_LITERAL();
            if ~success
                error('Index expected after as.');
            end
            linkas = { first first_index };
        end

        function [ linkindexing, success ] = parse_LINKINDEXING(obj)
            linkindexing = [];
            [op, success] = obj.parse_OPERATOR('<');
            if ~success
                error('< expected.');
                return
            end
            [ link1, success ] = obj.parse_LINKAS();
            
            [op, success] = obj.parse_OPERATOR(',');
            if ~success
                error(', expected.');
            end

            [ link2, success ] = obj.parse_LINKAS();
            
            [op, success] = obj.parse_OPERATOR(',');
            if ~success
                error(', expected.');
            end

            [ link3, success ] = obj.parse_LINKAS();
            
            [op, success] = obj.parse_OPERATOR('>');
            if ~success
                error('> expected.');
                return
            end
            linkindexing = { link1 link2 link3 };
        end
        
        function [ class, success ] = parse_LINKDEF(obj)
            class=[];
            obj.tokenizer.push_ptr();
            if (obj.tokenizer.peek_type() ~= Tokenizer.TOKEN_LITERAL)
                class = [];
                success = false;
                obj.tokenizer.pop_ptr();
                return
            end
            literal = obj.tokenizer.get_data();
            if ~strcmp(literal,'LinkDef')
               success = false;
               obj.tokenizer.pop_ptr();
               return
            end
            if (obj.tokenizer.peek_type() ~= Tokenizer.TOKEN_LITERAL)
                success = false;
                obj.tokenizer.pop_ptr();
                return
            end
            class_name = obj.tokenizer.get_data();
            
            [linkindexing, success] = obj.parse_LINKINDEXING();
            if ~success
                error('Expected < >');
            end
            
            [op, success] = obj.parse_OPERATOR('{');
            if ~success
                %obj.tokenizer.pop_ptr();
                obj.tokenizer.buffer.error(obj.tokenizer.peek_position(), sprintf('''{'' expected after LinkDef-definition', literal));
            end
            statements = obj.parse_STATEMENTLIST();
            [op, success] = obj.parse_OPERATOR('}');
            if ~success
                %obj.tokenizer.pop_ptr();
                obj.error(sprintf('''}'' expected'), obj.tokenizer.token_ptr);
            end
            [op, success] = obj.parse_OPERATOR(';');
            if ~success
                %obj.tokenizer.pop_ptr();
                obj.error(sprintf(''';'' expected'), obj.tokenizer.token_ptr);
            end
            class = SENodeDef(class_name, linkindexing, statements,[]); % LinkDef is NodeDef but with link spesific indexing
        end
        
        
        function [ class, success ] = parse_DEPLOY(obj)
            class=[];
            obj.tokenizer.push_ptr();
            if (obj.tokenizer.peek_type() ~= Tokenizer.TOKEN_LITERAL)
                class = [];
                success = false;
                obj.tokenizer.pop_ptr();
                return
            end
            literal = obj.tokenizer.get_data();
            if ~strcmp(literal,'deploy')
               success = false;
               obj.tokenizer.pop_ptr();
               return
            end
            if (obj.tokenizer.peek_type() ~= Tokenizer.TOKEN_LITERAL)
                success = false;
                obj.tokenizer.pop_ptr();
                return
            end
            class_name = obj.tokenizer.get_data(); % TODO: Valid REF
            
            [op, success] = obj.parse_OPERATOR('{');
            if ~success
                obj.tokenizer.pop_ptr();
                obj.tokenizer.buffer.error(obj.tokenizer.peek_position(), sprintf('''{'' expected after ''class %s''', literal));
            end
            statements = obj.parse_STATEMENTLIST();
            [op, success] = obj.parse_OPERATOR('}');
            if ~success
                obj.tokenizer.pop_ptr();
                obj.tokenizer.buffer.error(obj.tokenizer.peek_position(), sprintf('''}'' expected'));
            end
            [op, success] = obj.parse_OPERATOR(';');
            if ~success
                obj.tokenizer.pop_ptr();
                obj.tokenizer.buffer.error(obj.tokenizer.peek_position(), sprintf(''';'' expected'));
            end
            class = SEDeploy(class_name, SEExpressionList(statements));
        end
        
        function [ statement, success ] = parse_INCLUDE(obj)
            statement = [];
            obj.tokenizer.push_ptr();
            [op, success] = obj.parse_OPERATOR('#');
            if success
                [str, success] = obj.parse_LITERAL();
                success = strcmp(str, 'include');
                if success
                    [string, success] = obj.parse_STRING();
                    [op, success] = obj.parse_OPERATOR(';');
                    if ~success
                        error('; expected.');
                    end

                    filename = string.value;
                    buffer = Buffer(filename);
                    tokenizer = Tokenizer(buffer);
                    obj.tokenizer.nest(tokenizer);
                    statement = SEExpressionList([]);
                    obj.tokenizer.stash_ptr();
                    return
                end
            end
            obj.tokenizer.pop_ptr();
        end
        
        % STATEMENT := LHS EXPRESSION ';';
        function [ statement, success ] = parse_STATEMENT(obj)
            obj.tokenizer.push_ptr();
            [ statement, success ] = parse_INCLUDE(obj);
            if success
                obj.tokenizer.stash_ptr();
                return
            end
            [ token, disabled ] = obj.parse_DISABLED();
            [ statement, success ] = parse_CLASS(obj);
            if success
                if disabled
                    statement = SEExpressionList([]);
                end
                obj.tokenizer.stash_ptr();
                return
            end
            [ statement, success ] = parse_NODEDEF(obj);
            if success
                if disabled
                    statement = SEExpressionList([]);
                end
                obj.tokenizer.stash_ptr();
                return
            end
            [ statement, success ] = parse_LINKDEF(obj);
            if success
                if disabled
                    statement = SEExpressionList([]);
                end
                obj.tokenizer.stash_ptr();
                return
            end
            [ statement, success ] = parse_DEPLOY(obj);
            if success
                if disabled
                    statement = SEExpressionList([]);
                end
                obj.tokenizer.stash_ptr();
                return
            end
            [ statement, success ] = parse_DISPLAYSTATEMENT(obj);
            if success
                if disabled
                    statement = SEExpressionList([]);
                end
                obj.tokenizer.stash_ptr();
                return
            end
            [ lhs, rhs, success ] = obj.parse_ASSIGNSTATEMENT();
            if success
                statement = SEAssign(lhs, rhs);
                obj.require_OPERATOR(';');
                if disabled
                    statement = SEExpressionList([]);
                end
                obj.tokenizer.stash_ptr();
                return 
            end
            [ lhs, rhs, success ] = obj.parse_ASSIGNSTATEMENT(1);
            if success
                statement = SEAssign(lhs, rhs,'add');
                obj.require_OPERATOR(';');
                if disabled
                    statement = SEExpressionList([]);
                end
                obj.tokenizer.stash_ptr();
                return 
            end
            
            [ lhs, success ] = obj.parse_LHS();
            if success
                statement = SEAssign(lhs, []); % TODO: Handle empty SEAssign
                obj.require_OPERATOR(';');
                if disabled
                    statement = SEExpressionList([]);
                end
                obj.tokenizer.stash_ptr();
                return
            end
            [ expression_list, success ] = obj.parse_EXPRESSIONLIST();
            if success
                statement = expression_list;
                obj.require_OPERATOR(';');
                %statement = SEAssign([], statement);
                if disabled
                    statement = SEExpressionList([]);
                end
                obj.tokenizer.stash_ptr();
                return
            end
            success = 0;
            obj.tokenizer.pop_ptr();
            %obj.tokenizer.expected_error(sprintf('Expression expected.'));
        end
        
        function parse_END(obj)
            if obj.tokenizer.peek_type() ~= Tokenizer.TOKEN_EOF
                obj.tokenizer.expected_error('Statement expected.');
            end
        end
                
        % STATEMENTLIST := { STATEMENT }
        function [statements, success] = parse_STATEMENTLIST(obj)
            statements = [];
            [ statement, success ] = obj.parse_STATEMENT();
            if ~success
                success = true; % Empty statementlist is also ok.
                return
            end
            
            while (success)
                statements = [ statements statement ];
                if obj.tokenizer.peek_type() == Tokenizer.TOKEN_EOF
                    break
                end
                [ statement, success ] = obj.parse_STATEMENT();
            end
            success = true;
        end
        % MODULE := STATEMENTLIST;
        function module = parse_MODULE(obj)
            if obj.tokenizer.peek_type() == Tokenizer.TOKEN_EOF
                module = SEModule(SEExpressionList([]));
                return
            end
            statements = obj.parse_STATEMENTLIST();
            obj.parse_END();
            module = SEModule(statements);
        end
    end
    
    methods (Access=protected)
        function log(obj, msg)
            disp(msg);
        end
        
        function log3(obj, msg)
            disp(msg);
        end
        

        % MASTER := { OBJDEFINITION ';' }
        function [ master, success ] = parse_MASTER(obj)
            sad
            master = [];
            while 1
                [ obj_definition, success ] = obj.parse_OBJDEFINITION();
                if ~success
                    error('Expected obj-definition.');
                end
                master = [ master obj_definition ];    
            end
        end
        
        
    end
end