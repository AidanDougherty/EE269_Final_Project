function performWaveletDecomposition2(N, wavelet, dirpath, writepath)
arguments
    N  = 120; % Crop Window size
    wavelet  = "sym4"; % Compression method
    dirpath = "C:\Users\dough\OneDrive\Documents\MATLAB\EE269\Project_Data\Del_10_Sorted\"; % Folder of Beam Folders to Read
    writepath = "C:\Users\dough\OneDrive\Documents\MATLAB\EE269\EE269_Final_Project\DataProcessing\WCoef2_Del_10\"; % Folder to write Beam png's
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
        wavelet_coeffs = cat(3, approximation, horizontalDetail, verticalDetail);%diagonalDetail);
        
        % Normalize coefficients to the range [0, 1] globally
        wavelet_coeffs = (wavelet_coeffs - min(wavelet_coeffs(:))) / (max(wavelet_coeffs(:)) - min(wavelet_coeffs(:)));
        
        %Threshold and amplify horizontal/vertical detail to 50% of
        %approximation coeff level
        max_coeffs = max(wavelet_coeffs,[],[1 2]);
        means = mean(wavelet_coeffs,[1 2]);
        stds = std(wavelet_coeffs,0,[1 2]);
        hthresh = max(0.1, means(1,1,2)+2*stds(1,1,2)); %thresh = 2 std dev above mean or 0.05 if no details present
        vthresh = max(0.1, means(1,1,3)+2*stds(1,1,3));
        wavelet_coeffs(:,:,2) = 0.5*(max_coeffs(1,1,1)/max_coeffs(1,1,2))*wthresh(wavelet_coeffs(:,:,2),"h",hthresh);
        wavelet_coeffs(:,:,3) = 0.5*(max_coeffs(1,1,1)/max_coeffs(1,1,3))*wthresh(wavelet_coeffs(:,:,3),"h",vthresh);
        
        %scale to 0 to 1 channel wise
        %wavelet_coeffs = (wavelet_coeffs - min(wavelet_coeffs,[],[1 2])) ./ (max(wavelet_coeffs,[],[1 2]) - min(wavelet_coeffs,[],[1 2])); 
        
        
        
        % Write the compressed image to the specified folder
        imwrite(wavelet_coeffs, strcat(writepath, beam_dir_name, "\", fsrc(i).name))
    end
end

disp("Done Processing")
end