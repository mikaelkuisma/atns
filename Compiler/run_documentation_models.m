function run_documentation_models
folder = '..\doc\examples\';
files = dir(fullfile(folder,'*.model'));

for file_info=files'
    run_doc_model(fullfile(file_info.folder, file_info.name));
end

function run_doc_model(filename)
filename
buffer = Buffer(fileread(filename));
compiler = Compiler(Parser(Tokenizer(buffer)));
compiler.compile();
compiler.model.repr()

Compiler.disassembler(compiler.get_byte_code());
vm = VM(compiler.get_byte_code(), compiler.model);
data2 = vm.solve();



