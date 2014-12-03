%% BORROWED THIS FROM ...
%   https://github.com/rasmusbergpalm/DeepLearnToolbox/blob/master/util/zscore.m

function [x, mu, sigma] = zscore(x)
    mu=mean(x);	
    sigma=max(std(x),eps);
	x=bsxfun(@minus,x,mu);
	x=bsxfun(@rdivide,x,sigma);
end