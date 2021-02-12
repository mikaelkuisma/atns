%buffers = { 'B=3;alpha=2;.B=alpha*B;' };
buffers = { 'parameter alpha=1;parameter beta=1;parameter gamma=1;dynamic B1=2/3;dynamic B2=1/2;.B1=alpha*B1-gamma*B1*B2;.B2=-beta*B2+gamma*B1*B2;' };

results = [];
namespace = Namespace();

for i=1:numel(buffers)
compiler = Compiler(Parser(Tokenizer(Buffer(buffers{i}))));
compiler.compile();
code = compiler.get_byte_code();
Compiler.disassembler(code);
fprintf('0x%02x, ',code(0xd2:end));
vm = VM(compiler.get_byte_code(), compiler.model);
data = vm.compare_solve();
end
