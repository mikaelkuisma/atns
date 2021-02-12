% NodeDef Guild index as i
% {
%   parameter alpha_i;
%   dynamic B_i;
%   .B_i = alpha*B_i;
% };
%
% LinkDef Feed <Guild as i, Guild as j, Guild as k>
% {
%    parameter gamma_ij;
%    paramter rate_ij = gamma_ij*B_i*B_j;
%   .B_i = rate_ij;
%   .B_i = -rate_ij;
% }
% deploy Guild
% {
%   tag Prey = new { alpha=1; B=1; };
%   tag Predator = new { alpha=-1; B=1; };
% };
%
% deploy Feed
% {
%    new <Prey, Predator> { gamma=1; };
% }
%
% DEPLOY LINKDEF Feed
% NEW_LINK_INDEXED class_idx1, tagidx1, classidx_2, tagdix2, classidx3, tagidx3
% LOAD_CONSTANT 1.4
% STORE_LINK_INDEXED 1
% END_DEPLOY
%
% .Feed.gradient
% LINK_LOOP
% .loopstart
% .B_i = gamma_ij*B_i*B_j;
% LOAD_LINK_INDEXED_PARAMETER 1 (load gamma_ij)
% LOAD_DYNAMIC_BY_IDX 1
% MUL
% LOAD_DYNAMIC_BY_IDX 2
% MUL
% STORE_LINK_INDEXED_PARAMETER 2 (store rate_ij)
% LOAD_LINK_INDEXED_PARAMETER 2
% STORE_GRADIENT_BY_IDX 1
% LOAD_LINK_INDEXED_PARAMETER 2
% UNARY_MINUS
% STORE_GRADIENT_BY_IDX 2
% LINK_JUMP .loopstart
% 
% producer, 1 for index 1 of producer list, determined by tag.
% SET_INDEX_OP_CODE 2 class_idx 1 
% Tags must be universal
% LinkInstance has indices i,j,k



c = zeros(0, 'uint8');

% Define constants
c = [ c Compiler.encode_OPCODE(Compiler.DOUBLE_CONSTANT_COUNT, 3) ];
c = [ c Compiler.encode_DOUBLE(1) ];
c = [ c Compiler.encode_DOUBLE(-1) ];
c = [ c Compiler.encode_DOUBLE(0.2) ];

% The standard 3 entries, all pointing just to RET
c = [ c Compiler.encode_OPCODE(Compiler.ENTRY_COUNT, 3) ];
% Entry 1
MODULE_INIT_ENTRY_ADDRESS = numel(c)+1;
c = [ c 0 0 0 0 ]; % Placeholder for entry
c = [ c Compiler.encode_STRING('.init') ];
% Entry 2
MODULE_EVALUATE_PARAMETERS_ADDRESS = numel(c)+1;
c = [ c 0 0 0 0 ]; % Placeholder for entry
c = [ c Compiler.encode_STRING('.evaluate_parameters') ];

% Entry 3
MODULE_EVALUATE_GRADIENTS_ADDRESS = numel(c)+1;
c = [ c 0 0 0 0 ]; % Placeholder for entry
c = [ c Compiler.encode_STRING('.evaluate_gradients') ];

% We define one nodedef
c = [ c Compiler.encode_OPCODE(Compiler.NODEDEF_COUNT,2)]; % CLASS_DEFINITION:2

% Called Feeding
c = [ c Compiler.encode_STRING('Feeding') ];

% TODO: Indexing info here
%c = [ c Compiler.encode_OPCODE(Compiler.INDEX_AS,1)];
%c = [ c Compiler.encode_STRING('i') ];

% The standard 3 entries
c = [ c Compiler.encode_OPCODE(Compiler.ENTRY_COUNT, 3) ];
% Entry 1
FEEDING_INIT_ENTRY_ADDRESS = numel(c)+1;
c = [ c 0 0 0 0 ]; % Placeholder for entry
c = [ c Compiler.encode_STRING('.Feeding.init') ];

% Entry 2
FEEDING_EVALUATE_PARAMETERS_ADDRESS = numel(c)+1;
c = [ c 0 0 0 0 ]; % Placeholder for entry
c = [ c Compiler.encode_STRING('.Feeding.evaluate_parameters') ];

% Entry 3
FEEDING_EVALUATE_GRADIENTS_ADDRESS = numel(c)+1;
c = [ c 0 0 0 0 ]; % Placeholder for entry
c = [ c Compiler.encode_STRING('.Feeding.evaluate_gradients') ];

