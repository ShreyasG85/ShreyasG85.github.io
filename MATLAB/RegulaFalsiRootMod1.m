function root = RegulaFalsiRootMod1(func, xl, xu, error)
format long

% set default error 
if nargin < 4 || error < 4
    error = 0.0001;
end

% max number of iterations
i = 100;

% initialize 
root = 0;
xr = 0;
itr = 0;

% loop until relative error is smaller or equal to error
while itr <= i
    y = xr;
    fxl = feval(func, xl);
    fxu = feval(func, xu);
    xr = xu - (fxu * (xl - xu)) / (fxl - fxu);
    fxr = feval(func, xr);
    itr = itr + 1;
    
    if fxr == 0
        root = xr;
        break;
    end
    
    if fxl * fxr < 0
        xu = xr;
    else
        xl = xr;
    end
    
    % if endpoint stays the same 
    if xr == y
        if mod(itr, 3) == 0
            fxr = fxr / 2;
        end
    end
    
    % if relative error is smaller or equal to error
    relError = abs((xr - y) / xr);
    if relError <= error
        root = xr;
        break;
    end
end

% if max number of iterations is reached
if itr >= i
    fprintf('The answer has not been derived in %d iterations.\n', i);
end
