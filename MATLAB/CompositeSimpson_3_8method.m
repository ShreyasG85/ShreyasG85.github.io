function I = Simp38(FunName, a, b)

    % Initialize 
    n = 3; 
    h = (b - a) / (3*n); 
    x = linspace(a, b, 3*n+1); 
    y = FunName(x); % calculate values
    
    % calculate integral 
    I = (3*h/8) * (y(1) + 3*sum(y(2:3:end-1)) + 3*sum(y(3:3:end-2)) + 2*sum(y(4:3:end-3)) + y(end));
    
    % error
    err = Inf;
    while err > 0.01*I
        n = n*2;
        h = (b - a) / (3*n);
        x = linspace(a, b, 3*n+1);
        y = FunName(x);
        Ip = I;
        I = (3*h/8) * (y(1) + 3*sum(y(2:3:end-1)) + 3*sum(y(3:3:end-2)) + 2*sum(y(4:3:end-3)) + y(end));
        err = abs(I - Ip);%calculate error
    end
end