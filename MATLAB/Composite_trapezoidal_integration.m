function I = Comptrapez(FunName, a, b)
    err = 10;
    n = 2;
    I = 0; 
    while err > 0.01
        h = (b - a)/n;
        x = a:h:b;
        Integ = 0;
        for m = 1:n
            Integ = Integ + (h/2)*(FunName(x(m))+ FunName(x(m+1)));  
        end
        err = Integ - I;
        I = Integ;
        n = n*2;
    end
end