x = [0.76 6.66 9.44 16.8];
y = [3.74 4.90 9.97 9.62];

spl = spline(x, y);

coefs = spl.coefs;

% first and second derivatives with xi
xd = 0.76:0.1:16.8;
n = length(x) - 1;
yd = zeros(1, length(xd));
dyd = zeros(1, length(xd));
d2yd = zeros(1, length(xd));
for i = 1:n
    idx = (xd >= x(i)) & (xd <= x(i + 1));
    a = coefs(i, 1);
    b = coefs(i, 2);
    c = coefs(i, 3);
    d = coefs(i, 4);
    xi = xd(idx) - x(i);
    yd(idx) = a * xi.^3 + b * xi.^2 + c * xi + d;
    dyd(idx) = 3 * a * xi.^2 + 2 * b * xi + c;
    d2yd(idx) = 6 * a * xi + 2 * b;
end

% Plotting
scatter(x, y, 'k', 'filled');
hold on;
plot(xd, yd);
plot(xd, dyd, ':');
plot(xd, d2yd, '--');
hold off;
legend({'Data Points', 'f(x)', 'f''(x)', 'f’’’(x)'}, 'Location', 'best');
title('Spline Interpolation and Derivatives');
xlabel('x');
ylabel('y');

% first and second derivative at x=15
x_val = 15;
interval_idx = 1;
for i = 1:length(x)-1
    if x(i) <= x_val && x_val <= x(i+1)
        interval_idx = i;
        break;
    end
end
a = coefs(interval_idx, 1);
b = coefs(interval_idx, 2);
c = coefs(interval_idx, 3);
d = coefs(interval_idx, 4);
dx = x_val - x(interval_idx);
dydx = 3 * a * dx^2 + 2 * b * dx + c;
d2ydx2 = 6 * a * dx + 2 * b;
fprintf('First derivative at x=15: %f\n', dydx);
fprintf('Second derivative at x=15: %f', d2ydx2);


