field = 'allbiomasses';

figure(1)
clf

B = Results.(field);
% y0 = 95;

INDS1 = {23:27, 28:32};
titleStrs = {'Whitefish', 'Perch'};

for i = 1:2
    subplot(2,1,i)
    Inds1 = INDS1{i};
    titleStr = titleStrs{i};
    Inds2 = Data.ltspan*(y0-1)+[(1:Data.ltspan) ; (1:Data.ltspan)+Data.ltspan ; (1:Data.ltspan)+2*Data.ltspan ; (1:Data.ltspan)+3*Data.ltspan];

    B_cohort = [B(Inds1(1),Inds2(1,:)) B(Inds1(2),Inds2(2,:)) ...
        B(Inds1(3),Inds2(3,:)) B(Inds1(4),Inds2(4,:))];
    plot(B_cohort, 'LineWidth', 1)
    hold on
    axis tight
    box off
    set(gca, 'TickDir', 'out')
    ylabel('Density')
    xlabel('Time (years)')
    title(titleStr)
    plot([Data.ltspan Data.ltspan], get(gca, 'YLim'), '--k')
    plot(2*[Data.ltspan Data.ltspan], get(gca, 'YLim'), '--k')
    plot(3*[Data.ltspan Data.ltspan], get(gca, 'YLim'), '--k')
    set(gca, 'FontSize', 16)
    set(gca, 'XTick', 0:Data.ltspan:4*Data.ltspan)
    set(gca, 'XTickLabel', {'0', '1', '2', '3', '4'})

    htY = 0.5*max(get(gca, 'YLim'));

    ht(1) = text(35, htY, 'Larvae');
    ht(1).FontSize = 20;

    ht(2) = text(123, htY, 'Juveniles');
    ht(2).FontSize = 20;

    ht(3) = text(203, htY, 'Adults (2 years)');
    ht(3).FontSize = 20;

    ht(4) = text(292, htY, 'Adults (3 years)');
    ht(4).FontSize = 20;
end