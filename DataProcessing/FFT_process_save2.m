function FFT_process_save2(dirpath, writepath) %For Applying LPF in K-space and IFFT Back
arguments
    dirpath = "C:\Users\dough\OneDrive\Documents\MATLAB\EE269\EE269_Final_Project\DataProcessing\ResizedBeamImg_Del_10\"; % Folder of Beam Folders to Read
    writepath = "C:\Users\dough\OneDrive\Documents\MATLAB\EE269\EE269_Final_Project\DataProcessing\LPFBeamFFT_Del_10\"; % Folder to write Beam png's
end
cnn_img_size = 64; % pixels - size of square image for CNN
r = 16; % low pass filter radius
%Make Low Pass Filter
[x, y] = meshgrid(1:cnn_img_size, 1:cnn_img_size);
lpf = sqrt((x - cnn_img_size/2).^2 + (y - cnn_img_size/2).^2) <= r;

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
        %Will's Code:
        beam = imread(fname);
        beam = double(beam)/256;
        beam_F = fft2(beam);
        beam_sF = fftshift(beam_F);
        beam_sF = beam_sF.*lpf;
        beam_F = ifftshift(beam_sF);
        beam_filt = real(ifft2(beam_F));
       
        % Write the compressed image to the specified folder
        imwrite(abs(beam_sF), strcat(writepath, beam_dir_name, "\", fsrc(i).name))
        %imwrite(abs(fftshift(beam_F)), strcat(writepath, beam_dir_name, "\", fsrc(i).name))
    end
end

disp("Done Processing")
end