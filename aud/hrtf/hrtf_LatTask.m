function [OUT, R]=hrtf_LatTask(sid,d,n)
% DESCRIPTION:
%   
%   Script to analyze results from lateralization task.  In the task,
%   subjects are instructed to make speeded responses to which side of
%   midline a stimulus seems to be on.  This is a two alternative forced
%   choice task, with #1 corresponding to LEFT, and #2 corresponding to
%   RIGHT.
%
%   This was motivated by classic studies of sound lateralization.  The
%   hope here is that we can directly compare the "spatial blurriness" of a
%   set of stimuli.  The most difficult point to get good spatial
%   localization/lateralization at is the midline.  Here, we ask subjects
%   to make a left/right of subjective midline judgment. 
%
% INPUT:
%
%   sid:    string, subject ID (e.g., 's1398')
%   d:      double array, angles tested. (e.g., -45:1:45)
%   n:      integer, number of different source files used. (e.g., 3)
%           defaults to 3.
%
% OUTPUT:
%
%   OUT:    double array, d x(n+1) matrix. Each row is a different angle
%           defined by d, each column is a different file index, defined by
%           n.  THE FIRST COLUMN IS THE ANGLE.
%   
% Bishop, Chris Miller Lab 2009

%% LOAD SUBJECT SPECIFIC DATA
%   Contains
%       ObjAzi:     Objective stimulus location in degrees azimuth.
%                   Negative is to the LEFT, positive is to the RIGHT.
%       SubjAzi:    Subject responses to each trial.  1 means left, 2 means
%                   right.
%       Pind:       An index value for each trial.  This corresponds to the
%                   file number fed into hrtf_cal_prep.m.
load(['C:\Documents and Settings\cwbishop\My Documents\Presentation\HRTF_validate\logs\' sid '.mat']);

%% CALCULATE NUMBER OF RIGHTWARD RESPONSES FOR EACH ANGLE.
OUT=[];
for z=1:length(d)
    % Store angle information
    OUT(z,1)=d(z);
    for o=1:n
        t=find(Pind==o & ObjAzi==OUT(z,1));
        s=find(Pind==o & ObjAzi==OUT(z,1) & SubjAzi==2);
        OUT(z,o+1)=length(s)./length(t);
        R(z,o+1)=mean(RT(find(Pind==o & ObjAzi==OUT(z,1))));
    end % o
end % z

