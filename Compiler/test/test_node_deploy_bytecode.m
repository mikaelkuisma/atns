% NodeDef Guild index as i
% {
%   parameter C = 1.1;
%   parameter s;
%   parameter igr_i;
%   dynamic B_i;
%   .B_i = C*s*igr_i*B_i;
% };
% 
% deploy Guild
% {
%   s=3;
%   Alg1 = new { igr=2; B=3; };
%   Alg2 = new { igr=1; B=3; };
% };



c = zeros(0, 'uint8');

% Define constants
c = [ c Compiler.encode_OPCODE(Compiler.DOUBLE_CONSTANT_COUNT, 4) ];
c = [ c Compiler.encode_DOUBLE(1.1) ];
c = [ c Compiler.encode_DOUBLE(1) ];
c = [ c Compiler.encode_DOUBLE(2) ];
c = [ c Compiler.encode_DOUBLE(3) ];

% The standard 3 entries, all pointing just to RET
c = [ c Compiler.encode_OPCODE(Compiler.ENTRY_COUNT, 3) ];
% Entry 1
MODULE_INIT_ENTRY_ADDRESS = numel(c)+1;
c = [ c 0 0 0 0 ]; % Placeholder for entry
c = [ c Compiler.encode_STRING('.guild.init') ];
% Entry 2
MODULE_EVALUATE_PARAMETERS_ADDRESS = numel(c)+1;
c = [ c 0 0 0 0 ]; % Placeholder for entry
c = [ c Compiler.encode_STRING('.guild.evaluate_parameters') ];

% Entry 3
MODULE_EVALUATE_GRADIENTS_ADDRESS = numel(c)+1;
c = [ c 0 0 0 0 ]; % Placeholder for entry
c = [ c Compiler.encode_STRING('.guild.evaluate_gradients') ];

% We define one nodedef
c = [ c Compiler.encode_OPCODE(Compiler.NODEDEF_COUNT,1)]; % CLASS_DEFINITION:1

% Called guild
c = [ c Compiler.encode_STRING('Guild') ];
c = [ c Compiler.encode_OPCODE(Compiler.INDEX_AS,1)];
c = [ c Compiler.encode_STRING('i') ];

% The standard 3 entries
c = [ c Compiler.encode_OPCODE(Compiler.ENTRY_COUNT, 3) ];

% Entry 1
INIT_ENTRY_ADDRESS = numel(c)+1;
c = [ c 0 0 0 0 ]; % Placeholder for entry
c = [ c Compiler.encode_STRING('.init') ];

% Entry 2
EVALUATE_PARAMETERS_ADDRESS = numel(c)+1;
c = [ c 0 0 0 0 ]; % Placeholder for entry
c = [ c Compiler.encode_STRING('.evaluate_parameters') ];

% Entry 3
EVALUATE_GRADIENTS_ADDRESS = numel(c)+1;
c = [ c 0 0 0 0 ]; % Placeholder for entry
c = [ c Compiler.encode_STRING('.evaluate_gradients') ];


% Double parameters in nodedef
c = [ c Compiler.encode_OPCODE(Compiler.DOUBLE_PARAMETER_COUNT, 2) ];
c = [ c Compiler.encode_STRING({'C','s'}) ];

% Double indexed parameters in nodedef
c = [ c Compiler.encode_OPCODE(Compiler.DOUBLE_INDEX_PARAMETER_COUNT, 1) ];
c = [ c Compiler.encode_STRING({'igr_i'}) ];

% Double dynamic parameters in nodedef
c = [ c Compiler.encode_OPCODE(Compiler.DOUBLE_INDEX_DYNAMIC_COUNT, 1) ];
c = [ c Compiler.encode_STRING({'B_i'}) ];

% Create the NODEDEF
c = [ c Compiler.encode_OPCODE(Compiler.CREATE_NODEDEF) ];

% Deploy the newly defined node
c = [ c Compiler.encode_OPCODE(Compiler.DEPLOY, 1) ];

c = [ c Compiler.encode_OPCODE(Compiler.LOAD_CONSTANT_8, 4) ]; % Load number 3
c = [ c Compiler.encode_OPCODE(Compiler.STORE_PARAMETER, 2) ]; % Store to s (2)

c = [ c Compiler.encode_OPCODE(Compiler.NEW_INDEXED, 1) ]; % New indexed entry
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_CONSTANT_8, 3) ]; % Load number 2
c = [ c Compiler.encode_OPCODE(Compiler.STORE_INDEXED_PARAMETER, 1) ]; % Store to igr (2)
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_CONSTANT_8, 2) ]; % Load number 2
c = [ c Compiler.encode_OPCODE(Compiler.STORE_INDEXED_DYNAMIC, 1) ]; % Store to B (2)

