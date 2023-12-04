function performWaveletDecomposition(N, wavelet, dirpath, writepath)
arguments
    N  = 120; % Crop Window size
    wavelet  = "bior4.4"; % Compression method
    dirpath = "C:\Users\dough\OneDrive\Documents\MATLAB\EE269\Project_Data\Del_10_Sorted\"; % Folder of Beam Folders to Read
    writepath = "C:\Users\dough\OneDrive\Documents\MATLAB\EE269\EE269_Final_Project\DataProcessing\WCoef_Del_10\"; % Folder to write Beam png's
end

% Extract subfolder names (Beam classes)
files = dir(dirpath);
dirFlags = [files.isdir];
beamFolders = files(dirFlags);
subFolderNames = {beamFolders(3:end).name};

NBeams = length(subFolderNames);

% Process each beam class
for y = 1:NBeams
    fpath = strcat(dirpath, subFolderNames(y), "\*.png");
    fsrc = dir(fpath);
    beam_dir_name = strcat("Beam_", num2str(y-1, '%03d'));
    mkdir(writepath, beam_dir_name); % Make Folder for beam class
    disp(strcat("Processing Beam Number ", num2str(y-1, '%03d')))
    
    % Process each image in the current beam class
    for i = 1:size(fsrc, 1)
        fname = strcat(dirpath, subFolderNames(y), "\", fsrc(i).name);
        Img = imread(fname);
        
        % Crop the central region
        Img = Img(end/2 - N/2 + 1:end/2 + N/2, end/2 - N/2 + 1:end/2 + N/2);
        
        % Apply wavelet decomposition
        [c, s] = wavedec2(Img, 2, wavelet);
        
        % Access approximation and detail coefficients
        approximation = appcoef2(c, s, wavelet, 1);
        horizontalDetail = detcoef2('h', c, s, 1);
        verticalDetail = detcoef2('v', c, s, 1);
        diagonalDetail = detcoef2('d', c, s, 1);
        
        % Concatenate wavelet coefficients to create multi-channel input
        wavelet_coeffs = cat(3, approximation, horizontalDetail, verticalDetail); %diagonalDetail);
        
        % Normalize coefficients to the range [0, 1]
        wavelet_coeffs = (wavelet_coeffs - min(wavelet_coeffs(:))) / (max(wavelet_coeffs(:)) - min(wavelet_coeffs(:)));
        
        % Write the compressed image to the specified folder
        imwrite(wavelet_coeffs, strcat(writepath, beam_dir_name, "\", fsrc(i).name))
    end
end

disp("Done Processing")
end