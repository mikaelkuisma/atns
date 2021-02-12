function results = atns(modelfile, varargin)
buffer = fileread(modelfile);
parser = Parser(Tokenizer(Buffer(buffer)));
compiler = Compiler(parser);
compiler.compile();
bytecode = compiler.get_byte_code();
vm = VM(compiler.get_byte_code(), compiler.model);
parameters = SolverParameterSet(varargin{:});
results = vm.jit_jacobian_simple(parameters);
results