function atnsinit
[filepath,name,ext] = fileparts(mfilename('fullpath'))
run(fullfile(filepath, '.\Compiler\atnspaths.m'));