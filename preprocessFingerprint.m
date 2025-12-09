function [grayImg, enhancedImg, binaryImg, skeletonImg] = preprocessFingerprint(inputImg)
% preprocessFingerprint
%   Performs preprocessing steps on fingerprint image:
%   1. Convert to grayscale
%   2. Denoise with median filter
%   3. Enhance contrast using adaptive histogram equalization
%   4. Binarize
%   5. Morphological cleaning
%   6. Skeletonize

    % Convert to grayscale if needed
    if size(inputImg, 3) == 3
        grayImg = rgb2gray(inputImg);
    else
        grayImg = inputImg;
    end
    
    % Convert to double for processing
    grayImg = im2uint8(grayImg);
    
    % Median filter to remove noise
    filteredImg = medfilt2(grayImg, [3 3]);
    
    % Contrast enhancement
    enhancedImg = adapthisteq(filteredImg);
    
    % Binarization (Otsu thresholding)
    level = graythresh(enhancedImg);
    binaryImg = imbinarize(enhancedImg, level);
    
    % Invert if necessary (ridges should be 1)
    % We assume that ridges are dark; so if mean of foreground is higher, invert.
    if mean(enhancedImg(binaryImg)) > mean(enhancedImg(~binaryImg))
        binaryImg = ~binaryImg;
    end
    
    % Remove small objects and fill holes
    binaryImg = bwareaopen(binaryImg, 30);
    binaryImg = imfill(binaryImg, 'holes');
    
    % Skeletonization
    skeletonImg = skeletonizeFingerprint(binaryImg);
end
