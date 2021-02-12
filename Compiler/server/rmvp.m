function str=rmvp(str)
if ~isempty(str)
while((str(end)==' ') ||(uint8(str(end))==13)), str=str(1:end-1); end
end