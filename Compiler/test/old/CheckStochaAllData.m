function CheckStochaAllData

% Calculating color index and coefficient of variation - data from simulation data in \\192.168.21.132\home\testresults\
% mijuvest 2.8.2018

% loading database for filtered webs (ensure that this includes the ones
% used in stochastic simulations)
load('filteredwebs.mat', 'filtered_outputStructure');

% Get a list of all files and folders in QNAP home folder:
path = '\\192.168.21.132\home\testresults\';
files = dir(path);

% A logical vector that tells which is a directory, excluding the current
% folder and the folders above ("." and ".." -named ones)
dirFlags = [files.isdir] & ~strcmp({files.name},'.') & ~strcmp({files.name},'..');

% Extract only those that are directories.
subFolders = files(dirFlags);

% Print folder names to command window and analyze everything:
fprintf('Reading & analyzing data of subfolders in \\\\192.168.21.132\\home\\testresults \n\n'); 

for k = 5 : 30 %length(subFolders)
	fprintf('Sub folder #%d = %s\n', k, subFolders(k).name);
    
    Data = filtered_outputStructure(k).data;
    speciesType = {Data.Guilds(:).type};
    prodIndex = find(strcmp(speciesType, 'Producer'));
    consIndex = find(strcmp(speciesType, 'Consumer'));
    fishIndex = find(strcmp(speciesType, 'Fish'));
    
    replicateIDs = 1:100;
    %replicateIDs = 1;
    nRep = length(replicateIDs);

    Ksdsp = [0.05 0.10 0.15 0.20];
    %Ksdsp = [0.05 ];
    Kacs = [0 0.4 -0.4];
    %Kacs = [-0.4];
    
    nKsds = length(Ksdsp);
    nKacs = length(Kacs);


    formatSpec = repmat('%f',1,36);
    sizeA = [36 Inf];

    CinArray = zeros(nRep,36);  % color index for each replicate
    CVArray = zeros(nRep, 36);  % coefficient of variation for each species / replicate

    % an average of the replicates saved to a struct
    tempStruct = repmat(struct('cIndeces', []), nKacs, 1);

    % final struct for each Ksdsp:
    dataStruct = repmat(struct('tempStruct', []), nKsds,1); 

    % reading folders one by one
    partialPath = strcat('\\\\192.168.21.132\\home\\testresults\\', subFolders(k).name);
    
    count = 0; 
    for iKsds = 1:nKsds
        for iKacs = 1:nKacs
            massAverages = zeros(36,100);
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
                
                % full path to result file 
                fullPath = strcat(partialPath, '\\results_%s_%s_%s.txt');
                
                filePath = sprintf(fullPath,KsdStr,KacStr,repStr)
                
                %filePath = sprintf('./testresults/2018-07-04_10-43-44/results_%s_%s_%s.txt',KsdStr,KacStr,repStr);
                fileID = fopen(filePath,'r');
                A = fscanf(fileID,formatSpec, sizeA);
                fclose(fileID);

                Adata = A(:,91:91:end);
                CinArray(iRep,:) = tehospektri(Adata); 
                CVArray(iRep, :) = meanCV(Adata'); 
                massAverages = massAverages + Adata;
                count = count + 1; 
                fprintf('Done %f  percents \n', count/(nKsds*nKacs*nRep)*100);


            end
            % An average of the replicates for each iKacs
            %tempStruct(iKacs).cIndeces = sum(CinArray)/nRep;
            dataStruct(iKsds).tempStruct(iKacs).cIndeces = sum(CinArray)/nRep;
            dataStruct(iKsds).tempStruct(iKacs).cIndeces_produces = sum(CinArray(:,prodIndex))/nRep;
            dataStruct(iKsds).tempStruct(iKacs).cIndeces_consumers = sum(CinArray(:,consIndex))/nRep;
            dataStruct(iKsds).tempStruct(iKacs).cIndeces_fishes = sum(CinArray(:,fishIndex))/nRep;
            
            dataStruct(iKsds).tempStruct(iKacs).cv_produces = sum(CVArray(:,prodIndex))/nRep;
            dataStruct(iKsds).tempStruct(iKacs).cv_consumers = sum(CVArray(:,consIndex))/nRep;
            dataStruct(iKsds).tempStruct(iKacs).cv_fishes = sum(CVArray(:,fishIndex))/nRep;
            
            dataStruct(iKsds).tempStruct(iKacs).aveMasses = massAverages/nRep;
            
        end
    end

    %size(Adata)
    %Adata(:,end-1)

    % saving each web as a mat file
    savedString = strcat(subFolders(k).name, '_ci_data_modified.mat');
    save(savedString, 'dataStruct');

end



