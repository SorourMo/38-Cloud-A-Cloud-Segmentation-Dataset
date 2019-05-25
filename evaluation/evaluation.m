%% This mfile reads the predicted images obtained by the activation function 
% of the last layer in a CNN (for instance, the output of a sigmoid). Then, it
% stitches those patches masks up together to create a mask for entire Landsat
% 8 scene, and at last, it calculates the quantitative evaluators including
% Jaccard index, precision, recall, specificity, and accuracy in %.

% Author: Sorour Mohajerani
% Simon Fraser University, Canada
% email: smohajer@sfu.ca
% First version: 11 May 2017; This version: v1.4
%%
%clear
gt_folder_path = ('path_to_38-Cloud_test_set_ground_truths');
preds_folder_root = ('path_to_predicted_patches_parent_directory');
preds_folder = {'name_of_the_directory_containig_predicted_patches'};

pr_patch_size_rows = 384;
pr_patch_size_cols = 384;

%"0" for clear and "1" for cloud
classes = [0,1]; 

% Should be 1 for printing out the confusion matrix of each scene 
conf_matrix_print_out = 0; 

%Threshold for binarizing the output of the network and creating a binary 
% mask. Should be between [0,1].
thresh = 12 / 255; % The threshold used in Cloud-Net


% Getting unique sceneids existing in the presiction folder
all_uniq_sceneid = extract_unique_sceneids(preds_folder_root, preds_folder);

%% The patch masks are put together to generate a complete scene mask

for n = 1:length(all_uniq_sceneid)
    if n == length(all_uniq_sceneid)
        fprintf('Working on sceneID # %d : %s \n\n', n, char(all_uniq_sceneid(n,1)));
    else
        fprintf('Working on sceneID # %d : %s ... \n', n, char(all_uniq_sceneid(n,1)));
    end

    gt = imread(char(fullfile(gt_folder_path,...
        strcat('edited_corrected_gts_',all_uniq_sceneid(n,1),'.TIF'))));
    
    % Finding all the patch masks corresponding to a unique sceneID
    % based on the sceneID from the name string of each patch mask.
    scid_related_patches = get_patches_for_sceneid (preds_folder_root,...
        preds_folder, all_uniq_sceneid(n,1));
    
    % Generating a complete scene mask from the found patch masks
    complete_pred_mask = false();   
    for pcount = 1:length(scid_related_patches)
        predicted_patch_path =(fullfile (preds_folder_root, preds_folder,scid_related_patches(pcount,1)));
        predicted_patch = imread(char(predicted_patch_path));
        predicted_patch =  imbinarize(predicted_patch,thresh);

        raw_result_patch_name = char(scid_related_patches(pcount,1));
        
        % Getting row and column number of each patch from the name string of
        % each patch mask. this row and column obtain the location o each
        % patch mask in the complete mask.
        [patch_row , patch_col] = extract_rowcol_each_patch (raw_result_patch_name);

        % Stiching up patch masks together
        complete_pred_mask ((patch_row-1)*pr_patch_size_rows+1:(patch_row)... 
            *pr_patch_size_rows,(patch_col-1)*pr_patch_size_cols+1:...
            (patch_col)*pr_patch_size_cols ) = predicted_patch;
    end
    
    % Removing the zero padded distance around the whole mask
    complete_pred_mask = unzeropad (complete_pred_mask,gt);
    
    % Saving complete scene predicted masks    
    complete_folder = strcat('entire_masks_',char(preds_folder));
    if 7~=exist(fullfile(preds_folder_root ,complete_folder),'dir')
        mkdir(preds_folder_root ,complete_folder);
    end
    baseFileName = sprintf('%s.TIF', char(all_uniq_sceneid(n,1)));
    path = fullfile(preds_folder_root,complete_folder,baseFileName); 
    imwrite(complete_pred_mask,path); 
    
    % Calculating the quantitative evaluators
    QE(n,:) = 100 .* QE_calcul(complete_pred_mask,gt, classes, conf_matrix_print_out);
    
    % Preparing evaluators for further saving in excel and txt files 
    scene_assess (n,:) = [all_uniq_sceneid(n,1),num2str(thresh), num2str(QE(n,1)) , ...
        num2str(QE(n,2)), num2str(QE(n,3)), num2str(QE(n,4)), num2str(QE(n,5)) ,...
        '#', num2str(100-QE(n,1)), num2str(100-QE(n,2)), num2str(100-QE(n,3))];
end

% Averaging evaluators over 20 landsat 8 scenes
mean_on_test_data = mean(QE);

