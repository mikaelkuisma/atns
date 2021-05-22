buffer = fileread('LCmbr.model');
compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
compiler.model.repr()
compiler.compile();
compiler.disassembler(compiler.get_byte_code());
vm = VM(compiler.get_byte_code(), compiler.model);
[x,data2] = vm.compare_solve().get_daily_data();
clf
hold on
for i=1:42
    %plot(x, log10(data2),'xb');
    plot(x, log10(data2),'-b');
    %text(0.2, log10(data2(i).y(1)), num2str(i));
end
load results_for_new_code_wgonads.mat B0
hold on
for y=0:3
plot((0:90)+y*90, log10(B0(1+y*91:91+y*91,:))','or');
end
%xxx
%clf
%hold on
%for i=1:42
%    plot(data2(i).x, (data2(i).y),'-xb');
%    text(0.2, (data2(i).y(1)), num2str(i));
%end
%load results_for_new_code_wgonads.mat B0
%hold on
%for y=0:3
%plot((0:90)+y*90, (B0(1+y*91:91+y*91,:))','or');
%end
%xxx
%xlim([0 12]);
%figure(2);
%clf
%plot(0,B0(1,:),'xb');
%hold on
%for i=1:42
%    plot(data2(i).x(1), data2(i).y(1),'o');
%    text(0.2, (data2(i).y(1)), num2str(i));
%end
%
%plot(1,B0(2,:),'x');
%hold on
%row =[];
%clf
%for day=0:2
%for i=1:42
%    %plot(data2(i).x(21), data2(i).y(21),'o');
%    row(i) = data2(i).y(1+20*day);
%    %text(0.2, (data2(i).y(1)), num2str(i));
%end
%plot(row-B0(day+1,:));
%hold on
%end

