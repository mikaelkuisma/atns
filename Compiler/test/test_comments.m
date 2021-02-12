function test_comments
tests = { [ '// starting first line with comment' newline 'second' ], ...
          [ 'first' newline '// ending file with comment'], ...
          [ '//////' newline '//','/']};
results = { 'second', ['first' newline], ''};
for i=1:numel(tests)
    i
result = Buffer(tests{i}).read()
uint8(result)
uint8(results{i})
assert(strcmp(result , results{i}))
end

