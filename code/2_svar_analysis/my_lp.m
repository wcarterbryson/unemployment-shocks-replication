function [lp, lp_low, lp_upp] = my_lp(lp_vars, dt, BB, par)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%MY_LP Run local projections on auxiliary variables
% - Inputs: 
%   + lp_vars : T x M matrix of outcome variables
%   + dt      : T x 1 vector of corresponding time variable
%   + BB      : struct array containing estimation output 
%   + par     : struct array containing parameters
% - Outputs:    
%   + lp      : coefficient estimates; dim = (outcome, shock, horizon)
%   + lp_low  : lower confidence interval; dim = (outcome, shock, horizon)
%   + lp_upp  : upper confidence interval; dim = (outcome, shock, horizon)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Print progress to screen
if par.verbose
    disp('---------------------------------------------------------------')
    disp('----- Starting LPs --------------------------------------------')
    disp('---------------------------------------------------------------')
end

% Set some parameters
N = BB.N;               % Number of variables (same as number of shocks)
[T, M] = size(lp_vars); % Number of (time periods, local projections)
P = par.p;              % Number of lags
H = par.opt.hor;        % Number of horizons for IRF
K = par.opt.K;          % Number of draws

% Break if date range does not correspond to outcome variables
if T ~= length(dt)
    error('Make sure date range corresponds to time period for outcomes.')
end

% Preallocate LPs: (outcome, shock, horizon, draw)
lp_draws     = nan(M, N, H, K); % Coefficient
lp_low_draws = nan(M, N, H, K); % Lower confidence internal
lp_upp_draws = nan(M, N, H, K); % Upper confidence internal

% Loop over draws
for iik = 1:K

    % Set matrices
    Sig = BB.Sigma_draws(:,:,iik);
    Ut  = BB.e_draws(:,:,iik);
    
    % Set impact matrix based on model
    Atl = chol(Sig, 'lower');
    A = Atl; % Default impact matrix
    if strcmp(BB.mdl, 'zerosign')
        A = A * median(BB.Omegaz, 3); % Apply rotation if needed
    end

    % Back out structural shocks
    Et = (A\Ut')';

    % Loop over shocks
    for iis = 1:N

        % Get shock 
        xlp = Et(:,iis);
    
        % Loop over outcome variables
        for iiv = 1:M
            
            % Loop over horizons
            for iih = 1:H
    
                % Variable y at horizon h
                ylp = my_lagmatrix(lp_vars(:,iiv), -iih);
    
                % Trim dt
                ylp = ylp(ismember(dt((P+1):end), dt));
                xlp = xlp(ismember(dt((P+1):end), dt));
    
                % Regression data
                Xlp = [ones(size(xlp)) xlp];
    
                % Run the regression
                [Blp, Blp_int] = regress(ylp, Xlp);
    
                % Store the results
                lp_draws(iiv,iis,iih,iik)     = Blp(end);
                lp_low_draws(iiv,iis,iih,iik) = Blp_int(end, 1);
                lp_upp_draws(iiv,iis,iih,iik) = Blp_int(end, 2);
    
            end
    
        end
    
    end

    % Print
    if ismember(iik,0:(K / 10):K) && par.verbose
        disp(['Draw number: ' num2str(iik)])
    end

end

% Extract the median across draws
lp = median(lp_draws, 4);
lp_low = median(lp_low_draws, 4);
lp_upp = median(lp_upp_draws, 4);
