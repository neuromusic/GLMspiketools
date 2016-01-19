function [gg,fval,H] = MLfit_GLM(gg,Stim,optimArgs)
%  [ggnew,fval,H] = MLfit_GLM(gg,Stim,optimArgs)
% 
%  Computes the ML estimate for GLM params, using grad and hessians.
%  Assumes basis for temporal dimensions of stim filter
%
%  Inputs: 
%     gg = param struct
%     Stim = stimulus
%     optimArgs = cell array of optimization params (optional)
%
%  Outputs:
%     ggnew = new param struct (with ML params);
%     fval = negative log-likelihood at ML estimate
%        H = Hessian of negative log-likelihood at ML estimate

MAXSIZE  = 1e7;  % Maximum size matrix (product of dimensions) to hold in memory at once;

% Set optimization parameters 
if nargin > 2
    opts = optimset('Gradobj','on','Hessian','on', optimArgs{:});
else
    opts = optimset('Gradobj','on','Hessian','on','display','iter');
end

% --- Create design matrix using bases and extract initial params from gg -------
[prs0,Xstruct] = setupfitting_GLM(gg,Stim,MAXSIZE);

% minimize negative log likelihood --------------------
[prs,fval] = fminunc(@(prs)Loss_GLM_logli(prs,Xstruct),prs0,opts);

% Compute Hessian if desired
if nargout > 2 
    [fval,~,H] = Loss_GLM_logli(prs,Xstruct);
end


% Put returned vals back into param structure ------
gg = reinsertFitPrs_GLM(gg,prs);

% %----------------------------------------------------
% Optional debugging code
% %----------------------------------------------------
%
% % ------ Check analytic gradients and Hessians -------
%  HessCheck(@Loss_GLM_logli,prs0,opts);
%  HessCheck_Elts(@Loss_GLM_logli, [1 12],prs0,opts);
%  tic; [lival,J,H]=Loss_GLM_logli(prs0); toc;
