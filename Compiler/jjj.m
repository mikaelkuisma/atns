function a
dt=0.01;
t=0;
B=1;
Bp=1.1;
data=zeros(4,1000);
C = log(Bp);
C1 = log(Bp)-log(B);
for i=1:1000
    B = B+f(B)*dt;
    Bp = Bp+f(Bp)*dt;
    C = C + f(exp(C))*exp(-C)*dt;
    C1 = C1 - f(exp(C))*C1*dt;
    data(:,i) = [ B;Bp;C;C1];
    t=t+dt;
end
clf
plot(log(data(1,:)),'Linewidth',2);
data(1,:)=0;
hold on
plot(log(data(2,:)-data(1,:)),'Linewidth',2);
plot(log(exp(data(3,:))-data(1,:)),'--','Linewidth',2);
plot(log(exp(log(1.0)+data(4,:))-data(1,:)),':','Linewidth',2);
legend({'A','B','C'});
function dBdt = f(B)
dBdt = B;%+3*B;
