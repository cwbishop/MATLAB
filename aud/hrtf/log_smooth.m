function [PsmM,fxx] = log_smooth(PxxM,fxx,oct,smin,plotFlag)
% LOG SMOOTH
%       Gaussian spectral smoothing filter with smoothing kernel width increasing
%       logarithmically with frequency.  It's ungodly ineffiecient due to the
%       anisotropic smoothing, so it downsamples spectrum to "nout" points.
%       Smooths in log-log (frequency-magnitude) space. Assumes fxx from 0 to Nyquist
%       and Pxx  magnitude on a linear scale (not 10*log10), so it works well with
%       output from pwelch.  It doesn't know anything about phase.
%       Power values equal to zero are changed to eps.
%
% INPUTS
%   PxxM    A matric of spectrum magnitudes (linear scale) in columns
%   fxx     frequency array for Pxx, must be monotonically increasing, same
%            length as Pxx
%   oct     width, in octaves, of the smoothing kernel, subject to smin.
%            Default = 1/10
%   smin    minimum number of points to include in a kernel, must be odd.
%            Larger numbers keep signal smoother at very low frequencies.
%            Default = 101
% OUTPUTS
% PsmM      A matrix of smoothed spectrum spectrum (linear scale) in columns
% fxx       frequency array for plotting Psm
%
%           [PsmM,fxxsm] = logsmooth(PxxM,fxx,oct,smin);
%
% MillerLM 01/07
% Minor changes, KHill 08/07


fmin = 20;


%input checks
if ~exist('plotFlag') || isempty(plotFlag)
    plotFlag=0;
end
if ~exist('smin') || isempty(smin)
    smin = 101; %this default should be made dynamic to length of PxxM
end
if ~exist('oct') || isempty(oct)
    oct = 1/10;
end

if oct > 0.5
    if plotFlag, warning('Broad smoothing kernel may shift peaks or have weird edge effects.  Reduce smoothing to < 0.5 octaves'), end
end



% set oversampling ratio
nup = 20;
nout = log2(fxx(end)/fmin) * nup;  %resample in octaves at appx. nup times the filter width

if rem(smin,2) == 0
    smin = smin + 1;
    if plotFlag, disp('Made smin odd'), end
end

for col=1:size(PxxM,2)
%     fprintf(1,['Starting column ' num2str(col) '...\n']);
    Pxx=PxxM(:,col);
    
%     tic,fprintf(1,['\tSetting up ... '])
    % set zero powers to tiny number, so can take log
    Pxx(find(abs(Pxx)<eps)) = eps;
    PxxdB = 20*log10(Pxx);  % so smoothing occurs in log amplitude
    
    % gaussian kernel
    grange = 2;
    xg = [-grange:.01:grange];
    g = gaussmf(xg,[1 0]);
    %
    % grange = 2;
    % xg = [.01:.01:2*grange];
    % g = gaussmf(xg,[1 grange]);
%     fprintf(1,[num2str(toc) ' secs\n']);
% 
%     tic,fprintf(1,['\tReflecting ends ... '])
    % reflect ends of spectrum to avoid edge effects
    PxxrdB = [flipud(PxxdB); PxxdB; flipud(PxxdB)];
    offset = length(PxxdB);
    fxxincr = fxx(end)-fxx(end-1);
    fxxr = [zeros(offset,1)' fxx' fxx(end)+fxxincr.*[1:offset]];
%     fprintf(1,[num2str(toc) ' secs\n']);
% 
%     tic,fprintf(1,['\tLooping through convolve ... '])
    % loop through and 'convolve' each point with ever larger smoothing kernels
    istart = offset+1;
    iend = 2*offset;
    ieval = round(logspace(log10(istart-offset),log10(iend-offset),nout))+offset;  %could also make this lin spaced
    if fxxr(istart)==0  % if freq array starts at DC
        fxxsm = [0 logspace(log10(fxxr(istart+1)),log10(fxxr(iend)),length(ieval)-1)];
        PxxrDC = PxxrdB(istart);
        PxxrdB(istart) = PxxrdB(istart+1);
    else
        fxxsm = [logspace(log10(fxxr(istart)),log10(fxxr(iend)),length(ieval))];
    end
    norep = [1 find(diff(ieval)~=0)+1];
    ieval = ieval(norep);
    fxxsm = fxxsm(norep);
%     fprintf(1,[num2str(toc) ' secs\n']);
% 
%     tic,fprintf(1,['\tMaking smoothed signal ... '])
    % Make smoothed signal
%     PsmdB = zeros(length(ieval),1);
%     fspan = fxxr(ieval) - fxxr(ieval).*2^-(oct*2);
%     fmin = fxxr(ieval) - fspan;
%     fmax = fxxr(ieval) + fspan;
    for i = 1:length(ieval)
        iieval = ieval(i);
        fspan = fxxr(iieval) - fxxr(iieval)*2^-(oct*2);
        fmin = fxxr(iieval) - fspan;
        fmax = fxxr(iieval) + fspan;
        ifmin = find(fxxr>fmin,1);
        ifmax = find(fxxr<fmax,1,'last');

        n = ifmax - ifmin + 1;
        if n > smin
            glin = linspace(-grange,grange,n);
            %glin = logspace(log10(xg(1)),log10(xg(end)),n);
            gspline = interp1(xg,g,glin,'spline');
            gspline = gspline./sum(gspline);
            PsmdB(i) = gspline * PxxrdB(ifmin:ifmax);
        else
            glin = linspace(-grange,grange,smin);
            %glin = logspace(log10(xg(1)),log10(xg(end)),smin);
            gspline = interp1(xg,g,glin,'spline');
            gspline = gspline./sum(gspline);
            PsmdB(i) = gspline * PxxrdB(ieval(i)-floor(smin/2):ieval(i)+floor(smin/2));  % enforce at least smin-point smoothing
        end
    end
%     fprintf(1,[num2str(toc) ' secs\n']);

    if fxxr(istart)==0
        if plotFlag, disp('Took out DC during smoothing and replaced with original value'), end
        PsmdB(1) = PxxrDC;
    end

%     tic,fprintf(1,['\tFinishing up ... '])
    Psm = 10.^(PsmdB/20);  %revert to linear amplitude, as with input Pxx
    Psm = interp1(fxxsm,Psm,fxx,'pchip');  %pchip is more graceful at abrupt boundaries than spline
    PsmM(:,col)=Psm;
%     fprintf(1,[num2str(toc) ' secs\n']);
    
    if plotFlag
        % plot
        figure, hold on
        plot(fxx,PxxdB,'r')
        plot(fxxsm,PsmdB,'g')
        plot(fxx,20*log10(Psm),'k')
        set(gca,'Xscale','log')
    end
end