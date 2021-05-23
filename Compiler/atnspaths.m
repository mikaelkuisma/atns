function atnspaths
[filepath,name,ext] = fileparts(mfilename('fullpath'));
addpath(filepath);
addpath(fullfile(filepath, '/../'));
addpath(fullfile(filepath, '/test'));
addpath(fullfile(filepath, '/server'));
addpath(fullfile(filepath, '/SE'));
addpath(fullfile(filepath, '/test/old'));