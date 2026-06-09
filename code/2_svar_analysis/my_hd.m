function hd_decomp = my_hd(BB, par)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%VARIANCE_DECOMP Compute closed form variance contribution
% - Inputs: 
%   + BB  : struct array containing estimation output 
%   + par : struct array containing parameters
% - Outputs:
%   + hd_decomp : historical decomposition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% Print progress to screen
if par.verbose
    disp('---------------------------------------------------------------')
    disp('----- Starting HD ---------------------------------------------')
    disp('---------------------------------------------------------------')
end

% Set some parameters
[T, N] = size(BB.data); % Size of Y
p = par.p;              % Number of lags
K = par.opt.K;          % Number of draws
In = eye(N);            % Identity matrix
Y0 = zeros(1, N);       % Initialize at ss = 0

% Loop over draws
hd_decomp_d = nan(T-p, N, N, K);    % Preallocate HD
for iik = 1:K

    % Extract matrices for each draw
    Phi = BB.Phi_draws(:,:,iik);    % Coefficients
    Sig = BB.Sigma_draws(:,:,iik);  % Variance-covariance matrix
    Ut  = BB.e_draws(:,:,iik);      % Innovations  

    % Set impact matrix based on model
    Atl = chol(Sig, 'lower');
    A = Atl; % Default impact matrix
    if strcmp(BB.mdl, 'zerosign')
        A = A * BB.Omegaz(:,:,iik); % Apply rotation if needed
    end

    % Back out structural shocks
    Et = (A\Ut')';          
    
    % Separate coefficients
    P0 = Phi(end,:);        % Coefficients: intercept
    P1 = Phi(1:end-1,:);    % Coefficients: VAR
    
    % Loop over shocks
    for iis = 1:N
    
        % Initialize simulation
        Yc = nan(T-p, N);
        Yc(1,:) = Y0;
    
        % Loop over time
        for iit = 2:(T-p)
    
            % Compute Lags of Y (check i < p)
            if iit < p + 1
                LYc = [Yc((iit-1):-1:1,:); repmat(Y0,p - (iit - 1),1)];
            else
                LYc = Yc((iit-1):-1:(iit-p),:);
            end
    
            % Update simulated Y
            Yc(iit,:) = P0' + P1'*vec(LYc') + Et(iit,iis).*(A*In(:,iis));
    
        end
    
        % Store for each draw
        hd_decomp_d(:,:,iis,iik) = Yc;
    
    end

    % Print
    if ismember(iik,0:(K / 10):K) && par.verbose
        disp(['Draw number: ' num2str(iik)])
    end

end

% Extract the median
hd_decomp = median(hd_decomp_d,4);
