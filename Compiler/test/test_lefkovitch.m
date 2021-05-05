buffer = fileread('lefkovitch.model');
compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
compiler.compile();
code = compiler.get_byte_code()

Compiler.disassembler(code);
vm = VM(code, compiler.model);
results  = vm.compare_solve();
data = results.get_struct();
row = [ data{3}.data{1}.y(end) data{2}.data{1}.y(end) data{1}.data{1}.y(end) data{4}.data{1}.y(end) ];
ref = 1e-3*[ 0.000000000000000   0.000000101406332   0.018934392758488   0.199229477708892];
assert(norm(row-ref)<1e-10);
