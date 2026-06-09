function [yt_hat, ut_hat] = ham_filter(yt, h, p)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%HAM_FILTER Run Hamilton filter to extract cyclical and trend components
% - Inputs:
%   + yt: time series vector
%   + h: horizon
%   + p: lags
% - Outputs:
%   + yt_hat: trend component
%   + ut_hat: cyclical component
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create matrices for regression
Y = yt;
X = [ones(size(yt)) my_lagmatrix(yt,h:(h+p-1))];

% Trim NaN's
Y = Y(~any(isnan(X),2));
X = X(~any(isnan(X),2),:);

% Regression
B = (X'*X)\(X'*Y);

% Fitted values and residuals
Y_hat = X*B;        % Trend component
U_hat = Y - Y_hat;  % Cyclical component

% Replace with NaN's 
nlags = size(yt,1) - size(Y_hat,1);
yt_hat = [nan(nlags,1); Y_hat];
ut_hat = [nan(nlags,1); U_hat];

end

