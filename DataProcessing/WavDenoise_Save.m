%Crop Images into middle 128x128 square and compress to 64x64 using
%approximation wavelet coefficients
%interpolation
%Images stored in Cell array with each row as a Beam Class
function WavDenoise_Save(dirpath,writepath,den_type)
arguments %Set Defaults
dirpath = "C:\Users\dough\OneDrive\Documents\MATLAB\EE269\EE269_Final_Project\DataProcessing\ResizedBeamImg_Del_10\"; %Folder of Beam Folders to Read, include last slash
writepath = "C:\Users\dough\OneDrive\Documents\MATLAB\EE269\EE269_Final_Project\DataProcessing\ResizedDenoised\ResizedCpxWavCSDen_Del_10\"; %Folder to write Beam png's
den_type = 3; %1 = normal wavelet denoise, 2 = cpxdt wavelet denoise, 3 = compressed sensing cpxdt denoise
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
    for i = 1:size(fsrc,1) %for each png in directory
        fname=strcat(dirpath, subFolderNames(y), "\", fsrc(i).name); %Get img name
        Img = imread(fname);
        Img = cast(Img,"double");
        Img = wcodemat(Img,255,'mat',1); %normalize to 1-255 double
        if(den_type ==1 ) %Normal Wavelet Denoising
            imden = wdenoise2(Img,"Wavelet","sym2");
        elseif(den_type ==2) %Complex Wavelet Denoising
            wt = dddtree2('cplxdt', Img, 1, 'FSfarras', 'qshift10');
            imp = sort(abs(wt.cfs{1}(:)),'descend'); %vectorize + sort
            idx = floor(length(imp)*15/100); %Keep 15 percent of coeffs
            thresh= imp(idx); %Threshold away lower 85 percent
            wt.cfs{1} = wthresh(wt.cfs{1},"s",thresh);
            imden = idddtree2(wt);
        else %den_type == 3
            imden = cpxddt_sparse_denoise(Img,100); %Compressed sensing denoise
        end
        new_img = cast(wcodemat(imden,255,'mat',1),"uint8"); %Cast to uint8 for png
        imwrite(new_img,strcat(writepath,beam_dir_name,"\",fsrc(i).name))%Write to File in Folder
    end
    
end
disp("Done Processing")
end
