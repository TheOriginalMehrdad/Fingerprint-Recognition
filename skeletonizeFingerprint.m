function skeletonImg = skeletonizeFingerprint(binaryImg)
% skeletonizeFingerprint
%   Produces a one-pixel wide skeleton of the fingerprint ridges.

    % Ensure logical image
    binaryImg = logical(binaryImg);
    
    % Thinning
    skeletonImg = bwmorph(binaryImg, 'thin', Inf);
    
    % Remove small spurs to clean skeleton
    skeletonImg = bwmorph(skeletonImg, 'spur', 10);
end
