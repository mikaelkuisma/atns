buffer = fileread('producer_consumer.model');
compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
compiler.compile();
Compiler.disassembler(compiler.get_byte_code());
vm = VM(compiler.get_byte_code(), compiler.model);
data2 = vm.compare_solve();
for d=1:2
plot(data2(d).x, data2(d).y);
hold on
end