% Double link indexed parameters in nodedef
c = [ c Compiler.encode_OPCODE(Compiler.DOUBLE_LINK_INDEXED_PARAMETER_COUNT, 2) ];
c = [ c Compiler.encode_STRING({'gamma_ij','rate_ij'}) ];

% Create the NODEDEF
c = [ c Compiler.encode_OPCODE(Compiler.CREATE_NODEDEF) ];

% Called guild
c = [ c Compiler.encode_STRING('Guild') ];
c = [ c Compiler.encode_OPCODE(Compiler.INDEX_AS,1)];
c = [ c Compiler.encode_STRING('i') ];

% The standard 3 entries
c = [ c Compiler.encode_OPCODE(Compiler.ENTRY_COUNT, 3) ];

% Entry 1
INIT_ENTRY_ADDRESS = numel(c)+1;
c = [ c 0 0 0 0 ]; % Placeholder for entry
c = [ c Compiler.encode_STRING('.guild.init') ];

% Entry 2
EVALUATE_PARAMETERS_ADDRESS = numel(c)+1;
c = [ c 0 0 0 0 ]; % Placeholder for entry
c = [ c Compiler.encode_STRING('.guild.evaluate_parameters') ];

% Entry 3
EVALUATE_GRADIENTS_ADDRESS = numel(c)+1;
c = [ c 0 0 0 0 ]; % Placeholder for entry
c = [ c Compiler.encode_STRING('.guild.evaluate_gradients') ];

% Double parameters in nodedef
c = [ c Compiler.encode_OPCODE(Compiler.DOUBLE_PARAMETER_COUNT, 0) ];

% Double indexed parameters in nodedef
c = [ c Compiler.encode_OPCODE(Compiler.DOUBLE_INDEX_PARAMETER_COUNT, 1) ];
c = [ c Compiler.encode_STRING({'alpha_i'}) ];

% Double dynamic parameters in nodedef
c = [ c Compiler.encode_OPCODE(Compiler.DOUBLE_INDEX_DYNAMIC_COUNT, 1) ];
c = [ c Compiler.encode_STRING({'B_i'}) ];

% Create the NODEDEF
c = [ c Compiler.encode_OPCODE(Compiler.CREATE_NODEDEF) ];

% Deploy the newly defined node
c = [ c Compiler.encode_OPCODE(Compiler.DEPLOY, 2) ]; % Deploy Guild
c = [ c Compiler.encode_OPCODE(Compiler.NEW_INDEXED, 1) ]; % New indexed entry
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_CONSTANT_8, 1) ]; % Load number 2
c = [ c Compiler.encode_OPCODE(Compiler.STORE_INDEXED_PARAMETER, 1) ]; % Store to igr (2)
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_CONSTANT_8, 1) ]; % Load number 2
c = [ c Compiler.encode_OPCODE(Compiler.STORE_INDEXED_DYNAMIC, 1) ]; % Store to B (2)

c = [ c Compiler.encode_OPCODE(Compiler.NEW_INDEXED, 1) ]; % New indexed entry
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_CONSTANT_8, 2) ]; % Load number 2
c = [ c Compiler.encode_OPCODE(Compiler.STORE_INDEXED_PARAMETER, 1) ]; % Store to igr (2)
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_CONSTANT_8, 3) ]; % Load number 0.2
c = [ c Compiler.encode_OPCODE(Compiler.STORE_INDEXED_DYNAMIC, 1) ]; % Store to B (2)
c = [ c Compiler.encode_OPCODE(Compiler.END_DEPLOY) ];

c = [ c Compiler.encode_OPCODE(Compiler.DEPLOY, 1) ]; % Deploy Feeding
c = [ c Compiler.encode_NEW_LINK_INDEXED(1,1,1,2,-1,-1) ]; % Spesify the index to input in
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_CONSTANT_8, 1) ]; % Store to gamma_ij (2)
c = [ c Compiler.encode_OPCODE(Compiler.STORE_LINK_INDEXED_PARAMETER, 1) ]; % Store to gamma_ij (2)
c = [ c Compiler.encode_OPCODE(Compiler.END_DEPLOY) ]; % End Deploy Feeding
c = [ c Compiler.encode_OPCODE(Compiler.RET) ];

% .Feeding.init begins here
c(FEEDING_INIT_ENTRY_ADDRESS:FEEDING_INIT_ENTRY_ADDRESS+3) = typecast(cast(numel(c)+1,'uint32'),'uint8');
c = [ c Compiler.encode_OPCODE(Compiler.RET) ];

