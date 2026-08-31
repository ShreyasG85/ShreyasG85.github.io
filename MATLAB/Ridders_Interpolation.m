[x, df] = DerivativeRidders(@(x) exp(x) / (sin(x) - x^2), 1, 0.01);
disp(['The derivative at x=1 is: ' num2str(df)]);

function [a, df] = DerivativeRidders(func, x, h, err)
format long;
if h == 0
    disp('h must be nonzero');
    return;
end
if nargin < 4
    err = 1e-7;
end
a = zeros(5);
df = (feval(func, x + h) - feval(func, x - h)) / (2 * h);
a(1, 1) = df;
for i = 2:5
    h = h / 2;
    dfn = (feval(func, x + h) - feval(func, x - h)) / (2 * h);
    a(1:i, i) = dfn;
    for j = 2:i
        a(j,i) = (4.^(j-1) * a(j-1,i) - a(j-1, i-1)) / (4.^(j-1) - 1);
    end
    e = max(abs(a(i,i)-a(i-1,i)), abs(a(i,i)-a(i-1,i-1)));
    if e < err
      df = a(i, i);
      return;
    end
end
df = a(5,5);
end

