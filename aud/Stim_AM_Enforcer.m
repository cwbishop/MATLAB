function [sigs,AM,flag] = Stim_AM_Enforcer(A,B)
%
%
%
%
sigs = zeros(181,4801);
AM = zeros(181,1);
A = inv_env(A,50);
[A, AMa] = inv_env(A,50);
B = inv_env(B,50);
[B, AMb] = inv_env(B,50);

holder(1,1,:) = A;
holder(1,2,:) = B;
T = generate_corr_table(holder);

if (AMa > .05) || (AMb > .05)
    flag = 4;
    return
end

i = 1;
flag = 0;
while i <= 181
    C = (A .* T(i)) + (B .* (1 - T(i)));
    D = un_tone_shape(.025,[],.1,48000,C);
    D(1) = 0;
    env = elope(D, 0, 20000, 0, 50, 48000);
    clip = env(720:4080);
    ma = max(abs((clip - mean(clip))/mean(clip)));
    AM(i) = ma;
    if (ma < .05)
        sigs(i,:) = C;
    else
         if (ma < .5)
            D = inv_env(C,50);
            [D, AMi] = inv_env(D,50);
            sigs(i,:) = D;
            AM(i) = AMi;
            if (AMi > .05)
                D = inv_env(C,60);
                [D, AMi] = inv_env(D,60);
                sigs(i,:) = D;
                AM(i) = AMi;
                if (AMi > .05)
                    flag = 1;
                end
            end
            if (abs(corr(C,A) - (((i - 1) / 200) + .1)) > .01)
                flag = 2;
            end
        else
           flag = 3;
           break
        end
    end
    i = i + 1;
end
            
           
    
   
