function [roots, nofiterations] = NewtonManyVariables(x, f, jf, tol)
    if nargin < 4
        tol = 0.00005;
    end
    nofiterations = 0;
    while true
        fx = feval(f, x);
        jfx = feval(jf, x);
        dx = jfx \ (-fx);
        x = x + dx;
        if norm(feval(f, x)) < tol
            break;
        end        
        nofiterations = nofiterations + 1;
    end
    roots = x;
end
