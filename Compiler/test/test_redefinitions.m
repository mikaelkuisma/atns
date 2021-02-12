%buffer = fileread('producer_consumer_deploy.model');
for d=1:2
    try
buffer = fileread(sprintf('redefinitions%d.model',d));
compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
compiler.model.repr()
compiler.compile();
compiler.disassembler(compiler.get_byte_code());
vm = VM(compiler.get_byte_code(), compiler.model);
data2 = vm.compare_solve();
    catch e
        e.message
        c = 'AE';
        assert(startsWith(e.message, ['@000013:Symbol already defined: ' c(d) '.']));
    end
end

