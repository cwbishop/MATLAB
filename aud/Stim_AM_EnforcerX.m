function [A,B,sigs,AM,flag] = Stim_AM_EnforcerX(A,B)
%
%
%
%
sigs = zeros(181,4801);
AM = zeros(181,1);
AMa = 1;
AMb = 1;

while AMa > .05
    [A, AMa] = inv_env(A,50);
end

while AMb > .05
    [B, AMb] = inv_env(B,50);
end

if corr(A,B) > .1
    flag = 2;
    return
end

holder(1,1,:) = A;
holder(1,2,:) = B;
T = generate_corr_table(holder);

i = 1;
flag = 0;
while i <= 181

    C = (A .* T(i)) + (B .* (1 - T(i)));
    D = C;
    AMi = 1;
    while (AMi > .05)
    D = inv_env(D,50);
    [D, AMi] = inv_env(D,50);
    sigs(i,:) = D;
    AM(i) = AMi;
    end        
    if (abs(corr(D,A) - (((i - 1) / 200) + .1)) > .0125)
        if abs(corr(D,A) - (((i - 1) / 200) + .1)) > flag
        flag = abs(corr(D,A) - (((i - 1) / 200) + .1));
        end
    end
    
    
    i = i + 1;
end
            
           
    
   
