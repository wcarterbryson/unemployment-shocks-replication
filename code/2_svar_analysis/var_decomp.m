function VD = var_decomp(BB, par, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%VARIANCE_DECOMP Compute closed form variance contribution
% - Inputs: 
%   + BB  : struct array containing estimation output 
%   + par : struct array containing parameters
% - Outputs:
%   + VD  : table with variance contribution of each shock to each variable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Print progress to screen
if par.verbose
    disp('---------------------------------------------------------------')
    disp('----- Starting variance contribution --------------------------')
    disp('---------------------------------------------------------------')
end

% Set some parameters
N = BB.N;       % Number of variables (same as number of shocks)
p = par.p;      % Number of lags
K = par.opt.K;  % Number of draws
In = eye(N);    % Eye(N) matrix

% Set some coefficients to 0
ZZ = ones(N*p + 1, N);
if length(varargin) >= 1
    disp('----- Placing restrictions on some coefficients')
    res = varargin{1};
    for ii = 1:length(res)
        vv = res{ii}{1};
        ss = res{ii}{2};
        ZZ(ss:N:(N*p), vv) = 0;
    end
end

% Loop over draws
bet_vsd = nan(N, N, K); % Preallocate (variable, shock, draw)
for iid = 1:K

    % Get coefficient for each draw
    Phi1 = BB.Phi_draws(:, :, iid);
    Sig1 = BB.Sigma_draws(:, :, iid);
    PP = ZZ.*Phi1;  % Optional: set some coefficients to 0

    % Set Impact matrix
    Q1 = In;
    if strcmp(BB.mdl, 'zerosign')
        Q1 = BB.Omegaz(:, :, iid);
    end
    C = chol(Sig1, 'lower');
    A = C*Q1;

    % Get variance-covariance matrix | all shocks
    Gam0 = cov_varp(PP, Sig1);  % Variance-covariance matrix
    var_Yhat = diag(Gam0);      % Variance of each variable

    % Get variance-covariance matrix | one shock at a time
    Gam0_v = nan(N, N, N);
    var_Yhat_v = nan(N, N);
    for iin = 1:N
        Gam0_v(:,:,iin) = cov_varp(PP, A(:,iin)*A(:,iin)');
        var_Yhat_v(:,iin) = diag(Gam0_v(:,:,iin));
    end

    % Store variance decomposition for specific draw
    bet_vsd(:,:,iid) = 100 .* var_Yhat_v ./ var_Yhat;

    % Print
    if ismember(iid, 0:(K / 10):K) && par.verbose
        disp(['Draw number: ' num2str(iid)])
    end

end

% Take mean across draws
bet_vs = mean(bet_vsd, 3);

% Convert to table
VD = array2table(bet_vs, ...
    'VariableNames', par.opt.shocksnames, ...
    'RowNames', par.opt.varnames);
VD.Total = sum(bet_vs, 2);  % Add cumulative column

end
