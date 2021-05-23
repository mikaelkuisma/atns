function RunAllSimulations

% stochastic runs 4.7.2018 (1 random web)
%fileID = './testresults/2018-07-04_10-43-44';

replicateIDs = 1:100;
%replicateIDs = 1;
nRep = length(replicateIDs);

Ksdsp = [0.05 0.10 0.15 0.20];
Kacs = [0 0.4 -0.4];

nKsds = length(Ksdsp);
nKacs = length(Kacs);


formatSpec = repmat('%f',1,36);
sizeA = [36 Inf];

CinArray = zeros(nRep,36);  % color index for each replicate

% an average of the replicates saved to a struct
tempStruct = repmat(struct('cIndeces', []), nKacs, 1);

% final struct for each Ksdsp:
dataStruct = repmat(struct('tempStruct', []), nKsds,1); 

count = 0; 
for iKsds = 1:nKsds
    for iKacs = 1:nKacs
        for iRep = 1:nRep
            
            repStr = '000000';
            repStr = [repStr num2str(replicateIDs(iRep))]; %#ok<AGROW>
            repStr = repStr(end-2:end);
            
            KsdStr = '000000';
            KsdStr = [KsdStr num2str(Ksdsp(iKsds)*100)]; %#ok<AGROW>
            KsdStr = KsdStr(end-2:end);
            
            KacStr = '000000';
            KacStr = [KacStr num2str(abs(Kacs(iKacs))*100)]; %#ok<AGROW>
            KacStr = KacStr(end-2:end);
            if Kacs(iKacs) < 0
                KacStr = ['-' KacStr]; %#ok<AGROW>
            end
            filePath = sprintf('./testresults/2018-07-04_10-43-44/results_%s_%s_%s.txt',KsdStr,KacStr,repStr);
            fileID = fopen(filePath,'r');
            A = fscanf(fileID,formatSpec, sizeA);
            fclose(fileID);
            
            Adata = A(:,91:91:end);
            CinArray(iRep,:) = tehospektri(Adata); 
            count = count + 1; 
            fprintf('Done %f  percents \n', count/(nKsds*nKacs*nRep)*100);
            
            
        end
        % An average of the replicates for each iKacs
        %tempStruct(iKacs).cIndeces = sum(CinArray)/nRep;
        dataStruct(iKsds).tempStruct(iKacs).cIndeces = sum(CinArray)/nRep;
    end
end

%size(Adata)
%Adata(:,end-1)

save('colorindex_datastructure.mat', 'dataStruct');


