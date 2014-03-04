function cb_pop_ploterps(ERP, binArray, chanArray, varargin)
%% DESCRIPTION:
%
%   Function to generate ERP equivalent plots. Turns out that ERPLAB's
%   plotting function is damn near impossible to use in a flexible way (at
%   least flexible like CWB needed it), so I had to write a wrapper
%   function to define and modify its inputs dynamically. The function
%   can be used to generate ERPLAB-like plots with any input paramter set.
%   To change a field, simply use a fieldname/value format for varargin.
%
%   Part of the reason for the difficulty using pop_ploterps is that many
%   of its default inputs are defined all over the place so it's difficult
%   to gather all the necessary code into one location. 
%
%   CWB tried using the input parser scheme used by ERPLAB, but it will
%   *not* allow parameter values to be modified on the fly. Thus, CWB opted
%   to go with a simple structure that can be modified on a whim. 
%
%
% INPUT:
%
%   ERP:    ERPLAB structure
%   binArray:   bins to plot
%   chanArray:  channels to plot
%
%   (Optional)
%   varargin:   input arguments to modify.   
%
% OUTPUT:
%
%   ERPLAB like plot.
%
% Example:
%   cb_pop_ploterps(ERP, [1:3], 1, 'Style', 'Classic');
%
% Christopher W. Bishop
%   University of Washington
%   3/14

o=struct(varargin{:});

%% SET XTICKS
%   ploterpGUI 1116:1118
xtickarray = str2num(char(default_time_ticks(ERP)));
xxs1       = ceil(1000*ERP.xmin);
xxs2       = floor(1000*ERP.xmax);
xxscale        = [xxs1 xxs2 xtickarray]; % ploterpGUI 1127

%% GET COLOR AND STYLE DEFS
%   Custom function written by CWB.
%   Again, ERPLAB makes it *very* diffcult to return even simple default
%   information that is used repeatedly in many functions.
[colorDef, styleDef]=erplab_linespec(max(binArray));
colorDef=colorDef(binArray);

%% DEFAULT OPTIONS
d=struct('Mgfp', [], ...
    'Blc', 'none', ...
    'xscale', xxscale, ...
    'yscale', [-10 10], ...
    'LineWidth', 1, ...
    'YDir', 'normal', ...
    'FontSizeChan', 10, ...
    'FontSizeLeg', 12, ...
    'FontSizeTicks', 10, ...
    'Style', 'Classic', ...
    'SEM', 'on', ...
    'Transparency', .7, ...
    'Box', [1 1], ...
    'HoldCh', 'off', ...
    'AutoYlim', 'on', ...
    'BinNum', 'off', ...
    'ChLabel', 'on', ...
    'LegPos', 'external', ...
    'Maximize', 'off', ...
    'Position', [103.667 29.625 106.833 31.9375], ...
    'Axsize', [0.05 0.08], ... % size ([w h] ) for each channel when topoplot is being used.
    'MinorTicksX', 'off', ...
    'MinorTicksY', 'off', ... % off | on
    'Linespec', {colorDef}, ...
    'ErrorMsg', 'cw', ... % cw = command window
    'Tag', 'ERP_figure', ... % figure tag
    'History', 'script'); % history from scripting


%% CHANGE PARAMETERS
%   User specified inputs 
flds=fieldnames(o);
for i=1:length(flds)
    d.(flds{i})=o.(flds{i}); 
end % i=1:length(flds)


%% HOUSE KEEPING
%   Some additional code fragments stolen from ERPLAB to make the function
%   call happy
if strcmpi(d.AutoYlim,'on')
        qyauto = 1;
else
        qyauto = 0;
end

BinArraystr  = vect2colon(binArray, 'Sort','yes'); % pop_ploterps 611
chanArraystr = vect2colon(chanArray);


%% GENERATE ERP COMMAND
%   CWB hijacks ERPLAB ERPCOM return variable to evaluate the function
%   call. 
%
%   See pop_ploterps line 619 onward
fn = fieldnames(d);
filename4erp=''; 
if isempty(filename4erp) % first input was an ERP or a filename?
	firstinput = inputname(1);
else
	firstinput = filename4erp;
end

skipfields = {firstinput,'binArray','chanArray', 'ErrorMsg','History'}; % modified so other variable names can be used as inputs for ERP
if qyauto
	skipfields = [skipfields 'yscale'];
end
erpcom     = sprintf( 'pop_ploterps( %s, %s, %s ',  firstinput, BinArraystr, chanArraystr);

for q=1:length(fn)
        fn2com = fn{q}; % inputname
        if ~ismember(fn2com, skipfields)
                fn2res = d.(fn2com); %  input value
                if ~isempty(fn2res)
                        if ischar(fn2res)
                                if ~strcmpi(fn2res,'off')
                                    erpcom = sprintf( '%s, ''%s'', ''%s''', erpcom, fn2com, fn2res);
                                end
                        elseif iscell(fn2res)
                                nn = length(fn2res);
                                erpcom = sprintf( '%s, ''%s'', {''%s'' ', erpcom, fn2com, fn2res{1});
                                for ff=2:nn
                                        erpcom = sprintf( '%s, ''%s'' ', erpcom, fn2res{ff});
                                end
                                erpcom = sprintf( '%s}', erpcom);
                        else
                                if ~ismember(fn2com,{'xscale','yscale'})
                                        erpcom = sprintf( '%s, ''%s'', %s', erpcom, fn2com, vect2colon(fn2res,'Repeat','on'));
                                else
                                        xyscalestr = sprintf('[ %.1f %.1f  %s ]', fn2res(1), fn2res(2), vect2colon(fn2res(3:end),'Delimiter','off'));
                                        erpcom = sprintf( '%s, ''%s'', %s', erpcom, fn2com, xyscalestr);
                                end
                        end
                end
        end
end
erpcom = sprintf( '%s );', erpcom);

% Plot the data
eval(erpcom); 