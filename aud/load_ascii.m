function [dat] = load_ascii(filename)
file = importdata(filename);
dat = file.data;

% str = file.textdata{1};
% remain = str;
% while true
%    [str, remain] = strtok(remain);
%    eval(str)
%    if isempty(str),  break;  end
%    disp(sprintf('%s', str))
%    end