%%
%Script to do Basic CNN Classification on Resized 64x64 Beam images
%Get Image Dataset
dataset_path = "C:\Users\dough\OneDrive\Documents\MATLAB\EE269\EE269_Final_Project\DataProcessing\ResizedBeamImg_Del_1";
imds = imageDatastore(dataset_path,"IncludeSubfolders",true,"FileExtensions",".png","LabelSource","foldernames");

%%
pixelWidth = 64;
classSize = 1000;
numClasses = 16;
numTrainFiles = 0.8*classSize;
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize'); %Split Train/Test
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






