%% CNN Training and Testing, modified by Aidan for project data sets
% Will Jarrett
clearvars; close all; clc
% tic

%% Folder Information
% ===== WHAT YOU CHANGE ===== %
experimentFolder = "C:\Users\dough\OneDrive\Documents\MATLAB\EE269\EE269_Final_Project\Results"; % folder for experiment (organizes everything in matlab)
dataFolder = sprintf('CNN_WavComp_Del_5'); % this is the big folder all the data goes in
cnnFolder = "C:\Users\dough\OneDrive\Documents\MATLAB\EE269\EE269_Final_Project\DataProcessing\WavCompBeamImg_Del_5";
imNum = 1000; % number of images per beam
totalBeams = 16; % total number of beams being classified
trainImg = 400; % number of images per beam used for training
testImg = 600; % number of images used per beam for testing
res = 64; % size of images
xyTrans = 4; % number of pixels translated to combat overfitting
% =========================== %

% access images
cd(experimentFolder);
cd(dataFolder);

%% CNN Set Up
imds = imageDatastore(cnnFolder, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

p = trainImg / imNum;  % percentage of images used for training
[imdsTrain, imdsTest] = splitEachLabel(imds, p, 'randomized');

[imdsTrain, imdsVali] = splitEachLabel(imdsTrain, (9/10), 'randomized');
[imdsTest, imdsDiscard] = splitEachLabel(imdsTest, testImg, 'randomized');

augmenter = imageDataAugmenter('RandXTranslation', [-xyTrans xyTrans], 'RandYTranslation', [-xyTrans xyTrans]);

audsTrain = augmentedImageDatastore([res res 1], imdsTrain, 'DataAugmentation', augmenter);
audsVali  = augmentedImageDatastore([res res 1], imdsVali, 'DataAugmentation', augmenter);
audsTest  = augmentedImageDatastore([res res 1], imdsTest, 'DataAugmentation', augmenter);

% Preview augmented data
minibatch = preview(audsTrain);
sample = figure; imshow(imtile(minibatch.input));
    name = sprintf('sampleData.png');
    saveas(sample, name);

% minibatch_vali = preview(audsVali);
% figure; imshow(imtile(minibatch_vali.input));

% minibatch_test = preview(audsTest);
% figure; imshow(imtile(minibatch_test.input));
% pause();


%% CNN Architecture
% 15 layers
fprintf('Creating Network\n');
layers = [
    imageInputLayer([res res 1]); % input layer - images are 64x64 grayscale
    convolution2dLayer([3 3], 8, 'Stride', 1, 'Padding', 'same');

    batchNormalizationLayer();
    reluLayer();
    maxPooling2dLayer([2 2], 'Stride', 2);
    convolution2dLayer([3 3], 16, 'Stride', 1, 'Padding', 'same', 'NumChannels', 8);

    batchNormalizationLayer();
    reluLayer();
    maxPooling2dLayer([2 2], 'Stride', 2);
    convolution2dLayer([3 3], 32, 'Stride', 1, 'Padding', 'same', 'NumChannels', 16);

    batchNormalizationLayer();
    reluLayer();
    fullyConnectedLayer(totalBeams);
    softmaxLayer();
    classificationLayer()
    ];

% options = trainingOptions('sgdm', ... 
%     'Plots', 'training-progress', ...
%     'Momentum', 0.5, ...
%     'Shuffle', 'every-epoch', ...
%     'ValidationData', audsVali, ...
%     'ValidationPatience', 20, ...
%     'MiniBatchSize', 64, ...
%     'MaxEpochs', 200, ...
%     'InitialLearnRate', 0.01, ...
%     'ExecutionEnvironment', 'gpu');

options = trainingOptions('adam', ...
    'Plots', 'training-progress', ...
    'MaxEpochs', 20, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', audsVali, ...
    'ValidationPatience', 25, ...
    'ExecutionEnvironment', 'gpu');

%% Train Network
beamNet = trainNetwork(audsTrain, layers, options); % LG beams

%% Test Network
[pred, scores] = classify(beamNet, audsTest);

%% Results
totalTest = testImg*totalBeams;
acc = nnz(imdsTest.Labels == pred) / totalTest;
fprintf('Accuracy is %2.2f%%\n', acc*100);

CM = figure; set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    set(gca,'position',[0 0 1 1],'units','normalized');
    cm = confusionchart(imdsTest.Labels, pred); cm.NormalizedValues;
%     title('Confusion Matrix'); 
    name = sprintf('CM.png');
    saveas(CM, name);

misClassed = 1:1:255;
for i = 1:totalBeams
    misClassed(i) = testImg - cm.NormalizedValues(i,i);
end
inacc = figure; hold on
    plot(misClassed, '^r'); grid on
    axis([0 totalBeams 0 testImg]);
%     title('Number of Misclassifications by Symbol'); 
    xlabel('Alphabet Beam Number'); ylabel('Number of Misclassifications');
    name = sprintf('inacc.png');
    saveas(inacc, name);

%% Activation Maps
%{
audsTrain.reset;
im = read(audsTrain);
for i = 1:3
    numEx = (i-1)*23 + 1;
    thisImage =  im.input{numEx} ;
    YPred = classify(beamNet,thisImage);
    scoreMap = gradCAM(beamNet,thisImage,YPred);
    actMap = figure; imshow(thisImage); hold on
        title('Activation Map');
        imagesc(scoreMap,'AlphaData',0.5)
        colormap jet; hold off; colorbar
%         name = sprintf('actMap.png');
%         saveas(actMap, name);
end
%}









