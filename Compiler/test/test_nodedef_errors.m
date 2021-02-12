buffer = fileread('nodedef_errors_1.model');
compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
try
   compiler.compile();
catch e
    e.message
    assert(strcmp(e.message,'@000009:Undefined index p.'));
end