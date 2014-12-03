function [h,CR_test,Str_testE,CR_train]=svdboostV3pred(x,y,h,DeltaH,MaxIter,segno)
%   DeltaH will be reset to 0.005 in the function
%   At least 10 iterations will be done
%   After 10 iterations, prediction error works as the stop criterion
%   Created by N. Ding 2011 [gahding@umd.edu]
%   Modified by M. Villafañe Delgado [mariselv@umd.edu] and F. Cervantes Constantino 2012 [fcc@umd.edu]
DeltaH=0.005;

%% LENGTH OF TESTING SIGNAL
%   The test signal is essentially divided into 10, approximately equal
%   chunks. This is described in detail in 
%
%   Ding, N. and J. Z. Simon (2012). "Neural coding of continuous speech in auditory cortex during monaural and dichotic listening." J Neurophysiol 107(1): 78-89.
TSlen=size(x,2)/10;
TSlen=floor(TSlen);

%vector form regression
hstr=[];
BestPos=0;
testing_range=[1:TSlen]+TSlen*segno;
training_range=setdiff([1:length(x)],testing_range);
x_test=x(:,testing_range);y_test=y(:,testing_range);
x=x(:,training_range);y=y(:,training_range);

for iter=1:MaxIter
    ypred_now=y*0;
    ypred_test=y_test*0;
    for ind=1:size(h,1)
        ypred_now=ypred_now+filter(h(ind,:),1,x(ind,:));
        ypred_test=ypred_test+filter(h(ind,:),1,x_test(ind,:));
    end
    
    % Compute predictive power: Training
    rg=size(h,2):length(y);
    m_y = mean(y(rg));
    m_ypred_now = mean(ypred_now(rg));
    CR_train(iter)=sum((y(rg) - m_y).*(ypred_now(rg) - m_ypred_now))/sqrt(sum((y(rg) - m_y).^2)*sum((ypred_now(rg) - m_ypred_now).^2));
    
    % Compute predictive power: Testing
    rg=size(h,2):length(y_test);
    m_ytest = mean(y_test(rg));
    m_ypred_test = mean(ypred_test(rg));
    CR_test(iter)=sum((y_test(rg) - m_ytest).*(ypred_test(rg) - m_ypred_test))/sqrt(sum((y_test(rg) - m_ytest).^2)*sum((ypred_test(rg) - m_ypred_test).^2));
    
    TestE(1:size(h,1))=sum((y_test-ypred_test).^2);
    Str_testE(iter)=sum(TestE);
    TrainE(1:size(h,1))=sum((y-ypred_now).^2);
    Str_TrainE(iter)=sum(TrainE);
    
    %     % Alternative ways to compute the correlation coefficient using Matlab's functions.  This yield to the same result as before
    %     R = corrcoef(y_test, ypred_test); corrTest(iter) = R(2,1);
    %     Ctrain = cov(y,ypred_now); predPwr_train(iter) = Ctrain(2)/(std(y)*std(ypred_now));
    %     Ctest = cov(y_test,ypred_test); predPwr_test(iter) = Ctest(2)/(std(y_test)*std(ypred_test));
     
    % stop the iteration if all the following requirements are met
    % 1. more than 10 iterations are done
    % 2. The testing error in the latest iteration is higher than that in the
    % previous two iterations
    if iter>10 && Str_testE(iter)>Str_testE(iter-1) && Str_testE(iter)>Str_testE(iter-2) % && Str_testE(iter)>Str_testE(iter-3)
        %   if iter>10 && Str_testE(iter)>Str_testE(iter-1)
        %         [dum,iter]=min(Str_testE);iter=iter+1;
        [dum,Best_iter]=min(Str_testE);Best_iter=Best_iter+1;
        try
            h=squeeze(hstr(Best_iter,:,:));
        catch
            h=h*0;
        end
        if size(h,2)==1
            h=h';
        end
        break;
        %     DeltaH=DeltaH*0.5;
        %     if DeltaH<0.005
        %       break;
        %     end
    end
    
    MinE(1:size(h,1))=sum((y-ypred_now).^2);
    for ind1=1:size(h,1)
        for ind2=1:size(h,2)
            ypred=ypred_now+DeltaH*[zeros(1,ind2-1) x(ind1,1:end-ind2+1)];
            e1=sum((y-ypred).^2);
            
            ypred=ypred_now-DeltaH*[zeros(1,ind2-1) x(ind1,1:end-ind2+1)];
            e2=sum((y-ypred).^2);
            
            if e1>e2
                e(ind2)=e2;
                IncSignTmp=-1;
            else
                e(ind2)=e1;
                IncSignTmp=1;
            end
            if e(ind2)<MinE(ind1)
                BestPos(ind1)=ind2;
                IncSign(ind1)=IncSignTmp;
                MinE(ind1)=e(ind2);
            end
        end
    end
    if sum(abs(BestPos))==0;
        DeltaH=DeltaH*0.5;
        %     disp('Precision doubled')
        %     disp(DeltaH)
        if DeltaH<0.005
            %         disp('It is already precise enough')
            break;
        end
        continue;
    end
    [dum, bestfil]=min(MinE);
    h(bestfil,BestPos(bestfil))=h(bestfil,BestPos(bestfil))+IncSign(bestfil)*DeltaH;
    BestPos=BestPos*0;
    hstr(iter,:,:)=h;
    try
        if sum(abs(h-hstr(iter-2,:)))==0
            disp(iter)
            break
        elseif sum(abs(h-hstr(iter-3,:)))==0
            disp(iter)
            break
        end
    end
end
try
    CR_test=CR_test(Best_iter);     % Keep predictive power as the correlation for the best iteration
catch
    CR_test=CR_test(iter);
end
return;
