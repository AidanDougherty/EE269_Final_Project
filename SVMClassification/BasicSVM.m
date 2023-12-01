%%
%Script to do Basic CNN Classification on Resized 64x64 Beam images
%Get Image Dataset
dataset_path = "C:\Users\dough\OneDrive\Documents\MATLAB\EE269\EE269_Final_Project\DataProcessing\ResizedBeamImg_Del_1";
imds = imageDatastore(dataset_path,"IncludeSubfolders",true,"FileExtensions",".png","LabelSource","foldernames");
%%
%Set up Training/Validation Data
%XTrain, YTrain, XVal, YVal
pixelWidth = 64;
classSize = 1000;
numClasses = 16;
N_k_train = 0.2*classSize; %Train on First 20 percent of each class data
N_train = numClasses*N_k_train;
N_val = numClasses*classSize - N_train;
[imdsTrain,imdsValidation] = splitEachLabel(imds,N_k_train); %Split Train/Test
YTrain = imdsTrain.Labels;
YVal = imdsValidation.Labels;
XTrain_cell = readall(imdsTrain);
XVal_cell = readall(imdsValidation);

XTrain = zeros(N_train,pixelWidth^2);
XVal = zeros(N_val,pixelWidth^2);
for i = 1:N_train
    XTrain(i,:) = reshape(XTrain_cell{i},1,pixelWidth^2);
end
for i = 1:N_val
    XVal(i,:) = reshape(XVal_cell{i},1,pixelWidth^2);
end

%%
t = templateSVM('Standardize',true);
Mdl = fitcecoc(XTrain, YTrain,'Learners',t);
train_acc = 1 - resubLoss(Mdl)
Y_hat = predict(Mdl,XVal);
accuracy = sum(Y_hat == YVal)/size(YVal,1) %62 Percent accuracy for Del 10, 80 percent accuracy for Del 1


