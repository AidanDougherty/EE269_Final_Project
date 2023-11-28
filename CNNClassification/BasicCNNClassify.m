%%
%Script to do Basic CNN Classification on Resized 64x64 Beam images
%Get Image Dataset
dataset_path = "C:\Users\dough\OneDrive\Documents\MATLAB\EE269\EE269_Final_Project\DataProcessing\ResizedBeamImg_Del_10";
imds = imageDatastore(dataset_path,"IncludeSubfolders",true,"FileExtensions",".png","LabelSource","foldernames");

%%
pixelWidth = 64;
classSize = 1000;
numClasses = 16;
numTrainFiles = 0.2*classSize; %Train on First 10 percent of each class data
testDataSize = 0.95*numClasses*classSize;
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles); %Split Train/Test
%%
%Use Matlab's example for simple CNN
layers = [
    imageInputLayer([pixelWidth pixelWidth 1])
    
    convolution2dLayer(3,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',4, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'Plots','training-progress');

net = trainNetwork(imdsTrain,layers,options);

%%
YPred = classify(net,imdsValidation);
YValidation = imdsValidation.Labels;

accuracy = sum(YPred == YValidation)/numel(YValidation)
BER = 1-accuracy;



