function par = set_paras()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%set_paras Sets parameters
% File description: Set all parameters and opt for estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parameters
par.p = 4;              % Number of lags
par.save_flag = true;   % Save the results?
par.plot_flag = false;  % Plot the results in Matlab?
par.verbose = true;     % Display output to screen?
par.seed = 2;           % Set the seed

% Options for estimation: passed to bvar_.m
par.opt.K = 10000;                  % Number of draws
par.opt.hor = 24;                   % Horizon for IRF (5 years)
par.opt.irf_1STD = 1;               % Use 1 std. (1) or 1% (0) for IRF
par.opt.conf_sig   = 0.68;          % Interior credible set
par.opt.conf_sig_2 = 0.90;          % Exterior credible set
par.opt.priors.name = 'Conjugate';  % Set priors
par.opt.shocksnames = {'Inflow','Outflow','Level','Length'}; 
par.opt.varnames    = {'Job separation probability',...
    'Job finding probability','Unemployment rate',...
    'Average unemployment duration'};

end
