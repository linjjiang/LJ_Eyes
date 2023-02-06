function [speed,direction] = WindRandomDistrib(N,maxspeed)
if nargin==1
    maxspeed = 20;
end
x     = linspace(0,2*pi,100000);

n = randi([2 10],1);
Y = linspace(0.001,1,n)';
Y = Y(randperm(n));
Y = [Y;Y(1)];
X = linspace(0,2*pi,n+1);

func  = @(x) interp1(X,Y,x,'pchip');

f = cumsum(func(x)*mean(diff(x)));
f = f/max(f);

direction = mod(interp1(f,x,rand(N,1),'spline')*180/pi,360);

% direction = mod(randn(N,1)*2*pi*180/pi,360);

speed = maxspeed*randn(N,1);
while any(speed>maxspeed)
    speed(speed>maxspeed) = 30*randn(sum(speed>maxspeed),1);
end