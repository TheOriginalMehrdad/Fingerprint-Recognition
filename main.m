% ==============================
% main.m
% ==============================

clear; clc; close all;

if ~isfile('finger_db.mat')
    error('Database file finger_db.mat not found. Please run buildDatabase.m first.');
end

load('finger_db.mat', 'fingerDB');

% Path to query fingerprint image
queryImagePath = fullfile('query', 'query.bmp'); % or .png, .jpg, ...

if ~isfile(queryImagePath)
    error('Query image not found at: %s', queryImagePath);
end

queryImg = imread(queryImagePath);

[~, enhancedImg, ~, skeletonImg] = preprocessFingerprint(queryImg);
queryEnhSmall = imresize(enhancedImg, [128 128]);

queryMinutiae = extractMinutiae(skeletonImg);

if numel(queryMinutiae) < 5
    fprintf('Query fingerprint has too few minutiae. Result: NO MATCH (low quality).\n');
    figure; imshow(skeletonImg); title('Query Skeleton (Low Minutiae Count)');
    return;
end

% Thresholds (needs tuning with real scores)
distanceThreshold      = 15;   % pixels
orientationThreshold   = 20;   % degrees
globalThreshold        = 0.45; % SSIM threshold
localRatioThreshold    = 0.60; % local score threshold
localCountThreshold    = 20;   % minimal matches
scoreGapThreshold      = 0.10; % best - second-best must be at least this

[bestIndex, bestScore, bestMatchCount, bestGlobalScore, secondBestScore] = ...
    matchFingerprints(queryMinutiae, queryEnhSmall, fingerDB, distanceThreshold, orientationThreshold);

fprintf('Best index: %d\n', bestIndex);
fprintf('Local score (minutiae): %.3f\n', bestScore);
fprintf('Local match count: %d\n', bestMatchCount);
fprintf('Global score (SSIM): %.3f\n', bestGlobalScore);
fprintf('Second best local score: %.3f\n', secondBestScore);

% Decision logic
isGlobalOk    = bestGlobalScore >= globalThreshold;
isLocalRatioOk = bestScore >= localRatioThreshold;
isLocalCountOk = bestMatchCount >= localCountThreshold;
isSeparated    = (bestScore - secondBestScore) >= scoreGapThreshold;

if isGlobalOk && isLocalRatioOk && isLocalCountOk && isSeparated
    fprintf('Result: MATCH (fingerprint belongs to subject: %s)\n', fingerDB(bestIndex).id);
else
    fprintf('Result: NO MATCH FOUND (global/local similarity or separation below thresholds)\n');
end

% Visualization
figure;
imshow(skeletonImg); title('Query Fingerprint Skeleton with Minutiae'); hold on;

if ~isempty(queryMinutiae)
    endingsIdx = strcmp({queryMinutiae.type}, 'ending');
    bifIdx     = strcmp({queryMinutiae.type}, 'bifurcation');
    plot([queryMinutiae(endingsIdx).x], [queryMinutiae(endingsIdx).y], 'ro', 'MarkerSize', 4, 'LineWidth', 1.5);
    plot([queryMinutiae(bifIdx).x],     [queryMinutiae(bifIdx).y],     'gs', 'MarkerSize', 4, 'LineWidth', 1.5);
    legend('Endings', 'Bifurcations');
end
hold off;





% Developed By Mahdi Siri F.