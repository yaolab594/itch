function [scl, scr,p1,p2,p3,p4] = getsclscr(data)
%CREATEFIT(X,Y)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : x
%      Y Output: y
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  另请参阅 FIT, CFIT, SFIT.

%  由 MATLAB 于 07-Sep-2024 13:17:08 自动生成


%% Fit: 'untitled fit 1'.
y = smoothdata(data,'gaussian','SmoothingFactor',0.2);
x = (1:length(y))';
[xData, yData] = prepareCurveData( x, y );

% Set up fittype and options.
ft = fittype( 'poly3' );

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft );
p1 = fitresult.p1;
p2 = fitresult.p2;
p3 = fitresult.p3;
p4 = fitresult.p4;

scl = fitresult.p1.*x.^3+fitresult.p2.*x.^2+fitresult.p3.*x+fitresult.p4;
scr = y-scl;
