buffer = fileread('nodedef_errors_1.model');
compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
errored = false;
try
   compiler.compile();
catch e
    e.message
    assert(startsWith(e.message,'Error in file N/A line 3 col 15'));
    assert(contains(e.message,'Undefined index p.'));
    errored = true;
end

assert(errored);

errored = false;
buffer = fileread('nodedef_errors_2.model');
compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
try
   compiler.compile();
catch e
    if ~contains(e.message,'Undefined index p.')
        rethrow(e);
    end
    errored = true;
end
assert(errored);



errored = false;
buffer = fileread('nodedef_errors_3.model');
compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
try
   compiler.compile();
catch e
    if ~strcmp(e.message,'Undefined index p.')
        rethrow(e)
    end
    errored = true;
end
assert(errored);

