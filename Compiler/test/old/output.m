function output

seed = 10; 
rng(seed);
test = true; 
maxAttempts = 100; 
attemptCount = 0; 
fileID = fopen('errorlog_seed10_noageclasses.txt','w');
%outputStructure.name = sprintf('dataStructure_date_%s/',datestr(now,'YYYY-mm-DD_HH-MM-ss'));
%outputStructure.layers = maxAttempts;

%saving as a new "Data" struct to the folder one above the current one:
%curr_folder = cd; 
%upper_folder = fullfile(curr_folder, '..'); 
%save(fullfile(upper_folder, '1_LakeConstance_updated_nicheweb.mat'), 'Data'); 

%outputStructure(maxAttempts).data = [];         % initialize an array of structures
outputStructure = repmat(struct('data', []), maxAttempts, 1); 

while test
    try
        outputStructure(attemptCount+1).data = NicheModeller(25);
    catch
        % If failed:
        %fileID = fopen('errorlog.txt','w');
        fprintf(fileID,'The run number #(%d) failed \r\n', attemptCount+1);
        %fprintf(fileID, '\n');
        %fclose(fileID);
    end
    
    attemptCount = attemptCount + 1 
    
    if attemptCount > maxAttempts-1
        fprintf('Max number of attempts achieved');
        test = false; 
        fclose(fileID);
    end
    
    
end

save('testing_seed10_noageclasses.mat', 'outputStructure');
%upper_folder = fullfile(curr_folder, '..'); 
%save(fullfile(upper_folder, '1_LakeConstance_updated_nicheweb.mat'), 'Data'); 


