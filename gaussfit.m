function [a1, mu1, sigma1, a2, mu2, sigma2] = gaussfit(xdata, ydata, type)

% Matlab script to accept two arrays of xdata and ydata, and fit using two
% Gaussian curves.

verbosity = 0;

if ( verbosity == 1 )
    fprintf('\n%s\n','Double Gaussian curve fitting routine version 1.1.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% MAIN FUNCTION

% Create sensible starting values for single Gaussian fit:

astart = max(ydata);
mustart = xdata(find(ydata == max(ydata)));
sigmastart = sqrt(mustart);

sgaussinp = [astart, mustart sigmastart];

% Fit single Gaussian curve to data:

[estimates, model] = sgaussfit(xdata, ydata, sgaussinp);

% Use output from single Gaussian fit as input for double Gaussian fit:

destimates = [estimates 0 0 0];
dmodel = model;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ( strcmp(type,'d') == 1 )
    
    a2start = estimates(1);
    mu2start = estimates(2) + 3*estimates(3);
    sigma2start = estimates(3);
    
    dgaussinp = [estimates a2start mu2start sigma2start];
    
    % Fit double Gaussian curve to data:
    
    [destimates, dmodel] = dgaussfit(xdata, ydata, dgaussinp);
    
end
    
% Write output variables:
    
a1 = destimates(1);
mu1 = destimates(2);
sigma1 = destimates(3);
a2 = destimates(4);
mu2 = destimates(5);
sigma2 = destimates(6);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (verbosity == 1 )
    
    % Write out results:
    
    fprintf('\n%s %3.0f %s %3.0f %s %3.2f%s\n','First Gaussian has: A =',destimates(1),'; Mu =',destimates(2),'; Sigma =',destimates(3),',');
    fprintf('\n%s %3.0f %s %3.0f %s %3.2f%s\n','Second Gaussian has: A =',destimates(4),'; Mu =',destimates(5),'; Sigma =',destimates(6),'.');
    
    if ( strcmp(type,'d') == 1 )
        
        sigtest = (mu2-mu1)/sqrt((sigma1^2)+(sigma2^2));
        prob = 100*erf(sigtest*(sqrt(0.5)));
        
        fprintf('\n%s %3.2f %s %3.2f%s\n','Curves are displaced by',sigtest,'sigma (',prob,'% ).');
    
    end
    
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot data and model:

if ( verbosity == 1 )
    
    plot(xdata, ydata, 'd', 'markersize', 6, 'markeredgecolor', 'b','markerfacecolor', 'none', 'linewidth', 1.5);
    
    hold on;
    
    [sse, FittedCurve] = dmodel(destimates);
    plot(xdata, FittedCurve, 'r');
    
    xlabel('Counts/Pixel');
    ylabel('No of Pixels');
    title('Source and Background Distribution');
    legend('Data', 'Model');
    
    hold off;
    
    plotname = 'gaussfit.jpg';
    print('-djpeg',plotname);
    fprintf('\n%s %s\n\n','Plot written to:',plotname);

end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SUBFUNCTIONS

% Single Gaussian curve fitting subfunction:

function [estimates, model] = sgaussfit(xdata, ydata, gaussinp)

model = @gauss;

% Set some options and run fminsearch:

options = optimset(@fminsearch);
options = optimset('MaxIter',1000000,'MaxFunEvals',1000000);
estimates = fminsearch(model, double(gaussinp), options);

    % Define function to be fitted:

    function [sse, FittedCurve] = gauss(params)
        
        A = params(1);
        mean = params(2);
        sigma = params(3);
        FittedCurve = A.*exp(-0.5.*((xdata-mean).^2)./(sigma^2));
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Double Gaussian curve fitting subfunctiom:

function [estimates, model] = dgaussfit(xdata, ydata, dgaussinp)

model = @dgauss;

% Set some options and run fminsearch:

options = optimset(@fminsearch);
options = optimset('MaxIter',1000000,'MaxFunEvals',1000000);
estimates = fminsearch(model, double(dgaussinp), options);

    % Define function to be fitted:
    
    function [sse, FittedCurve] = dgauss(params)
        
        A = params(1);
        mean = params(2);
        sigma = params(3);
        A2 = params(4);
        mean2 = params(5);
        sigma2 = params(6);
        FittedCurve = (A.*exp(-0.5.*((xdata-mean).^2)./(sigma^2))) + (A2.*exp(-0.5.*((xdata-mean2).^2)./(sigma2^2)));
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end
end