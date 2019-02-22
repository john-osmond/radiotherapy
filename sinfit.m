function [estimates, model] = sinfit(xdata, ydata, sininp)

model = @sine;

% Set some options and run fminsearch:

options = optimset(@fminsearch);
options = optimset('MaxIter', 1000000, 'MaxFunEvals', 1000000);
estimates = fminsearch(model, double(sininp), options);

    % Define function to be fitted:

    function [sse, FittedCurve] = sine(params)
        
        A = params(1);
        f = params(2);
        x = params(3);
        y = params(4);
        
        FittedCurve = (A.*sin((xdata+x)*f)) + y;
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
        
    end

end