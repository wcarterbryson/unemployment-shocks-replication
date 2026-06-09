function Gam0 = cov_varp(Phi, Sig)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COV_VARP Compute the variance covariance matrix of variables in a VAR
% system in closed form.
% - Inputs:
%   + Phi: VAR coefficients
%   + Sig: variance covariance matrix of estimated residuals
% - Outputs:
%   + Gam0: variance covariance matrix of VAR variables (contemporaneous)
% - Note: by default, assumes there is a constant in the VAR(p) model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Number of variables and lags
n = size(Phi(1:end-1,:),2);
p = size(Phi(1:end-1,:),1)/n;

% F: companion matrix
F = zeros(n*p);
F(1:n,:) = Phi(1:end-1,:)';
for j = 1:(p-1)
    F(j*n+1:(j+1)*n,(j-1)*n+1:(j)*n) = eye(n);
end

% Q: variance matrix
Q = [Sig zeros(n,n*p-n); zeros(n*p-n,n*p)];

% Outer product of F
calA = kron(F,F);

% Solve for variance
vecE = (eye(size(calA)) - calA)\Q(:);

% Reshape
Gam = reshape(vecE,n*p,[]);

% Extract the contemporaneous variance-covariance matrix
Gam0 = Gam(1:n,1:n);

end
