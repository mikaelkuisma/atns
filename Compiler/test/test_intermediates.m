errored = false;
try
buffer = fileread('intermediates1.model');
compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
compiler.compile();
compiler.disassembler(compiler.get_byte_code());
vm = VM(compiler.get_byte_code(), compiler.model);
data2 = vm.compare_solve([],201);
catch e
    e.message
    assert(startsWith(e.message, '@000002:Unknown symbol A'));
    errored = true;
end
assert(errored);
