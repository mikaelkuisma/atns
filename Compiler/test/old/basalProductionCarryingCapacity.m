function K = basalProductionCarryingCapacity(bDOC2, Kdef, isNew)
%%
if isNew
    
    Kdiff = 80000;
%     Kdiff = 200000;
    
%     Kmean = Kdef.mean;
%     Kmean = Kdef.mean-Kdiff;
    Kmean = Kdef-Kdiff;
    
    bDOC2max = 4e6;
%     bDOC2max = 1e6;

%     % B-H -type curve   
%     alpha = 0.1;
%     Kinf = Kdef.mean;
%     beta = alpha/Kinf;
%     K = alpha*bDOC2/(1+beta*bDOC2);
    
%     % Sigmoid
%     a = 2e-6;
%     c = bDOC2max/2;
%     K = 2*Kdiff*sigmf(bDOC2,[a c])+Kmean-Kdiff;
    
    % Constant K
%     K = Kdef.mean;
    K = Kdef;

    
    %%
    
%     plots = true;
    plots = false;
    if plots
        x = linspace(0,bDOC2max); %#ok<UNRCH>
        f=figure(666);
        set(f,'units','normalized','position',[0.5 0.5 0.5 0.5])
        f.Name = 'Basal production carrying capacity';
        clf

        %plot(x,2*Kdiff*sigmf(x,[a c])+Kmean-Kdiff)
       
        plot(x,alpha*x./(1+beta*x))

        hold on
        plot(bDOC2,K,'xr')
    end
    
else
%     K = Kdef.mean;
    K = Kdef;
end