fprintf('Average evaluators over %d scenes are: \n\n', n);
fprintf ('Precision, Recall, Specificity, Jaccard, Accuracy \n');
fprintf(' %2.3f , %2.3f , %2.3f , %2.3f , %2.3f \n', mean_on_test_data(1,1), ...
    mean_on_test_data(1,2), mean_on_test_data(1,3), mean_on_test_data(1,4), ...
    mean_on_test_data(1,5));

%% Saving the evaluators in a excel file
excel_baseFileName = strcat(complete_folder,'.xlsx');
excelpath = fullfile(preds_folder_root, excel_baseFileName);
xlswrite(excelpath,{'Scene ID','Threshold','Precision', 'Recall', 'Specificity', 'Jaccard', 'Accuracy',...
    '#','100-Precision','100-Recall','1-Specificity'},'sheet1', 'A1:K1');        
position1 = strcat('A',num2str(2)); 
position2 = strcat('K',num2str(n+1)); 
position = strcat(position1,':',position2);
xlswrite(excelpath,scene_assess,'sheet1', position);

%% Saving the average of evaluators in a text file

txt_baseFileName = strcat(complete_folder,'.txt');
txtpath = fullfile(preds_folder_root, txt_baseFileName);
fileID = fopen(txtpath, 'w');
fprintf(fileID,'Threshold= \r\n');
fprintf(fileID,'%3f \r\n\r\n', thresh);
fprintf(fileID,'Precision, Recall, Specificity, Jaccard, Overall Accuracy \r\n');
fprintf(fileID,'%2.6f,  %2.6f, %2.6f, %2.6f, %2.6f\r\n', mean_on_test_data);
fclose(fileID);

%% This function extracts the unique scene IDs in the prediction folder

function uniq_sceneid = extract_unique_sceneids(result_root, preds_dir)
    path_4landtype = fullfile (result_root, preds_dir );
    folders_inside_landtype = dir(char(path_4landtype));
    l1 = length(folders_inside_landtype); % number of the patch masks inside the pred flder

    for iix = 1:l1-2 
        raw_result_patch_name = char(folders_inside_landtype(iix+2,1).name);
        raw_result_patch_name = strrep(raw_result_patch_name, '.TIF', '');    
        str = {raw_result_patch_name};
        loc1 = cell2mat (regexp(str, 'LC'));
        leng = length(raw_result_patch_name);
        sceneid_lists(iix,1) = {raw_result_patch_name(loc1:leng)}; %this gets scene ID
    end
    uniq_sceneid = unique(sceneid_lists(3:end));
end
%% This function finds the row and column number present in the name of
% each patch

function [row, col] = extract_rowcol_each_patch (name)
        name = strrep(name, '.TIF', '');  
        str = {name};
        loc1 = cell2mat (regexp(str, 'LC'));
        loc2 = cell2mat (regexp(str, 'h_'));
        patchbad = name(loc2+2:loc1-2);
        str2 = {patchbad};
        loc3 = cell2mat(regexp(str2,'_'));

        row = str2double(patchbad(loc3(1)+1:loc3(2)-1));
        col = str2double(patchbad(loc3(3)+1:end));
end
%% This function finds all the patch masks corresponding to a unique sceneID
% based on the sceneID from the name string of each patch mask.
    
function  related_patches = get_patches_for_sceneid (result_root, preds_dir, sceneid)
    path_4preds = fullfile (result_root, preds_dir);
    files_inside = dir(char(path_4preds));
    ps = contains({files_inside(3:end,1).name},sceneid);
    desired_rownums = find(ps==1);
    le = length(desired_rownums); 
    
    related_patches={};
    for nsp = 1: le
        related_patches(nsp,1) = {char(files_inside...
            (desired_rownums(1,nsp)+2,1).name)};
    end
end
%% This function removes the zero pads around a complete scene mask.
% This  padding had been added to each scene before cropping it to 
% small patches

function out = unzeropad (in_dest, in_source)
    [ny, nx] = size(in_dest); 
    [nys, nxs] = size (in_source);
    tmpy= floor((ny-nys)/2);
    tmpx= floor((nx-nxs)/2);
    
    out = in_dest(tmpy+1:tmpy+nys, tmpx+1:tmpx+nxs);
end

%% This prepares the data for calculating the evaluators.

function out = QE_calcul (predict,gt, labels, conf_print)
    out_both = cfmatrix(gt(:), predict(:), labels, 1, conf_print);
    
    % We are interested in getting the numerical evaluators of "1" or
    % "cloud" class only
    ix = find(labels(:)==1);
    out = out_both (ix,:); 
end