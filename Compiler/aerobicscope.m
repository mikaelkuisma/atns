data = zeros(3,10000);
dt = 0.01;
x0 = 1;
x = 2;
y=0;
X=0.1;
lambda = 4;
for i=1:50000
    G = sin(i/25000*pi);
    x = x + y*x*dt;
    y = y + (-1/X*(x*y) + G - lambda*(x-x0))*dt;
    data(:,i) = [ x;y;G];
end
plot(data');
legend({'x','y','G'});