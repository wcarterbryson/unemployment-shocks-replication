function Y_lag = my_lagmatrix(Y, lags)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%MY_LAGMATRIX: Creates matrix of lead/lag values from a time series 
%
% File description: 
% This function mimics lagmatrix from the Econometrics Toolbox.
%
% - Inputs: 
%   + Y    : An (n x k) matrix where each column is a separate time series 
%            and each row is an observation.
%   + lags : A vector of integers indicating the lags (positive) or leads 
%            (negative) to apply. For example, lags = [1 2 -1] will produce 
%            columns for 1-step lag, 2-step lag, and 1-step lead.
% - Outputs:
%   + Y_lag : An (n x (length(lags) * k)) matrix of lagged/lead values.
%            Columns are arranged in order of lags, with NaNs for rows 
%            where lagged/lead values are not available.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Preallocate output
[T, N] = size(Y);
p = length(lags);
Y_lag = NaN(T, p * N);

% Loop to fill columns
for ii = 1:p
    lag = lags(ii);
    for jj = 1:N
        col_idx = (ii-1) * N + jj;
        if lag > 0
            Y_lag((lag+1):end, col_idx) = Y(1:end-lag, jj);
        elseif lag < 0
            Y_lag(1:end+lag, col_idx) = Y((-lag+1):end, jj);
        else
            Y_lag(:, col_idx) = Y(:, jj);
        end
    end
end

end
