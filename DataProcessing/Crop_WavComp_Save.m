%Crop Images into middle 128x128 square and compress to 64x64 using
%approximation wavelet coefficients
%interpolation
%Images stored in Cell array with each row as a Beam Class
function Crop_WavComp_Save(N,wavelet,dirpath,writepath)
arguments %Set Defaults
N = 120; %Crop Window size
wavelet = "bior4.4"; %Compression method
dirpath = "C:\Users\dough\OneDrive\Documents\MATLAB\EE269\Project_Data\Del_10_Sorted\"; %Folder of Beam Folders to Read
writepath = "C:\Users\dough\OneDrive\Documents\MATLAB\EE269\EE269_Final_Project\DataProcessing\WavCompBeamImg_Del_10\"; %Folder to write Beam png's
end

files = dir(dirpath);
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
% Extract only those that are directories.
beamFolders = files(dirFlags); % A structure with extra info.
% Get only the folder names into a cell array.
subFolderNames = {beamFolders(3:end).name}; % Start at 3 to skip . and ..


NBeams = length(subFolderNames);
for y = 1:NBeams %For each Beam folder find all pngs 
    fpath = strcat(dirpath,subFolderNames(y),"\*.png");
    fsrc = dir(fpath); 
    beam_dir_name = strcat("Beam_",num2str(y-1));
    mkdir(writepath, beam_dir_name); %Make Folder for beam class
    display(strcat("Processing Beam Number ", num2str(y-1,'%03d')))
    for i = 1:size(fsrc,1) %crop and compress each png in directory
        fname=strcat(dirpath, subFolderNames(y), "\", fsrc(i).name); %Get img name
        Img = imread(fname);
        Img = Img(end/2-N/2+1:end/2+N/2,end/2-N/2+1:end/2+N/2); %Crop
        [c,s]=wavedec2(Img,2,wavelet);
        A1 = appcoef2(c,s,wavelet,1); %Get Wavelet Approximation Coeffs
        A1img = cast(wcodemat(A1,255,'mat',1),"uint8"); %Cast to uint8 for png
        imwrite(A1img,strcat(writepath,beam_dir_name,"\",fsrc(i).name))%Write to File in Folder
    end
    
end
disp("Done Processing")
end
