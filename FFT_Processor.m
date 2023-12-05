%% FFT Processor
% Will Jarrett
% takes 2D FFT

clearvars; close all; clc

%% Parameters
% ===== WHAT YOU CHANGE ===== %
experimentFolder = sprintf('EE_269_Data'); % folder for experiment (organizes everything in matlab)
dataFolder = sprintf('Del_10_Processed'); % this is the big folder everything goes in
processedFolder = sprintf('Del_10_LPFr16');
beamTotal = 16; % number of beams in set
numImgs = 1000;
cnn_img_size = 64; % pixels - size of square image for CNN
r = 16; % low pass filter radius
% =========================== %

%% Make Low Pass Filter
[x, y] = meshgrid(1:cnn_img_size, 1:cnn_img_size);
lpf = sqrt((x - cnn_img_size/2).^2 + (y - cnn_img_size/2).^2) <= r;
figure; imshow(lpf);

%%
cd(experimentFolder);
cd(dataFolder);

mkdir(processedFolder);
cd(processedFolder);

for i = 1:beamTotal
    newFolder = sprintf('Beam_%03d', i-1);
    mkdir(newFolder);
end

for i = 1:beamTotal
    newFolder = sprintf('FFT2_Beam_%03d', i-1);
    mkdir(newFolder);
end

cd ..

for i = 1:beamTotal
    beamFolder = sprintf('Beam_%03d', i-1);
    beamFolder_fft = sprintf('FFT2_Beam_%03d', i-1);

    for j = 1:numImgs
    dataFileName = sprintf('img%04d.png', j);
    dataFileName = fullfile(beamFolder, dataFileName);

    beam = imread(dataFileName);
    beam = double(beam)/256;
%     figure; imshow(beam_px_val); 
    
    % take 2D fft
    beam_F = fft2(beam);
    beam_sF = fftshift(beam_F);
%     figure; imagesc(log(abs(beam_sF)));
%     figure; imagesc(angle(beam_sF));
%     figure; imshow(beam_sF);

    % filter
    beam_sF = beam_sF.*lpf;
%     figure; imshow(real(beam_sF));
%     figure; imagesc(log(abs(beam_sF)));
%     figure; imagesc(angle(beam_sF));
    
    % take 2D ifft
    beam_F = ifftshift(beam_sF);
    beam_filt = real(ifft2(beam_F));
%     figure; imshow(filt_beam);

    imgFileName = sprintf('img%04d.png', j);
    fullFileName = fullfile(processedFolder, beamFolder, imgFileName);
    imwrite(beam_filt, fullFileName);
    fullFileName_fft = fullfile(processedFolder, beamFolder_fft, imgFileName);
    imwrite(real(beam_sF), fullFileName_fft);
    fprintf('%s_img%04d\n', beamFolder, j)
    
    end
end

cd ../..


