c = [ c Compiler.encode_OPCODE(Compiler.NEW_INDEXED, 1) ]; % New indexed entry
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_CONSTANT_8, 2) ]; % Load number 2
c = [ c Compiler.encode_OPCODE(Compiler.STORE_INDEXED_PARAMETER, 1) ]; % Store to igr (2)
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_CONSTANT_8, 3) ]; % Load number 2
c = [ c Compiler.encode_OPCODE(Compiler.STORE_INDEXED_DYNAMIC, 1) ]; % Store to B (2)

c = [ c Compiler.encode_OPCODE(Compiler.END_DEPLOY) ];

c = [ c Compiler.encode_OPCODE(Compiler.RET) ];

% .Guild.init begins here
c(INIT_ENTRY_ADDRESS:INIT_ENTRY_ADDRESS+3) = typecast(cast(numel(c)+1,'uint32'),'uint8');

c = [ c Compiler.encode_OPCODE(Compiler.LOAD_CONSTANT_8, 1) ]; % Load number 1.1
c = [ c Compiler.encode_OPCODE(Compiler.STORE_PARAMETER, 1) ]; % Store to C (1)
c = [ c Compiler.encode_OPCODE(Compiler.RET) ];

% .Guild.update begins here
c(EVALUATE_PARAMETERS_ADDRESS:EVALUATE_PARAMETERS_ADDRESS+3) = typecast(cast(numel(c)+1,'uint32'),'uint8');
c = [ c Compiler.encode_OPCODE(Compiler.RET) ];

% .Guild.gradient begins here
c(EVALUATE_GRADIENTS_ADDRESS:EVALUATE_GRADIENTS_ADDRESS+3) = typecast(cast(numel(c)+1,'uint32'),'uint8');
c = [ c Compiler.encode_OPCODE(Compiler.INDEX_LOOP, 1) ]; 
loopstart_ptr = numel(c)+1;
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_PARAMETER, 1) ]; % C
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_PARAMETER, 2) ]; % s
c = [ c Compiler.encode_OPCODE(Compiler.MUL_OPERATOR) ]; % *
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_INDEXED_PARAMETER, 1) ]; % load igr_i
c = [ c Compiler.encode_OPCODE(Compiler.MUL_OPERATOR) ]; % *
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_INDEXED_DYNAMIC, 1) ]; % load igr_i
c = [ c Compiler.encode_OPCODE(Compiler.MUL_OPERATOR) ]; % *
c = [ c Compiler.encode_OPCODE(Compiler.STORE_INDEXED_GRADIENT, 1) ]; % load igr_i
c = [ c Compiler.encode_OPCODE(Compiler.INDEX_JUMP, loopstart_ptr) ]; % load igr_i
c = [ c Compiler.encode_OPCODE(Compiler.RET) ];

% Empty functions
c(MODULE_INIT_ENTRY_ADDRESS:MODULE_INIT_ENTRY_ADDRESS+3) = typecast(cast(numel(c)+1,'uint32'),'uint8');
c(MODULE_EVALUATE_PARAMETERS_ADDRESS:MODULE_EVALUATE_PARAMETERS_ADDRESS+3) = typecast(cast(numel(c)+1,'uint32'),'uint8');
c(MODULE_EVALUATE_GRADIENTS_ADDRESS:MODULE_EVALUATE_GRADIENTS_ADDRESS+3) = typecast(cast(numel(c)+1,'uint32'),'uint8');
c = [ c Compiler.encode_OPCODE(Compiler.RET) ];

Compiler.disassembler(c);

if 1
vm = VM(c);
vm.solve()

%assert( all( cell2mat(result{1}.parameter) == [3 2 6]));
%assert(result{1}.dynamic{1} == 13);
end
% Now that this is done, attempt to create the same structure with syntax
% tree
test_class_def = SEExpressionList( [SEParameter('A') SEAssign(SEParameter('B'), SEConstant(2)) SEDynamic('C') SEAssign(SEParameter('D'), SEOperator('*', SEReference('A'), SEReference('B'))) ] );
lambda_constructor = [ SEAssign(SEIntermediate('A'), SEConstant(3)) SEAssign(SEIntermediate('C'), SEConstant(13)) ];
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
%assert( all( cell2mat(result{1}.parameter) == [3 2 6]));
%assert(result{1}.dynamic{1} == 13);
% TODO: Results not verified
