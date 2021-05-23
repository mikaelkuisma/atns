function RunAllPlots
% plotting color indeces for each species

load('colorindex_datastructure.mat', 'dataStruct');
%strVector = ['White', 'Red', 'Blue'];
sdStrVector = [0.05 0.10 0.15 0.20];

figure(111);
for ii = 1:4
    subplot(2,2,ii);
    for jj = 1:3
        plot(dataStruct(ii).tempStruct(jj).cIndeces);
        hold on;
    end
    legend('White', 'Red', 'Blue');
    title(strcat('SD = ', num2str(sdStrVector(ii))));
end

