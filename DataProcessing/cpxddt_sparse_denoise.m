function [imden] = cpxddt_sparse_denoise(img, iter_length)
%Apply Iterative denoising Algorithm under assumption that img is sampled
%sparsely in K-domain - Compressed Sensing
%Assume Square image
px = size(img,1);
ft_weight = 1/px;
im_sp = cast(img,"double");
im_sp = im_sp./(abs(max(im_sp,[],'all'))); %Normalize
F_im_sp = fftshift(fft2(im_sp).*ft_weight);
im_final = zeros(px,px);
for i = 1:iter_length
    wt = dddtree2('cplxdt', im_sp, 1, 'FSfarras', 'qshift10'); %Take Complex Double Density WT
    thresh = 0.010*max(abs(wt.cfs{1}(:)),[],'all'); %Set threshold to 1 percent of max coefficient
    wt.cfs{1} = wthresh(wt.cfs{1},"s",thresh); %Soft thresholding
    im_sp_th = idddtree2(wt); %Reconstructed image after thresholding
    F_sp_th = fftshift(fft2(im_sp_th).*ft_weight);
    
    F_err = F_sp_th + F_im_sp; %Difference image in K-space between denoised and original
    delta_im = ifft2(ifftshift(F_err))./ft_weight; %correction image
    
    new_im = im_sp + delta_im; %Apply correction and renormalize
    im_sp = new_im./abs(max(new_im, [],'all'));
    im_final = im_final + delta_im; %Final image will be sum of correction images which highlight maximal wavelet components
    im_final = im_final./abs(max(im_final,[],'all'));
    im_final(im_final < 10^(-10)) = 0; %Remove super small values
end

imden = im_final;

end