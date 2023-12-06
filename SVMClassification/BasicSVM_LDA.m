%%
%Script to do Basic SVM/LDA/QDA Classification on Resized 64x64 Beam images

function [accuracy, Mdl] = BasicSVM_LDA(dataset_path, pixelWidth, train_prop, pca_opt, svm_lda_opt)
%Get Image Dataset
arguments
dataset_path = "C:\Users\dough\OneDrive\Documents\MATLAB\EE269\EE269_Final_Project\DataProcessing\LPFBeamFFT_Del_10";
pixelWidth = 64; %width of image in pixels
train_prop = 0.2; %Proportion of data used as training
pca_opt = 1; %use PCA and/or LDA (0 = none, 1 = PCA)
svm_lda_opt = 2; %1 = SVM, 2 = LDA, 3 = Quadratic Discrim
end
imds = imageDatastore(dataset_path,"IncludeSubfolders",true,"FileExtensions",".png","LabelSource","foldernames");
%Set up Training/Validation Data
%XTrain, YTrain, XVal, YVal

classSize = 1000;
numClasses = 16;
N_k_train = train_prop*classSize; %Train on First 20 percent of each class data
N_train = numClasses*N_k_train;
N_val = numClasses*classSize - N_train;
[imdsTrain,imdsValidation] = splitEachLabel(imds,N_k_train); %Split Train/Test
YTrain = imdsTrain.Labels;
YVal = imdsValidation.Labels;
XTrain_cell = readall(imdsTrain);
XVal_cell = readall(imdsValidation);

%Convert imds to arrays
XTrain = zeros(N_train,pixelWidth^2);
XVal = zeros(N_val,pixelWidth^2);
for i = 1:N_train
    XTrain(i,:) = reshape(XTrain_cell{i},1,pixelWidth^2);
end
for i = 1:N_val
    XVal(i,:) = reshape(XVal_cell{i},1,pixelWidth^2);
end
train_mean = mean(XTrain);
train_sdev = std(XTrain);
XTrain = (XTrain - train_mean)./train_sdev; %Normalize Train and Test data over train distribution
XVal = (XVal - train_mean)./train_sdev;
XTrain(isnan(XTrain))=0; %set NaN to 0 (case where sdev = 0)
XVal(isnan(XVal))=0;

if(pca_opt==1)
    %do PCA, compress data to 10% of size
    n_components = floor(0.1*pixelWidth^2);
    p = pca(XTrain, 'NumComponents',n_components); %pixelWidth^2 by n_components transformation matrix
    XTrain = XTrain*p;
    XVal = XVal*p;

end

if(svm_lda_opt == 1) %SVM   62 Percent accuracy for Del 10, 80 percent accuracy for Del 1, drop 2-3 percent with PCA
    t = templateSVM('Standardize',true);
    Mdl = fitcecoc(XTrain, YTrain,'Learners',t,'Verbose',1);
    train_acc = 1 - resubLoss(Mdl);
    type_str = "SVM";
elseif(svm_lda_opt == 2) %LDA   using PCA: 65 Percent acc at Del 10, 80 percent accuracy at Del 1
    Mdl = fitcdiscr(XTrain, YTrain,'DiscrimType','linear');
    type_str = "LDA";
elseif(svm_lda_opt == 3) %QDA   using PCA: 50 Percent at Del 1, with only 20 percent training, hard to estimate class covar
    Mdl = fitcdiscr(XTrain, YTrain,'DiscrimType','diagQuadratic'); %DO NOT USE WITHOUT PCA
    type_str = "QDA";
end

display("Performing Validation...")
Y_hat = predict(Mdl,XVal);
accuracy = sum(Y_hat == YVal)/size(YVal,1); 
display(strcat("Validation accuracy for ",type_str," Model is: ",num2str(accuracy,4)));
end

