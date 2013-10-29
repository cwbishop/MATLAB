function show_data(varargin)
%
%
%
%

if length(varargin) == 1
    load(varargin{1})
else
    freq = varargin{1};
    perc = varargin{2};
    data = varargin{3};
    stim = varargin{4};
    resp = varargin{5};
end

p = input('1 = Frequency Curves\n 2 = Across Frequency\n 3 = Control Performance\n 4 = Stimuli Performance\n 5 = Multiple Subjects');

switch p
    case 1
        freq_curve(freq,perc,data);
    case 2
        xfreq_curve(freq,perc,data);
    case 3
        control_performance(freq,data,resp);
    case 4
        stim_performance(freq,data,stim,resp);
end

end


function freq_curve(freq,perc,data)

i = 1;
j = 1;
k = 1;
l = 1;
temp30 = zeros(3000,1);
temp50 = zeros(3000,1);
temp70 = zeros(3000,1);
p = input('Frequency of Interest?(500, 1000, 2000, 4000)'); 
p = num2str(p);
while ~isempty(freq{i})
    if strcmp(freq{i},p)
        switch perc{i}
            case '30%'
                temp30(j) = data(i);
                j = j + 1;
            case '50%'
                temp50(k) = data(i);
                k = k + 1;
            case '70%'
                temp70(l) = data(i);
                l = l + 1;
        end
        
    end
    i = i + 1;
end

plot(temp30,'b')
hold on
plot(temp50,'g')
plot(temp70,'r')
axis([1 j 0 1])
title(p)

end


function xfreq_curve(freq,perc,data)

fullcurve = zeros(3,4,3);
tracker = ones(3,4);
graphcurve = zeros(3,4);
endex = find(data == 0);
en = endex(1);
i = en - 1;


while i > 0
   switch freq{i}
       case '500'
           c = 1;
       case '1000'
           c = 2;
       case '2000'
           c = 3;
       case '4000'
           c = 4;
       otherwise
           c = 0; 
   end
   switch perc{i}
       case '30%'
           d = 1;
       case '50%'
           d = 2;
       case '70%'
           d = 3;
       otherwise
           d = 0;
   end
   if c ~= 0 && d ~= 0
      if tracker(d,c) < 4
          fullcurve(d,c,tracker(d,c)) = fullcurve(d,c,tracker(d,c)) + data(i);
          tracker(d,c) = tracker(d,c) + 1;
          if (find(tracker < 3)) == 0
              break
          end
      end
      
   end
   i = i - 1;    
end

i = 1;
while i < 4
    j = 1;
    while j < 5
        graphcurve(i,j) = mean(fullcurve(i,j,:));
        if length(find(fullcurve(i,j,:) == 1)) > 1
            graphcurve(i,j) = 1;
        end
        if length(find(fullcurve(i,j,:) == .1)) > 1 
            graphcurve(i,j) = .1;
        end
        j = j + 1;
    end
    i = i + 1;
end

figure, plot(graphcurve')
axis([1 4 0 1])
set(gca,'XTick',1:1:4)
set(gca,'XTickLabel',{500,1000,2000,4000})
title('Psychometric Curves Across Frequency')

end


function stim_performance(freq,data,stim,resp)

i = 1;
performance = zeros(4,10);
presentations = zeros(4,10);
while ~isempty(freq{i}) 
   switch freq{i}
       case '500'
           q = 1;
       case '1000'
           q = 2;
       case '2000'
           q = 3;
       case '4000'
           q = 4;
       otherwise 
           q = 0;
   end
   if q ~= 0
       if data(i) > .3 && data(i) < .7
            a = resp(i,1);
            b = resp(i,2);
            if a < 3
                temp = a;
            else 
                temp = b;
            end
            presentations(q, str2double(stim{i})) = presentations(q, str2double(stim{i})) + 1;
            if temp == 1
                performance(q, str2double(stim{i})) = performance(q, str2double(stim{i})) + 1;
            end
       end
   end
   i = i + 1;
       
end

i = 1;

while i < 5
    j = 1;
    while j < 11
        
        switch i
            case 1
                lab = 500;
            case 2
                lab = 1000;
            case 3
                lab = 2000;
            case 4
                lab = 4000;
        end
        out = sprintf('The %dth stimuli at %dHz suppressed %d of %d presentations in range.', j, lab, performance(i,j), presentations(i,j));
        disp(out)
        j = j + 1;
    end
    i = i + 1;
end


end


function control_performance(freq,data,resp)

i = 1;
controls = zeros(2,4);
totals = zeros(2,4);
while ~isempty(freq{i}) 
   t = freq{i};
   if t(1) == 'M'
        a = resp(i,1);
        b = resp(i,2);
        if a < 3
           temp = a;
        else 
           temp = b;
        end
        if data(i) == .1
            switch freq{i}
                case 'M500'
                    if temp == 2
                        controls(1,1) = controls(1,1) + 1;
                    end
                    totals(1,1) = totals(1,1) + 1;
                case 'M1000'
                    if temp == 2
                        controls(1,2) = controls(1,2) + 1;
                    end
                    totals(1,2) = totals(1,2) + 1;
                case 'M2000'
                    if temp == 2
                        controls(1,3) = controls(1,3) + 1;
                    end
                    totals(1,3) = totals(1,3) + 1;
                case 'M4000'
                    if temp == 2
                        controls(1,4) = controls(1,4) + 1;
                    end
                    totals(1,4) = totals(1,4) + 1;
            end
        else
            switch freq{i}
                case 'M500'
                    if temp == 1
                        controls(2,1) = controls(2,1) + 1;
                    end
                    totals(2,1) = totals(2,1) + 1;
                case 'M1000'
                    if temp == 1
                        controls(2,2) = controls(2,2) + 1;
                    end
                    totals(2,2) = totals(2,2) + 1;
                case 'M2000'
                    if temp == 1
                        controls(2,3) = controls(2,3) + 1;
                    end
                    totals(2,3) = totals(2,3) + 1;
                case 'M4000'
                    if temp == 1
                        controls(2,4) = controls(2,4) + 1;
                    end
                    totals(2,4) = totals(2,4) + 1;
            end
        end
   end
   i = i + 1;
end

i = 1;

while i < 3
    j = 1;
    while j < 5
        controls(i,j) = controls(i,j) / totals(i,j);
        switch i
            case 1
                co = .1;
            case 2
                co = 1;
        end
        switch j
            case 1
                lab = 500;
            case 2
                lab = 1000;
            case 3
                lab = 2000;
            case 4
                lab = 4000;
        end
        out = sprintf('Controls at %dHz with a correlation of %1.1f were correct %0.2f%% of the time.',lab,co,controls(i,j) * 100);
        disp(out)
        j = j + 1;
    end
    i = i + 1;
end

end
