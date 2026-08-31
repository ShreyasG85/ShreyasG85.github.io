clear
clearvars
format short
x = load('data.txt');
n = length(x);
xo = usesort(x);

[f, X] = GroupData(xo);
bar(X, f)

[A, s] = MeanStD(xo);

g = zeros(1, length(xo));
for i=1:length(g)
    g(i) = exp((-((xo(i)-A)/s)^2)/2) / (s*sqrt(2*pi));
end

scatter(xo, g, 'filled')
figure()
bar(X, f/n)

CDF = @(x1) cdf('Normal', x1, A, s);
P1 = CDF(174);
P2 = CDF(182) - CDF(174);

disp(P1)
disp(P2)