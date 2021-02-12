% This corresponds to following code
% class TestClass
% {
%   parameter A;
%   parameter B = 2;
%   dynamic C;
%   parameter D = A*B;
%   .C = -D*C;
% };
% A = new TestClass { A=3; C=13; });


c = zeros(0, 'uint8');
c = [ c Compiler.encode_OPCODE(Compiler.DOUBLE_CONSTANT_COUNT, 3) ];
c = [ c Compiler.encode_DOUBLE(3) ];
c = [ c Compiler.encode_DOUBLE(13) ];
c = [ c Compiler.encode_DOUBLE(2) ];
c = [ c Compiler.encode_OPCODE(Compiler.CLASS_COUNT,1)]; % CLASS_DEFINITION:1
c = [ c Compiler.encode_STRING('TestClass') ];
c = [ c Compiler.encode_OPCODE(Compiler.DOUBLE_PARAMETER_COUNT, 3) ];
c = [ c Compiler.encode_STRING({'A','B','D'}) ];
c = [ c Compiler.encode_OPCODE(Compiler.DOUBLE_DYNAMIC_COUNT, 1) ];
c = [ c Compiler.encode_STRING('C') ];
c = [ c Compiler.encode_OPCODE(Compiler.ENTRY_COUNT, 3) ];
INIT_ENTRY_ADDRESS = numel(c)+1;
c = [ c 0 0 0 0 ]; % Placeholder for entry
c = [ c Compiler.encode_STRING('.init') ];
EVALUATE_PARAMETERS_ADDRESS = numel(c)+1;
c = [ c 0 0 0 0 ]; % Placeholder for entry
c = [ c Compiler.encode_STRING('.evaluate_parameters') ];
EVALUATE_GRADIENTS_ADDRESS = numel(c)+1;
c = [ c 0 0 0 0 ]; % Placeholder for entry
c = [ c Compiler.encode_STRING('.evaluate_gradients') ];
c = [ c Compiler.encode_OPCODE(Compiler.CREATE_CLASS) ];
c = [ c Compiler.encode_OPCODE(Compiler.NEW_INSTANCE, 1) ];
c = [ c Compiler.encode_OPCODE(Compiler.ENTER_LAMBDA) ];
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_CONSTANT_8, 1) ];
c = [ c Compiler.encode_OPCODE(Compiler.STORE_PARAMETER, 1) ];
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_CONSTANT_8, 2) ];
c = [ c Compiler.encode_OPCODE(Compiler.STORE_DYNAMIC, 1) ];
c = [ c Compiler.encode_OPCODE(Compiler.EXIT_LAMBDA) ];
c = [ c Compiler.encode_OPCODE(Compiler.CALL_ENTRY, 1) ]; % Call constructor
%c = [ c Compiler.encode_OPCODE(Compiler.BUILTIN_FUNCTION, 23) ]; % @SOLVE
c = [ c Compiler.encode_OPCODE(Compiler.RET) ];

% Start defining function TestClass.init
c(INIT_ENTRY_ADDRESS:INIT_ENTRY_ADDRESS+3) = typecast(cast(numel(c)+1,'uint32'),'uint8');
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_CONSTANT_8, 3) ]; % Load number 2
c = [ c Compiler.encode_OPCODE(Compiler.STORE_PARAMETER, 2) ]; % Store to 'B'
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_PARAMETER, 1) ]; % Load 'A'
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_PARAMETER, 2) ]; % Load 'B'
c = [ c Compiler.encode_OPCODE(Compiler.MUL_OPERATOR) ];
c = [ c Compiler.encode_OPCODE(Compiler.STORE_PARAMETER, 3) ]; % Store to 'D'
c = [ c Compiler.encode_OPCODE(Compiler.RET) ];

% Start defining function TestClass.evaluate_parameters
c(EVALUATE_PARAMETERS_ADDRESS:EVALUATE_PARAMETERS_ADDRESS+3) = typecast(cast(numel(c)+1,'uint32'),'uint8');
c = [ c Compiler.encode_OPCODE(Compiler.RET) ];

% Start defining function TestClass.evaluate_gradients
c(EVALUATE_GRADIENTS_ADDRESS:EVALUATE_GRADIENTS_ADDRESS+3) = typecast(cast(numel(c)+1,'uint32'),'uint8');
c = [ c Compiler.encode_OPCODE(Compiler.RET) ];

%Compiler.disassembler(c);
if 1
vm = VM(c);
result = vm.run(1); % Just start running from the start
assert( all( cell2mat(result{1}.parameter) == [3 2 6]));
assert(result{1}.dynamic{1} == 13);
end
% Now that this is done, attempt to create the same structure with syntax
% tree
test_class_def = SEExpressionList( [SEParameter('A') SEAssign(SEParameter('B'), SEConstant(2)) SEDynamic('C') SEAssign(SEParameter('D'), SEOperator('*', SEReference('A'), SEReference('B'))) ] );
lambda_constructor = [ SEAssign(SEParameter('A'), SEConstant(3)) SEAssign(SEDynamic('C'), SEConstant(13)) ];
statement_list = [ SEClassDef('TestClass', test_class_def) SEFunctionCall('SOLVE', SENewInstance('TestClass', SEExpressionList(lambda_constructor))) ];
main_module = SEModule(SEExpressionList(statement_list));
compiler = Compiler(main_module);
compiler.compile(); 
c2 = compiler.get_byte_code();
comparison = zeros(2, max(size(c,2),size(c2,2)));
comparison(1,1:size(c,2))=c;
comparison(2,1:size(c2,2))=c2;

comparison'
Compiler.disassembler(c2)

vm = VM(c2);
vm.run(1); % Just start running from the start
result = vm.call_by_entry_id(1);

result{1}.parameter
assert( all( cell2mat(result{1}.parameter) == [3 2 6]));
assert(result{1}.dynamic{1} == 13);
