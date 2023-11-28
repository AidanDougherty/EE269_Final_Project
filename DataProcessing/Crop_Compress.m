%Crop Images into middle 128x128 square and resize to 64x64 using bilinear
%interpolation
%Images stored in Cell array with each row as a Beam Class
function Crop_Compress(N,comp_ratio,method,dirpath,data_name)
arguments %Set Defaults
N = 128; %Crop Window size
comp_ratio = 0.5; %Compression Ratio After Croppping
method = "bilinear"; %Compression method
dirpath = "C:\Users\dough\OneDrive\Documents\MATLAB\EE269\Project_Data\Del_10_Sorted\"; %Folder of Beam Folders
data_name = "ResizedBeamData_Del_10.mat"; %Name of output file
end

files = dir(dirpath);
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
% Extract only those that are directories.
beamFolders = files(dirFlags); % A structure with extra info.
% Get only the folder names into a cell array.
subFolderNames = {beamFolders(3:end).name}; % Start at 3 to skip . and ..


NBeams = length(subFolderNames);
BeamData = {};
for y = 1:NBeams %For each Beam folder find all pngs and put into row of cell array
    fpath = strcat(dirpath,subFolderNames(y),"\*.png");
    fsrc = dir(fpath); 
    BeamData = [BeamData; cell(1,size(fsrc,1))]; %Add new row to BeamData
    display(strcat("Processing Beam Number ", num2str(y-1)))
    for i = 1:size(fsrc,1) %crop and compress each png in directory
        fname=strcat(dirpath, subFolderNames(y), "\", fsrc(i).name); %Get img name
        Img = imread(fname);
        Img = Img(end/2-N/2+1:end/2+N/2,end/2-N/2+1:end/2+N/2); %Crop
        Img = imresize(Img,comp_ratio,method); %Compress
        BeamData{y,i} = Img; %Store
    end
    
end
labels = (0:NBeams-1)'; %Data Labels

save(data_name,"BeamData", "labels")
end
