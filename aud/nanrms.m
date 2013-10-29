function out = nanrms(in,dim)
%get the rms square of a vector or matrix (along a dimension)

%smart handeling of dim taken from mean()
if nargin<2
    dim = min(find(size(in)~=1));
    if isempty(dim), dim = 1; end
end

out = sqrt(nanmean(in.^2,dim));