% .Feeding.update begins here
c(FEEDING_EVALUATE_PARAMETERS_ADDRESS:FEEDING_EVALUATE_PARAMETERS_ADDRESS+3) = typecast(cast(numel(c)+1,'uint32'),'uint8');

c = [ c Compiler.encode_OPCODE(Compiler.LINK_LOOP) ];
loopstart_ptr = numel(c)+1;
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_LINK_INDEXED_PARAMETER, 1) ]; %(load gamma_ij)
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_DYNAMIC_BY_IDX_1, 1) ]; %(load B_i)
c = [ c Compiler.encode_OPCODE(Compiler.MUL_OPERATOR) ]; % *
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_DYNAMIC_BY_IDX_2, 1) ]; %(load B_j)
c = [ c Compiler.encode_OPCODE(Compiler.MUL_OPERATOR) ]; % *
c = [ c Compiler.encode_OPCODE(Compiler.STORE_LINK_INDEXED_PARAMETER, 2) ]; %(store rate_ij)
c = [ c Compiler.encode_OPCODE(Compiler.LINK_JUMP, loopstart_ptr) ]; % load igr_i

% LINK_LOOP
% .loopstart
% .B_i = gamma_ij*B_i*B_j;
% LOAD_LINK_INDEXED_PARAMETER 1 (load gamma_ij)
% LOAD_DYNAMIC_BY_IDX 1
% MUL
% LOAD_DYNAMIC_BY_IDX 2
% MUL
% STORE_LINK_INDEXED_PARAMETER 2 (store rate_ij)
% LOAD_LINK_INDEXED_PARAMETER 2
% STORE_GRADIENT_BY_IDX 1
% LOAD_LINK_INDEXED_PARAMETER 2
% UNARY_MINUS
% STORE_GRADIENT_BY_IDX 2
% LINK_JUMP .loopstart


c = [ c Compiler.encode_OPCODE(Compiler.RET) ];

% .Feeding.gradient begins here
c(FEEDING_EVALUATE_GRADIENTS_ADDRESS:FEEDING_EVALUATE_GRADIENTS_ADDRESS+3) = typecast(cast(numel(c)+1,'uint32'),'uint8');

c = [ c Compiler.encode_OPCODE(Compiler.LINK_LOOP) ];
loopstart_ptr = numel(c)+1;
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_LINK_INDEXED_PARAMETER, 2) ]; %(load rate_ij)
c = [ c Compiler.encode_OPCODE(Compiler.STORE_GRADIENT_BY_IDX_2, 1) ]; %(load B_j)
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_LINK_INDEXED_PARAMETER, 2) ]; %(load rate_ij)
c = [ c Compiler.encode_OPCODE(Compiler.UNARY_MINUS) ]; 
c = [ c Compiler.encode_OPCODE(Compiler.STORE_GRADIENT_BY_IDX_1, 1) ]; %(load B_j)
c = [ c Compiler.encode_OPCODE(Compiler.LINK_JUMP, loopstart_ptr) ]; % load igr_i
c = [ c Compiler.encode_OPCODE(Compiler.RET) ];


% .Guild.init begins here
c(INIT_ENTRY_ADDRESS:INIT_ENTRY_ADDRESS+3) = typecast(cast(numel(c)+1,'uint32'),'uint8');
c = [ c Compiler.encode_OPCODE(Compiler.RET) ];

% .Guild.update begins here
c(EVALUATE_PARAMETERS_ADDRESS:EVALUATE_PARAMETERS_ADDRESS+3) = typecast(cast(numel(c)+1,'uint32'),'uint8');
c = [ c Compiler.encode_OPCODE(Compiler.RET) ];

% .Guild.gradient begins here
c(EVALUATE_GRADIENTS_ADDRESS:EVALUATE_GRADIENTS_ADDRESS+3) = typecast(cast(numel(c)+1,'uint32'),'uint8');
c = [ c Compiler.encode_OPCODE(Compiler.INDEX_LOOP, 1) ]; 
loopstart_ptr = numel(c)+1;
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_INDEXED_PARAMETER, 1) ]; % load alpha_i
c = [ c Compiler.encode_OPCODE(Compiler.LOAD_INDEXED_DYNAMIC, 1) ]; % load B_i
c = [ c Compiler.encode_OPCODE(Compiler.MUL_OPERATOR) ]; % *
c = [ c Compiler.encode_OPCODE(Compiler.STORE_INDEXED_GRADIENT, 1) ]; % load to .B_i
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
% TODO: Verify results
