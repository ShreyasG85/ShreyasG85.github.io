clear
clc
Strain=0:.4:6;
Stress=[0 3 4.5 5.8 5.9 5.8 6.2 7.4 9.6 15.6 20.7 26.7 31.1 35.6 39.3 41.5];
[a,Er]=CubPolFit(Strain,Stress);
fprintf('Coefficients: ')
disp(a')
fprintf('Overall error: %fn',Er)
plot(Strain,Stress,'o')
x=0:.1:6;
y=a(1)*x.^3+a(2)*x.^2+a(3)*x+a(4);
hold on
plot(x,y)
hold off
grid on
legend('Data','Cubic best fit','location','best')
ylabel('Stress MPa')
xlabel('Strain')

%Function
function [a,Er]=CubPolFit(x,y)
% x and y should be row vectors
x=x';
y=y';
n=3:-1:0;
A=x.^n;
a=A\y;
yy=a(1)*x.^3+a(2)*x.^2+a(3)*x+a(4);
Er=sum(abs(y-yy));
end