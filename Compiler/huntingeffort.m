x=1;
fa=0.4;
fm=0.1;
lambda = linspace(0,3,1000);
B=1;
D=1;
y=8;
for F=linspace(0,1,20)
dotA = D*(lambda.^0.5./(lambda.^0.5+D))*x*y*F*B;
dotB = 1/3*(lambda)*x*y*B;%+fm*x*B;
%dB = (-1/4+(1./(lambda+D)-lambda./(lambda+D).^2))*fa*x*y*F*B;
hold off
plot(lambda, dotA-dotB,'r');
%plot(lambda, dotB,'b');
hold on
%plot(lambda, dB);
plot(lambda, gradient(dotA-dotB, lambda),'--');
plot(lambda, 1./gradient(dotA-dotB, lambda),':');
plot(lambda, (dotA-dotB)/(x*y*F*B),'b');
%plot(-D+sqrt(D*y*F),0,'o');
title(num2str(F))
ylim([-2 2]);
pause(0.2)
end