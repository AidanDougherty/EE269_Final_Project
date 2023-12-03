%Test Wavelet Denoising Methods on Random subset of data
close all
dataset_path = "C:\Users\dough\OneDrive\Documents\MATLAB\EE269\EE269_Final_Project\DataProcessing\WavCompBeamImg_Del_10";
imds = imageDatastore(dataset_path,"IncludeSubfolders",true,"FileExtensions",".png","LabelSource","foldernames");
N = 16000;
px = 64;
p = randperm(N);
n = 9;
Noisy_imgs = cell(1,n);
for i = 1:n
    img = cast(readimage(imds,p(i)),"double");
    Noisy_imgs{i} = cast(wcodemat(img,255,'mat',1),"uint8");
end
figure();
montage(Noisy_imgs)
title("Noisy Images")

%Denoise
Clean_imgs = cell(1,n);
for i = 1:n
    imden = wdenoise2(Noisy_imgs{i},"Wavelet","sym2");
    Clean_imgs{i} = cast(wcodemat(imden,255,'mat',1),"uint8");
end
figure();
montage(Clean_imgs)
title("Clean Images")

%%
Clean_imgs_cpx = cell(1,n);
for i = 1:n
    wt = dddtree2('cplxdt', Noisy_imgs{i}, 1, 'FSfarras', 'qshift10');
    imp = sort(abs(wt.cfs{1}(:)),'descend'); %vectorize + sort
    idx = floor(length(imp)*15/100); %Keep 15 percent of coeffs
    thresh= imp(idx); %Threshold away lower 80 percent
    wt.cfs{1} = wthresh(wt.cfs{1},"s",thresh);
    imgrec = cast(wcodemat(idddtree2(wt),255,'mat',1),"uint8");
    Clean_imgs_cpx{i} = imgrec;
end
figure();
montage(Clean_imgs_cpx)
title("Clean Images - Complex Denoising")

%%
Clean_imgs_cpx_cs = cell(1,n);
for i = 1:n
    imden = cpxddt_sparse_denoise(Noisy_imgs{i},100);
    Clean_imgs_cpx_cs{i} = cast(wcodemat(imden,255,'mat',1),"uint8");
end

figure();
montage(Clean_imgs_cpx_cs)
title("Clean Images - Complex Compressed Sensing Denoising")



