function BB = estimate_svar(Yt, par, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ESTIMATE_SVAR_CHOL Estimate (Bayesian) SVAR using Canova and Ferroni 
% Empirical macro toolbox.
% - Inputs: 
%   + Yt  : T x k matrix of time series variables
%   + par : struct array containing parameters
%   + mdl : option to use order (default) or zero-sign restrictions
% - Outputs:
%   + BB  : struct array containing estimation output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Determine which restrictions to impose
if length(varargin) >= 1
    mdl = varargin{1};
else
    mdl = 'cholesky';   % Default = Cholesky
end

% Print progress to screen
if par.verbose
    disp('--------------------------------------------------------------')
    disp(['----- Running model: ' mdl ' --------------------------------'])
    disp('--------------------------------------------------------------')
end

% Set sign and zero restrictions (on impact)
if strcmp(mdl, 'zerosign')
    par.opt.zeros_signs{1}     = 'y(1,1)=+1'; % Inflow  -> EU = +
    par.opt.zeros_signs{end+1} = 'y(3,1)=+1'; % Inflow  -> UR = +
    par.opt.zeros_signs{end+1} = 'y(4,1)=-1'; % Inflow  -> AD = -
    par.opt.zeros_signs{end+1} = 'ys(1,2)=0'; % Outflow -> EU = 0
    par.opt.zeros_signs{end+1} = 'y(2,2)=-1'; % Outflow -> UE = -
    par.opt.zeros_signs{end+1} = 'y(3,2)=+1'; % Outflow -> UR = +
    par.opt.zeros_signs{end+1} = 'y(4,2)=+1'; % Outflow -> AD = +
    par.opt.zeros_signs{end+1} = 'ys(1,3)=0'; % Level   -> EU = 0
    par.opt.zeros_signs{end+1} = 'y(3,3)=+1'; % Level   -> UR = +
    par.opt.zeros_signs{end+1} = 'y(4,3)=-1'; % Level   -> AD = -    
    par.opt.zeros_signs{end+1} = 'y(4,4)=+1'; % Length  -> AD = +
end

% Implement additional restrictions
if isfield(par, 'robust')
    if strcmp(par.robust, 'specification')
        par.opt.zeros_signs{end+1} = 'ys(1,5)=0';
        par.opt.zeros_signs{end+1} = 'ys(2,5)=0';
        par.opt.zeros_signs{end+1} = 'ys(3,5)=0';
        par.opt.zeros_signs{end+1} = 'ys(4,5)=0';
        par.opt.zeros_signs{end+1} = 'ys(1,6)=0';
        par.opt.zeros_signs{end+1} = 'ys(2,6)=0';
        par.opt.zeros_signs{end+1} = 'ys(3,6)=0';
        par.opt.zeros_signs{end+1} = 'ys(4,6)=0';
        par.opt.zeros_signs{end+1} = 'ys(5,6)=0';
        par.opt.zeros_signs{end+1} = 'y(5,5)=-1';
        par.opt.zeros_signs{end+1} = 'y(6,6)=-1';
    end
end

% Run the BVAR
rng(par.seed);                  % Set seed
BB = bvar_(Yt, par.p, par.opt); % Estimate model
BB.mdl = mdl;                   % Save model name

end
