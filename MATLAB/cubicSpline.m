format short
clear
clearvars
clc
x = [10 25 40 55];
y = [12 26 28 30];
n = length(x);
k = zeros(length(x));
b = zeros(1, length(x));
z = 0;
for i=2:n-1
    k(i, z+1) = (x(i-1) - x(i));
    k(i, z+2) = 2*(x(i-1) - x(i+1));
    k(i, z+3) = x(i) - x(i+1);
    b(1, i) = 6*(((y(i-1) - y(i))/(x(i-1) - x(i))) - ((y(i) - y(i+1))/(x(i) - x(i+1))));
    z = z+1;
end

k(1, 1) = 1; 
k(n, n) = 1; 
b = b';
M = k\b;
for i=1:n-1
    X = linspace(x(i), x(i+1));
    Y = evalSpline(X, x(i), x(i+1), y(i), y(i+1), M(i), M(i+1));
    plot(X, Y, 'k')
    hold on
end
plot(x, y, '*r');
plot(30, evalSpline(30, 25, 40, 26, 28, -0.0853, 0.0213), 'Ob')

function Y = evalSpline(X, xi, xi1, yi, yi1, mi, mi1)
    Y = ((X - xi1).^3/(xi - xi1) - (X - xi1)*(xi - xi1))*mi/6 - ((X - xi).^3/(xi - xi1) - (X - xi)*(xi - xi1))*mi1/6 + yi*(X - xi1)/(xi - xi1) - yi1*(X - xi)/(xi - xi1);
end