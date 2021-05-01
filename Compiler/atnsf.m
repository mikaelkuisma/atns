function results = atns(modelfile, optimize, varargin)
buffer = fileread(modelfile);
parser = Parser(Tokenizer(Buffer(buffer)));
compiler = Compiler(parser);
compiler.compile();
bytecode = compiler.get_byte_code();
Compiler.disassembler(bytecode);
vm = VM(compiler.get_byte_code(), compiler.model, optimize);
parameters = SolverParameterSet(varargin{:});
% w/o comments: Elapsed time is 200.198180 seconds.

results = vm.jit_solve(parameters);
results