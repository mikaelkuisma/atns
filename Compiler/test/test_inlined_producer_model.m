buffer = fileread('producer_vectorized.model');
compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
compiler.compile();
Compiler.disassembler(compiler.get_byte_code());
vm = VM(compiler.get_byte_code(), compiler.model);
data2 = vm.compare_solve();

buffer = fileread('producer.model');
compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
compiler.compile();
Compiler.disassembler(compiler.get_byte_code());
vm = VM(compiler.get_byte_code(), compiler.model);
data1 = vm.compare_solve();
%for i=1:6
%plot(data2(i).x, data2(i).y,'-r');
%hold on
%plot(data1(i).x, data1(i).y,'--b');
%end
% TODO: Producer vectorized not outputting correclty from solve (there is 1
% double dynamic size assumption)
%assert(all(abs(data1(:)-data2(:))<1e-10));

